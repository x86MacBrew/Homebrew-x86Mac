# x86MacBrew

x86MacBrew is an independent continuation project for Intel x86_64 Macs after upstream Homebrew Intel support ends. It preserves familiar Homebrew workflows while separating three components that can evolve independently.

| Component | Repository | Responsibility |
| --- | --- | --- |
| Compatibility client | `x86macbrew/brew` | Keep the `brew` command runnable on supported Intel macOS after upstream removal. |
| Formula catalogue | `x86macbrew/homebrew-core` | Carry Intel-focused formula revisions, pins, and fixes. |
| This distribution tap | `x86macbrew/homebrew-x86mac` | Publish approved Intel bottles and ship `x86macbrew-doctor`. |

This repository is the distribution tap. It publishes release metadata and tooling for a supported Intel host.

## Support contract

**Supported**
- Physical Intel Macs (`x86_64`) on macOS 15.
- Homebrew-compatible client installed at `/usr/local`.
- Formulae explicitly listed in a versioned release manifest.
- Bottles that passed source build, `brew test`, clean-host install, and runtime smoke test.

**Not promised**
- Every upstream formula.
- Casks.
- Untested bottles.
- Ongoing macOS platform security updates from Apple.

See `/home/runner/work/Homebrew-x86Mac/Homebrew-x86Mac/config/support.yml` for machine-readable policy.

## User workflow

```sh
brew tap x86macbrew/x86mac
brew install x86macbrew/x86mac/x86macbrew-doctor
x86macbrew-doctor
```

If `x86macbrew-doctor` passes, install only formulae included in `/home/runner/work/Homebrew-x86Mac/Homebrew-x86Mac/config/release-manifest.yml`.

## Migration for post-2027 Intel users

See `/home/runner/work/Homebrew-x86Mac/Homebrew-x86Mac/docs/migration-from-upstream-homebrew.md` for the migration path from upstream Homebrew to x86MacBrew-managed components.

## Maintainer release workflow

1. Run `scripts/check-repository.sh` before review.
2. On an isolated Intel builder, run `scripts/build-bottle.sh <formula>`.
3. On a clean Intel macOS 15 host, run `scripts/verify-bottle.sh <formula>`.
4. Record verified metadata and evidence links in `config/release-manifest.yml`.
5. Create a versioned `x86macbrew-doctor` source release and run `scripts/render-doctor-formula.sh VERSION RELEASE_URL`.
6. Publish from a protected release environment after checksum, logs, and provenance review.

## Governance, scope, and runbooks

- Architecture boundary: `/home/runner/work/Homebrew-x86Mac/Homebrew-x86Mac/docs/ADR-001-continuation-boundary.md`
- Release policy: `/home/runner/work/Homebrew-x86Mac/Homebrew-x86Mac/docs/release-policy.md`
- Support matrix: `/home/runner/work/Homebrew-x86Mac/Homebrew-x86Mac/docs/support-matrix.md`
- Formula scope policy: `/home/runner/work/Homebrew-x86Mac/Homebrew-x86Mac/docs/formula-scope-policy.md`
- Migration guide: `/home/runner/work/Homebrew-x86Mac/Homebrew-x86Mac/docs/migration-from-upstream-homebrew.md`
- Maintainer runbook: `/home/runner/work/Homebrew-x86Mac/Homebrew-x86Mac/docs/maintainer-runbook.md`
- Governance and sustainability: `/home/runner/work/Homebrew-x86Mac/Homebrew-x86Mac/docs/governance.md`
