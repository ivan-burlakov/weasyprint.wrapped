$workingDir = "./standalone-windows-64";
$assets = "./assets";

if (Test-Path $workingDir) {
    Write-Host "*** Cleaning $workingDir"
    Remove-Item $workingDir -Recurse -Force | Out-Null
}
Write-Host "*** Creating $workingDir"
New-Item -ItemType "directory" -Path $workingDir | Out-Null

if (!(Test-Path $assets)) {
    Write-Host "*** Creating $assets"
    New-Item -ItemType "directory" -Path $assets | Out-Null
}

$workingDir = Resolve-Path -Path "./standalone-windows-64";
$assets = Resolve-Path -Path "./assets";

Write-Host "*** Downloading gtk3 (https://github.com/tschoonj/GTK-for-Windows-Runtime-Environment-Installer)"
Invoke-WebRequest -Uri "https://github.com/tschoonj/GTK-for-Windows-Runtime-Environment-Installer/releases/download/2022-01-04/gtk3-runtime-3.24.31-2022-01-04-ts-win64.exe" -OutFile "$workingDir/gtk3.exe"
Invoke-Expression "$workingDir/gtk3.exe /setpath=no /dllpath_silent=yes /sideeffects=no /dllpath=root /translations=no /removeold=no /S /D=$workingDir\gtk3\install\"
# Previous command is not blocking but should be done in 30 seconds
Start-Sleep -Seconds 30
Move-Item -Path "$workingDir/gtk3/install/*" -Destination "$workingDir/gtk3"
Remove-Item $workingDir/gtk3.exe -Recurse -Force | Out-Null
Remove-Item $workingDir/gtk3/install -Recurse -Force | Out-Null

Write-Host "*** Downloading python (https://github.com/indygreg/python-build-standalone)"
Invoke-WebRequest -Uri "https://github.com/indygreg/python-build-standalone/releases/download/20220502/cpython-3.10.4+20220502-x86_64-pc-windows-msvc-shared-install_only.tar.gz" -OutFile "$workingDir/python.tar.gz"
Invoke-Expression "tar -xvzf $workingDir/python.tar.gz -C $workingDir"
Remove-Item "$workingDir/python.tar.gz" -Recurse -Force | Out-Null

Set-Location  "$workingDir/python"
Write-Host "*** Installing weasyprint"
Invoke-Expression ".\python.exe -m pip install weasyprint"
$Env:PATH += ";$workingDir/gtk3"
Write-Host "*** Testing weasyprint"
Invoke-Expression ".\python.exe -m weasyprint --info"
$version = Invoke-Expression ".\python.exe -m weasyprint --version"
$versionCleared = $version.Replace(' ','').ToLower();
$versionFile = "version-$versionCleared"
New-Item -Path "$workingDir/$versionFile"
Set-Location  "../../"

Write-Host "*** Create archive $assets/standalone-windows-64.zip"
Compress-Archive -Path "$workingDir/*"  -DestinationPath "$assets/standalone-windows-64.zip" -CompressionLevel "Optimal" -Force