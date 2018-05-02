param(
	[string] $path = $(throw "A path is required. Usage: .\hash.ps1 -path 'my_path' -algorithm 'sha256' -day 2 "),
	[string] $algorithm = 'sha256',
	[double] $day = 0
)

$day = $day * -1
$files = gci $path $recurse | Where-Object { !$_.PSIsContainer } | Where{$_.LastWriteTime -gt (Get-Date).AddDays($day)}

$powershellversion = $PSVersionTable.PSVersion.Major

if($powershellversion -ge 4){

	foreach ($file in $files) {
		Get-ChildItem $file.FullName -File | Select LastWriteTime,Name,FullName,@{N='FileHash';E={(Get-FileHash $_.PSPath -algorithm SHA256).Hash}},@{N='Algorithm';E={echo $algorithm}} | ConvertTo-JSON -Compress
	}
}else{

	echo "["
	foreach ($file in $files) {
		$hash = [System.Security.Cryptography.HashAlgorithm]::create($algorithm)
		$FullName = $file.FullName.ToString().Replace('"','\"').Replace('\','\\').Replace("`n",'\n').Replace("`r",'\r').Replace("`t",'\t')
		'{"FileHash":"'+[System.BitConverter]::ToString( $hash.ComputeHash([System.IO.File]::ReadAllBytes($file.FullName))).ToLower().replace('-',"")+'","Name":"'+$file+'", "FullName":"'+$FullName+'", "LastWriteTime":"'+$file.LastWriteTime+'", "Algorithm":"'+$algorithm+'"},'
	}
	echo "]"

}
