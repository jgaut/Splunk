# Commandes

#### Déploiement d'une nouvelle configuration sur un cluster d'indexer
* ``splunk validate cluster-bundle``
* ``splunk show cluster-bundle-status`` 
* ``splunk apply cluster-bundle``

#### Lister la configuration d'un fichier de conf
``splunk cmd btool indexes list --debug``
``splunk btool savedsearches list "Nest - Alert Heating" --user=admin --app=search``

#### Sortir le contenu d'un index
``splunk search "index=xxx" -preview 0 -maxout 0 -output rawdata > out.log``

#### Exemple d'utilisation des variables/tokens dans une alerte
``https://api.trello.com/1/cards?name=$result.titre$&desc=$result.desc$``

