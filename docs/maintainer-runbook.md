# Maintainer runbook

## Roles

- **Client maintainers** (`x86macbrew/brew`): Intel client compatibility and security patching.
- **Catalog maintainers** (`x86macbrew/homebrew-core`): formula acceptance, fixes, and pin decisions.
- **Tap maintainers** (`x86macbrew/homebrew-x86mac`): bottle publication, manifest curation, and advisory publication.

## Release checklist

1. Validate tap integrity with `scripts/check-repository.sh`, diagnostic
   behaviour with `scripts/test-doctor.sh`, and the validator's own rules with
   `scripts/test-validator.sh`. All three run in CI on every pull request and
   push to `main`, and gate `scripts/build-source-release.sh`.
2. Add the reviewed stable formula name to `config/bottle-build-allowlist.yml`.
   The protected builder refuses formulas outside this allowlist.
3. Build the authorized formula bottle on protected Intel builder with
   `scripts/build-bottle.sh <formula>`.
4. Verify installation/audit on clean Intel host with `scripts/verify-bottle.sh <formula>`.
5. Record evidence links and checksums in `config/release-manifest.yml`.
6. Review manifest update under branch protection.
7. Publish from protected release environment.

## Cutting an `x86macbrew-doctor` release

1. Bump `VERSION` in `bin/x86macbrew-doctor`.
2. Run `scripts/build-source-release.sh <version>`; it refuses to build unless
   the declared version matches and both check suites pass.
3. Create the tag and upload `dist/x86macbrew-doctor-<version>.tar.gz` as a
   release asset.
4. Run `scripts/render-doctor-formula.sh <version> <asset-download-url>` to
   regenerate the formula against the published artifact's real checksum.
5. Add the release to `source_releases` in `config/release-manifest.yml`.
   `scripts/check-repository.sh` fails if the formula and the manifest disagree.

## Security and provenance controls

- Keep publication signing key outside builder hosts.
- Treat self-hosted builders as untrusted for publication authority.
- Preserve source build, test, install, and smoke test logs for every manifest addition.
- For incidents, remove affected entries from manifest and publish signed withdrawal advisory.
