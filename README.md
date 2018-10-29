# Splunk

## Vision verticale de l'architecture

_Visualisation et export des données_

                      Export des données               -----| 
                              /\                            | 
                              ||                            | 
                              ||                            |               
                   Visualisation des données           -----|               
                              /\
                              ||
                              || 
                              
_Gestion des données_   

                 Mise à disposition des données        -----|
                              /\                            |
                              ||                            | 
                              ||                            | 
            Reconnaissance/Transformation des données       |
                              /\                            |
                              ||                            |
                              ||                            |
                     Recherche des données                  |
                              /\                            |
                              ||                            |
                              ||                            |
                     Indexation des données                 |
                              /\                            |
                              ||                            |
                              ||                            |
                     Stockage des données              -----|
                              /\
                              ||
                              ||

_Acquisition des données_

                     Transfert des données             -----|
                              /\                            |
                              ||                            |
                              ||                            |
                 Génération/captation des données      -----|
               
### Visualisation et export des données

La solution Splunk couvre 90% des cas d'usage.

_Concurrence :_
* [Tableau](https://www.tableau.com) est une solution web spécialisée dans la visualisation,
    * "+" Grand nombre de choix de présentation,
    * "-"  
* [Grapher](http://www.goldensoftware.com/products/grapher) est une solution avec un client lourd,
    * "+" Grand nombre de choix de présentation, 
    * "+" Finesse des graphiques (>10 000 points),
    * "-"
* [Kibana](https://www.elastic.co/fr/products/kibana) pour une solution de type web open source,
    * "+" Open source,
    * "-" Open source,
