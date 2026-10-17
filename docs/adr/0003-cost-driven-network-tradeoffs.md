# ADR-0003: Cost-driven network trade-offs (free-tier constraint)

**Status:** Accepted · **Date:** 2026-10

## Context
GUARDRAIL must stay within Azure free amounts. Several production-standard
controls carry hourly charges: Azure Firewall, Bastion, VPN/NAT Gateway,
Application Gateway WAF, private endpoints, and self-hosted runners in a VNet.
GitHub-hosted runners have no fixed egress IPs, so IP allow-listing the state
account is not practical.

## Decision
- Keep public network access on the state account, but disable shared keys so
  only Entra ID identities with explicit container-scoped RBAC can read or write.
- Use NSGs and service endpoints in place of Firewall and private endpoints.
- Record each gap as a POA&M item with its production remediation.

## What production would use
Private endpoints with private DNS zones, self-hosted runners (or managed DevOps
pools) inside the hub VNet, Azure Firewall for egress control, GRS state, and
customer-managed keys.

## Consequences
The design demonstrates knowledge of the production pattern while documenting a
deliberate, risk-assessed deviation — the same reasoning used in an RMF
risk acceptance. See `docs/poam.md` POAM-001 to POAM-003.
