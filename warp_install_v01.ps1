# Set file
Set-Variable -Name "DOWNLOAD_FILE" -Value "https://appcenter-filemanagement-distrib1ede6f06e.azureedge.net/e6aceddd-bc42-4c91-8e3a-f9ee5b1cb948/Cloudflare_WARP_Release-x64.msi?sv=2019-02-02&sr=c&sig=qQ9WIW4/lLIuTWoVbbLuVX5QpqY0ptB7xyUATbPxBdk=&se=2023-05-05T07:25:23Z&sp=r&download_origin=appcenter"
Set-Variable -Name "EXE_FILE" -Value "./warp-64.msi"

$MSIArguments = @(
    "/qn"
    "ORGANIZATION=''"
)

# Download file
Invoke-Webrequest -Uri $DOWNLOAD_FILE -OutFile $EXE_FILE -UseBasicParsing

# Execute file
Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow