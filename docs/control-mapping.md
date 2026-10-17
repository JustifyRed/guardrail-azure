# Control Mapping — NIST SP 800-53 Rev. 5 ↔ NIST SP 800-171 Rev. 2 / CMMC Level 2

Every row ties a control to the code that implements it and to where an assessor
finds the evidence. The 800-171 column exists from day one so Phase 2
(RMF-as-code / CMMC Level 2) extends this file instead of rewriting it.

> Crosswalk entries are the author's mapping and should be checked against the
> official NIST SP 800-171 Rev. 2 Appendix D crosswalk before being relied on.
> This repository implements controls on a personal lab subscription. It holds
> no CUI, no government data, and makes no claim of compliance for any system.

| 800-53 R5 | 800-171 R2 / CMMC L2 | Implementation | Evidence location | Status |
|---|---|---|---|---|
| AC-5 Separation of Duties | 3.1.4 | Separate plan (read) and deploy (write) identities; deploy trusts only the gated environment | `bootstrap/identity.tf`; Entra ID → App registrations → Federated credentials | Implemented (Wk 1) |
| AC-6 Least Privilege | 3.1.5 | Reader for plan; Contributor + Policy Contributor + ABAC-constrained RBAC Admin for deploy (cannot grant Owner/UAA) | `bootstrap/rbac.tf`; `az role assignment list --assignee <client-id>` | Implemented (Wk 1) |
| IA-2 Identification & Authentication | 3.5.2 | GitHub OIDC federation — no client secrets exist | `bootstrap/identity.tf`; workflow logs show token exchange | Implemented (Wk 1) |
| IA-5 Authenticator Management | 3.5.10 | No long-lived credentials; storage shared keys disabled | `bootstrap/main.tf` `shared_access_key_enabled = false` | Implemented (Wk 1) |
| SC-8 Transmission Confidentiality | 3.13.8 | TLS 1.2 minimum, HTTPS only | `bootstrap/main.tf`; Checkov CKV_AZURE_44 pass | Implemented (Wk 1) |
| SC-28 Protection at Rest | 3.13.16 | Infrastructure (double) encryption on state | `bootstrap/main.tf` | Implemented (Wk 1) |
| CP-9 System Backup | 3.8.9 | Blob versioning + 30-day soft delete on state; delete lock | `bootstrap/main.tf` | Implemented (Wk 1) |
| CM-2 Baseline Configuration | 3.4.1 | Entire environment defined in Terraform on `main` | Git history of `main` | Implemented (Wk 1) |
| CM-3 Configuration Change Control | 3.4.3 | PR + plan comment + required-reviewer approval + apply of reviewed plan only | `.github/workflows/cd.yml`; Environment deployment history | Implemented (Wk 1) |
| CM-6 Configuration Settings | 3.4.2 | Nightly drift detection opens issues on deviation | `.github/workflows/drift.yml`; Issues labeled `drift` | Implemented (Wk 1) |
| CM-8 System Component Inventory | 3.4.1 | Mandatory tags from `naming`; enforced by deny policy in Wk 4 | `modules/naming`; Azure Resource Graph tag query | Partial (Wk 1) → Wk 4 |
| RA-5 Vulnerability Monitoring & Scanning | 3.11.2 | Checkov + TFLint on every push; SARIF to Security tab | `.github/workflows/_static-checks.yml`; Security → Code scanning | Implemented (Wk 1) |
| SI-2 Flaw Remediation | 3.14.1 | Dependabot for Actions and providers | `.github/dependabot.yml`; Dependabot PRs | Implemented (Wk 1) |
| CA-5 Plan of Action & Milestones | 3.12.2 | Every accepted scanner finding has a POA&M entry and inline justification | `docs/poam.md` | Implemented (Wk 1) |
| AU-2 / AU-12 Event Logging | 3.3.1 | Activity Log + resource diagnostics → Log Analytics | `modules/monitoring` | Planned (Wk 3) |
| AU-6 Audit Review & Analysis | 3.3.5 | Alerts on privileged role grants, policy deletion, Key Vault deletion | `modules/alerting` | Planned (Wk 5) |
| SC-7 Boundary Protection | 3.13.1 | Hub-spoke VNets, deny-by-default NSGs | `modules/networking` | Planned (Wk 3) |
| SC-12 Key Establishment & Management | 3.13.10 | Key Vault RBAC mode, purge protection | `modules/key-vault` | Planned (Wk 3) |
| CA-7 Continuous Monitoring | 3.12.3 | NIST 800-53 R5 initiative (audit) + Defender foundational CSPM secure score | `modules/governance`, `modules/defender` | Planned (Wk 4) |
