# Package status

## Source-build validation

| Formula | Version | Target | Dependency closure | Result |
| --- | --- | --- | --- | --- |
| `x86macbrew-doctor` | 0.1.0 | Intel macOS 15 | None | Installed from the public tap and passed its support-contract diagnostic. |
| `oniguruma` | 6.9.10 | Intel macOS 15 | None | Built from the upstream release's generated `configure` script and passed `onig-config --prefix`. |
| `jq` | 1.8.2 | Intel macOS 15 | `x86macbrew/x86mac/oniguruma` | Source release built and returned `2` for `.bar`; the standalone test used jq's bundled Oniguruma fallback, while the formula explicitly requests the tap-local dependency. |

These entries are source-build candidates only. No x86MacBrew bottles have
been published for them yet. A formula becomes bottle-supported only after a
clean-host installation, runtime test, uploaded bottle, checksum, and release
manifest entry.
