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

