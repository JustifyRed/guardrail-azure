# Phase 2 — RMF-as-Code for NIST SP 800-171 / CMMC Level 2

**Entry gate (all three required):** GUARDRAIL v1.0 tagged and README finished ·
AZ-104 exam booked · OPSEC/ethics check complete (see "Guardrails on the guardrail").

**Window:** weeks 7–12, same 6–8 hrs/week. Phase 2 never starts before v1.0 ships.

## Why this target
Defense contractors handling Controlled Unclassified Information must meet
NIST SP 800-171 and, under the CMMC program, increasingly prove it through
third-party assessment. Azure Policy ships a built-in **NIST SP 800-171 R2**
regulatory compliance initiative in commercial Azure, so the whole phase runs on
the free subscription — no Azure Government access needed. The DoD Cloud SRG
impact-level initiatives are not in the commercial built-in catalog, so IL
mapping is documented, not enforced.

## Deliverables
1. **Governance module v2** — assign the NIST SP 800-171 R2 initiative alongside
   800-53 R5; add custom policies for gaps the built-in leaves open.
2. **Evidence pipeline** — a scheduled workflow that exports Azure Policy
   compliance state and joins it to `docs/control-mapping.md`, producing a dated
   evidence report per 800-171 requirement (the artifact an assessor asks for).
3. **OSCAL component definition** — generate a NIST OSCAL JSON component
   definition from the control mapping, so the controls are machine-readable.
4. **Published modules** — split modules into public repos named
   `terraform-azurerm-guardrail-<module>` with semantic version tags and publish
   to the Terraform Registry.
5. **Content** — a 4-part LinkedIn series: OIDC without secrets; POA&M-as-code;
   policy deny vs audit; turning 800-171 into pipeline gates.

## Guardrails on the guardrail (do these before publishing)
- Talk to your unit OPSEC officer and an ethics counselor about publishing a
  personal open-source project and writing about it while on active duty.
- Never reference unit systems, network names, configurations, or anything
  learned from non-public sources. Use only public NIST/Microsoft documentation.
- No rank, unit, or DoD branding implying endorsement. Use the README disclaimer.
- Never use a .mil address or government equipment for this project.

## Kill criteria
Stop Phase 2 and return to certification study if any of these happen:
v1.0 is not shipped by week 8, monthly spend exceeds the budget twice, or the
OPSEC/ethics answer is anything other than a clear yes.
