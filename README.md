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
