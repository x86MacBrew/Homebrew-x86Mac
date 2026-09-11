# Package status

## Stable public tap

| Formula | Version | Target | Dependency closure | Result |
| --- | --- | --- | --- | --- |
| `x86macbrew-doctor` | 0.2.0 | Intel macOS 15 | None | Released as an unsigned prerelease. The v0.2.0 source archive passed reproducibility, extraction, and diagnostic checks. |

## Candidate branch

`oniguruma` 6.9.10 and `jq` 1.8.2 are retained on the
[`candidates/jq-oniguruma`](https://github.com/x86MacBrew/Homebrew-x86Mac/tree/candidates/jq-oniguruma)
branch. They are not shipped from `main` and are not supported for users.

| Formula | First-builder observation | Promotion blocker |
| --- | --- | --- |
| `oniguruma` | In a fresh isolated x86MacBrew client prefix on Intel macOS 15.7.7 with CLT 26.3: source install, `brew test`, `brew audit --strict`, and `onig-config --prefix` passed. | Independent clean-host install and runtime test; bottle build, provenance, and verification before any bottle publication. |
| `jq` | In that same prefix, the public candidate formula built against the explicit x86MacBrew `oniguruma` dependency. Source install, `brew test`, `brew audit --strict`, `jq .bar`, and dynamic linkage to `opt/oniguruma/lib/libonig.5.dylib` passed. | Independent clean-host install and runtime test; bottle build, provenance, and verification before any bottle publication. |

No x86MacBrew bottles have been published. A formula is promoted to `main`
only after the source build, formula test, clean-host installation, runtime
smoke test, artifact checksum, and provenance evidence are complete.
