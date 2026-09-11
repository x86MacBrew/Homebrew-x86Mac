# Experimental formula candidates

This branch contains formulas under evaluation for future x86MacBrew support.
It is not a stable distribution branch and it must not be used as a normal
user tap.

Current candidates:

- `oniguruma` 6.9.10
- `jq` 1.8.2

The first-builder validation record is available in
[`docs/evidence/2026-09-11-intel-builder-candidates.md`](docs/evidence/2026-09-11-intel-builder-candidates.md).
It proves source installation, formula tests, strict audits, and runtime smoke
tests in an isolated Intel prefix. It does not satisfy the separate clean-host
or bottle-release requirements.

A candidate is promoted to `main` only after a source build, `brew test`,
clean-host installation, runtime smoke test, checksum, provenance evidence,
and reviewed manifest entry are complete. See
[`docs/formula-scope-policy.md`](docs/formula-scope-policy.md) on `main` for
the stable promotion policy.
