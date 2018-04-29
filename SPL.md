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
index=_internal source="*license_usage.log" type=usage idx="*" | eval MB = round(b/1048576,2) | eval st_idx = st.": ".idx | fields ** | timechart span=15minutes sum(MB) by st_idx | addtotals
```

