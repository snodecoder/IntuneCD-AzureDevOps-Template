## 🔄 Restore Request

This pull request is intended to restore configuration files from the `prod-backup` folder into `prod-restore`. After pull request is completed, these configuration files will be restored to Intune. Finally the configuration files will be removed from `prod-restore`.

---

### 📋 Summary

- **What is being restored?**
  _Describe the configuration or files being restored._

- **Why is this being restored?**
  _Explain the reason for the restore (e.g., rollback, correction, etc.)._

- **Restore assignments as well?**
  _Yes / No (default = No)_

---

### ✅ Restore Checklist

Please confirm the following steps have been completed:

- [ ] A new branch was created from `main`.
- [ ] The correct file(s) were located using the **Timeline** feature in VSCode.
- [ ] File(s) were copied to the correct subfolder in `prod-restore`, matching the original structure in `prod-backup`.
- [ ] File placement was double-checked.
- [ ] File contents were verified to match the intended restore state.
- [ ] Changes were committed and pushed to this branch.
- [ ] This pull request includes a clear explanation of what and why.

---

### 🧪 Review Notes

- Ensure all files in `prod-restore` are correct and complete.
- If assignments should be restored, confirm that the `UpdateAssignments` parameter will be set when running the pipeline.

---

### 🚀 Restore Execution

After approval:

- Run the `intune-restore.yml` pipeline manually.
- Set the `UpdateAssignments` parameter as needed.
- The pipeline will restore the files and automatically clean up the `prod-restore` folder.
