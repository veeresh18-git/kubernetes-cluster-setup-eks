# kubernetes-cluster-setup-eks-prod
Got it! Let’s make this **super easy to understand** by explaining the **purpose of each folder and file** in your Terraform project. Think of it as a blueprint for your infrastructure.

---
PR Workflow test 1
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


Absolutely, Veeresh! Let’s slow down and really **understand why ConfigMaps and Secrets exist**, what problems they solve, and when to use each. I’ll make it simple with examples you can relate to your EKS/Helm setup.

---

## **1️⃣ ConfigMaps**

### **Problem it solves**

* In Kubernetes, your **application runs inside containers**.
* Containers are **immutable** — you build an image once and deploy it.
* If you hard-code configuration (like API URLs, feature flags) inside your Docker image:

  * Changing config means **rebuilding and redeploying the image every time**.
  * Not practical for production where config changes often.

**ConfigMap solves this:** it **decouples configuration from code**, allowing you to change config **without touching the container image**.

---

### **Main use cases**

1. **Environment variables for apps**

   ```text
   APP_MODE=production
   API_URL=https://api.myapp.com
   ```
2. **Application settings or feature flags**

   * Example: enable/disable caching or debug mode.
3. **Configuration files**

   * You can mount ConfigMaps as files in the container (`/etc/config/app.conf`).

---

### **Example**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
data:
  APP_MODE: "production"
  API_URL: "https://api.myapp.com"
```

* App reads `APP_MODE` and `API_URL` from environment variables.
* Change `APP_MODE` from `production` → `staging` without rebuilding the image.

✅ **Key point:** ConfigMaps are for **non-sensitive configuration** that can be shared among pods.

---

## **2️⃣ Secrets**

### **Problem it solves**

* Some configuration is **sensitive**, like:

  * Database passwords
  * API keys / tokens
  * TLS certificates
* If you put these directly in your Docker image or in a ConfigMap, anyone with access to the cluster **can read them**.
* Secrets solve this by **storing sensitive data separately** and encoding it (base64) so it’s not plain text in the YAML files.

---

### **Main use cases**

1. **Database credentials**

   ```text
   DB_USER=admin
   DB_PASSWORD=supersecret
   ```
2. **API tokens / keys**

   * Example: AWS keys, Stripe API key, third-party service tokens.
3. **TLS certificates**

   * Use with Ingress for HTTPS.

---

### **Example**

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: frontend-secret
type: Opaque
data:
  DB_PASSWORD: cGFzc3dvcmQ=   # base64 encoded "password"
```

* App reads `DB_PASSWORD` from environment variable.
* Kubernetes ensures it’s stored **separately from ConfigMaps** and only mounted for pods that need it.

✅ **Key point:** Secrets are for **sensitive data** that must be protected from plain view.

---

### **3️⃣ Key differences between ConfigMaps & Secrets**

| Feature         | ConfigMap                 | Secret                                                          |
| --------------- | ------------------------- | --------------------------------------------------------------- |
| Data type       | Non-sensitive config      | Sensitive data                                                  |
| Encoding        | Plain text                | Base64 encoded                                                  |
| Use case        | Env vars, settings, files | Passwords, tokens, TLS keys                                     |
| Mounted in pods | Yes, as env vars or files | Yes, as env vars or files                                       |
| Security        | Not encrypted by default  | Stored separately, can be encrypted at rest in cloud (optional) |

---

### **Example scenario**

Imagine your frontend app:

* Needs to connect to `https://api.myapp.com` → **ConfigMap**
* Needs database password to connect → **Secret**

This way:

* You can **change API URL** without redeploying the app.
* Database password is **secure and isolated**.

---

 the **main takeaway**:

* **ConfigMap** → decouples app configuration (non-sensitive) from the container.
* **Secret** → securely stores sensitive info that your pods need.



Ingress and Ingress controller:
-------------------------------
need to install controller frist using kubectl apply -f file (online)
setup rules in ingress values.yaml

You now understand:
✅ Service LoadBalancer
   • Direct access
   • One service = one LB
   • (before I created one lb type service to expose frontend)
✅ Ingress
(After ingress it will manage both frontend and backend services)

   • One LB → multiple services
   • Path-based routing (/ , /contact)
Host-based routing (domain)

PV & PVCS & SC:
------------------
Perfect! Let’s go over **all the important concepts** we used in your PVC + PV setup and explain **what each does and why it’s needed**, especially in the context of **EKS + Helm**. I’ll keep it simple.

---

### 1️⃣ **PersistentVolume (PV)**

* **What it is:** A storage resource in the cluster (like a hard disk).
* **Why it’s needed:** Pods in Kubernetes are ephemeral — if a pod dies, all its local data disappears. PV provides **durable storage** outside the pod.
* **In your setup:** Kubernetes dynamically created an **EBS volume** (`pvc-2a6246f9-...`) for your PVC.

---

### 2️⃣ **PersistentVolumeClaim (PVC)**

* **What it is:** A request for storage by a pod. Think of it as **reserving a disk**.
* **Why it’s needed:** Your pod doesn’t directly request a PV; it requests a PVC and Kubernetes finds or creates a PV that satisfies it.
* **In your setup:** `frontend-v1-pvc` asked for 5Gi on StorageClass `gp2`. Kubernetes created and bound the PV.

---

### 3️⃣ **StorageClass**

* **What it is:** Defines **how PVs should be provisioned** automatically.
* **Why it’s needed:** Lets Kubernetes know what type of storage to use (e.g., AWS EBS gp2, gp3, SSD, etc.) and how to create it.
* **In your setup:** You used `gp2` (default in your cluster). Kubernetes automatically created a PV using **gp2 EBS volume** when PVC was created.

---

### 4️⃣ **Access Modes**

* **RWO (ReadWriteOnce)** → Only one pod can write to the PV at a time.
* **ROX / RWX** → other modes for read-only or multiple pods access.
* **Why it’s needed:** Prevents data corruption and defines how pods can use the PV.

---

### 5️⃣ **Dynamic Provisioning**

* **What it is:** Automatically creating PVs when PVCs are requested.
* **Why it’s needed:** No need to manually create PVs; Kubernetes + StorageClass handles it.
* **In your setup:** PVC requested 5Gi → PV created automatically on AWS EBS.

---

### 6️⃣ **Helm Chart**

* **What it is:** A package manager for Kubernetes (like apt/yum for Linux).
* **Why it’s needed:** Lets you **define all your Kubernetes resources (Deployment, PVC, Ingress, ConfigMap, etc.)** in templates and deploy consistently.
* **In your setup:** PVC template and Deployment template are defined in Helm. Helm fills values from `values.yaml` and deploys resources.

---

### 7️⃣ **Volumes & volumeMounts**

* **Volumes:** Connect your pod to storage (PV/PVC).
* **volumeMounts:** Mount the volume inside the container at a **specific path**, e.g., `/data`.
* **Why it’s needed:** Without this, your app cannot read/write data to PV.

---

### 8️⃣ **Reclaim Policy**

* **Delete:** When PVC is deleted, PV (EBS volume) is also deleted automatically.
* **Retain:** PV stays even if PVC is deleted.
* **Why it’s important:** Controls **data lifecycle**. In production, sometimes you want to keep data after deleting a pod.

---

### 9️⃣ **PVC Status (Bound / Pending)**

* **Pending:** PVC is waiting for PV to be created or bound.
* **Bound:** PVC is successfully connected to a PV.
* **Why it matters:** Only **Bound PVCs** can be mounted by pods.

---

### 10️⃣ **Release Name in Helm (`.Release.Name`)**

* **What it is:** The name you give your Helm deployment, e.g., `frontend-v1`.
* **Why it’s needed:** Helps **consistently name resources**, like `frontend-v1-pvc`, so Helm can track and upgrade them.

---

✅ **Summary Flow in Your Cluster**

```text
Helm Chart (Deployment + PVC) 
          │
          ▼
PVC requests storage (5Gi, gp2)
          │
          ▼
Dynamic PV created on EBS
          │
          ▼
Pod mounts PV at /data → persistent storage available
```

---

If you want, I can now **explain IRSA, Network Policies, and how to connect this PVC setup to Ingress + TLS**, so you see **the full production-ready flow** for your app.

Do you want me to do that next?

User
 ↓
Ingress LB (single entry) (domainname/hostname/lburl)
 ↓
Ingress Controller
 ↓
/ → frontend
/contact → backend
 ↓
MongoDB


Docker&ports

Docker build --no-cache - build from scartch
OTHERWISE it uses caches

docker run -p = expose container to outside world perment
kubectl port-forward = temporary tunnel to a pod  - console close till

Port: 80 service acccess via port 80
Targetport: 5000 ->app runs inside container


You can't access container port directly you need service to access it and expose it.
kubectl port-forward pod/service 80:5000

You NEVER talk to Pod port directly
You ALWAYS go through Service port





💡 Memory Aid: Think of your cluster like a city:
   • Pods → houses
   • Services → roads connecting houses
   • Ingress → city gate
   • PV/PVC → storage units
   • IRSA → ID cards for accessing resources
Network Policy → rules on who can visit whom


HPA:
-----------
1️⃣ What HPA solves

Automatically scales the number of pods in a Deployment based on metrics like CPU or memory usage.

Solves the problem of manual scaling when traffic spikes or drops.

Ensures your app is responsive and cost-efficient.

2️⃣ How HPA works

You define min and max replicas for your Deployment.

You define a target metric, e.g., CPU utilization 50%.

Kubernetes continuously monitors the metric:

If CPU usage > 50%, HPA adds pods.

If CPU usage < 50%, HPA removes pods.

IRSA
-------
Perfect, Veeresh! 🎯 HPA is done. The next major concept we had in the list is:

## **ConfigMaps & Secrets → manage configuration & sensitive info** ✅

We already covered these in practice.

So the next concept to focus on is:

---

## **Service Accounts & IRSA (IAM Roles for Service Accounts)**

### 1️⃣ Problem it solves

* By default, pods in EKS **use the worker node IAM role** to access AWS resources (S3, DynamoDB, etc.).
* This **limits fine-grained access** because all pods share the same role.
* **IRSA (IAM Roles for Service Accounts)** solves this by allowing each pod to use its **own IAM role**.

---

### 2️⃣ How it works

1. Create an **IAM role** in AWS with the permissions you need.
2. Create a **Kubernetes service account** annotated with that IAM role.
3. Deploy your pod using that **service account**.
4. Pods can now access AWS resources using their **own IAM role**, not the node role.

---

### 3️⃣ Why it’s important

* **Security:** Least privilege access for each microservice.
* **Auditability:** Each pod’s actions are traced to its own role.
* **Flexibility:** Different pods can access different AWS resources safely.

---

### 4️⃣ Example

#### Step 1: Create IAM Role with trust policy for EKS OIDC

```json id="irsa-trust"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<account-id>:oidc-provider/<eks-cluster-oidc>"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "<eks-cluster-oidc>:sub": "system:serviceaccount:default:frontend-sa"
        }
      }
    }
  ]
}
```

* `<eks-cluster-oidc>` → get via:

```bash
aws eks describe-cluster --name <cluster-name> --query "cluster.identity.oidc.issuer" --output text
```

---

#### Step 2: Attach AWS policies

```bash
aws iam attach-role-policy --role-name frontend-role --policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess
```

---

#### Step 3: Create Kubernetes Service Account

```yaml id="sa-example"
apiVersion: v1
kind: ServiceAccount
metadata:
  name: frontend-sa
  namespace: default
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<account-id>:role/frontend-role
```

---

#### Step 4: Use it in Deployment

```yaml id="sa-deployment"
spec:
  serviceAccountName: frontend-sa
```

Now your frontend pod uses **frontend-role** to access AWS resources.

---
