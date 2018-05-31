Param (
        [Parameter(ValueFromPipeline=$true)]
        [string]$Fichier1 = "Connexion.ini",
        [string]$Fichier2 = "mdpco.conf",
        [string]$key = "clef de chiffrement",
        [string]$scriptTelnet = "..."
    )



$MonFichier = get-content $Fichier1

foreach ($UneLigne in $MonFichier){
    $tmp=$UneLigne.split("=")
    if($tmp[0] -cmatch "Modem_IP"){
        $modemIp=$tmp[1].Trim('"')
    }
    if($tmp[0] -cmatch "Modem_port"){
        $modemPort=$tmp[1]
    }
}

#Write-Host $modemIP
#Write-Host $modemPort

$MonFichier = get-content $Fichier2

foreach ($UneLigne in $MonFichier){
    $tmp=$UneLigne.split("separateur")
    $mdp=$tmp[0]
}

#Write-Host $mdp

$enc = [system.Text.Encoding]::UNICODE 
$data = $enc.GetBytes($mdp)
$data2 = $enc.GetBytes($key)
$data3 = $enc.GetBytes("")
#Write-Host $data

$j=0;
for($i=0; $i -lt $data.Length; $i++){
    $data3+=$data2[$j] -bxor $data[$i]
    #Write-host $i $j
    $j++
    $j %= $data2.Length
}

#Write-host $data3

$modemPass = [System.Text.Encoding]::UNICODE.GetString($data3)
$modemPass = $modemPass+"UsEr"
#Write-Host $modemIp $modemPort $modemPass $scriptTelnet

$argumentList = ' -RemoteHost $modemIP -port $modemPort -Commands " ", "user", "$modemPass", "AT*NETIP?", "AT*NETSTATE?", "AT*NETRSSI?", "AT*CELLINFO?"'

Invoke-Expression "& `"$scriptTelnet`" $argumentList"