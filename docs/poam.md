# Plan of Action & Milestones (POA&M)

Every scanner finding that is accepted rather than fixed is recorded here and
referenced inline (`#checkov:skip=ID:POAM-xxx`). Nothing is suppressed silently.
Control reference: NIST SP 800-53 CA-5 / NIST SP 800-171 3.12.2.

| ID | Finding | Control | Risk | Compensating control | Production remediation | Milestone | Status |
|---|---|---|---|---|---|---|---|
| POAM-001 | State storage reachable from public network; no private endpoint (CKV_AZURE_59, CKV2_AZURE_33) | SC-7 | Moderate | Shared keys disabled — Entra ID auth only; RBAC scoped to the container; TLS 1.2 | Self-hosted runners in a VNet + private endpoint, `public_network_access_enabled = false` | Phase 2 | Open — accepted (cost) |
| POAM-002 | State uses LRS, not GRS (CKV_AZURE_206) | CP-9 | Low | Blob versioning, 30-day soft delete, CanNotDelete lock | GRS or RA-GRS | Phase 2 | Open — accepted (cost) |
| POAM-003 | Microsoft-managed keys, not CMK (CKV2_AZURE_1) | SC-12 | Low | Infrastructure (double) encryption enabled | CMK in Key Vault with rotation policy | Phase 2 | Open — accepted |
| POAM-004 | Queue logging not enabled (CKV_AZURE_33) | AU-12 | Low | Queue service unused on this account | N/A — close if queues are never used | Wk 3 review | Open |
| POAM-005 | Blob read logging not enabled on state (CKV2_AZURE_21) | AU-12 | Moderate | Activity Log captures control-plane access | Diagnostic setting → Log Analytics in `modules/monitoring` | Wk 3 | Open — scheduled |
| POAM-006 | `destroy.yml` uses a workflow_dispatch input (CKV_GHA_7) | SA-10 | Low | Input is a confirmation string only; job requires environment approval | N/A — rule targets build provenance, not teardown | — | Closed — not applicable |
| POAM-007 | OIDC trust subject flagged (CKV_AZURE_249) | IA-2 | None (false positive) | Subjects are exact, ID-bound, wildcard-free; verified the rule's regex rejects GitHub's `owner@id/repo@id` format | Upstream fix to Checkov's `gh_repo_regex` (candidate open-source contribution, Phase 2) | — | Closed — false positive |
