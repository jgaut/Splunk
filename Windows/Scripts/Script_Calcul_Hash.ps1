param(
	[string] $path = $(throw "A path is required. Usage: .\Script_Calcul_Hash.ps1 -path 'my_path' -algorithm 'sha256' -day 2 "),
	[string] $algorithm = 'sha256',
	[double] $day = 0,
	[string] $reptmp = "C:\"
)

$day = $day * -1
$files = gci $path -Recurse | Where-Object { !$_.PSIsContainer } | Where{$_.LastWriteTime -gt (Get-Date).AddDays($day)}

$powershellversion = $PSVersionTable.PSVersion.Major
$powershellversion

if($powershellversion -ge 4){
	foreach ($file in $files) {
		Get-ChildItem $file.FullName -File | Select LastWriteTime,Name,FullName,@{N='FileHash';E={(Get-FileHash $_.PSPath -algorithm SHA256).Hash}},@{N='Algorithm';E={echo $algorithm}} | ConvertTo-JSON -Compress
		$file
	}
}else{
	foreach ($file in $files) {
		if($file){
			$hash = [System.Security.Cryptography.HashAlgorithm]::create($algorithm)
			$Name = $file.Name.ToString().Replace('"','\"').Replace('\','\\').Replace("`n",'').Replace("`r",'').Replace("`t",'')
			$FullName = $file.FullName.ToString().Replace('"','\"').Replace('\','\\').Replace("`n",'').Replace("`r",'').Replace("`t",'')
			$FullName = gci $FullName
			$tmp = '{"time":"'+$time+'","Name":"'+$Name+'","FullName":"'+$FullName+'","FileHash":"'+[System.BitConverter]::ToString( $hash.ComputeHash([System.IO.File]::ReadAllBytes($FullName))).replace('-',"")+'","Algorithm":"'+$algorithm+'"}' 
			$rand = Get-Random
			$rand_file = $reptmp+"\"+$rand+"_hash.json"
			$tmp_file = $reptmp+"tmp.json"
			$tmp | Out-File -Append -FilePath $logfile
		}
	}
}
