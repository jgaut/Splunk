param(
	[string] $path = $(throw "A path is required. Usage: .\Script_Calcul_Hash.ps1 -path 'my_path' -algorithm 'sha256' -day 2 "),
	[string] $algorithm = 'sha256',
	[double] $day = 0
)

$day = $day * -1
$files = gci $path -Recurse | Where-Object { !$_.PSIsContainer } | Where{$_.LastWriteTime -gt (Get-Date).AddDays($day)}

$powershellversion = $PSVersionTable.PSVersion.Major

if($powershellversion -ge 4){
	foreach ($file in $files) {
		Get-ChildItem $file.FullName -File | Select LastWriteTime,Name,FullName,@{N='FileHash';E={(Get-FileHash $_.PSPath -algorithm SHA256).Hash}},@{N='Algorithm';E={echo $algorithm}} | ConvertTo-JSON -Compress
	}
}else{
	$rand = Get-Random
	$rand_file = "C:\hash_files_"+$algorithm+"_"+$rand+".json"
	$tmp_file = "C:\tmp.json"
	foreach ($file in $files) {
		$hash = [System.Security.Cryptography.HashAlgorithm]::create($algorithm)
		$Name = $file.Name.ToString().Replace('"','\"').Replace('\','\\').Replace("`n",'').Replace("`r",'').Replace("`t",'')
		$FullName = $file.FullName.ToString().Replace('"','\"').Replace('\','\\').Replace("`n",'').Replace("`r",'').Replace("`t",'')
		'{"LastWriteTime":"'+$file.LastWriteTime+'","Name":"'+$Name+'","FullName":"'+$FullName+'","FileHash":"'+[System.BitConverter]::ToString( $hash.ComputeHash([System.IO.File]::ReadAllBytes($file.FullName))).replace('-',"")+'","Algorithm":"'+$algorithm+'"}' | Out-File -Append -FilePath $tmp_file
	}
	Rename-Item -Path $tmp_file -NewName $rand_file
}
