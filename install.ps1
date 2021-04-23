$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$QuarkFolder = $env:QUARK
$BinDir = if ($QuarkFolder) {
  "$QuarkFolder"
} else {
  "$Home\.quark"
}

$Target = 'windows-latest'
$QuarkZip = "$BinDir\quark-$Target.zip"
$QuarkExe = "$BinDir\quark.exe"

# GitHub requires TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$QuarkUri = "https://github.com/quark-lang/quark/releases/latest/download/quark-${Target}.zip"
$releases = "https://api.github.com/repos/quark-lang/quark/releases"

Write-Host -NoNewline "* Searching a release..."
$tag = (Invoke-WebRequest $releases | ConvertFrom-Json)[0].tag_name
Write-Output " found '$tag'"

if (!(Test-Path $BinDir)) {
  New-Item $BinDir -ItemType Directory | Out-Null
}
Write-Host -NoNewline "* Downloading the latest Quark release archive... "
Invoke-WebRequest $QuarkUri -OutFile $QuarkZip -UseBasicParsing
Write-Host -ForegroundColor Green "done"

Write-Host -NoNewline "* Deflating archive... "
if (Get-Command Expand-Archive -ErrorAction SilentlyContinue) {
  Expand-Archive $QuarkZip -Destination $BinDir -Force
} else {
  if (Test-Path $QuarkExe) {
    Remove-Item $QuarkExe
  }
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [IO.Compression.ZipFile]::ExtractToDirectory($QuarkZip, $BinDir)
}
Write-Host -ForegroundColor Green "done"

Write-Host -NoNewline "* Cleaning $BinDir directory... "
Remove-Item $QuarkZip
Write-Host -ForegroundColor Green "done"
Write-Host ""

$User = [EnvironmentVariableTarget]::User
$Path = [Environment]::GetEnvironmentVariable('Path', $User)
if (!(";$Path;".ToLower() -like "*;$BinDir;*".ToLower())) {
  [Environment]::SetEnvironmentVariable('Path', "$Path;$BinDir", $User)
  $Env:Path += ";$BinDir"
  [Environment]::SetEnvironmentVariable('QUARK', "$BinDir", $User)
}

Write-Output "Quark was installed successfully to $QuarkExe"
Write-Output "Run 'quark --help' to get started"