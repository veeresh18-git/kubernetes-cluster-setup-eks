# kubernetes-cluster-setup-eks
Got it! Let’s make this **super easy to understand** by explaining the **purpose of each folder and file** in your Terraform project. Think of it as a blueprint for your infrastructure.

---

## **1️⃣ infra/**

This is the **root folder** of your project. Everything related to your infrastructure goes here.

---

## **2️⃣ bootstrap/**

* Purpose: **One-time setup** for Terraform remote state.
* You usually only run this once to create things like **S3 bucket + DynamoDB table** (for storing Terraform state safely).

Files inside:

* **backend.tf** → Configures the remote backend (S3 + DynamoDB).
* **main.tf** → Resources to create the backend.
* **variables.tf** → Input variables for your backend setup.
* **outputs.tf** → Outputs from this setup (like S3 bucket name).

> Think of this folder as “Terraform’s setup assistant.”

---

## **3️⃣ modules/**

* Purpose: **Reusable components** of your infrastructure.
* Each module can be used in multiple environments.

### Example modules:

1. **network-aws/**

   * Wraps the official VPC module.
   * Files: `main.tf`, `variables.tf`
   * Purpose: Creates your network (VPC, subnets, security groups).

2. **eks-aws/**

   * Wraps the official EKS module.
   * Purpose: Creates Kubernetes cluster on AWS.

3. **irsa-aws/**

   * IAM Roles for Service Accounts.
   * Purpose: Gives Kubernetes pods AWS permissions securely.

4. **addons-helm/**

   * Installs extra services on EKS (metrics-server, ALB, external-dns, autoscaler).

> **Modules are like Lego blocks** — you can combine them to build your infrastructure.

---

## **4️⃣ env/**

* Purpose: **Environment-specific configs** (prod, dev, staging).
* Example: `env/prod/` → Production environment configuration.

Files inside:

* **backend.tf** → Connects this environment to remote backend.
* **providers.tf** → Specifies cloud provider (AWS) info.
* **versions.tf** → Terraform and provider versions.
* **variables.tf** → Environment-specific variables.
* **main.tf** → Wires together the modules for this environment.
* **outputs.tf** → Outputs for this environment.

> Think of this folder as “the actual environment you’re deploying.”

---

## **5️⃣ .github/workflows/**

* Purpose: **CI/CD automation** (GitHub Actions workflows).
* Example: `terraform.yml` → Runs Terraform plan/apply automatically when you push code.

---

### **Simple analogy:**

* `bootstrap/` → Setup the tools for Terraform to work (one-time).
* `modules/` → Building blocks (like Lego pieces).
* `env/prod/` → A finished Lego model for production.
* `.github/workflows/` → Robots that automatically build your Lego models when code changes.

---


Git commands used :

Absolutely! Here’s a **quick reference for Git commands** to check user info and essential commands you should know **before and during commits**. I’ll also explain why they’re important.

---

## **1️⃣ Check Git user info (before commit)**

Before committing, you want to make sure Git knows **who you are**:

```bash
# Check current Git user name and email
git config user.name
git config user.email

# Check global config (applies to all repos)
git config --global user.name
git config --global user.email

# Show all config including repo-specific overrides
git config --list
```

> ✅ **Tip:** If your commits are going to a company repo, make sure your **user.email** matches the one allowed by the repo (e.g., your corporate email).

---

## **2️⃣ Common Git commands before commit**

```bash
# Check status of repo
git status

# See what changed
git diff            # changes not staged
git diff --staged   # changes staged for commit

# Stage files for commit
git add <file>      # stage a single file
git add .           # stage all changes
git add -p          # interactively stage changes (very useful)

# Unstage files
git restore --staged <file>
git reset HEAD <file>

# Discard changes
git restore <file>        # discard changes in working directory
git checkout -- <file>    # older syntax for same

# View previous commits
git log                  # full log
git log --oneline --graph # simplified view
```

---

## **3️⃣ Commit commands**

```bash
# Commit staged changes
git commit -m "Your commit message"

# Amend last commit (without changing commit message)
git commit --amend --no-edit

# Commit with new message
git commit --amend -m "Updated message"
```

---

## **4️⃣ Push / Pull**

```bash
# Push your commits
git push origin <branch_name>

# Pull latest changes from remote
git pull origin <branch_name>

# Fetch changes without merging
git fetch origin
```

---

## **5️⃣ Branch commands**

```bash
# Show branches
git branch             # local branches
git branch -a          # local + remote

# Create branch
git checkout -b <branch_name>

# Switch branch
git checkout <branch_name>
```

---

## **6️⃣ Merge / Rebase**

```bash
# Merge another branch into current branch
git merge <branch_name>

# Rebase current branch onto another branch
git rebase <branch_name>
```

---

## **7️⃣ Useful tips**

* Always check `git status` before commit.
* Use `git diff` to review changes before staging.
* Use `git log --oneline --graph --all` to see the branch structure.
* If working with **remote teams**, double-check `git user.email` to avoid commit rejections.

---

If you want, I can **make a one-page “cheat sheet”** for your daily Git workflow that includes **all these commands in order** so you never have to wonder what to do before a commit.

Do you want me to make that cheat sheet?
