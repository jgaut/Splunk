# SPL

#### Découpage d'event selon un pas de temps avec affectation de valeur selon le ratio
Pas de temps = $grabularite$

```javascript
| from datamodel:"VIAVI_mes_datamodel.Ordre_de_fabrication_search" 
| join key 
    [ search `viavi_mes_indexes()` sourcetype=viavi_mes_with_user 
        ] 
| search $operateurs1$ $produits1$ $stations1$ $commandes1$ 
| eval cpt=$granularite1$ 
| eval nb=mvrange(0, round(((action_fin-action_debut)/cpt)+1,0), 1) 
| mvexpand nb 
| eval delais=action_fin-action_debut
| eval deb_seg=strftime(action_debut, "%Y-%m-%d") 
| eval deb_seg=strptime(deb_seg, "%Y-%m-%d")
| eval delta=(round((action_debut-deb_seg)/cpt, 0))*cpt
| eval deb_seg=deb_seg+delta
| eval deb_seg=deb_seg+nb*cpt
| eval fin_seg=deb_seg+cpt
| eval debut=if(deb_seg &lt; action_debut, action_debut, if(nb&gt;0,deb_seg, action_debut))
| eval debut=if(debut&gt;action_fin, action_fin, debut)
| eval fin=if(fin_seg &gt; action_fin, action_fin, fin_seg-1)
| eval temps_fabrication_heure= temps_fabrication_heure * (fin-debut)/(action_fin-action_debut), temps_interruption_heure= temps_interruption_heure * (fin-debut)/(action_fin-action_debut)
| eval temps_fabrication= temps_fabrication * (fin-debut)/(action_fin-action_debut), temps_interruption= temps_interruption * (fin-debut)/(action_fin-action_debut), temps_encyclage= temps_encyclage * (fin-debut)/(action_fin-action_debut)
| rename debut as _time
| rename $axe1value$ as "$axe1label$" 
| eval sel=random()%1, preprod=temps_fabrication*100/(temps_fabrication+(random()%1000*if(sel==0, 1, -1))) 
| chart max(preprod) as Productivité avg(preprod) as Moyenne stdevp(preprod) as Dispersion by "$axe1label$" $span1$ 
| eval 
    "$axe1label$"=if(match("$axe1label$", "Temps"), strftime('$axe1label$', "%d/%m/%Y"), '$axe1label$'),
    Moyenne=round(Moyenne, 2),
    Dispersion=round(Dispersion, 2),
    Productivité=round(Productivité, 2)
```

#### Recherche et visualisation avec multisearch

```javascript
| multisearch 
    [ search index=nest sourcetype=nest_devices 
    | rename "data.devices.thermostats.wyB2GytM6dGf2KXOA3kyWj1YlBYpEigH.hvac_state" as status 
    | eval resultat=if(match(status, "heating"),1,0) ] 
    [ search (index=nest OR index=openweather) 
    | eval 'main.temp'='main.temp'-273.15] 
    [ search index=nest sourcetype=nest_devices 
    | rename "data.devices.thermostats.wyB2GytM6dGf2KXOA3kyWj1YlBYpEigH.target_temperature_c" as target 
    | eval resultat4=target ] 
| timechart span=30m 
    max(target) as cible 
    max(resultat) as Statut 
    max("data.devices.thermostats.wyB2GytM6dGf2KXOA3kyWj1YlBYpEigH.ambient_temperature_c") as "Température maison" 
    max('main.temp') as "Température Paris"
```

### Inspecter un index
```javascript
| dbinspect index=syslog
```

### Explorer les API REST
```javascript
| rest splunk_server=local /services/...
```

### Regarder le taux d'occupation des partitions des DD sur les serveurs Splunk
```javascript
`dmc_set_index_introspection` sourcetype=splunk_disk_objects component=Partitions
| eval free = if(isnotnull('data.available'), 'data.available', 'data.free') 
| eval usage = round(('data.capacity' - free) / 1024, 2) 
| eval capacity = round('data.capacity' / 1024, 2)
| eval pct_usage = round(usage / capacity * 100, 2)
| chart avg(pct_usage) as usage  by host, "data.mount_point"
```

#### Utilisation Licence par index
```javascript
index=_internal source="*license_usage.log" type=usage idx="*" | eval MB = round(b/1048576,2) | eval st_idx = st.": ".idx | fields ** | timechart span=1d sum(MB) by st_idx | addtotals
```

#### Utilisation Licence par sourcetype
```javascript
earliest=@day-7days latest=@day index=* ( sourcetype!=btool* sourcetype!=splunk* sourcetype!=*too_small* sourcetype!=stash )
| fields + sourcetype, _raw, host
| eval size = len( _raw )
| rex field=sourcetype "^(?<sourcetype>.+)-\d+"
| stats count AS sample_set, perc95(size) AS perc95_size_bytes, dc(host) AS NumHosts BY sourcetype
| eval perc95_size_bytes = round( perc95_size_bytes , 2 ) | eval daily_size_per_host_MB=round(((perc95_size_bytes*sample_set)/(NumHosts*7*1024*1024)), 2) | eval daily_size_MB = round((perc95_size_bytes*sample_set)/(7*1024*1024),2) | sort -daily_size_MB | addcoltotals daily_size_MB
```

#### Transfert de données d'un index event à un autre index event

Commandes _collect_ pour les index de type _event_ et _mcollect_ pour les index de type _metric_.

```javascript
index="test" sourcetype="sentinel_data"
| eval id=source." ".host." "._raw
| search
[search index="test" sourcetype="sentinel_data"
| rex field=source "(?P<station>.*) (?P<numero_affaire>[\d\w]*) (?P<mytime>(?P<annee>\d{4})\.(?P<mois>\d{2})\.(?P<jour>\d{2})).*- (?P<collect_de_voies>.*)\.txt"
| rex field=_raw "^(?P<seconde>\d+)[\s\t]*(?P<tension>[\d\.]*)"
| search seconde >= 0
| head 10
| eval id=source." ".host." "._raw, _time=strptime(mytime, "%Y.%m.%d")+seconde, mycol=mvappend(mycol, "seconde=".seconde), mycol=mvappend(mycol, "tension=".tension)
| mvexpand mycol
| rex field=mycol "^(?P<metric_name>.*)=(?P<_value>.*)"
| eval _raw="time="._time." "._raw
| collect testmode=false index=test_collect addtime=false sourcetype="sentinel_data_metric"
| return 20 id ]
| delete
```

#### Interrogation d'une base de données via SPL
```javascript
| dbxquery query="SELECT * FROM DBO.FACTURES
inner join DBO.CLIENTS
on FCC_CLI_ID =  DBO.CLIENTS.CLI_ID
inner join  DBO.COMMANDES 
ON DBO.CLIENTS.CLI_ID = DBO.COMMANDES.CMD_CLI_ID
where FCC_CLI_ID=48 " 

connection="ADISTA-NOVA"

| eval nb=if(CMD_ABOTYPE = 0 , if(NOT match(CMD_TITRE, ".*BIMESTRIEL.*"), 1,2), if(CMD_ABOTYPE = 1, 3, if(CMD_ABOTYPE = 2, 6,12))), nb=if(CMD_ABOTYPE=1, 1, nb),
montant = FCC_MNTHT / nb, _time=strptime(FCC_DATE_CREATION, "%Y-%m-%d")
| timechart sum(montant)  by CMD_ABOTYPE
```

#### Multisearch avec _tstats_ et/ou _mstats_
```javascript
|  mstats prestats=true avg(cpu.percent.idle.value)  WHERE index="collectd" AND source="http:collectd" span=10m
|  mstats prestats=true append=true avg(cpu.percent.nice.value) WHERE index="collectd" AND source="http:collectd" span=10m
|  timechart span=10m avg(cpu.percent.idle.value) avg(cpu.percent.nice.value)
```

#### Voir les différences pour les alarmes avec _Set diff_
```javascript
| set diff 
    [| makeresults 1 
    | eval tmp="a" 
    | makemv delim="," tmp 
    | mvexpand tmp 
    | table tmp 
    | append 
        [| makeresults 1 
        | eval tmp="a,b,c,d" 
        | makemv delim="," tmp 
        | mvexpand tmp 
        | table tmp] ] 
    [| makeresults 1 
    | eval tmp="a,b,c,d" 
    | makemv delim="," tmp 
    | mvexpand tmp 
    | table tmp] 
| join type=left tmp 
    [| makeresults 1 
    | eval tmp="a,b,c,d"
    | makemv delim="," tmp 
    | mvexpand tmp 
    | table tmp
    | eval tmp2=1]
| table tmp*
| eval tmp2=if(isnull(tmp2),0,tmp2)
```
Avec un _search tmp2=1_ pour détecter lorsqu'il y a une nouvelle alerte.

Avec la recherche des éléments récents
```javascript
| makeresults 1 
    | eval tmp="a" 
    | makemv delim="," tmp 
    | mvexpand tmp 
    | table tmp
```

Et la recherche des éléments de la précédente recherche
```javascript
| makeresults 1 
    | eval tmp="a,b,c,d"
    | makemv delim="," tmp 
    | mvexpand tmp 
    | table tmp
```

#### Sauvegarde et modification d'un KV Store
```javascript
 | inputlookup csvcoll_lookup | search _key=544948df3ec32d7a4c1d9755 | eval CustName="Marge Simpson" | eval CustCity="Springfield" | outputlookup csvcoll_lookup append=True
```
