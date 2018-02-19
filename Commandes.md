# Commandes

#### Déploiement d'une nouvelle configuration sur un cluster d'indexer
* ``splunk validate cluster-bundle``
* ``splunk show cluster-bundle-status`` 
* ``splunk apply cluster-bundle``

``splunk validate cluster-bundle && splunk show cluster-bundle-status && splunk apply cluster-bundle``

#### Lister la configuration d'un fichier de conf
``splunk cmd btool indexes list --debug``
``splunk btool savedsearches list "Nest - Alert Heating" --user=admin --app=search``

#### Sortir le contenu d'un index
``splunk search "index=xxx" -preview 0 -maxout 0 -output rawdata > out.log``

#### Exemple d'utilisation des variables/tokens dans une alerte
``https://api.trello.com/1/cards?name=$result.titre$&desc=$result.desc$``

#### Configure the universal forwarder to connect to a deployment server
``splunk set deploy-poll <host name or ip address>:<management port>``

#### Configure the universal forwarder to connect to a receiving indexer
``splunk add forward-server <host name or ip address>:<listening port>``

#### Reload the deployment server
``splunk reload deploy-server``

#### Inspecter un index
``splunk dispatch "| dbinspect index=syslog"``

#### Reboot de tous les peers d'un cluster
``splunk rolling-restart cluster-peers`` [documentation](https://docs.splunk.com/Documentation/Splunk/latest/Indexer/Userollingrestart)

#### Ajout d'un indexer à un search head [](https://docs.splunk.com/Documentation/Splunk/7.0.0/DistSearch/Configuredistributedsearch)
``splunk add search-server <scheme>://<host>:<port> -auth <user>:<password> -remoteUsername <user> -remotePassword <passremote>``

Note the following:

 * <scheme> is the URI scheme: "http" or "https".
 * <host> is the host name or IP address of the search peer's host machine.
 * <port> is the management port of the search peer.
 * Use the -auth flag to provide credentials for the search head.
 * Use the -remoteUsername and -remotePassword flags for the credentials for the search peer. The remote credentials must be for an admin-level user on the search peer.

``splunk add search-server https://192.168.1.1:8089 -auth admin:password -remoteUsername admin -remotePassword passremote``

distsearch.conf in ``$SPLUNK_HOME/etc/system/local``
```
[distributedSearch]
servers = https://192.168.1.1:8089,https://192.168.1.2:8089
```

#### Indexer de nouveau des fichiers
```
$SPLUNK_HOME/bin/splunk stop
rm -rf $SPLUNK_HOME/var/lib/splunk/fishbucket
$SPLUNK_HOME/bin/splunk start
```


#### Indexer de nouveau des fichiers sur un UF 
```
$SPLUNK_HOME/bin/splunk stop
$SPLUNK_HOME/bin/splunk clean all
$SPLUNK_HOME/bin/splunk start
```

#### Indexer de nouveau des fichiers sur Indexer
```
$SPLUNK_HOME/bin/splunk stop
$SPLUNK_HOME/bin/splunk clean eventdata -index my_index1
$SPLUNK_HOME/bin/splunk clean eventdata -index my_index2
$SPLUNK_HOME/bin/splunk start
```

#### Supprimer un KVSTORE
```
$SPLUNK_HOME/bin/splunk clean kvstore -app <app_name> -collection <collection_name>
```
