Absolutely Veeresh — now I will explain the CI/CD pipeline **pin‑to‑pin, dead easy**, like you’re hearing it from a senior DevOps engineer sitting next to you.

You will understand **EVERY SINGLE LINE** of the two GitHub Actions workflows.

I’ll break it into:  
✅ What it does  
✅ Why it exists  
✅ How GitHub + Terraform + AWS interact

Let’s start.

***

# ✅ PART 1 — Understanding the Terraform Plan Workflow

File: **terraform-plan.yml**  
Purpose: **Runs on Pull Requests** (does NOT modify infra)

***

# ✅ **1. Workflow Name**

```yaml
name: Terraform Plan (prod)
```

➡️ This is just the name you’ll see in GitHub Actions.

***

# ✅ **2. Triggering Condition**

```yaml
on:
  pull_request:
    paths:
      - 'infra/env/prod/**'
      - 'infra/modules/**'
```

➡️ This workflow runs **only when a PR is opened**  
➡️ Only if files inside `infra/env/prod` or `infra/modules` change  
➡️ This prevents unnecessary workflow runs

✅ You save money  
✅ You avoid long pipelines running every time

***

# ✅ **3. Job Definition**

```yaml
jobs:
  terraform-plan:
    runs-on: ubuntu-latest
```

➡️ You define a job named `terraform-plan`  
➡️ It runs on the latest Ubuntu VM provided by GitHub

***

# ✅ **4. Permissions Required**

```yaml
permissions:
  id-token: write
  contents: read
  pull-requests: write
```

### What these mean:

*   **id-token: write** → Required for AWS OIDC authentication  
    GitHub creates a temporary token → AWS trusts this token → gives Terraform access.

*   **contents: read** → Allows reading from the repo

*   **pull-requests: write** → Allows GitHub to add plan results to the PR if you enable that later

✅ NO AWS Access Keys are used.  
✅ OIDC = modern secure authentication.

***

# ✅ **5. Set Default Working Directory**

```yaml
defaults:
  run:
    working-directory: infra/env/prod
```

➡️ All “run” commands inside this job will run inside:

    infra/env/prod

✅ This is your Terraform root  
✅ This is where `main.tf` and `providers.tf` exist  
✅ This is where Terraform must run

This line is VERY important.  
Without it Terraform will run in the wrong folder → FAIL.

***

# ✅ **6. Checkout Repository**

```yaml
- name: Checkout repository
  uses: actions/checkout@v4
```

➡️ Downloads your GitHub repo into the runner  
➡️ Needed because Terraform requires your `.tf` files

Basic but mandatory.

***

# ✅ **7. AWS OIDC Authentication**

```yaml
- name: Configure AWS Credentials (OIDC)
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::<YOUR_AWS_ACCOUNT_ID>:role/<YOUR_GITHUB_OIDC_ROLE>
    aws-region: ap-south-1
```

🔍 This is the MOST IMPORTANT security concept:

✅ GitHub says to AWS:

> “I am Veeresh’s GitHub workflow”

✅ AWS checks the trust policy:

> “Okay, GitHub is allowed to assume this role”

✅ AWS gives temporary 1‑hour credentials.

NO access keys needed.  
NO secrets stored.  
99% more secure than old method.

***

# ✅ **8. Install Terraform**

```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v3
```

➡️ Downloads Terraform  
➡️ Ensures correct version

***

# ✅ **9. Terraform Init**

```yaml
- name: Terraform Init
  run: terraform init -upgrade
```

It:

✅ Downloads modules  
✅ Connects to remote backend (S3/DynamoDB)  
✅ Prepares Terraform to run

`-upgrade` → refreshes provider versions.

***

# ✅ **10. Terraform Format Check**

```yaml
- name: Terraform Format
  run: terraform fmt -check
```

➡️ Ensures all `.tf` files follow standard formatting  
➡️ Prevents messy code in PR

✅ Does NOT modify files  
✅ Only checks formatting

***

# ✅ **11. Terraform Validate**

```yaml
- name: Terraform Validate
  run: terraform validate
```

Ensures:

✅ No syntax errors  
✅ All variables defined  
✅ Configuration is correct

***

# ✅ **12. Terraform Plan**

```yaml
- name: Terraform Plan
  run: terraform plan -no-color -out=tfplan
```

This generates:

✅ A dry‑run of infrastructure  
✅ Shows which resources will be created, changed, destroyed  
✅ Does NOT change anything

`tfplan` is stored as output → used later if needed.

***

# ✅ **13. Upload Plan File**

```yaml
- name: Upload Plan File
  uses: actions/upload-artifact@v4
  with:
    name: tfplan
    path: infra/env/prod/tfplan
```

This:

✅ Uploads your plan file  
✅ You can download it from GitHub Actions UI  
✅ Helps in approval or debugging

***

# ✅ ✅ Summary of terraform-plan workflow:

✅ Runs on PR  
✅ Fully safe (no apply)  
✅ Validates formatting  
✅ Validates syntax  
✅ Generates plan  
✅ Uploads plan  
✅ No secrets used (OIDC only)

***

# ✅ PART 2 — Understanding the Terraform Apply Workflow

File: **terraform-apply.yml**  
Purpose: **Runs when PR is merged → applies infra**

***

# ✅ Basic Structure

```yaml
name: Terraform Apply (prod)

on:
  push:
    branches:
      - main
```

➡️ Runs ONLY when commits reach **main**  
➡️ Prevents accidental apply

***

# ✅ Environment Protection (VERY IMPORTANT)

```yaml
environment:
  name: production
  url: https://console.aws.amazon.com/eks/home
```

### Why?

✅ Apply step is dangerous  
✅ GitHub "production" environment requires **manual approval**  
✅ Someone (you) must click ✅ Approve before apply runs  
✅ Prevents accidental infra changes

This is how production pipelines work in real companies.

***

# ✅ Working Directory

Same as before:

    infra/env/prod

So Terraform applies only for prod environment.

***

# ✅ Steps:

### **1. Checkout Repo**

```yaml
uses: actions/checkout@v4
```

### **2. Authenticate to AWS (OIDC)**

Same as plan workflow.

### **3. Setup Terraform**

```yaml
uses: hashicorp/setup-terraform@v3
```

### **4. Terraform Init**

```yaml
terraform init -upgrade
```

### **5. Terraform Apply**

```yaml
terraform apply -auto-approve
```

✅ This applies real infrastructure  
✅ No manual typing needed  
✅ Runs after environment approval

***

# ✅ ✅ Full Summary (Ultra Easy)

### **terraform-plan.yml**

✅ Runs on PR  
✅ Safe  
✅ No changes  
✅ Shows what will happen  
✅ Validates code  
✅ Uploads plan

### **terraform-apply.yml**

✅ Runs on main  
✅ Needs your approval  
✅ Applies changes  
✅ Fully secure with OIDC  
✅ Infrastructure updated (EKS, VPC, IAM, etc.)

***

# ✅ Want me to annotate the code word-by-word?

I can generate:

✅ A commented version with explanation on every line  
✅ A visual diagram explaining how GitHub ↔ AWS ↔ Terraform communicate  
✅ A step-by-step flow of how both pipelines work

Just say:

👉 **"Explain the commented version"**  
or  
👉 **"Send architecture diagram"**

Happy to go deeper.
