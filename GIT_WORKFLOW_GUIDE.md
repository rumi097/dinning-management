# Git & GitHub Team Workflow Guide

> **Project**: DSI RUET — 8-member team  
> **Your role**: Backend team — Marketplace module  
> **Main branch**: `develop`  
> **Strategy**: Feature branches → Pull Requests → Merge to `develop`

---

## Table of Contents

1. [First-Time Setup](#1-first-time-setup)
2. [Branch Strategy](#2-branch-strategy)
3. [Daily Workflow — Step by Step](#3-daily-workflow--step-by-step)
4. [Committing Your Code](#4-committing-your-code)
5. [Pushing & Creating Pull Requests](#5-pushing--creating-pull-requests)
6. [Handling Merge Conflicts](#6-handling-merge-conflicts)
7. [Staying Updated with `develop`](#7-staying-updated-with-develop)
8. [Code Review Process](#8-code-review-process)
9. [Common Scenarios & Commands](#9-common-scenarios--commands)
10. [Commit Message Convention](#10-commit-message-convention)
11. [Branch Naming Convention](#11-branch-naming-convention)
12. [Golden Rules](#12-golden-rules)
13. [Quick Reference Card](#13-quick-reference-card)

---

## 1. First-Time Setup

### 1.1 — Configure your identity (do this ONCE on your machine)

```bash
git config --global user.name "Ali Azgor Rumi"
git config --global user.email "rumi@student.ruet.ac.bd"
```

### 1.2 — Clone the repository (if you haven't already)

```bash
cd ~/Development
git clone https://github.com/YOUR_ORG/checking.git
cd checking
```

Or if you already have the repo and need to add the remote:

```bash
cd ~/Development/checking
git remote add origin https://github.com/YOUR_ORG/checking.git
```

### 1.3 — Verify your setup

```bash
git remote -v
# Should show:
# origin  https://github.com/YOUR_ORG/checking.git (fetch)
# origin  https://github.com/YOUR_ORG/checking.git (push)
```

### 1.4 — Switch to the develop branch

```bash
git checkout develop
git pull origin develop
```

If `develop` doesn't exist locally yet:

```bash
git checkout -b develop origin/develop
```

### 1.5 — Set develop as your default upstream

```bash
git branch --set-upstream-to=origin/develop develop
```

Now `git pull` on `develop` automatically pulls from `origin/develop`.

---

## 2. Branch Strategy

```
main (production — DO NOT touch directly)
 │
 └── develop (team integration branch — all features merge here)
      │
      ├── feature/marketplace-core         ← Your feature branches
      ├── feature/marketplace-reject
      ├── feature/marketplace-countdown
      ├── feature/auth-jwt                 ← Another team member's branch
      ├── feature/wallet-topup             ← Another team member's branch
      ├── fix/marketplace-timeout-bug      ← Bug fix branch
      └── ...
```

### Rules

| Branch | Who pushes | How |
|--------|-----------|-----|
| `main` | Team lead only | Merge from `develop` when ready for release |
| `develop` | Everyone | Via Pull Requests only — **NEVER push directly** |
| `feature/*` | You | Push freely, create PR when done |
| `fix/*` | You | Same as feature, but for bug fixes |

---

## 3. Daily Workflow — Step by Step

### Step 1: Start your day — pull latest `develop`

```bash
# Make sure you're on develop
git checkout develop

# Pull latest changes from all teammates
git pull origin develop
```

### Step 2: Create a new feature branch

```bash
# Create and switch to a new branch FROM develop
git checkout -b feature/marketplace-sell-post develop
```

> **Name your branch** based on what you're working on. See [naming conventions](#11-branch-naming-convention).

### Step 3: Do your work

Write code, test it, make sure it compiles:

```bash
cd backend
./mvnw compile
```

### Step 4: Check what you changed

```bash
# See which files changed
git status

# See exact line changes
git diff

# See changes for a specific file
git diff src/main/java/dsi/ruet/backend/marketplace/MarketplaceService.java
```

### Step 5: Stage your changes

```bash
# Stage specific files (RECOMMENDED — be intentional)
git add backend/src/main/java/dsi/ruet/backend/marketplace/MarketplaceService.java
git add backend/src/main/java/dsi/ruet/backend/marketplace/MarketplaceController.java

# OR stage all changes in the marketplace module
git add backend/src/main/java/dsi/ruet/backend/marketplace/

# OR stage everything (use carefully)
git add .
```

### Step 6: Commit

```bash
git commit -m "feat(marketplace): add sell post endpoint with validation"
```

### Step 7: Push your branch to GitHub

```bash
# First push — sets upstream tracking
git push -u origin feature/marketplace-sell-post

# Subsequent pushes — just this
git push
```

### Step 8: Create a Pull Request on GitHub

1. Go to your GitHub repo in the browser
2. You'll see a banner: "feature/marketplace-sell-post had recent pushes — **Compare & pull request**"
3. Click it
4. Set **base branch** to `develop` (NOT main!)
5. Write a description of what you did
6. Request review from your teammates
7. Click **Create pull request**

### Step 9: After PR is approved and merged

```bash
# Switch back to develop
git checkout develop

# Pull the merged code
git pull origin develop

# Delete your old feature branch (cleanup)
git branch -d feature/marketplace-sell-post

# Also delete it from GitHub
git push origin --delete feature/marketplace-sell-post
```

### Step 10: Start next feature

```bash
git checkout -b feature/marketplace-buy-request develop
# ... repeat from Step 3
```

---

## 4. Committing Your Code

### 4.1 — What to stage (and what NOT to)

```bash
# ✅ GOOD — stage only your source code
git add backend/src/main/java/dsi/ruet/backend/marketplace/

# ✅ GOOD — stage specific files
git add backend/src/main/java/dsi/ruet/backend/marketplace/MarketplaceService.java
git add backend/src/main/java/dsi/ruet/backend/marketplace/MarketplaceController.java

# ❌ BAD — never stage build artifacts
# git add backend/target/        ← NO! (.gitignore should block this)
# git add frontend/build/        ← NO!

# ❌ BAD — never stage IDE configs
# git add .idea/                 ← NO!
# git add .vscode/               ← NO!
```

### 4.2 — Review before committing

```bash
# See what's staged (will be committed)
git diff --staged

# See what's NOT staged (won't be committed)
git diff

# See a summary
git status
```

### 4.3 — Make small, logical commits

Don't put everything in one giant commit. Split by logical unit:

```bash
# Commit 1: Entity + Repository
git add backend/src/main/java/dsi/ruet/backend/marketplace/MarketplacePost.java
git add backend/src/main/java/dsi/ruet/backend/marketplace/MarketplaceRepository.java
git commit -m "feat(marketplace): add MarketplacePost entity and repository"

# Commit 2: Service layer
git add backend/src/main/java/dsi/ruet/backend/marketplace/MarketplaceService.java
git commit -m "feat(marketplace): implement marketplace service with sell/buy logic"

# Commit 3: Controller
git add backend/src/main/java/dsi/ruet/backend/marketplace/MarketplaceController.java
git commit -m "feat(marketplace): add REST controller with 9 endpoints"

# Commit 4: DTOs and exception
git add backend/src/main/java/dsi/ruet/backend/marketplace/dto/
git add backend/src/main/java/dsi/ruet/backend/marketplace/exception/
git commit -m "feat(marketplace): add DTOs and custom exception"
```

### 4.4 — Amend a commit (fix last commit before pushing)

```bash
# Made a typo? Forgot a file? Fix it:
git add backend/src/main/java/dsi/ruet/backend/marketplace/MarketplaceService.java
git commit --amend -m "feat(marketplace): implement marketplace service with sell/buy/reject logic"
```

> ⚠ **Only amend commits you haven't pushed yet.** If already pushed, make a new commit instead.

---

## 5. Pushing & Creating Pull Requests

### 5.1 — Push your feature branch

```bash
# First time pushing this branch
git push -u origin feature/marketplace-sell-post

# After that, just
git push
```

### 5.2 — Create a Pull Request (PR)

**On GitHub** → go to the repository → click **"Pull Requests"** → **"New pull request"**

Set:
- **base**: `develop`  ← where your code will merge INTO
- **compare**: `feature/marketplace-sell-post`  ← your branch

### 5.3 — PR description template

Use this template when creating PRs:

```markdown
## What does this PR do?
- Implements the sell-post endpoint for the marketplace module
- Adds MarketplacePost entity, repository, service, and controller
- Adds 5 validations (ownership, status, hall, duplicate, self-buy)

## Changes
- `marketplace/MarketplacePost.java` — new entity
- `marketplace/MarketplaceRepository.java` — 6 custom JPQL queries
- `marketplace/MarketplaceService.java` — 12 public methods
- `marketplace/MarketplaceController.java` — 9 REST endpoints
- `marketplace/MarketplaceScheduler.java` — 15-min timeout auto-rollback

## How to test
1. Start backend: `cd backend && ./mvnw spring-boot:run`
2. Sell a token: `curl -X POST http://localhost:8080/api/v1/marketplace/sell -H "X-User-Id: 1" -H "Content-Type: application/json" -d '{"tokenId": 1}'`
3. Browse: `curl http://localhost:8080/api/v1/marketplace -H "X-User-Id: 3"`

## Checklist
- [x] Code compiles (`./mvnw compile`)
- [x] Tested endpoints via curl
- [x] No hardcoded credentials
- [ ] Unit tests (pending)
```

### 5.4 — Request reviewers

On the PR page, use the right sidebar to request review from your backend teammates. At least 1 approval should be required before merging.

### 5.5 — Merge the PR

After approval:
1. Click **"Squash and merge"** (recommended — keeps develop history clean)
2. Or click **"Merge pull request"** (preserves all your individual commits)
3. Delete the branch when prompted

---

## 6. Handling Merge Conflicts

### When do conflicts happen?

When two people edit the **same lines** in the **same file**. For example, both you and a teammate modified `Token.java`.

### 6.1 — Update your branch before creating a PR

```bash
# You're on your feature branch
git checkout feature/marketplace-sell-post

# Fetch latest from GitHub
git fetch origin

# Rebase your branch on top of latest develop
git rebase origin/develop
```

### 6.2 — If there's a conflict during rebase

Git will pause and tell you which files have conflicts:

```
CONFLICT (content): Merge conflict in backend/src/main/java/dsi/ruet/backend/models/Token.java
```

**Step 1**: Open the file — you'll see conflict markers:

```java
<<<<<<< HEAD (your changes)
    @Column(nullable = false)
    private TokenStatus status;
=======
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TokenStatus status;
>>>>>>> origin/develop (their changes)
```

**Step 2**: Decide which version to keep (or combine both). Remove the markers:

```java
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TokenStatus status;
```

**Step 3**: Mark as resolved and continue

```bash
git add backend/src/main/java/dsi/ruet/backend/models/Token.java
git rebase --continue
```

**If you want to abort and start over**:

```bash
git rebase --abort
```

### 6.3 — Alternative: Merge instead of rebase

If rebase feels scary, you can merge instead:

```bash
git checkout feature/marketplace-sell-post
git merge origin/develop
# Resolve conflicts if any
git add .
git commit -m "merge: sync with latest develop"
git push
```

### Rebase vs Merge — When to use which

| Approach | When to use | Result |
|----------|------------|--------|
| `git rebase origin/develop` | Before creating a PR (cleaner history) | Your commits sit ON TOP of latest develop |
| `git merge origin/develop` | When your branch is shared with others, or rebase is confusing | Creates a merge commit |

---

## 7. Staying Updated with `develop`

### 7.1 — Daily sync (do this every morning)

```bash
# Switch to develop
git checkout develop

# Pull all new changes
git pull origin develop

# Switch back to your feature branch
git checkout feature/marketplace-your-current-work

# Bring develop's changes into your branch
git rebase origin/develop
# OR
git merge origin/develop
```

### 7.2 — Quick sync without switching branches

```bash
# Fetch without switching (just downloads, doesn't apply)
git fetch origin

# Then rebase your current branch onto the latest develop
git rebase origin/develop
```

### 7.3 — See what teammates pushed

```bash
# See recent commits on develop
git log origin/develop --oneline -10

# See what changed compared to your branch
git log feature/marketplace-sell-post..origin/develop --oneline
```

---

## 8. Code Review Process

### As a PR author (you)

1. Push your branch and create a PR
2. Write a clear description (use the template above)
3. Request review from at least 1 backend teammate
4. Respond to review comments — either fix the code or explain your reasoning
5. After fixing, push your changes (they auto-update the PR):
   ```bash
   git add .
   git commit -m "fix: address review comments — add null check"
   git push
   ```
6. Re-request review if needed

### As a reviewer (when reviewing teammate's PR)

1. Go to the PR on GitHub
2. Click **"Files changed"** tab
3. Read through the code
4. Leave comments on specific lines by clicking the `+` next to the line number
5. When done, click **"Review changes"** → choose:
   - **Approve** ✅ — code looks good
   - **Request changes** ❌ — needs fixes
   - **Comment** 💬 — general feedback, no decision

### What to look for in a backend review

- [ ] Does it compile? (`./mvnw compile`)
- [ ] Is the logic correct? (validations, edge cases)
- [ ] Are `@Transactional` boundaries correct?
- [ ] Are there N+1 query issues? (should use JOIN FETCH)
- [ ] Are error messages helpful?
- [ ] Are there hardcoded values that should be configurable?
- [ ] Does it follow the project's package structure?

---

## 9. Common Scenarios & Commands

### Scenario 1: "I started coding on `develop` by accident!"

```bash
# Save your changes to a temporary stash
git stash

# Create the correct feature branch
git checkout -b feature/marketplace-new-feature develop

# Get your changes back
git stash pop
```

### Scenario 2: "I want to undo my last commit (haven't pushed)"

```bash
# Undo commit but KEEP your code changes
git reset --soft HEAD~1

# Now your changes are staged again — you can re-commit with a better message
git commit -m "better commit message"
```

### Scenario 3: "I want to discard all my uncommitted changes"

```bash
# ⚠ DESTRUCTIVE — throws away all changes
git checkout -- .

# Or for a specific file
git checkout -- backend/src/main/java/dsi/ruet/backend/marketplace/MarketplaceService.java
```

### Scenario 4: "I want to see what a teammate did"

```bash
# Fetch their branch
git fetch origin

# See their branch locally
git log origin/feature/auth-jwt --oneline -10

# Or check out their branch to test it
git checkout -b auth-jwt-review origin/feature/auth-jwt
```

### Scenario 5: "I need to work on two features at the same time"

```bash
# Save current work
git stash -m "marketplace sell post - work in progress"

# Switch to a different branch
git checkout -b feature/marketplace-scheduler develop

# ... do work, commit, push ...

# Go back to your original branch
git checkout feature/marketplace-sell-post

# Restore your saved work
git stash pop
```

### Scenario 6: "I pushed something wrong and want to undo"

```bash
# Create a NEW commit that undoes the bad one (safe for shared branches)
git revert HEAD
git push
```

### Scenario 7: "My branch is way behind develop and has tons of conflicts"

```bash
# Nuclear option: create a new branch and cherry-pick your commits

# First, note your commit hashes
git log --oneline -5
# Example output:
# a1b2c3d feat(marketplace): add scheduler
# e4f5g6h feat(marketplace): add service
# i7j8k9l feat(marketplace): add entity

# Create fresh branch from latest develop
git checkout -b feature/marketplace-v2 origin/develop

# Cherry-pick your commits (oldest first)
git cherry-pick i7j8k9l
git cherry-pick e4f5g6h
git cherry-pick a1b2c3d
```

### Scenario 8: "I want to see the difference between my branch and develop"

```bash
# See all files that differ
git diff develop..feature/marketplace-sell-post --name-only

# See full diff
git diff develop..feature/marketplace-sell-post
```

### Scenario 9: "I accidentally committed a file I shouldn't have (like .env)"

```bash
# Remove it from git tracking (keeps the file on disk)
git rm --cached .env
git commit -m "chore: remove .env from tracking"
git push

# Make sure it's in .gitignore
echo ".env" >> .gitignore
git add .gitignore
git commit -m "chore: add .env to gitignore"
git push
```

---

## 10. Commit Message Convention

Use the **Conventional Commits** format:

```
type(scope): short description
```

### Types

| Type | When to use | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(marketplace): add sell post endpoint` |
| `fix` | Bug fix | `fix(marketplace): handle null buyer in confirm` |
| `refactor` | Code restructure (no behavior change) | `refactor(marketplace): extract validation helpers` |
| `docs` | Documentation | `docs: add marketplace API documentation` |
| `test` | Tests | `test(marketplace): add unit tests for sell logic` |
| `chore` | Build/tooling changes | `chore: update spring boot to 4.0.3` |
| `style` | Formatting (no logic change) | `style: fix indentation in MarketplaceService` |

### Scope (optional but recommended)

For your work, the scope is usually `marketplace`:

```bash
git commit -m "feat(marketplace): add reject buy request endpoint"
git commit -m "fix(marketplace): fix 15-min timeout calculation"
git commit -m "feat(models): add MarketplacePostStatus enum"
git commit -m "feat(seeder): add demo data for marketplace testing"
```

### Multi-line commit messages (for important commits)

```bash
git commit -m "feat(marketplace): implement token transfer confirmation

- Atomic operation: token ownership + post status + transaction record
- Double-checks buyer doesn't already own the meal token
- Rolls back to OPEN if buyer acquired token since request
- Creates TokenTransaction audit record"
```

---

## 11. Branch Naming Convention

```
type/module-short-description
```

### Examples for your work

```bash
# Features
feature/marketplace-core              # Initial marketplace setup
feature/marketplace-sell-post         # Sell token endpoint
feature/marketplace-buy-request       # Buy request flow
feature/marketplace-confirm-transfer  # Transfer confirmation
feature/marketplace-scheduler         # 15-min timeout scheduler
feature/marketplace-reject            # Seller reject option
feature/marketplace-countdown-timer   # Frontend countdown

# Bug fixes
fix/marketplace-timeout-bug
fix/marketplace-null-buyer

# Refactoring
refactor/marketplace-extract-validators

# Documentation
docs/marketplace-api-guide
```

---

## 12. Golden Rules

### ✅ DO

1. **Always branch from `develop`** — never from `main` or another feature branch
2. **Pull `develop` daily** — before starting new work
3. **Make small, frequent commits** — one logical change per commit
4. **Write clear commit messages** — your teammates will read them
5. **Create PRs for everything** — even small changes
6. **Test before pushing** — at minimum, `./mvnw compile`
7. **Review teammates' PRs** — within 24 hours

### ❌ DON'T

1. **Never push directly to `develop`** — always use PRs
2. **Never push directly to `main`** — that's for releases only
3. **Never commit build artifacts** — `target/`, `build/`, `node_modules/`
4. **Never commit secrets** — `.env`, passwords, API keys
5. **Never force-push to shared branches** — `git push --force` on `develop` = disaster
6. **Never leave a WIP branch for days** — merge or update regularly
7. **Never ignore merge conflicts** — resolve them carefully

### ⚠ SAFETY

```bash
# Force push is ONLY okay on YOUR OWN feature branches
git push --force-with-lease  # Safer than --force

# NEVER do this on develop or main:
# git push --force origin develop   ← NEVER EVER
```

---

## 13. Quick Reference Card

### Starting new work

```bash
git checkout develop
git pull origin develop
git checkout -b feature/marketplace-your-feature develop
```

### Saving your work

```bash
git add backend/src/main/java/dsi/ruet/backend/marketplace/
git commit -m "feat(marketplace): description of change"
git push -u origin feature/marketplace-your-feature
```

### Syncing with team

```bash
git fetch origin
git rebase origin/develop
```

### After PR is merged

```bash
git checkout develop
git pull origin develop
git branch -d feature/marketplace-your-feature
```

### Emergency commands

```bash
git stash                    # Save work temporarily
git stash pop                # Restore saved work
git reset --soft HEAD~1      # Undo last commit (keep changes)
git revert HEAD              # Undo last commit (safe for pushed code)
git rebase --abort           # Cancel a rebase gone wrong
git log --oneline -10        # See recent history
git diff --name-only         # See which files changed
```

---

## Your Specific Workflow for the Marketplace Module

Since you're working on the backend marketplace module, here's your **exact flow** for uploading the code you already wrote:

### Step 1: Initialize git (if not done)

```bash
cd ~/Development/checking

# If git isn't initialized yet
git init
git remote add origin https://github.com/YOUR_ORG/checking.git
```

### Step 2: Make sure develop exists

```bash
# If develop doesn't exist yet, create it
git checkout -b develop

# If it exists on GitHub already
git fetch origin
git checkout develop
git pull origin develop
```

### Step 3: Create your feature branch

```bash
git checkout -b feature/marketplace-core develop
```

### Step 4: Stage ONLY your marketplace files

```bash
# Shared models and repos (needed by marketplace)
git add backend/src/main/java/dsi/ruet/backend/models/
git add backend/src/main/java/dsi/ruet/backend/repositories/

# Your marketplace module
git add backend/src/main/java/dsi/ruet/backend/marketplace/

# Common utilities
git add backend/src/main/java/dsi/ruet/backend/common/

# Seeder
git add backend/src/main/java/dsi/ruet/backend/seeder/DataSeeder.java

# Config
git add backend/src/main/resources/application.properties

# Main app class
git add backend/src/main/java/dsi/ruet/backend/BackendApplication.java

# Build file
git add backend/pom.xml
```

### Step 5: Commit in logical chunks

```bash
# Commit 1: Foundation
git add backend/src/main/java/dsi/ruet/backend/models/
git add backend/src/main/java/dsi/ruet/backend/repositories/
git commit -m "feat(models): add all entity models, enums, and repositories

- Hall, User, Wallet, StudentInfo, Meal, Token, CoinTransaction, TokenTransaction
- Role, MealType, TokenStatus, TransactionType, MarketplacePostStatus enums
- 6 JPA repositories with custom queries"

# Commit 2: Common utilities
git add backend/src/main/java/dsi/ruet/backend/common/
git commit -m "feat(common): add ApiResponse wrapper, CORS config, and global exception handler"

# Commit 3: Marketplace module
git add backend/src/main/java/dsi/ruet/backend/marketplace/
git commit -m "feat(marketplace): implement complete marketplace module

- MarketplacePost entity with lifecycle (OPEN → PENDING → COMPLETED)
- 6 custom JPQL queries with JOIN FETCH
- Service with 12 methods: sell, buy-request, confirm, reject, cancel, timeout
- Controller with 9 REST endpoints under /api/v1/marketplace
- 15-minute timeout scheduler
- SellRequest and MarketplacePostResponse DTOs
- Custom MarketplaceException"

# Commit 4: Seeder + config
git add backend/src/main/java/dsi/ruet/backend/seeder/
git add backend/src/main/resources/application.properties
git add backend/src/main/java/dsi/ruet/backend/BackendApplication.java
git commit -m "feat(seeder): add demo data seeder with 2 halls, 4 users, 2 meals, 3 tokens"
```

### Step 6: Push and create PR

```bash
git push -u origin feature/marketplace-core
```

Then go to GitHub → create PR → base: `develop` → write description → request reviews.

---

## Appendix: Useful Git Aliases

Add these to your `~/.gitconfig` for faster typing:

```bash
git config --global alias.s "status"
git config --global alias.co "checkout"
git config --global alias.br "branch"
git config --global alias.cm "commit -m"
git config --global alias.lg "log --oneline --graph --all -20"
git config --global alias.last "log -1 --stat"
git config --global alias.unstage "reset HEAD --"
```

Now you can use:

```bash
git s                    # instead of git status
git co develop           # instead of git checkout develop
git br                   # instead of git branch
git cm "message"         # instead of git commit -m "message"
git lg                   # pretty history graph
git last                 # see last commit details
```

---

*This guide is specific to the DSI RUET project's Git workflow. For general Git help: https://git-scm.com/doc*
