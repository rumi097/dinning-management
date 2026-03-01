# 📝 Dining Token Digitalization - Git Cheat Sheet

## 💡 INITIAL SETUP (Do only once)
1. Open an empty project folder
2. Clone the repository:

```bash
git clone https://github.com/sadat2103108/Dining-Token-Digitalization.git .
```

---

## 🚀 1. Starting Work on a Task

### ✅ Always begin like this

```bash
git checkout develop
git pull origin develop
git checkout -b feature/<task-name>
```

**Example:**

```bash
git checkout -b feature/token-api
```

✔ Ensures your branch starts from the latest code
🚫 Never start a new feature directly in `develop` branch

---

## 💻 2. While Coding

### ✅ Save work frequently

```bash
git add .
git commit -m "feat: implement token purchase logic"
```

✔ Make small, frequent commits
🚫 Don’t wait hours to commit, avoid huge commits

---

## 🔄 3. If `develop` updated while you are mid-task

### ✅ Steps to safely update your branch

**i. Save your work**  
If you have uncommitted changes:

```bash
git add .
git commit -m "WIP: save current progress"

```

**ii. Switch to develop and pull latest**

```bash
git checkout develop
git pull origin develop
```

**iii. Switch back to your feature branch**

```bash
git checkout feature/<task-name>
```

**iv. Update your branch**

**Option 1: Merge develop into your branch**

```bash
git merge develop
```

If conflicts appear:

* Fix conflicts manually
* Then:

```bash
git add .
git commit -m "merge develop into feature/<task-name>"
```


✔ Keeps your branch up-to-date
✔ Prevents future PR conflicts
✔ Safe even with uncommitted code

**Important:**

* Never write new features directly in `develop`.
* Always finish WIP commits or stash before updating.
* Always make sure `develop` is stable before starting new tasks.

---



## 📤 4. Push Your Branch

```bash
git push origin feature/<task-name>
```

Then open Pull Request → target branch: **`develop`**

---

## 🔍 5. Before Opening PR — CHECKLIST

* [ ] App runs locally
* [ ] No debug prints/logs
* [ ] Code formatted properly
* [ ] No commented-out/junk code
* [ ] DB changes included (if needed)
* [ ] Tested feature manually
* [ ] Latest `develop` merged into branch

Only then open a PR.

---

## 🧪 6. After PR Approved & Merged

### ✅ Clean up locally

```bash
git checkout develop
git pull
git branch -d feature/<task-name>
```

✔ Keeps repo clean
✔ Prevents confusion

---

## 🛠️ 7. Fixing a Bug

```bash
git checkout develop
git pull
git checkout -b fix/<bug-name>
```

**Example:**

```bash
git checkout -b fix/qr-expiry
```

---

## 🔥 8. Emergency Hotfix (build broken)

```bash
git checkout develop
git pull
git checkout -b hotfix/<issue>
```

Fix → PR → merge fast

---

## 📦 9. Most Used Commands Summary

| **Task**                  | **Command**                      |
| ------------------------- | -------------------------------- |
| Pull latest code          | `git pull origin develop`        |
| Create branch             | `git checkout -b feature/<name>` |
| Save work                 | `git add .`                      |
| Commit                    | `git commit -m "message"`        |
| Push branch               | `git push origin branch`         |
| Merge develop into branch | `git merge develop`              |
| Delete branch             | `git branch -d <name>`           |

---

## 🧠 10. Team Golden Rules

✔ One task = one branch
✔ Always branch from `develop`
✔ Always merge/rebase `develop` before PR
✔ Never push directly to `develop`
✔ Never force push
✔ If asked to pull latest `develop` while mid-work:

* Commit your current work
* Merge or rebase carefully
* Never start writing new code in `develop` branch

---

## ⚠️ Tips for Mid-Work Pull

1. **Commit your current progress**: never leave changes uncommitted.
2. **Switch to develop and pull latest**:

```bash
git checkout develop
git pull origin develop
```

3. **Switch back to your feature branch**:

```bash
git checkout feature/<task-name>
```

4. **Merge or rebase develop into your branch**:

```bash
git merge develop
# or git rebase origin/develop
```

5. **Resolve conflicts carefully**
6. Continue coding on your feature branch

> ⚠ Never start writing code directly in `develop`. Always use a separate branch.

