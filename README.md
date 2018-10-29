# Splunk
Ceci est un dépôt de trucs utiles pour Splunk.

## Vision verticale de l'architecture

                      Export des données               -----|
                              /\                            |
                              ||                            | 
                              ||                            |
                   Visualisation des données           -----|
                              /\
                              ||
                              ||                          
                 Mise à disposition des données        -----|
                              /\                            | Partie différenciante :  
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
                     Transfert des données             -----|
                              /\                            |
                              ||                            |
                              ||                            |
                 Génération/captation des données      -----|
               
