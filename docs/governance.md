# Governance and sustainability

This document separates what is **true today** from what is **required before
x86MacBrew tells anyone to depend on it**. A distribution project that
overstates its own governance is not safer than one with none, because users
calibrate trust against the claim rather than the reality.

## Current state (pre-general-availability)

| Property | Reality today |
| --- | --- |
| Maintainers | One (`@Cooldode`), acting as sole owner of the organization |
| Published bottles | None |
| Published source releases | `x86macbrew-doctor` 0.1.0 and 0.2.0, marked prerelease, unsigned |
| Artifact signing | Not implemented; no signing key exists |
| Advisory feed | Not implemented |
| Branch protection on `main` | Not enabled |
| Bus factor | 1 |

**x86MacBrew is therefore not yet suitable as a production dependency.** The
tap is public so the process can be reviewed in the open, not because the
support contract is being honoured yet.

## Repository ownership

| Repository | Role | Owner |
| --- | --- | --- |
| `x86macbrew/brew` | Compatibility client fork | `@Cooldode` |
| `x86macbrew/homebrew-core` | Formula catalogue fork | `@Cooldode` |
| `x86macbrew/homebrew-x86mac` | Distribution tap | `@Cooldode` |

## Gates required before general availability

Each gate must be satisfied and recorded before the project advertises general
availability. None may be waived by the maintainer who implemented it.

1. **Two independent maintainers** with organization ownership, so account loss
   does not end the project and no single person can publish unreviewed.
2. **Branch protection** on `main` in all three repositories: required pull
   request, at least one approving review, required status checks, no force
   push.
3. **A signing key** held outside every build host, with its fingerprint
   recorded in `config/release-manifest.yml` under `security.signing_key_fingerprint`.
4. **An advisory feed** at a stable URL, recorded under `security.advisory_feed`,
   capable of announcing a bottle withdrawal.
5. **A second physical Intel Mac** serving as the clean-host verification
   machine, distinct from the builder.
6. **At least one bottle** promoted end to end through the pipeline in
   [release-policy.md](release-policy.md) with all evidence links published.

Until every gate is met, the README, support matrix and release manifest must
continue to state that no bottles are supported.

## Triage targets

These are targets, not guarantees, while the project has one maintainer.

| Class | Acknowledgement target |
| --- | --- |
| Security report | 48 hours |
| Release-blocking regression | 72 hours |
| Standard issue | 7 days |

Issues should be labelled `security`, `release-blocker`, `support`, or
`out-of-scope`.

## Lifecycle policy

- Current target: Intel `x86_64` macOS 15 at prefix `/usr/local`.
- Adding a macOS major version requires updated `config/support.yml`, a builder
  and clean host for that version, and an announcement.
- Removing a macOS major version requires at least one announced maintenance
  release window.

## End-of-life policy

If the project can no longer meet its support contract, it must:

1. Announce the end-of-life date at least 90 days ahead through the advisory feed.
2. Freeze the release manifest and stop accepting formula promotions.
3. Leave all published artifacts, checksums, and evidence in place so existing
   installations remain verifiable.
4. Update the README to direct users to alternatives such as MacPorts or
   building from source.

The project must not silently go dormant while continuing to serve bottles.
