# First Intel builder validation: `oniguruma` and `jq`

**Status:** candidate evidence only. This record does not authorize promotion
to `main`, bottle publication, or a user-support claim.

## Builder and source identity

| Item | Value |
| --- | --- |
| Date | 2026-09-11 |
| Host architecture | Intel `x86_64` (Broadwell) |
| Host macOS | 15.7.7 |
| Command Line Tools | 26.3.0.0.1.1769666919 |
| Apple Clang | 17.0.0, build 1700.6.4.2 |
| Client source | `x86MacBrew/brew` commit `e06501705c661d12432e2e49fd4de6c146ad4178` |
| Tap candidate source | `x86MacBrew/Homebrew-x86Mac` commit `3840974` |
| Test prefix | Fresh isolated workspace checkout; not `/usr/local` |

The test client tapped `x86macbrew/x86mac`, fetched
`candidates/jq-oniguruma`, and checked out candidate commit `3840974` in its
private tap clone. The system Homebrew installation and stable x86MacBrew tap
were not modified.

## Formula source identity

| Formula | Version | Source SHA-256 |
| --- | --- | --- |
| `oniguruma` | 6.9.10 | `2a5cfc5ae259e4e97f86b68dfffc152cdaffe94e2060b770cb827238d769fc05` |
| `jq` | 1.8.2 | `71b8d6e8f5fe81f6c6d0d110e3892251f6ce76ed095abd315e26e6e1193af3af` |

`jq` declares `depends_on "x86macbrew/x86mac/oniguruma"`. The linked `jq`
binary resolved `libonig.5.dylib` from the same isolated prefix's
`opt/oniguruma/lib` directory.

## Commands and results

Both commands below exited with status 0:

```sh
HOMEBREW_NO_AUTO_UPDATE=1 bin/brew install --build-from-source \
  x86macbrew/x86mac/oniguruma
HOMEBREW_NO_AUTO_UPDATE=1 bin/brew test x86macbrew/x86mac/oniguruma
HOMEBREW_NO_AUTO_UPDATE=1 bin/brew audit --strict \
  x86macbrew/x86mac/oniguruma

HOMEBREW_NO_AUTO_UPDATE=1 bin/brew install --build-from-source \
  x86macbrew/x86mac/jq
HOMEBREW_NO_AUTO_UPDATE=1 bin/brew test x86macbrew/x86mac/jq
HOMEBREW_NO_AUTO_UPDATE=1 bin/brew audit --strict x86macbrew/x86mac/jq
```

Runtime smoke tests passed:

```sh
onig-config --prefix
# returned the isolated oniguruma Cellar prefix

printf '%s\n' '{"foo":1,"bar":2}' | jq .bar
# returned: 2
```

`otool -L` showed the `jq` executable linked to its own `libjq.1.dylib`, the
isolated `opt/oniguruma/lib/libonig.5.dylib`, and `/usr/lib/libSystem.B.dylib`.

## What this proves

- The candidate client/tap/formula dependency path works on one Intel macOS 15
  builder.
- Both source archives download, verify, configure, build, install, test, and
  pass strict formula audit in that environment.
- `jq` uses the intended x86MacBrew `oniguruma` dependency rather than its
  bundled fallback.

## What remains before promotion

- Install each candidate on an independent clean Intel host or genuinely clean
  Intel macOS test volume.
- Run the same formula and runtime tests there.
- Build a bottle only after the clean-host source-install gate passes.
- Record bottle SHA-256, exact build inputs, install result, and runtime smoke
  result in the release manifest and provenance record.
- Obtain review and promote each formula separately. This record does not make
  `jq` or `oniguruma` stable public-tap packages.
