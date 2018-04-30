#Script d'installation automatique de l'universal forwarder Splunk

#Récupération des paramètres d'entrée : Tous sont obligatoires
param(
	[Parameter(Mandatory=$true)]
	[string] $binaire,
	[Parameter(Mandatory=$true)]
	[string] $checksum,
	[Parameter(Mandatory=$true)]
	[string] $server,
	[Parameter(Mandatory=$true)]
	[string] $port,
	[Parameter(Mandatory=$true)]
	[string] $password,
	[Parameter(Mandatory=$true)]
	[string] $server_name,
	[Parameter(Mandatory=$true)]
	[string] $secret
)

#Vérification du hash du fichier binaire (SHA256)
$checksum2 = $(CertUtil -hashfile .\splunkforwarder-7.0.3-fa31da744b51-x64-release.msi MD5)[1] -replace " ",""

if($checksum2 -ne $checksum){
	Write-Host "Checksum invalide : L'integrite du fichier est compromise ou le parametre en entree est faux."
	exit
}else{
	Write-Host "Integrite du binaire $binaire : OK"
}

#Arrêt du service SplunkForwarder (on ne sait jamais)
Write-Host "Arret du service SplunkForwarder"
Net stop SplunkForwarder

#Lancement de l'installation avec : Un déploiement serveur, un non lancement de l'application et l'acceptation de la licence
$config = $server + ":" + $port
#Write-Host $config
#Write-Host $binaire 
Write-Host "Installation du binaire : $binaire"
Start-Process msiexec.exe -Wait -ArgumentList "/i $binaire AGREETOLICENSE=Yes LAUNCHSPLUNK=0 /l*v install_splunkforwarder.msi.log /quiet"

#Changement du nom de l'host 
Write-Host "Changement du nom du serveur : $server_name"
& 'C:\Program Files\SplunkUniversalForwarder\bin\splunk' set servername $server_name
& 'C:\Program Files\SplunkUniversalForwarder\bin\splunk' set default-hostname $server_name
" " | Add-Content 'C:\Program Files\SplunkUniversalForwarder\etc\system\local\deploymentclient.conf'
"[deployment-client]" | Add-Content 'C:\Program Files\SplunkUniversalForwarder\etc\system\local\deploymentclient.conf'
"clientName = $server_name " | Add-Content 'C:\Program Files\SplunkUniversalForwarder\etc\system\local\deploymentclient.conf'
" " | Add-Content 'C:\Program Files\SplunkUniversalForwarder\etc\system\local\deploymentclient.conf'

#Setup du déploiement serveur
Write-Host "Deploiement serveur : $config"
& 'C:\Program Files\SplunkUniversalForwarder\bin\splunk' set deploy-poll $config

#Changement de mote de passe pour le user admin de l'application UF Splunk
Write-Host "Changement du mote de passe"
& 'C:\Program Files\SplunkUniversalForwarder\bin\splunk' edit user admin -password $PASSWORD -auth admin:changeme

#Mise en place du fichier splunk.secret
Write-Host "Mise en place du secret"
Remove-Item 'C:\Program Files\SplunkUniversalForwarder\etc\auth\splunk.secret'
Remove-Item 'C:\Program Files\SplunkUniversalForwarder\etc\auth\ca.pem'
Remove-Item 'C:\Program Files\SplunkUniversalForwarder\etc\system\local\server.conf'
$SECRET | Out-File 'C:\Program Files\SplunkUniversalForwarder\etc\auth\splunk.secret'

#Lancement du service SplunkForwarder
Write-Host "Lancement du service SplunkForwarder"
Net start SplunkForwarder 