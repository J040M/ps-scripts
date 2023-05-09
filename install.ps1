# WARP installation
$TMP_PATH = "C:\Temp\warp"
$DOWNLOAD_FILE = "https://1111-releases.cloudflareclient.com/windows/Cloudflare_WARP_Release-x64.msi"
$EXE_FILE = "$TMP_PATH\warp-64.msi"

# WARP certificate
$CERTPATH = "$TMP_PATH\certificates"
$CERT_LOG = "$TMP_PATH\certlogs.log"

# ------------------------ #
# Require Admin permission #
# ------------------------ #

if(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList "-File `"$($MyInvocation.MyCommand.Path)`"  `"$($MyInvocation.MyCommand.UnboundArguments)`""
    Exit
}

# ------------------------ #
# CERTIFICATE INSTALLATION #
# ------------------------ #
if (!(Test-Path -Path $CERTPATH -PathType Container)) {
    New-Item -ItemType Directory -Path $CERTPATH | Out-Null
}

# Certificate urls
$CERT_PEM_URL = "https://developers.cloudflare.com/cloudflare-one/static/documentation/connections/Cloudflare_CA.pem"
$CERT_CRT_URL = "https://developers.cloudflare.com/cloudflare-one/static/documentation/connections/Cloudflare_CA.crt"

$CERT_PEM_DESTINATION = "$CERTPATH\cf_pem.pem"
$CERT_CRT_DESTINATION = "$CERTPATH\cf_crt.crt"

$webClient = New-Object System.Net.WebClient

Write-Host "Starting certificate installation..."

# Download certificates
try {
    $webClient.DownloadFile($CERT_PEM_URL, $CERT_PEM_DESTINATION)
    Write-Host "PEM downloaded to: $CERT_PEM_DESTINATION"
    Add-Content $CERT_LOG "PEM downloaded to: $CERT_PEM_DESTINATION"
} catch {
    Write-Host "Error downloading PEM from: $CERT_PEM_URL"
    Add-Content $CERT_LOG "Error downloading PEM from: $CERT_PEM_URL"
}

try {
    $webClient.DownloadFile($CERT_CRT_URL, $CERT_CRT_DESTINATION)
    Write-Host "CRT downloaded to: $CERT_CRT_DESTINATION"
    Add-Content $CERT_LOG "CRT downloaded to: $CERT_CRT_DESTINATION"
} catch {
    Write-Host "Error downloading CRT from: $CERT_CRT_URL"
    Add-Content $CERT_LOG "Error downloading CRT from: $CERT_CRT_URL"
}

# Install certificates and log
Import-Certificate -FilePath $CERT_PEM_DESTINATION -CertStoreLocation "Cert:\LocalMachine\Root"
Write-Host "Certificate PEM installed in LocalMachine\Root"
Add-Content $CERT_LOG "Certificate PEM installed in LocalMachine\Root"

Import-Certificate -FilePath $CERT_CRT_DESTINATION -CertStoreLocation "Cert:\LocalMachine\Root"
Write-Host "Certificate CRT installed in LocalMachine\Root"
Add-Content $CERT_LOG "Certificate CRT installed in LocalMachine\Root"

# ----------------- #
# WARP INSTALLATION #
# ----------------- #

Write-Host "Starting WARP installation ..."

# Check if file already exists
if (!(Test-Path -Path $EXE_FILE)) {
    Write-Host "WARP file now found! Downloading it..."
    # Download file
    Invoke-WebRequest -Uri $DOWNLOAD_FILE -OutFile $EXE_FILE -UseBasicParsing
}

$ORG = Read-Host "Enter your organization name: "

# Set arguments
$MSIArguments = @(
    "/qn"
    "ORGANIZATION=$ORG"
)

# Launch MSI installer with logging
$CERT_LOG = Join-Path -Path $PSScriptRoot -ChildPath "$TMP_PATH\install.log"
$INSTALLATION_RESULT = Start-Process "msiexec.exe" -ArgumentList "/i `"$EXE_FILE`" $MSIArguments /L*v `"$CERT_LOG`"" -Wait

# Check if installation was successful
if ($INSTALLATION_RESULT.ExitCode -eq 0) {
    Write-Host "Installation successful!"

} else {
   Write-Host "Installation failed? Please check the installation logs for more information..."
}