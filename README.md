# x86MacBrew

x86MacBrew is an independent continuation project for Intel x86_64 Macs after
upstream Homebrew Intel support ends. It preserves familiar Homebrew workflows
while separating three components that can evolve independently.

> **Not affiliated with Homebrew.** x86MacBrew is a community fork. It is not
> endorsed, supported, or maintained by the Homebrew project. Upstream Homebrew
> lists Intel macOS as Tier 3, has stopped building new Intel bottles, and plans
> to remove Intel execution support in or after September 2027.

## Project status: pre-general-availability

**Do not depend on this project yet.**

| | |
| --- | --- |
| Bottles published | **None** |
| Source releases | `x86macbrew-doctor` 0.2.0 (prerelease, unsigned) |
| Artifact signing | Not implemented |
| Maintainers | 1 |

What works today is the diagnostic, the support policy, and the validation and
release process. What does not exist yet is a binary distribution. The tap is
public so the process can be reviewed in the open, not because the support
contract is being honoured yet. The remaining gates are listed in
[docs/governance.md](docs/governance.md).

## Components

| Component | Repository | Responsibility |
| --- | --- | --- |
| Compatibility client | `x86macbrew/brew` | Keep the `brew` command runnable on supported Intel macOS after upstream removal. |
| Formula catalogue | `x86macbrew/homebrew-core` | Carry Intel-focused formula revisions, pins, and fixes. |
| This distribution tap | `x86macbrew/homebrew-x86mac` | Publish approved Intel bottles and ship `x86macbrew-doctor`. |

This repository is the distribution tap. It publishes release metadata and
tooling for a supported Intel host.

## Support contract

**Supported**
- Physical Intel Macs (`x86_64`) on macOS 15.
- Homebrew-compatible client installed at `/usr/local`.
- Artifacts explicitly listed in [config/release-manifest.yml](config/release-manifest.yml).
- Bottles that passed source build, `brew test`, clean-host install, and runtime smoke test.

**Not promised**
- Every upstream formula.
- Casks.
- Untested bottles.
- Ongoing macOS platform security updates from Apple.

See [config/support.yml](config/support.yml) for machine-readable policy.

Experimental formula candidates are maintained outside the stable public tap
on the [`candidates/jq-oniguruma`](https://github.com/x86MacBrew/Homebrew-x86Mac/tree/candidates/jq-oniguruma)
branch. Their build observations are recorded in
[docs/package-status.md](docs/package-status.md); they are not supported
formulae and are intentionally unavailable from `main`.

## User workflow

```sh
brew tap x86macbrew/x86mac
brew install x86macbrew/x86mac/x86macbrew-doctor
x86macbrew-doctor
```

`x86macbrew-doctor` reports whether this host matches the support policy:
architecture, macOS major version, Homebrew prefix, and CPU baseline. It exits
`0` when the host is supported, `1` when a check fails, and `2` when the policy
cannot be read. Use `--json` for machine-readable output.

Every artifact this project supports is listed in
[config/release-manifest.yml](config/release-manifest.yml) with its SHA-256.
**Anything not listed there is unsupported, regardless of what appears on the
releases page.** Since no bottles are published yet, there is currently nothing
else to install.

## Migration for post-2027 Intel users

See [docs/migration-from-upstream-homebrew.md](docs/migration-from-upstream-homebrew.md)
for the migration path from upstream Homebrew to x86MacBrew-managed components.

## Maintainer release workflow

1. Run `scripts/check-repository.sh` before review.
2. On an isolated Intel builder, run `scripts/build-bottle.sh <formula>`.
3. On a clean Intel macOS 15 host, run `scripts/verify-bottle.sh <formula>`.
4. Record verified metadata and evidence links in [config/release-manifest.yml](config/release-manifest.yml).
5. Create a versioned `x86macbrew-doctor` source release and run `scripts/render-doctor-formula.sh VERSION RELEASE_URL`.
6. Publish from a protected release environment after checksum, logs, and provenance review.

## Contributing and security

- Contributing guide: [CONTRIBUTING.md](CONTRIBUTING.md)
- Security policy and artifact verification: [SECURITY.md](SECURITY.md)

## Governance, scope, and runbooks

- Architecture boundary: [docs/ADR-001-continuation-boundary.md](docs/ADR-001-continuation-boundary.md)
- Release policy: [docs/release-policy.md](docs/release-policy.md)
- Support matrix: [docs/support-matrix.md](docs/support-matrix.md)
- Formula scope policy: [docs/formula-scope-policy.md](docs/formula-scope-policy.md)
- Migration guide: [docs/migration-from-upstream-homebrew.md](docs/migration-from-upstream-homebrew.md)
- Maintainer runbook: [docs/maintainer-runbook.md](docs/maintainer-runbook.md)
- Governance and sustainability: [docs/governance.md](docs/governance.md)

## Licence

BSD 2-Clause. See [LICENSE](LICENSE).
