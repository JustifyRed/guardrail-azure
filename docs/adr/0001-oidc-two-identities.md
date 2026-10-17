# ADR-0001: GitHub OIDC with separate plan and deploy identities

**Status:** Accepted · **Date:** 2026-10

## Context
The pipeline needs Azure credentials. The common shortcut is one service principal
with a client secret stored as a GitHub secret and Owner on the subscription.
That secret is long-lived, can leak through logs or forks, and one identity can
both propose and execute any change, including granting itself more access.

## Decision
- Use OpenID Connect federation: GitHub issues a short-lived token per job and
  Entra ID exchanges it. No secret exists to steal or rotate.
- Split duties across two identities:
  - **plan** — Reader + state lock access. Trusts `pull_request` and `refs/heads/main`.
  - **deploy** — write roles. Trusts **only** `environment:production`, which
    requires a human approval in GitHub.
- Constrain the deploy identity's RBAC Administrator role with an ABAC condition
  so it cannot assign Owner, User Access Administrator or RBAC Administrator.

## Consequences
- A compromised feature branch or PR cannot obtain write access to Azure.
- The pipeline cannot escalate its own privileges.
- Bootstrap must run once locally by a human Owner (unavoidable chicken-and-egg).
- Maps to AC-5, AC-6, IA-2, IA-5 (see `docs/control-mapping.md`).
