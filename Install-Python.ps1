[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [String] $pythonVersion = "3.13.2"
    ,
    [Parameter(Mandatory=$false)]
    [String] $agentToolsDirectory = "C:\Agent\_work\_tool"
    ,
    [Parameter(Mandatory=$false)]
    [Switch] $InstallSystemWide
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
        exit 0
    }
    else {
        Write-Warning "A different version of Python is installed: $installedVersion."
    }
}

Write-Host "Proceeding with installation of Python $pythonVersion. This may take a while" -ForegroundColor Green

if ($InstallSystemWide) {
    # Install Python system-wide
    $installerPath = "$env:TEMP\python-$pythonVersion-amd64.exe"
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile("https://www.python.org/ftp/python/$pythonVersion/python-$pythonVersion-amd64.exe", $installerPath)

    Start-Process -FilePath $installerPath -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -NoNewWindow -Wait

    Start-Sleep -Seconds 5

    # Reload environment variables to ensure the new path is recognized
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

    $Result = & "python" --version

    if ($Result -ne "Python $pythonVersion") {
        Write-Error "Python installation failed. Expected version: $pythonVersion, Actual version: $Result"
    }
    else {
        Write-Host "Python $pythonVersion installed successfully system-wide." -ForegroundColor Green
    }
}
else {
    # Install Python in the agent tools directory
    if (-not (Test-Path "$agentToolsDirectory\Python\$pythonVersion\x64")) {
        $null = New-Item -Path "$agentToolsDirectory\Python\$pythonVersion\x64" -ItemType Directory -Force -ErrorAction Stop
    }

    # Ensure the directory creation is complete before proceeding
    while (-not (Test-Path "$agentToolsDirectory\Python\$pythonVersion\x64")) {
        Start-Sleep -Milliseconds 500
        Write-Host "Waiting for directories to be created.."
    }

    # Download the Python installer
    $installerPath = "$agentToolsDirectory\Python\$pythonVersion\x64\python-$pythonVersion-amd64.exe"
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile("https://www.python.org/ftp/python/$pythonVersion/python-$pythonVersion-amd64.exe", $installerPath)

    # Creating download complete file, required by the DevOps Agent
    New-Item -Path "$agentToolsDirectory\Python\$pythonVersion\" -Name "x64.complete" -ItemType File -Force

    Start-Process -FilePath $installerPath -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1 TargetDir=$agentToolsDirectory\Python\$pythonVersion\x64" -NoNewWindow -Wait

    Start-Sleep -Seconds 5

    # Reload environment variables to ensure the new path is recognized
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

    $Result = & "python" --version

    if ($Result -ne "Python $pythonVersion") {
        Write-Error "Python installation failed. Expected version: $pythonVersion, Actual version: $Result"
    }
    else {
        Write-Host "Python $pythonVersion installed successfully in the agent tools directory." -ForegroundColor Green
    }
}

Read-Host "Press any key to exit..."
