# Maintainer runbook

## Roles

- **Client maintainers** (`x86macbrew/brew`): Intel client compatibility and security patching.
- **Catalog maintainers** (`x86macbrew/homebrew-core`): formula acceptance, fixes, and pin decisions.
- **Tap maintainers** (`x86macbrew/homebrew-x86mac`): bottle publication, manifest curation, and advisory publication.

## Release checklist

1. Validate tap integrity with `scripts/check-repository.sh`.
2. Build reviewed formula bottle on protected Intel builder with `scripts/build-bottle.sh <formula>`.
3. Verify installation/audit on clean Intel host with `scripts/verify-bottle.sh <formula>`.
4. Record evidence links and checksums in `config/release-manifest.yml`.
5. Review manifest update under branch protection.
6. Publish from protected release environment.

## Security and provenance controls

- Keep publication signing key outside builder hosts.
- Treat self-hosted builders as untrusted for publication authority.
- Preserve source build, test, install, and smoke test logs for every manifest addition.
- For incidents, remove affected entries from manifest and publish signed withdrawal advisory.
