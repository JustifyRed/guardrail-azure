# GUARDRAIL — Compliance-as-Code Secure Landing Zone on Azure

GUARDRAIL deploys a hardened Azure environment entirely from Terraform, enforces a
NIST SP 800-53 Rev. 5 baseline with Azure Policy, blocks misconfigurations in the
pipeline before they reach the cloud, and tracks every accepted risk in a POA&M —
security controls written, reviewed and enforced as code.

> Personal portfolio project. Not affiliated with or endorsed by the U.S. Army or
> the Department of Defense. Built only from public documentation, on a personal
> lab subscription. Holds no government data or CUI.

## Security model at a glance
| Concern | How GUARDRAIL handles it |
|---|---|
| Pipeline credentials | GitHub OIDC → Entra ID. **Zero stored secrets.** ([ADR-0001](docs/adr/0001-oidc-two-identities.md)) |
| Separation of duties | Read-only *plan* identity; write *deploy* identity trusts only the approval-gated environment |
| Privilege escalation | Deploy identity's RBAC role is ABAC-constrained: it cannot grant Owner/UAA/RBAC Admin |
| Change control | PR plan comment → merge → human approval → apply **the exact reviewed plan** ([ADR-0002](docs/adr/0002-gated-apply-encrypted-plans.md)) |
| Shift-left security | fmt · validate · TFLint · Checkov on every push; findings in the Security tab |
| Drift | Nightly plan opens a GitHub issue on any out-of-band change |
| Accepted risk | Every suppression links to [docs/poam.md](docs/poam.md) |
| Cost | Budget + forecast alerts deploy **first**; one-click destroy |

Control coverage: [docs/control-mapping.md](docs/control-mapping.md) (800-53 R5 ↔ 800-171 R2).

## Repository layout
```
bootstrap/            one-time, run locally: state backend + OIDC identities + RBAC
modules/              naming, cost-guard (Wk 1) · networking, monitoring, key-vault,
                      secure-storage (Wk 3) · governance, defender (Wk 4) · alerting (Wk 5)
environments/dev/     composes the modules
.github/workflows/    ci · cd · drift · destroy · _static-checks (reusable)
docs/                 control mapping · POA&M · ADRs · Phase 2 plan
```

## Week 1 setup (about 90 minutes)

### 1. Install tools
Windows (PowerShell):
```powershell
winget install Microsoft.AzureCLI Hashicorp.Terraform GitHub.cli Git.Git
```
macOS: `brew install azure-cli terraform gh git`

Confirm: `terraform version` (≥ 1.9), `az version`, `gh --version`.
On Windows, run steps 2–7 in **Git Bash** (installed with Git) — the commands are bash.

### 2. Create the GitHub repo (empty) and sign in
```bash
gh auth login
gh repo create guardrail-azure --public --description "Compliance-as-code secure landing zone on Azure"
```

### 3. Sign in to Azure and register resource providers
```bash
az login
az account set --subscription "<your-subscription-id>"
for ns in Microsoft.Storage Microsoft.Consumption Microsoft.Insights Microsoft.OperationalInsights \
          Microsoft.KeyVault Microsoft.Network Microsoft.Security Microsoft.PolicyInsights; do
  az provider register --namespace $ns
done
```

### 4. Run the bootstrap (the only local apply for the main environment)
Re-run it locally only to change what the pipeline *is*: renaming the repo, adding an
environment, or changing the identities' permissions. Everything else goes through CI/CD.

> **Avast / AVG users:** HTTPS scanning intercepts Terraform's local plugin connection
> (`x509: certificate signed by unknown authority`). File exceptions do not fix it; turn
> off Web Shield → *Enable HTTPS scanning* for the bootstrap run, then turn it back on.

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars   # fill in subscription_id and github_owner
terraform init
terraform plan -out=bootstrap.tfplan            # read it before applying
terraform apply bootstrap.tfplan
```

### 5. Configure the repository
```bash
REPO="<your-github-username>/guardrail-azure"

# Approval-gated environment with you as required reviewer
gh api -X PUT "repos/$REPO/environments/production" \
  -F "reviewers[][type]=User" -F "reviewers[][id]=$(gh api user --jq .id)"

# Variables printed by Terraform (identifiers, not secrets)
terraform output -raw github_variables_commands | grep '^gh ' | sed "s|\$| -R $REPO|" | bash

# Secrets
gh secret set ALERT_EMAIL -R "$REPO" --body "you@personal-email.com"
gh secret set PLAN_ENCRYPTION_KEY -R "$REPO" --body "$(openssl rand -base64 32)"
```

### 6. Move the bootstrap state into the hardened backend
```bash
cp backend.tf.example backend.tf   # set storage_account_name from `terraform output state_storage_account`
terraform init -migrate-state
rm -f terraform.tfstate terraform.tfstate.backup
cd ..
```

### 7. Push and watch the first gated deploy
```bash
git init -b main && git add . && git commit -m "GUARDRAIL week 1: bootstrap, cost-guard, gated CI/CD"
git remote add origin "https://github.com/$REPO.git" && git push -u origin main
gh api -X PUT "repos/$REPO/branches/main/protection" --input docs/setup/branch-protection.json

# Now that main is protected, only protected branches may deploy to production
gh api -X PUT "repos/$REPO/environments/production" \
  -F "reviewers[][type]=User" -F "reviewers[][id]=$(gh api user --jq .id)" \
  -F "deployment_branch_policy[protected_branches]=true" \
  -F "deployment_branch_policy[custom_branch_policies]=false"
```
Open **Actions → cd**, review the plan in the run summary, approve the
`production` deployment, and confirm the budget alert email arrives.

From now on every change goes through a branch and a pull request:
```bash
git switch -c week2-test && <edit> && git push -u origin week2-test && gh pr create --fill
```

### Troubleshooting
- **`AuthorizationFailed` right after bootstrap** — role assignments take up to ~5 minutes to propagate. Re-run.
- **`AADSTS70021: No matching federated identity record`** — the repo owner/name in `terraform.tfvars` does not match GitHub exactly (case-sensitive), or the job is not running where you expect (PR vs main vs environment).
- **Budget creation fails** — some offer types restrict budgets until the subscription is upgraded to pay-as-you-go. Comment out the budget resource, keep the action group, and restore it after upgrading.

## Roadmap
- [x] Week 1 — bootstrap, OIDC, cost-guard, CI/CD, drift, destroy, POA&M
- [ ] Week 3 — networking, monitoring, Key Vault, secure storage
- [ ] Week 4 — Azure Policy (NIST 800-53 R5 + custom deny), Defender CSPM
- [ ] Week 5 — security alerting, Sentinel trial (timeboxed)
- [ ] Week 6 — architecture diagram, demo video, v1.0 tag
- [ ] Phase 2 — [RMF-as-code for NIST 800-171 / CMMC L2](docs/phase-2-rmf-as-code.md)
