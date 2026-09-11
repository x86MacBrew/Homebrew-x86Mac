# Second-environment validation: `oniguruma` and `jq`

**Status:** second independent environment. This record supports promotion to
the tap's **source-build tier only**. It does not authorize a bottle, and it is
not a clean-volume install.

## Why this is a second environment

The first record
([2026-09-11-intel-builder-candidates.md](2026-09-11-intel-builder-candidates.md))
built both formulae in a fresh isolated workspace prefix using a candidate
client checkout. This run used the host's real Homebrew installation instead,
so the prefix, the client and the tap clone all differ.

| Item | First record | This record |
| --- | --- | --- |
| Prefix | isolated workspace checkout | `/usr/local` |
| Client | `x86MacBrew/brew` `e06501705c` | system Homebrew `6.0.22-253-g23cd203` |
| Tap source | candidate commit `3840974` | stable `ffbfb575` + candidate formulae |
| Architecture | Intel `x86_64` Broadwell | Intel `x86_64` Broadwell |
| macOS | 15.7.7 | 15.7.7 |
| Apple Clang | 17.0.0 (1700.6.4.2) | 17.0.0 (1700.6.4.2) |
| Command Line Tools | 26.3.0.0.1.1769666919 | 26.3.0.0.1.1769666919 |

The macOS release and toolchain are identical, so this is **not** independent
coverage of a different OS or compiler. It is independent coverage of a
different prefix, client and tap state.

## Results

Every command exited 0.

| Formula | Version | install | `brew test` | `brew audit --strict` | Build time |
| --- | --- | --- | --- | --- | --- |
| `oniguruma` | 6.9.10 | pass | pass | pass | 2m52s |
| `jq` | 1.8.2 | pass | pass | pass | 4m54s |

Runtime smoke tests:

```text
onig-config --prefix   ->  /usr/local/Cellar/oniguruma/6.9.10
jq .bar   on {"foo":1,"bar":2}   ->  2
jq --version   ->  jq-1.8.2
```

Linkage, confirming `jq` resolves the tap's `oniguruma` rather than a bundled
fallback:

```text
/usr/local/bin/jq:
  /usr/local/Cellar/jq/1.8.2/lib/libjq.1.dylib
  /usr/lib/libSystem.B.dylib
  /usr/local/opt/oniguruma/lib/libonig.5.dylib
```

`brew linkage --test x86macbrew/x86mac/jq` exited 0.

The tap clone was restored to stable `main` `ffbfb575` with a clean working
tree after the run.

## What this still does not prove

- **No clean host or clean APFS volume was used.** Both records ran on the same
  physical machine, which already had a working toolchain and Homebrew. A
  formula that silently depends on something already present here would pass
  both records and still fail for a new user.
- No bottle was built, so nothing here supports a binary distribution claim.
- macOS 15.7.7 only. No coverage of any other Intel-capable macOS release.

These remain the gates in [../release-policy.md](../release-policy.md) before a
bottle may be listed in `config/release-manifest.yml`.
