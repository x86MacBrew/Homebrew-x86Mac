# Security policy

x86MacBrew distributes software that executes on users' machines. Treat every
report as potentially affecting the integrity of an installed system.

## Scope

This policy covers:

- `x86macbrew/homebrew-x86mac` — this distribution tap, its formulae, scripts,
  workflows, release manifest, and any published artifact.
- `x86macbrew/brew` — the compatibility client fork.
- `x86macbrew/homebrew-core` — the formula catalogue fork.

It does not cover upstream Homebrew, upstream package sources, or macOS itself.
Report those to their own maintainers.

## Reporting a vulnerability

Use GitHub's private vulnerability reporting on the affected repository
(**Security → Report a vulnerability**). Do not open a public issue for a
report that would let someone compromise an installation before a fix exists.

Please include the affected artifact and version, the host macOS and
architecture, reproduction steps, and what an attacker gains.

**Acknowledgement target: 48 hours.** The project currently has a single
maintainer; see [docs/governance.md](docs/governance.md) for what that means for
response capacity.

## Current security posture

Be aware of these limitations before depending on the project:

- **Artifacts are not signed.** No signing key exists yet. Integrity today
  rests only on the SHA-256 values recorded in
  [config/release-manifest.yml](config/release-manifest.yml) and in each formula.
- **No advisory feed exists yet.** Withdrawals would currently be announced only
  through this repository.
- **No bottles have been published.** There is no binary distribution to
  compromise at present.
- **`main` is not branch-protected.**

These are tracked as general-availability gates in
[docs/governance.md](docs/governance.md).

## Verifying what you install

Every supported artifact is recorded in `config/release-manifest.yml` with its
SHA-256. An artifact that is not listed there is not supported, regardless of
what appears on the releases page.

```sh
shasum -a 256 <downloaded-file>
```

Compare the result against the manifest entry before trusting the file.

## Withdrawal process

When an artifact must be withdrawn:

1. Remove its entry from `config/release-manifest.yml`.
2. Publish an advisory naming the artifact, version, and the reason.
3. Preserve the original build and verification evidence; withdrawal does not
   delete the audit trail.

## Build infrastructure

Self-hosted Intel builders are treated as untrusted for publication authority.
They produce artifacts; a separate protected environment reviews and publishes
them. Bottle builds run only on manual dispatch and never on pull-request code,
so an untrusted contribution cannot execute on a persistent builder.
