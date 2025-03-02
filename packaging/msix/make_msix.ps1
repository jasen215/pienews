param(
    [Parameter(Mandatory=$true)]
    [string]$Version
)

$ErrorActionPreference = "Stop"

# Ensure necessary tools are installed
if (!(Get-Command "makeappx.exe" -ErrorAction SilentlyContinue)) {
    Write-Error "makeappx.exe not found. Please install Windows SDK."
    exit 1
}

# Set paths
$BuildDir = "build\windows\x64\Release"
$MsixDir = "$BuildDir\msix"
$AssetsDir = "$MsixDir\assets"

# Create directories
New-Item -ItemType Directory -Force -Path $MsixDir
New-Item -ItemType Directory -Force -Path $AssetsDir

# Copy application files
Copy-Item "$BuildDir\*" -Destination $MsixDir -Recurse -Force
Copy-Item "assets\icons\*" -Destination "$AssetsDir" -Recurse -Force

# Update version number
$ManifestContent = Get-Content "packaging\msix\AppxManifest.xml"
$ManifestContent = $ManifestContent -replace 'Version="[0-9.]+\.0"', "Version=`"$Version.0`""
$ManifestContent | Set-Content "$MsixDir\AppxManifest.xml"

# Create MSIX package
$OutputFile = "$BuildDir\PieNews-$Version-Windows-Setup-x64.Msix"
& makeappx.exe pack /d $MsixDir /p $OutputFile

# If certificate exists, sign package
if (Test-Path "packaging\msix\certificate.pfx") {
    & signtool.exe sign /f "packaging\msix\certificate.pfx" /fd SHA256 $OutputFile
}

Write-Host "MSIX package created at: $OutputFile"