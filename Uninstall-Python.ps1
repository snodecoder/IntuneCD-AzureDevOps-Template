[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [String] $pythonVersion = "3.13.2"
    ,
    [Parameter(Mandatory=$false)]
    [String] $agentToolsDirectory = "C:\Agent\_work\_tool"
)

# Check if the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script needs to be run as an administrator."
    exit 1
}

$uninstallPath = "$agentToolsDirectory\Python\$pythonVersion\x64\python-$pythonVersion-amd64.exe"
if (Test-Path $uninstallPath) {
    Start-Process -FilePath $uninstallPath -ArgumentList "/uninstall /quiet" -NoNewWindow -Wait
    Remove-Item -Path "$agentToolsDirectory\Python\$pythonVersion\x64" -Recurse -Force
    Remove-Item -Path "$agentToolsDirectory\Python\$pythonVersion\" -Recurse -Force
}
