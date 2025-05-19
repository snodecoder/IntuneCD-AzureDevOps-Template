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

# Check if Python is already installed
if (Get-Command "python" -ErrorAction SilentlyContinue) {
    $installedVersion = (Get-Command "python" | Select-Object FileVersionInfo).FileVersionInfo.ProductVersion
    if ($installedVersion -match $pythonVersion) {
        Write-Host "Python $pythonVersion is already installed." -ForegroundColor Green
    }
    else {
        Write-Warning "A different version of Python is installed: $installedVersion."
    }
}
elseif ($null -eq (Get-Command "python" -ErrorAction SilentlyContinue)) {

    Write-Host "Proceeding with installation of Python $pythonVersion." -ForegroundColor Green

    if (-not (Test-Path "$env:agentToolsDirectory\Python\$env:pythonVersion\x64") ) {
        $null = New-Item -Path "$env:agentToolsDirectory\Python\$env:pythonVersion\x64" -ItemType Directory -Force
    }

    Invoke-RestMethod -Uri "https://www.python.org/ftp/python/$pythonVersion/python-$pythonVersion-amd64.exe" -OutFile "$agentToolsDirectory\Python\$pythonVersion\x64\python-$pythonVersion-amd64.exe"

    # Creating download complete file, required by the DevOps Agent
    New-Item -Path "$agentToolsDirectory\Python\$pythonVersion\" -Name "x64.complete" -ItemType File -Force

    Start-Process -FilePath "$agentToolsDirectory\Python\$pythonVersion\x64\python-$pythonVersion-amd64.exe" -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1 TargetDir=$agentToolsDirectory\Python\$pythonVersion\x64" -NoNewWindow -Wait

    Start-Sleep -Seconds 5

    $Result = & "$agentToolsDirectory\Python\$pythonVersion\x64\python.exe" --version

    if ($Result -ne "Python $pythonVersion") {
        Write-Error "Python installation failed. Expected version: $pythonVersion, Actual version: $Result"
    }
    else {
        Write-Host "Python $pythonVersion installed successfully." -ForegroundColor Green
    }
}

Read-Host "Press any key to exit..."
