# WARP installation
$DOWNLOAD_FILE = "https://1111-releases.cloudflareclient.com/windows/Cloudflare_WARP_Release-x64.msi"
$EXE_FILE = "warp-64.msi"

# WARP certificate
$certPath = "C:\Temp\certificates"
$logFile = ".\certlogs.log"

if (!(Test-Path -Path $certPath -PathType Container)) {
    New-Item -ItemType Directory -Path $certPath | Out-Null
}

$certPEMUrl = "https://developers.cloudflare.com/cloudflare-one/static/documentation/connections/Cloudflare_CA.pem"
$certCRTUrl = "https://developers.cloudflare.com/cloudflare-one/static/documentation/connections/Cloudflare_CA.crt"

$certPEMDestination = "$certPath\cf_pem.pem"
$certCRTDestination = "$certPath\cf_crt.crt"

$webClient = New-Object System.Net.WebClient

Write-Host "Starting certificate installation..."

try {
    $webClient.DownloadFile($certPEMUrl, $certPEMDestination)
    Write-Host "PEM downloaded to: $certPEMDestination"
    Add-Content $logFile "PEM downloaded to: $certPEMDestination"
} catch {
    Write-Host "Error downloading PEM from: $certPEMUrl"
    Add-Content $logFile "Error downloading PEM from: $certPEMUrl"
}

try {
    $webClient.DownloadFile($certCRTUrl, $certCRTDestination)
    Write-Host "CRT downloaded to: $certCRTDestination"
    Add-Content $logFile "CRT downloaded to: $certCRTDestination"
} catch {
    Write-Host "Error downloading CRT from: $certCRTUrl"
    Add-Content $logFile "Error downloading CRT from: $certCRTUrl"
}

Import-Certificate -FilePath $certPEMDestination -CertStoreLocation "Cert:\LocalMachine\Root"
Write-Host "Certificate PEM installed in LocalMachine\Root"
Add-Content $logFile "Certificate PEM installed in LocalMachine\Root"

Import-Certificate -FilePath $certCRTDestination -CertStoreLocation "Cert:\LocalMachine\Root"
Write-Host "Certificate CRT installed in LocalMachine\Root"
Add-Content $logFile "Certificate CRT installed in LocalMachine\Root"

Write-Host "Starting WARP installation ..."

# Check if file already exists
if (!(Test-Path -Path $EXE_FILE)) {
    Write-Host "WARP file now found! Downloading it..."
    # Download file
    Invoke-WebRequest -Uri $DOWNLOAD_FILE -OutFile $EXE_FILE -UseBasicParsing
}

$ORG = Read-Host "Enter your organization name: "

# Set MSI arguments
$MSIArguments = @(
    "/qn"
    "ORGANIZATION=$ORG"
)

# Launch MSI installer with logging
$LogFile = Join-Path -Path $PSScriptRoot -ChildPath "install.log"
Start-Process "msiexec.exe" -ArgumentList "/i `"$EXE_FILE`" $MSIArguments /L*v `"$LogFile`"" -Wait

# Check if installation was successful
if ($LASTEXITCODE -eq 0) {
    Write-Host "Installation successful."

} else {
    Write-Host "Installation failed? Please check the installation logs for more information..."
}