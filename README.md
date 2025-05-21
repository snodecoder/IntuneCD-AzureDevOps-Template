# Intune Backup and Documentation Automation

This project is based on https://github.com/almenscorner/IntuneCD (which automates the process of backing up, documenting, and restoring Microsoft Intune configurations. It also documents the changes made by admins since last backup in separate commits based on the Intune Audit logs) and based on the pipeline configuration of https://github.com/aaronparker/intune-backup-template.

### TLDR
The purpose of this project is to provide a ready-to-use implementation for Azure DevOps with Self Hosted Windows Agents.
- It contains the pipelines and instructions for configuring the required dependencies for using IntuneCD on Self Hosted Windows Azure DevOps Agents.
- It contains a conversion of the generated documentation to make it compatible for use in an Azure DevOps code Wiki.
- *Make sure to perform all necessary security reviews within your organizations before deploying in production environments*

---
## Table of Contents
- [Overview](#overview)
  - [Key Files and Folders](#key-files-and-folders)
- [Setup Dependencies and Environment](#setup-dependencies-and-environment)
  - [Requirements](#requirements)
  - [Install Dependencies](#install-dependencies)
  - [Entra ID App Registration Permissions](#entra-id-app-registration-permissions)
  - [Change Default Branch Name](#change-default-branch-name)
  - [Configure Environment](#configure-environment)
  - [Set Up Pipelines](#set-up-pipelines)
  - [Granting Permissions to Azure DevOps Pipeline Identity](#granting-permissions-to-azure-devops-pipeline-identity)
  - [Publish Code Wiki](#publish-code-wiki)
  - [Configuring Branch Policies](#configuring-branch-policies)
- [Usage](#usage)
  - [Backing Up Intune Configurations](#backing-up-intune-configurations)
  - [Restoring Configurations](#restoring-configurations)
- [Example Screenshots](#example-screenshots)
- [Contributing](#contributing)
- [License](#license)

---

## Overview
##### Key Files and Folders

- **`prod-backup\`**: Stores the Intune configuration backup.
- **`prod-documentation\`**: Contains generated markdown documentation.
- **`prod-restore\`**: Used for restoring configurations.
- **`pipelines\intune-backup.yml`**: Creates backup of Intune configurations in `prod-backup\`, generates markdown documentation in `prod-documentation\` converted for use with Azure DevOps code Wiki, stores changes made in Intune by admins since last backup in separate commits based upon Intune audit logs.
- **`pipelines\intune-restore.yml`**: Restores configurations from the `prod-restore` folder, removes restored files after successful execution. This pipeline contains a parameter to Update Assignments for the restored files (default = `false`).
- **`Install-Python.ps1`**: Installs Python on Windows Self Hosted Azure DevOps Agent.

## Setup Dependencies and Environment
##### Requirements
- Windows OS (Server or Client)
- Powershell 7.x (*Powershell 5 can also be used, but you need to change `pwsh: true` to `pwsh: false` in the pipeline files for that.*)
- Installed and configured Self Hosted Azure DevOps Agent. *(Instructions not included here, see [Microsoft Documentation](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/windows-agent?view=azure-devops&tabs=IP-V4))*

##### Install Dependencies
- Install Python on Self Hosted Windows Azure DevOps Agent (see `Install-Python.ps1`).
  - You can either install Python in the Work\Tool folder of the Azure DevOps Agent. Default is: "`C:\Agent\_work\_tool`"
  `.\install-Python.ps1 -pythonVersion "3.13.2" -agentToolsDirectory "C:\Agent\_work\_tool"`
  - Or you can install Python globally in Program Files (for example because you have multiple Azure DevOps Agents running) by adding the -SystemWide flag
  `.\install-Python.ps1 -pythonVersion "3.13.2" -installSystemWide`

##### Entra ID App Registration permissions
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

  *After adding the permissions, don't forget to provide Admin consent for them.*

  If you do not want / cannot add a particular permission then you need to add exclusions in the backup pipeline `pipelines\intune-backup.yml`. For example to exclude Conditional Access:
  For Intune data add the folowing permissions:
  - DeviceManagementApps.ReadWrite.All
  - DeviceManagementConfiguration.ReadWrite.All
  - DeviceManagementServiceConfig.ReadWrite.All
  - DeviceManagementManagedDevices.ReadWrite.All
  - DeviceManagementRBAC.ReadWrite.All
  - Group.Read.All
  - Policy.Read.All
  - Application.Read.All

  In `pipelines\intune-backup.yml` add ConditionalAccess to the --exclude parameter (parameters are case sensitive and need to be seperated by a space.)

##### Change Default branch name
Azure DevOps uses `master` as default branch name for new repositories. The pipelines in this project use `main` as default.
To change the default in Azure DevOps:
- Go to your **Azure DevOps project**.
- Navigate to **Project settings** > **Repositories**.
- Go to **Settings**
- Toggle **Default branch name for new repositories** to **On**
- Change the default branch name from `master` to `main`.

##### Configure Environment
- On the Windows Server or Client (but also on you local machine if you want to edit the repository from there), change Git config to allow long filepaths. This fixes potential issues with too long paths.
Open a Powershell window as Administrator (Powershell 7 or 5), and execute the following:
`git config --system core.longpaths true`
- Create a new Azure DevOps repository, and copy all files and folders from this repository (excluded the .git folder) to your newly created repository.
- Update `.vscode\settings.json` as needed.
- Make sure that you create a Variable Group in Azure DevOps under Library which contains the following variables:
   - USER_NAME = "IntuneCD"
   - USER_EMAIL = "IntuneCD@`[yourdomain.com]`"
   - TENANT_NAME = "`[tenant.yourdomain.com]`"
   - TENANT_ID = "`[TenantID]`"
   - CLIENT_ID = "`[ClientID]`" (Store the Application ID here for the App Registration that you've just created)
   - IntuneCDVersion = "==2.4.1b5" (Which IntuneCD version to use)
   - serviceconnection = "`[serviceconnection]`" (Optional, needed for retrieving KeyVault Secrets)
   - keyvault = "`[keyvault]`" (Optional, needed for retrieving KeyVault Secrets)
- Add the secret for the created App Registration as a secret to the Variable Group, or more secure: add it to a keyvault. If you choose keyvault, uncomment the KeyVault section in both `pipelines\intune-backup.yml` and `pipelines\intune-restore.yml`.
   - CLIENT_SECRET = "`[ClientSecret]`"
- Update the files `pipelines\intune-backup.yml` and `pipelines\intune-restore.yml` replace `##INSERT_YOUR_VARIABLE_GROUP_NAME##` with the name of your variable group (that you've just created), replace `##INSERT_YOUR_AGENT_POOL_NAME##` with the name of the pool that contains your Azure DevOps Agents.
- *If you choose different names for the variables stored in the Variable Group and KeyVault, be sure to update the names on the right side of the env: section in the pipeline files. Leave the left side unchanged, otherwise IntuneCD breaks.*
- Commit changes.

##### Set Up Pipelines
- Configure the `intune-backup.yml` and `intune-restore.yml` pipelines in Azure DevOps.

##### Granting Permissions to Azure DevOps Pipeline Identity
To allow your Azure DevOps pipeline to commit and push changes to the repository, follow these steps to assign the necessary permissions:

- Go to your **Azure DevOps project**.
- Navigate to **Project settings** > **Repositories**.
- Select the repository your pipeline is working with.
- Click on **Security**.

Next locate the Pipeline Identity. Search for one of the following identities:
- `Project Collection Build Service (<your project name>)`
- or `Build Service (<your project name>)`

Assign the Following Permissions:

| Permission       | Status     | Notes                                 |
|------------------|------------|----------------------------------------|
| **Contribute**   | ✅ Allow   | Required to commit and push changes    |
| **Create branch**| ✅ Allow   | Optional, needed if pipeline creates branches |
| **Create tag**   | ✅ Allow   | Required for tagging commits           |
| **Read**         | ✅ Allow   | Required to read the repository        |

##### Publish Code Wiki
- In Azure DevOps go to Overview > Wiki.
- If no Wiki is present you'll first have to create a project Wiki page. To do this simply fill in a title for the page and click save (for example `Wiki`).
- Click on the Wiki name you've just created to expand the Wiki menu, click on Publish Code Wiki.
- Select the Repository you've created, and select the folder `prod-documentation` and click save.
- After running the `intune-backup.yml` from Azure DevOps, the generated (and converted) documentation is shown here in the published code wiki.

##### Configuring Branch Policies
*Optional but recommended, mainly to make the restore process more controllable.*
During normal use, the only reason for a user to make changes manually to the repository would be to copy a backed up policy file to it's corresponding location in `prod-restore` for restoring it (see below for restore instructions). Because restoring the wrong policy can do harm, it makes sense to review these changes before they are applied to the `main` branch (and can be restored by running the `intune-restore.yml` pipeline).

    ##### Configure in Azure DevOps UI

    - Go to **Project Settings > Repositories > [Your Repo] > Branches**
    - Find the `main` branch, click **... > Branch Policies**
    - Configure:
      - Require a minimum number of reviewers (e.g., 1 or 2)
      - Require linked work items
      - Require comments to be resolved
      - Limit merge types (squash only, *this results in a single commit being added to the `main` branch*)
      - Optional: enable auto-reviewers

## Usage

##### Backing Up Intune Configurations
Run the `intune-backup.yml` pipeline in Azure DevOps to back up configurations to the `prod-backup` folder.
The `intune-backup.yml` pipeline automatically generates markdown documentation from the backup. It creates documentation files in the `prod-documentation` folder.

##### Restoring Configurations
Follow these steps carefully to ensure a smooth restore process:

1. **Create a New Branch**
- Start by creating a new branch from the `main` branch. This ensures your changes are isolated. Use a meaningful naming convention for the branch. For example: `restore/M23002333` (reference to a ticket) or `restore/name-of-policy`.

2. **Locate the File to Restore**
- Use the **Timeline** feature in VSCode to find the historic version of the file in `prod-backup` that contains the settings you want to restore.

3. **Place the File in `prod-restore`**
- Copy the file to the corresponding `prod-restore` subfolder. Ensure it is placed in the same location as it was saved in `prod-backup`.

4. **Verify File Placement**
- Double-check that the file in `prod-restore` is in the exact same location as it was in `prod-backup`.
- For some items (e.g., proactive remediations), you may need to restore multiple files (e.g., a file in `script data` and another in the directory above).

5. **Verify File Contents**
- Confirm that the file in `prod-restore` contains the changes you want restored.

6. **Commit and Sync Changes**
- Commit your changes to the branch you created.
- Sync your branch and open a pull request to merge it with `main`.
- In the pull request description, explain what you are restoring and why.
- In the pull request description, specify if you would like to restore assignments as well (default = `false`).

7. **Review and Approval**
- During review make sure that all the files located in `prod-restore` contain the settings and assignments that you would like to restore (assignments are only restored when you enable the UpdateAssignments parameter when running the `intune-restore.yml` pipeline).

8. **Run Restore Pipeline**
- Run the `intune-restore.yml` pipeline manually and specify if you would like to update assignments during restore by selecting the UpdateAssignments parameter in the pipeline.
- The pipeline will restore the files you've placed in `prod-restore` and afterwards remove them from the `prod-restore` folder and the repository.

## Example Screenshots
### Example Screenshots

#### Backup Pipeline Execution
![Backup Pipeline Execution](.img/backup-pipeline-execution.png)
This screenshot shows the successful execution of the `intune-backup.yml` pipeline in Azure DevOps.

#### Restore Pipeline Execution
![Restore Pipeline Execution](.img/restore-pipeline-execution.png)
This screenshot displays the `intune-restore.yml` pipeline restoring configurations from the `prod-restore` folder.

#### Generated Documentation
![Generated Documentation](.img/generated-documentation.png)
An example of the markdown documentation generated by the backup pipeline, formatted for use in an Azure DevOps code Wiki.

#### Published Code Wiki
![Published Code Wiki](.img/published-code-wiki.png)
This screenshot illustrates the published documentation in the Azure DevOps Wiki after running the backup pipeline.

## Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Submit a pull request with a detailed description.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
