# ADR 001: Maintain the minimum viable continuation boundary

## Decision

x86MacBrew will maintain an Intel-compatible `brew` client only after upstream removes that capability. Formulae and bottle metadata remain in separate tap and catalogue repositories.

## Rationale

The client is needed for familiar workflows such as `brew install`, `brew upgrade`, and `brew test`. It does not create bottles. Formulae and bottles change more often and need separate review. This keeps the client fork small and allows formula rollback without shipping a client update.

## Consequences

The project needs three release processes, each with an owner and security contact. A user gets an explicit support result for a formula release rather than an implied promise that all upstream packages work.
