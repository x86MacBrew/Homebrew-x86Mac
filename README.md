# x86MacBrew

x86MacBrew is an independent continuation project for Intel x86_64 Macs. It preserves familiar Homebrew formula workflows while separating three pieces that must be maintained independently:

| Component | Repository | Responsibility |
| --- | --- | --- |
| Compatibility client | `x86macbrew/brew` | Keep the `brew` command runnable on Intel macOS after upstream removal. |
| Formula catalogue | `x86macbrew/homebrew-core` | Carry formula revisions and Intel-specific fixes. |
| This distribution tap | `x86macbrew/homebrew-x86mac` | Publish approved Intel bottles and the `x86macbrew-doctor` tooling. |

This repository is the distribution tap. It is useful immediately as a host eligibility check and release tool; it must be published under a real GitHub organisation before users can install it with `brew tap`.

## Initial contract

**Supported:** physical Intel Macs (`x86_64`) on macOS 15, a Homebrew-compatible client at `/usr/local`, and formulae explicitly listed in a versioned release manifest.

**Not promised:** every upstream formula, casks, macOS security updates, or a bottle that has not passed installation testing on a clean target host.

## User workflow

After the repository and its first source release exist:

```sh
brew tap x86macbrew/x86mac
brew install x86macbrew/x86mac/x86macbrew-doctor
x86macbrew-doctor
```

The generated formula is not committed until the source archive is released and its SHA-256 is known. That prevents a placeholder formula from appearing installable.

## Maintainer release workflow

1. Run `scripts/check-repository.sh` before review.
2. On each isolated Intel builder, run `scripts/build-bottle.sh <formula>`.
3. Install the resulting bottle on a clean Intel macOS 15 test host with `scripts/verify-bottle.sh <formula>`.
4. Add the verified bottle URL and SHA-256 to `config/release-manifest.yml`.
5. Create a versioned `x86macbrew-doctor` source release, then run `scripts/render-doctor-formula.sh VERSION RELEASE_URL` and commit its output.
6. Publish only from a protected release environment after reviewing the manifest, bottle checksums, logs, and provenance.

## Client fork timing

Until upstream removes the Intel client, a third-party tap can use the existing `brew` program. Before that removal, freeze a known-good upstream revision, make `x86macbrew/brew` CI pass on the supported Intel target, and change this tap's install guidance to use that client. Formula metadata stays separate so client maintenance does not become a permanent fork of the catalogue.

See [the architecture decision record](docs/ADR-001-continuation-boundary.md) and [release policy](docs/release-policy.md).
