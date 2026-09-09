# Formula scope policy

The Intel continuation catalog (`x86macbrew/homebrew-core`) is intentionally curated.

## In scope

- Formulae required for common CLI development workflows on Intel macOS.
- Formulae that can be built, tested, bottled, and installed on a clean supported Intel host.
- Formula revisions with reproducible build and verification evidence.

## Out of scope

- Formulae that require unsupported platform features.
- Formulae that cannot complete source build + `brew test` + clean-host install.
- Casks and broad parity guarantees with upstream package volume.

## Promotion requirements

A formula revision can be promoted to this tap manifest only when evidence exists for:

- source build success,
- `brew test` success,
- clean host installation,
- runtime smoke test,
- artifact checksum and provenance metadata.

## Candidate branches

Experimental formulae belong on a `candidates/<scope>` branch, not under
`Formula/` on `main`. A candidate may record direct source-build observations,
but it must not be presented as a stable public-tap formula. Promotion happens
formula by formula through a reviewed pull request after every requirement
above is met.

## Rollback policy

If regressions or security concerns are found, remove the bottle entry from the release manifest, publish a signed advisory, and keep prior evidence artifacts for auditability.
