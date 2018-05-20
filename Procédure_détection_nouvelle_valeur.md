# Procédure pour la détection d'une nouvelle valeur dans un champ

## Prérequis

 - Un KV Store pour stocker les valeurs connues,
 - Un KV Store pour stocker la date de la dernière recherche (optionnel mais fortement recommandé pour optimiser les performances),
 
## Objectif

Avoir une recherche qui met à jour le KV Store des valeurs connues.

## Algorithme
```
Pour tous mes évènements :
    Récupération de l'ensemble des valeurs pour la création ou la mise à jour d'une valeur dans le KV Store
    Pour les nouveaux évènements :
        Ajout d'un enregistrement dans le KV Store
    Fin pour
    Pour les évènements à mettre à jour :
        Mise à jour de l'enregistrement dans le KV Store
    Fin pour
    Mise à jour de la date de la dernière recherche dans le KV Store correspondant
Fin pour
```
## Exemple

### Objectifs

 - Détecter les nouvelles adresses IP et mettre à jour celles déjà connues vers lesquelles les serveurs surveillés par l'application Splunk Stream envoient des données en TCP.
 - Pour chaque adresse IP référencée, la date de première et de dernière connexion associées doivent être enregistrées.

### Prérequis

Un KV Store pour stocker les valeurs connues et la collection associée.

 - KV Store dans le fichier de configuration transforms.conf.
```
[exemple_kvstore]
collection = exemple_kvstore
external_type = kvstore
fields_list = _key, ip_store, first_store, last_store, alert_store
```

 - Collection dans le fichier de configuration collections.conf.
```
[exemple_kvstore]
field.alert_store = boolean
field.ip_store = string
field.first_store = time
field.last_store = time
replicate = false
```

Un KV Store pour stocker la date de la dernière recherche et la collection associé.

 - KV Store dans le fichier de configuration transforms.conf.
```
[exemple_time_kvstore]
collection = exemple_time_kvstore
external_type = kvstore
fields_list = last_research_store
```

 - Collection dans le fichier de configuration collections.conf.
```
[exemple_time_kvstore]
field.last_research_store = time
replicate = false
```

### Requêtes SPL

```
source="stream:tcp_RGPD" index=* sourcetype="stream:tcp" 
    [| inputlookup exemple_time_kvstore 
    | append 
        [ makeresults 
        | eval last_research_store=0] 
    | stats max(last_research_store) as last_research_store
    | eval search="earliest=".last_research_store 
    | table search] 
| lookup exemple_kvstore ip_store as dest_ip OUTPUTNEW _key as _key last_store as last_store first_store as first_store 
| stats min(_time) as first_new max(_time) as last_new values(_key) as _key values(last_store) as last_store values(first_store) as first_store by dest_ip 
| eval new_or_update=if(isnull(last_store) OR last_store!=last_new, 1, 0) 
| search new_or_update>0 
| eval ip_store=dest_ip, last_store = last_new, first_store=if(isnull(first_store), first_new, first_store) 
| outputlookup exemple_kvstore append=true 
| append 
    [| inputlookup exemple_time_kvstore 
    | append 
        [ makeresults 
        | eval last_research_store=now()]]
| stats max(last_research_store) as last_research_store
| outputlookup exemple_time_kvstore
```

### Explications

Recherche de base :
```
source="stream:tcp_RGPD" index=* sourcetype="stream:tcp" 
```

Ciblage temporel de la recherche de base (Cette étape **doit** être réalisée par une macro) :
```
    [| inputlookup exemple_time_kvstore 
    | append 
        [ makeresults 
        | eval last_research_store=0] 
    | stats max(last_research_store) as last_research_store
    | eval search="earliest=".last_research_store 
    | table search] 
```

Jointure avec le KV Store des valeurs connues afin de pouvoir déterminer si la valeur a déjà été vue (Cette étape **doit** être réalisée par un lookup automatique) :
```
| lookup exemple_kvstore ip_store as dest_ip OUTPUTNEW _key as _key last_store as last_store first_store as first_store 
```

Statistique de valeurs souhaitées :
```
| stats min(_time) as first_new max(_time) as last_new values(_key) as _key values(last_store) as last_store values(first_store) as first_store by dest_ip 
```

Evaluation des nouvelles valeurs et de celles à mettre à jour :
```
| eval new_or_update=if(isnull(last_store) OR last_store!=last_new, 1, 0) 
```

Ciblage de la recherche sur les nouvelles valeurs ou celles à mettre à jour :
```
| search new_or_update>0 
```

Alignement des champs de la recherche sur ceux du KV Store des valeurs connues :
```
| eval ip_store=dest_ip, last_store = last_new, first_store=if(isnull(first_store), first_new, first_store) 
```

Ajout et mise à jour des valeurs dans le KV Store des valeurs connues :
```
| outputlookup exemple_kvstore append=true 
```

Evaluation de la valeur pour le KV Store de la date de la dernière recherche (Cette étape **doit** être réalisée par une macro) :
```
| append 
    [| inputlookup exemple_time_kvstore 
    | append 
        [ makeresults 
        | eval last_research_store=now()]]
```

Récupération de la valeur maximale du champ présent dans le KV Store de la date de la dernière recherche :
```
| stats max(last_research_store) as last_research_store
```
Ecriture du KV Store de la date de la dernière recherche :
```
| outputlookup exemple_time_kvstore
```