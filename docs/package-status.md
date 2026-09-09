# Package status

## Stable public tap

| Formula | Version | Target | Dependency closure | Result |
| --- | --- | --- | --- | --- |
| `x86macbrew-doctor` | 0.2.0 | Intel macOS 15 | None | Released as an unsigned prerelease. The v0.2.0 source archive passed reproducibility, extraction, and diagnostic checks. |

## Candidate branch

`oniguruma` 6.9.10 and `jq` 1.8.2 are retained on the
[`candidates/jq-oniguruma`](https://github.com/x86MacBrew/Homebrew-x86Mac/tree/candidates/jq-oniguruma)
branch. They are not shipped from `main` and are not supported for users.

| Formula | Direct-build observation | Promotion blocker |
| --- | --- | --- |
| `oniguruma` | The upstream release's generated `configure` script built on Intel macOS 15 and `onig-config --prefix` passed. | Install and test through the actual x86MacBrew tap on a clean host. |
| `jq` | The source release built and returned `2` for `.bar`; this standalone test used jq's bundled Oniguruma fallback. | Verify the public formula's explicit x86MacBrew Oniguruma dependency graph on a clean host. |

No x86MacBrew bottles have been published. A formula is promoted to `main`
only after the source build, formula test, clean-host installation, runtime
smoke test, artifact checksum, and provenance evidence are complete.
