# Intune Backup and Documentation Automation

This project is based on https://github.com/almenscorner/IntuneCD (which automates the process of backing up, documenting, and restoring Microsoft Intune configurations. It also documents the changes made by admins since last backup in separate commits based on the Intune Audit logs) and based on the pipeline configuration of https://github.com/aaronparker/intune-backup-template.

The purpose of this project is to provide a ready-to-use implementation for Azure DevOps with Self Hosted Windows Agents. It contains the pipelines and instructions for configuring the required dependencies.


## Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Setup](#setup)
- [Usage](#usage)
  - [Backing Up Intune Configurations](#backing-up-intune-configurations)
  - [Generating Documentation](#generating-documentation)
  - [Restoring Configurations](#restoring-configurations)
- [Pipelines](#pipelines)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This project provides tools to:
- Backup Intune configurations into the `prod-backup` folder.
- Generate markdown documentation from the backup and store it in the `prod-documenation` folder.
- Restore configurations from the `prod-restore` folder.

## Project Structure

#### Key Files and Folders

- **`prod-backup/`**: Stores the Intune configuration backup.
- **`prod-documentation/`**: Contains generated markdown documentation.
- **`prod-restore/`**: Used for restoring configurations.
- **`pipelines/`**: Contains YAML files for CI/CD pipelines.

## Setup
0. **Requirements:**
- Windows OS (Server or Client)
- Installed and configured Self Hosted Azure DevOps Agent. (Instructions not included here.)

1. **Install Dependencies**:
   - Install Python on Self Hosted Windows Azure DevOps Agent (see `.\Install-Python.ps1`).
   - Make sure that you install Python in the Work\Tool folder of the Azure DevOps Agent. Default is: "C:\Agent\\_work\\_tool"

2. **Entra ID App Registration permissions**
   - Create an Enterprise App registration in Entra ID
   - After creating the App registration -> browse to API permissions -> Click Add Permission -> Click the Microsoft Graph -> Application permissions.

   Select each of the following permissions:

   To access Intune data:
   - DeviceManagementApps.ReadWrite.All
   - DeviceManagementConfiguration.ReadWrite.All
   - DeviceManagementServiceConfig.ReadWrite.All
   - DeviceManagementManagedDevices.ReadWrite.All
   - DeviceManagementRBAC.ReadWrite.All
   - Group.Read.All
   - Policy.Read.All
   - Policy.ReadWrite.ConditionalAccess
   - Application.Read.All

   To access Entra data:
   - Domain.ReadWrite.All
   - Policy.ReadAll
   - Policy.ReadWrite.AuthenticationFlows
   - Policy.ReadWrite.AuthenticationMethod
   - Policy.ReadWrite.Authorization
   - Policy.ReadWrite.DeviceConfiguration
   - Policy.ReadWrite.ExternalIdentities
   - Policy.ReadWrite.SecurityDefaults
   - Group.ReadWrite.All

   Make sure to perform all necessary security reviews within your organizations before deploying in production environments

3. **Configure Environment**:
   - Create a new Azure DevOps repository, and copy all files and folders from this repository (excluded the .git folder) to your newly created repository.
   - Update `.vscode/settings.json` as needed.
   - Make sure that you create a Variable Group in Azure DevOps under Library which contains the following variables:
      - $env:USER_NAME = "IntuneCD"
      - $env:USER_EMAIL = "IntuneCD@`[yourdomain.com]`"
      - $env:TENANT_NAME = "`[tenant.yourdomain.com]`"
      - $env:TENANT_ID = "`[TenantID]`"
      - $env:CLIENT_ID = "`[ClientID]`" (Store the Application ID here for the App Registration that you've just created)
      - $env:IntuneCDVersion = "==2.4.1b5" (Which IntuneCD version to use)
   - Update the files `pipelines\intune-backup.yml` and `pipelines\intune-restore.yml` replace `##INSERT_YOUR_VARIABLE_GROUP_NAME##` with the name of your variable group (that you've just created).
   - Commit changes.
4. **Set Up Pipelines**:
   - Configure the `intune-backup.yml` and `intune-restore.yml` pipelines in Azure DevOps.

## Usage

#### Backing Up Intune Configurations

Run the `intune-backup.yml` pipeline in Azure DevOps to back up configurations to the `prod-backup` folder.

The `intune-backup.yml` pipeline automatically generates markdown documentation from the backup. It creates documentation files in the `prod-documentation` folder.

#### Restoring Configurations

Follow the steps in [Restore-Instructions.md](prod-restore/Restore-Instructions.md) to restore configurations. Running the `intune-restore.yml` pipeline from Azure DevOps restores the selected files to Intune.

## Pipelines

#### `intune-backup.yml`

- Backs up Intune configurations.
- Generates markdown documentation.
- Stores changes made by admins since last backup in separate commits based upon Intune audit logs.

#### `intune-restore.yml`

- Restores configurations from the `prod-restore` folder.
- Removes restored files after successful execution.

## Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Submit a pull request with a detailed description.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
