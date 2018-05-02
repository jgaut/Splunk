# Exemples de scripts PowerShell

#### Calcul des hash pour les fichiers d'un dossier
```
Get-ChildItem -File -Recurse | Select Name,FullName,@{N='FileHash';E={(Get-FileHash $_.PSPath).Hash}} | ConvertTo-Json -Compress > list.txt
```
