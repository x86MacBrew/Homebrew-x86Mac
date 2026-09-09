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

## Rollback policy

If regressions or security concerns are found, remove the bottle entry from the release manifest, publish a signed advisory, and keep prior evidence artifacts for auditability.
