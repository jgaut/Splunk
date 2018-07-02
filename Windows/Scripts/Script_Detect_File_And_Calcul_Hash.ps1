#By BigTeddy 05 September 2011 
 
#This script uses the .NET FileSystemWatcher class to monitor file events in folder(s). 
#The advantage of this method over using WMI eventing is that this can monitor sub-folders. 
#The -Action parameter can contain any valid Powershell commands.  I have just included two for example. 
#The script can be set to a wildcard filter, and IncludeSubdirectories can be changed to $true. 
#You need not subscribe to all three types of event.  All three are shown for example. 
# Version 1.1 
# Original script => https://gallery.technet.microsoft.com/scriptcenter/Powershell-FileSystemWatche-dfd7084b

param(
	[string] $path = $(throw "A path is required. Usage: .\Script_Detect_File_And_Calcul_Hash.ps1 -path 'my_path' -algorithm 'sha256' -day 2 "),
	[string] $algorithm = 'SHA256',
	[string] $reptmp = "C:\"
)

$global:algorithm = $algorithm
$global:reptmp = $reptmp

# To stop the monitoring, run the following commands:
Unregister-Event FileChanged 
Unregister-Event FileCreated 
 
#$path = 'C:\Users\jgautier\Desktop\' # Enter the root path you want to monitor. 
$filter = '*.*'  # You can enter a wildcard filter here.  
  
# In the following line, you can change 'IncludeSubdirectories to $true if required.                           
$fsw = New-Object IO.FileSystemWatcher $path, $filter -Property @{IncludeSubdirectories = $true;NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'} 


# Here, all three events are registerd.  You need only subscribe to events that you need: 
 
Register-ObjectEvent $fsw Created -SourceIdentifier FileCreated -Action {
    
    $name = $Event.SourceEventArgs.Name
	$FullName = '"' + $Event.SourceEventArgs.FullPath + '"'
	$changeType = $Event.SourceEventArgs.ChangeType
	$timeStamp = $Event.TimeGenerated

	$powershellversion = $PSVersionTable.PSVersion.Major
	 
	$rand = Get-Random
	$rand_file = $reptmp+"hash_files_"+$algorithm+"_"+$rand+".json" 
	$tmp_file = $reptmp+"tmp.json"
	

	if($powershellversion -ge 4){
		
		Get-ChildItem $FullName -File | Select LastWriteTime,Name,FullName,@{N='FileHash';E={(Get-FileHash $_.PSPath -algorithm $algorithm).Hash}},@{N='Algorithm';E={echo $algorithm}} | ConvertTo-JSON -Compress | Out-File -FilePath $tmp_file -Append

	}else{
		Write-Host $Event.SourceEventArgs 
		$hash = [System.Security.Cryptography.HashAlgorithm]::create($algorithm)
		#Write-Host $hash
		$Name = $name.ToString().Replace('"','\"').Replace('\','\\').Replace("`n",'').Replace("`r",'').Replace("`t",'')
		#Write-Host $Name
		$FullName = $FullName.ToString().Replace('"','\"').Replace('\','\\').Replace("`n",'').Replace("`r",'').Replace("`t",'')
		#Write-Host $FullName
		$file = gci $FullName
		'{"LastWriteTime":"'+$file.LastWriteTime+'","Name":"'+$Name+'","FullName":"'+$FullName+'","FileHash":"'+[System.BitConverter]::ToString( $hash.ComputeHash([System.IO.File]::ReadAllBytes($FullName))).replace('-',"")+'","Algorithm":"'+$algorithm+'"}' | Out-File -Append -FilePath $tmp_file
	
	} 

	Rename-Item -Path $tmp_file -NewName $rand_file
}
 

Register-ObjectEvent $fsw Changed -SourceIdentifier FileChanged -Action {
    
    $name = $Event.SourceEventArgs.Name
	$FullName = $Event.SourceEventArgs.FullPath  
	$changeType = $Event.SourceEventArgs.ChangeType
	$timeStamp = $Event.TimeGenerated

	$powershellversion = $PSVersionTable.PSVersion.Major
	 
	$rand = Get-Random
	$rand_file = $reptmp+"hash_files_"+$algorithm+"_"+$rand+".json" 
	$tmp_file = $reptmp+"tmp.json"
	

	if($powershellversion -ge 4){
		
		Get-ChildItem $FullName -File | Select LastWriteTime,Name,FullName,@{N='FileHash';E={(Get-FileHash $_.PSPath -algorithm $algorithm).Hash}},@{N='Algorithm';E={echo $algorithm}} | ConvertTo-JSON -Compress | Out-File -FilePath $tmp_file -Append

	}else{
		Write-Host $Event.SourceEventArgs 
		$hash = [System.Security.Cryptography.HashAlgorithm]::create($algorithm)
		#Write-Host $hash
		$Name = $name.ToString().Replace('"','\"').Replace('\','\\').Replace("`n",'').Replace("`r",'').Replace("`t",'')
		#Write-Host $Name
		$FullName = $FullName.ToString().Replace('"','\"').Replace('\','\\').Replace("`n",'').Replace("`r",'').Replace("`t",'')
		#Write-Host $FullName
		$file = gci $FullName
		'{"LastWriteTime":"'+$file.LastWriteTime+'","Name":"'+$Name+'","FullName":"'+$FullName+'","FileHash":"'+[System.BitConverter]::ToString( $hash.ComputeHash([System.IO.File]::ReadAllBytes($FullName))).replace('-',"")+'","Algorithm":"'+$algorithm+'"}' | Out-File -Append -FilePath $tmp_file
	
	} 

	Rename-Item -Path $tmp_file -NewName $rand_file
}

while(1){
	sleep 1
}