# Package status

## Stable public tap

### Bottled tier

**Empty.** No x86MacBrew bottle has been built, verified or published.
`bottles: []` in [config/release-manifest.yml](../config/release-manifest.yml)
is the authoritative statement of that.

### Source-build tier

`brew` compiles these on the user's machine. They are not binaries this project
distributes, and the claim is correspondingly narrow: the source archive
matches a recorded checksum, and the build has been reproduced on the Intel
environments named in the evidence.

| Formula | Version | Environments | Evidence |
| --- | --- | --- | --- |
| `oniguruma` | 6.9.10 | 2 | [second-environment](evidence/2026-09-11-second-environment-validation.md) |
| `jq` | 1.8.2 | 2 | [second-environment](evidence/2026-09-11-second-environment-validation.md) |

Promoted 2026-09-11. Both installed from source, passed `brew test` and
`brew audit --strict`, and `jq` linked against
`/usr/local/opt/oniguruma/lib/libonig.5.dylib` — the tap's dependency, not
jq's bundled Oniguruma fallback. `brew linkage --test` exited 0.

This resolves the dependency-graph question left open by the first builder
record, which had only observed the bundled fallback in a standalone test.

### Project tooling

| Formula | Version | Result |
| --- | --- | --- |
| `x86macbrew-doctor` | 0.2.0 | Released as an unsigned prerelease. The source archive passed reproducibility, extraction and diagnostic checks. |

## Outstanding gates before anything is bottled

Source-build promotion deliberately does **not** clear these:

- **Clean-host installation.** Both validation records ran on the same physical
  machine. A formula silently depending on something already present there
  would pass both and still fail for a new user.
- **A clean Intel macOS volume**, or a second physical Intel Mac.
- **Bottle build, checksum, provenance and clean-host runtime evidence**
  recorded in the release manifest.
- **macOS coverage beyond 15.7.7.** Both records used one OS and one toolchain.

See [release-policy.md](release-policy.md) and
[formula-scope-policy.md](formula-scope-policy.md).
