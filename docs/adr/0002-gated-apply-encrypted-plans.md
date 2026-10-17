# ADR-0002: Plan/apply gating with encrypted plan artifacts

**Status:** Accepted · **Date:** 2026-10

## Context
Applying on every push lets unfinished work change live infrastructure. Applying
after approval but re-planning at apply time means the approver may not have
seen what actually runs. This repository is public, and saved Terraform plans
can contain sensitive values and state data; public-repo workflow artifacts are
downloadable by other GitHub users.

## Decision
- CI on every push and PR: fmt, validate, TFLint, Checkov. PRs also get a
  read-only plan posted as a comment.
- CD only on `main`: plan → encrypt plan with AES-256 (key in a GitHub secret)
  → upload with 3-day retention → required-reviewer approval → decrypt → apply
  that exact plan file.
- A single concurrency group (`terraform-dev`) serializes cd, drift and destroy.

## Consequences
- What the reviewer approved is byte-for-byte what is applied; a stale plan fails
  safely instead of applying surprises.
- One extra secret (`PLAN_ENCRYPTION_KEY`) to manage.
- Maps to CM-3 and SC-28.
