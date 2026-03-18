# Hello World Container — AWS Version

## Overview

AWS equivalent of the Azure Hello World Container project. The same Flask app is containerised and deployed to **AWS App Runner** via **Amazon ECR**, with infrastructure managed by Terraform and CI/CD through **GitHub Actions**.

Key optimisations over the Azure version:
- **App Runner** scales to zero when idle (no always-on cost like App Service B1)
- **ECR scan-on-push** replaces the manual Trivy install step
- **OIDC authentication** replaces long-lived service principal secrets
- **GitHub Actions** replaces Azure DevOps Pipelines

---

## Project Structure

```
hello-world-container-aws/
├── .github/
│   └── workflows/
│       ├── 01-create-infra.yml
│       ├── 02-build-deploy.yml
│       └── 03-destroy-infra.yml
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── tests/
│       ├── conftest.py
│       └── test_app.py
├── infra/
│   ├── providers.tf        # AWS provider + S3 remote state backend
│   ├── variables.tf
│   ├── main.tf             # ECR, IAM role, App Runner
│   └── outputs.tf
├── Dockerfile
└── README.md
```

---

## AWS Resources

| Resource | Name |
|----------|------|
| ECR Repository | `hello-world-aws` |
| App Runner Service | `svc-hwc-aws-aue-001` |
| IAM Role (App Runner → ECR) | `role-hwc-aws-apprunner-ecr` |

### Terraform State Backend (never destroyed)

| Resource | Name |
|----------|------|
| S3 Bucket | `s3-hwc-aws-tfstate` |
| DynamoDB Lock Table | `ddb-hwc-aws-tfstate-lock` |
| State Key | `hwc-aws.terraform.tfstate` |

> The S3 bucket and DynamoDB table are created by the Bootstrap job in Pipeline 01 and are never touched by Pipeline 03.

---

## Infrastructure (Terraform)

- **Terraform version:** >= 1.7.0
- **AWS provider:** ~> 5.0
- **Backend:** S3 + DynamoDB (remote state with locking)
- **Region:** `ap-southeast-2` (Sydney)

---

## Prerequisites — OIDC Setup (one-time, done in AWS Console)

GitHub Actions authenticates to AWS via OIDC — no long-lived access keys needed.

**1. Create the OIDC provider in IAM:**
- Provider URL: `https://token.actions.githubusercontent.com`
- Audience: `sts.amazonaws.com`

**2. Create an IAM role with this trust policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
      },
      "StringLike": {
        "token.actions.githubusercontent.com:sub": "repo:<YOUR_GITHUB_ORG>/<YOUR_REPO>:*"
      }
    }
  }]
}
```

**3. Attach permissions to the role** (AdministratorAccess for the POC, scope down for production).

**4. Add the role ARN as a GitHub Actions variable:**
- Go to: GitHub repo → Settings → Secrets and variables → Actions → Variables
- Add: `AWS_ROLE_ARN` = `arn:aws:iam::<ACCOUNT_ID>:role/<ROLE_NAME>`

---

## GitHub Environments

| Environment | Approval |
|-------------|----------|
| `prod` | Manual approval required |

Set up at: GitHub repo → Settings → Environments → New environment → `prod` → add required reviewers.

---

## Workflows

### Workflow 01 — Create Infrastructure (`01-create-infra.yml`)

Trigger: **manual only** (workflow_dispatch)

**Jobs:**
1. **Bootstrap** — creates S3 bucket (versioned, encrypted) and DynamoDB lock table; idempotent, safe to re-run
2. **Terraform Apply** — installs Terraform 1.7.5, runs `init` / `plan` / `apply`; requires `prod` environment approval

---

### Workflow 02 — Build & Deploy (`02-build-deploy.yml`)

Trigger: **auto on push to `main`** for changes to `app/**` or `Dockerfile`

**Jobs:**

| Job | Details |
|-----|---------|
| Flake8 Lint | Max line length 120, excludes `app/tests` |
| Bandit Security Scan | Recursive, low-level severity (`-ll`), excludes `app/tests` |
| Pytest + Coverage | Min **80% coverage** required; uploads XML artifact |
| Build and Push to ECR | Docker build → push to ECR with run number tag + `latest`; ECR scan-on-push triggers automatically |
| Deploy to App Runner | Updates App Runner with the new image tag → waits for deployment to complete; requires `prod` environment approval |

---

### Workflow 03 — Destroy Infrastructure (`03-destroy-infra.yml`)

Trigger: **manual only** (workflow_dispatch)

Runs `terraform destroy -auto-approve`. The S3 state bucket and DynamoDB table are **not** touched.

---

## Reproducing from Scratch

1. Create a GitHub repo and push this folder as the repo root
2. Complete the OIDC setup (one-time, see above)
3. Create the `prod` GitHub Environment with required reviewers
4. Add the `AWS_ROLE_ARN` Actions variable
5. Run **Workflow 01** (Actions → 01 - Create Infrastructure → Run workflow) — approve the `prod` gate
6. Run **Workflow 02** (push a change or trigger manually) — approve the deploy gate
7. To tear down: run **Workflow 03** — state backend remains intact

---

## Application

| Endpoint | Response |
|----------|----------|
| `GET /` | `Hello, World!` |
| `GET /health` | `{"status": "healthy"}` (HTTP 200) |

Served by **Gunicorn** on port 8000 (`python:3.11-slim` base image).

App URL is printed at the end of Workflow 02's deploy job, and also available as a Terraform output after Workflow 01.

---

## Azure vs AWS Comparison

| Concern | Azure Version | AWS Version |
|---------|--------------|-------------|
| Container Registry | ACR | ECR |
| Image scanning | Trivy (manual install) | ECR scan-on-push (built-in) |
| App hosting | App Service B1 (always on) | App Runner (scales to zero) |
| IaC state | Azure Storage | S3 + DynamoDB |
| CI/CD | Azure DevOps Pipelines | GitHub Actions |
| Auth (pipelines → cloud) | Service principal secrets | OIDC (no long-lived secrets) |
| Approval gates | ADO Environments | GitHub Environments |
