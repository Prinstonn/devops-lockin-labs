# Day 3 — Git & GitHub

## 1. Git Fundamentals

Practiced the core Git workflow:

**Working Directory → Staging Area → Commit History**

### Important Commands

```bash
git status
git diff
git diff --staged
git add <file>
git commit -m "message"
git log --oneline
```

### Key Difference

- `git diff` compares the working directory against the staging area.
- `git diff --staged` compares the staging area against the latest commit (`HEAD`).
- A commit records the staged snapshot, not every modification currently present in the working directory.

---

## 2. Branching

Created feature branches to isolate work from `main`.

Example:

```bash
git switch -c feature/git-health-check
```

Created a Bash health-check script and committed it on the feature branch.

A branch is a movable reference to a commit. Creating a branch allows new work to progress independently without immediately modifying `main`.

---

## 3. Fast-Forward Merge

Merged a feature branch where `main` had not received independent commits since the branch was created.

In this situation, Git could move the `main` pointer forward without creating a merge commit.

### Concept

```text
Before:

A---B  main
     \
      C---D  feature

After fast-forward:

A---B---C---D
            main
            feature
```

---

## 4. Merge Conflict Lab

Created conflicting changes to `environment.conf`.

The feature branch configured:

```text
ENVIRONMENT=staging
```

while `main` configured:

```text
ENVIRONMENT=production
```

Git could not automatically determine which version should win and produced a merge conflict.

### Conflict Markers

```text
<<<<<<< HEAD
ENVIRONMENT=production
=======
ENVIRONMENT=staging
>>>>>>> feature/conflict-lab
```

Resolved the conflict manually, staged the resolved file, and completed the merge.

### Lesson

A merge conflict occurs when Git cannot automatically reconcile changes.

`HEAD` represents the currently checked-out commit and normally points through the currently checked-out branch.

---

## 5. Git Recovery

Practiced several Git recovery mechanisms.

### Restore

```bash
git restore <file>
```

Used to discard unstaged changes to a tracked file.

### Unstage

```bash
git restore --staged <file>
```

Removes changes from the staging area while preserving them in the working directory.

### Soft Reset

```bash
git reset --soft HEAD~1
```

Moves the branch pointer backward while keeping the removed commit's changes staged.

### Mixed Reset

```bash
git reset HEAD~1
```

Moves the branch pointer backward while retaining the changes as unstaged working-directory modifications.

### Hard Reset

```bash
git reset --hard HEAD~1
```

Moves the branch pointer and resets the index and tracked working-tree files to the target commit.

### Reflog

```bash
git reflog
```

Used to inspect previous local `HEAD` positions and recover commits that are no longer referenced by the current branch.

### Revert

```bash
git revert <commit>
```

Creates a new commit that reverses an earlier commit while preserving history.

This is generally safer than rewriting already-shared history.

---

## 6. Git Remotes

Configured and worked with the GitHub remote named `origin`.

```bash
git remote -v
git fetch origin
git pull --no-rebase origin main
git push origin main
```

### Important Concepts

- `origin` is the local nickname for a remote repository.
- `main` is a local branch.
- `origin/main` is a local remote-tracking reference representing the last fetched/known state of the remote `main` branch.
- `HEAD` identifies the currently checked-out commit and normally points through the current branch.

### Fetch vs Pull

`git fetch` downloads remote Git objects and updates remote-tracking references without integrating those changes into the current local branch.

`git pull` fetches remote changes and then integrates them into the current branch according to the selected pull strategy.

---

## 7. Remote Divergence

Created a commit directly on GitHub while the local repository had independent commits.

After fetching, Git reported that the branches had diverged:

```text
ahead 9, behind 1
```

This demonstrated that local and remote histories can contain commits the other side does not yet have.

A merge-based pull integrated both histories and created a merge commit.

---

## 8. GitHub SSH Authentication

Configured SSH authentication for GitHub.

Generated an Ed25519 key pair:

```bash
ssh-keygen -t ed25519
```

Added the public key to GitHub and tested authentication:

```bash
ssh -T git@github.com
```

Changed the repository remote from HTTPS to SSH:

```bash
git remote set-url origin git@github.com:Prinstonn/devops-lockin-labs.git
```

### DNS Troubleshooting

SSH initially failed because the VM could not resolve `github.com`.

Network connectivity was verified by successfully reaching an external IP address, while DNS queries through the configured DNS servers failed.

DNS resolution was restored by configuring working DNS resolvers, after which GitHub hostname resolution and SSH authentication succeeded.

This demonstrated an important networking distinction:

> A system can have working IP connectivity while DNS name resolution is broken.

---

## 9. Feature Branch and Pull Request Workflow

Created the feature branch:

```text
feature/deployment-check
```

and developed:

```text
deployment-check.sh
```

The script checks an HTTP endpoint and reports whether the deployment is healthy.

### Example

```bash
./deployment-check.sh http://localhost
```

Successful endpoint:

```text
PASS: Deployment is healthy (HTTP 200)
```

Unreachable endpoint:

```text
FAIL: Unable to connect to http://localhost:9999
```

Successful checks return:

```text
exit code 0
```

Failed checks return:

```text
exit code 1
```

A curl timeout was later added to prevent the health check from waiting indefinitely for an unreachable endpoint.

The branch was published using:

```bash
git push -u origin feature/deployment-check
```

A GitHub Pull Request was then created and reviewed.

A second commit was pushed to the same feature branch, automatically updating the existing Pull Request.

The Pull Request was eventually merged into `main` using a merge commit.

### Workflow Practiced

```text
main
  |
  v
Create feature branch
  |
  v
Develop
  |
  v
Test
  |
  v
Stage
  |
  v
Commit
  |
  v
Push feature branch
  |
  v
Open Pull Request
  |
  v
Review
  |
  v
Make additional change
  |
  v
Retest
  |
  v
Commit + Push
  |
  v
Pull Request updates
  |
  v
Merge into main
```

---

## 10. Synchronizing Local Main

After the Pull Request was merged on GitHub:

```bash
git fetch origin
```

updated:

```text
origin/main
```

but did not automatically move local `main`.

This demonstrated that `origin/main` is a local remote-tracking reference and can move independently from the local `main` branch.

Local `main` was then updated safely with:

```bash
git merge --ff-only origin/main
```

This fast-forwarded local `main` to the already-existing GitHub merge commit.

### Result

```text
HEAD
 |
 v
main
 |
 v
9a5ee13
 ^
 |
origin/main
```

Both local `main` and `origin/main` were synchronized.

---

## 11. Branch Cleanup

Deleted the merged local feature branch:

```bash
git branch -d feature/deployment-check
```

Deleted the remote feature branch:

```bash
git push origin --delete feature/deployment-check
```

Deleting the branch references did not remove the feature commits because those commits were already reachable through `main`.

### Important Concept

A branch is essentially a movable reference to a commit.

Deleting a merged branch removes the branch reference, not the commits that are already reachable through another branch.

---

## 12. Repository Hygiene and `.gitignore`

Created a repository-level `.gitignore` to exclude files that should not normally be committed.

```gitignore
# Environment files
.env
.env.*

# Logs
*.log

# Editor backup files
*.save

# Temporary files
*.tmp
```

Verified ignore rules with:

```bash
git check-ignore -v <file>
```

This command identifies which `.gitignore` rule is responsible for ignoring a particular file.

### Important Lesson

`.gitignore` primarily prevents matching untracked files from being added to Git.

It does **not** automatically stop tracking a file that has already been committed.

To stop tracking a file while keeping the local copy:

```bash
git rm --cached <file>
```

### Security Consideration

If a real password, API key, token, or other secret has already been committed, simply adding the file to `.gitignore` does not remove that secret from previous Git history.

The exposed credential should be considered compromised and should be rotated or revoked.

---

## Skills Practiced

- Git working directory, index, and commits
- Staging and unstaging
- `git status`
- `git diff`
- `git diff --staged`
- Branch creation and switching
- Fast-forward merges
- Three-way merges
- Merge conflict resolution
- `git restore`
- `git reset`
- `git revert`
- `git reflog`
- Local branches
- Remote branches
- Remote-tracking references
- `git fetch`
- `git pull`
- `git push`
- Diverged Git histories
- GitHub SSH authentication
- SSH key pairs
- DNS troubleshooting
- Feature branch workflows
- GitHub Pull Requests
- Pull Request updates
- Merge commits
- Branch cleanup
- `.gitignore`
- Repository hygiene
- Bash deployment health checks
- Linux exit codes

---

## Key Takeaway

Git is not just a tool for saving versions of files.

It provides a structured way to:

- isolate work using branches,
- inspect changes before committing,
- collaborate through remote repositories,
- review changes through Pull Requests,
- integrate independent histories,
- recover from mistakes,
- maintain clean repositories,
- and preserve an auditable development history.

The most important mental model developed during this lab was understanding the relationship between:

```text
Working Directory
       |
       v
Staging Area / Index
       |
       v
Commit History
       |
       v
Local Branch
       |
       v
Remote-Tracking Reference
       |
       v
Remote Repository
```

Understanding where a change exists at each stage makes Git behavior much easier to reason about and troubleshoot.
