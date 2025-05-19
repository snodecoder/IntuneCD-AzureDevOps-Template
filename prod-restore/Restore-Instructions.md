# Restore Instructions
Follow these steps carefully to ensure a smooth restoration process:

1. **Create a New Branch**
    - Start by creating a new branch from the `main` branch. This ensures your changes are isolated.

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
    - In the pull request description, specify if you would like to restore assignments as well (default = false).

7. **Review and Approval**
    - During review make sure that all the files located in `prod-restore` contain the settings and assignments that you would like to restore (assignments are only restored when you enable the UpdateAssignments parameter when running the `intune-restore.yml` pipeline).

8. **Run Restore Pipeline**
   - Run the `intune-restore.yml` pipeline manually and specify if you would like to update assignments during restore by selecting the UpdateAssignments parameter in the pipeline.
   - The pipeline will restore the files you've placed in `prod-restore` and afterwards remove them from the `prod-restore` folder and the repository.
