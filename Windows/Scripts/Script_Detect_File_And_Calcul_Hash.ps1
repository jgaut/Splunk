#By BigTeddy 05 September 2011 
 
#This script uses the .NET FileSystemWatcher class to monitor file events in folder(s). 
#The advantage of this method over using WMI eventing is that this can monitor sub-folders. 
#The -Action parameter can contain any valid Powershell commands.  I have just included two for example. 
#The script can be set to a wildcard filter, and IncludeSubdirectories can be changed to $true. 
#You need not subscribe to all three types of event.  All three are shown for example. 
# Version 1.1 
# Original script => https://gallery.technet.microsoft.com/scriptcenter/Powershell-FileSystemWatche-dfd7084b

param(
	[string] $path = $(throw "A path is required. Usage: .\Script_Detect_File_And_Calcul_Hash.ps1 -path 'my_path' -algorithm 'sha256'"),
	[string] $algorithm = 'SHA256',
	[string] $reptmp = "C:\",
	[string] $logfile = "hash.json",
	[string] $filesize = "10000000",
	[int] $logcount = 1
)

$global:algorithm = $algorithm
$global:reptmp = $reptmp
$global:logfile = $reptmp+$logfile
$global:logcount = $logcount
$global:filesize = $filesize

$hashPIDFile = $reptmp+"hash.pid"

#Stop old process
$oldPID = get-content $hashPIDFile
Stop-Process -Id $oldPID

#Replace PID file
$PID | Out-File -FilePath $hashPIDFile

# To stop the monitoring, run the following commands:
Unregister-Event FileChanged 
 
#$path = 'C:\Users\jgautier\Desktop\' # Enter the root path you want to monitor. 
$filter = '*.*'  # You can enter a wildcard filter here.  
  
# In the following line, you can change 'IncludeSubdirectories to $true if required.                           
$fsw = New-Object IO.FileSystemWatcher $path, $filter -Property @{IncludeSubdirectories = $true;NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'} 


# Here, all three events are registerd.  You need only subscribe to events that you need: 
Register-ObjectEvent $fsw Changed -SourceIdentifier FileChanged -Action {

    . "$PSScriptRoot\Script_LogRotate.ps1"
	Reset-Log -fileName $logfile -filesize $filesize -logcount $logcount

    $name = $Event.SourceEventArgs.Name
	$FullName = $Event.SourceEventArgs.FullPath  
	$changeType = $Event.SourceEventArgs.ChangeType
	$timeStamp = $Event.TimeGenerated

	$m = $name | Select-String -Pattern '(\d\d\d\d)\.(\d\d)\.(\d\d)\s(\d\d)h\.(\d\d)m\.(\d\d)s'
	
	#$time = Get-Date -Format s -Year $m.Matches[0].Groups[1].Value -Month $m.Matches[0].Groups[2].Value -Day $m.Matches[0].Groups[3].Value -Hour $m.Matches[0].Groups[4].Value -Minute $m.Matches[0].Groups[5].Value -Second $m.Matches[0].Groups[6].Value
	$time = $m.Matches[0].Groups[1].Value +"/"+ $m.Matches[0].Groups[2].Value +"/"+ $m.Matches[0].Groups[3].Value +" "+ $m.Matches[0].Groups[4].Value +":"+ $m.Matches[0].Groups[5].Value +":"+ $m.Matches[0].Groups[6].Value
	

	$powershellversion = $PSVersionTable.PSVersion.Major

	if($powershellversion -ge 4){
		
		Get-ChildItem $FullName -File | Select Name,FullName,@{N='FileHash';E={(Get-FileHash $_.PSPath -algorithm $algorithm).Hash}},@{N='Algorithm';E={echo $algorithm}},@{N='time';E={echo $time}} | ConvertTo-JSON -Compress | Out-File -FilePath $logfile -Append

	}else{

		$hash = [System.Security.Cryptography.HashAlgorithm]::create($algorithm)
		#Write-Host $hash
		$Name = $name.ToString().Replace('"','\"').Replace('\','\\').Replace("`n",'').Replace("`r",'').Replace("`t",'')
		#Write-Host $Name
		$FullName = $FullName.ToString().Replace('"','\"').Replace('\','\\').Replace("`n",'').Replace("`r",'').Replace("`t",'')
		#Write-Host $FullName
		$file = gci $FullName
		'{"time":"'+$time+'","Name":"'+$Name+'","FullName":"'+$FullName+'","FileHash":"'+[System.BitConverter]::ToString( $hash.ComputeHash([System.IO.File]::ReadAllBytes($FullName))).replace('-',"")+'","Algorithm":"'+$algorithm+'"}' | Out-File -Append -FilePath $logfile
	
	} 

}

while(1){
	sleep 1
}

# Exemples :

# Pour une stanza PowerShell
# Start-Job -Name MyhashJob -ScriptBlock {powershell.exe -File 'E:\splunk\etc\apps\_SNCF_TA_Server_Sentinel\bin\Script_Detect_File_And_Calcul_Hash.ps1' -path 'E:\FTP\Sentinel\' -algorithm 'SHA256' -repTmp 'E:\Splunk\etc\apps\_SNCF_TA_Server_Sentinel\tmp\'}
