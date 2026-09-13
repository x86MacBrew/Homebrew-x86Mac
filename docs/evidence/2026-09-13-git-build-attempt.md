# Git candidate foreground build attempt

**Status:** incomplete candidate evidence. This record does not support a
source-build promotion, bottle build or user-support claim for `git`.

## Environment

| Item | Value |
| --- | --- |
| Date | 2026-09-13 |
| Candidate branch | `candidates/git` at `5dd9a68` |
| Client branch | `x86macbrew-intel-2027` at `796ece7ac0` |
| Host | Intel `x86_64` Broadwell, macOS 15.7.7 |
| Command Line Tools | 26.3.0.0.1.1769666919 |
| Apple Clang | 17.0.0, build 1700.6.4.2 |
| Prefix | Isolated x86MacBrew workspace prefix, not `/usr/local` |

The candidate validation script switched only the isolated tap clone to
`candidates/git` and restored it to stable `main` after the attempt. The normal
system Homebrew installation was not changed.

## Requested source closure

`brew deps --include-build --formula x86macbrew/x86mac/git` reported:

```text
cmake gettext json-c libunistring pcre2 pkgconf
```

Before the attempt, the isolated prefix already contained `cmake`, `json-c` and
`libunistring`. The foreground run began by building the remaining `gettext`,
`pkgconf` and `pcre2` dependencies from source.

## Result

The run reached the nested `gettext-runtime` Autoconf configuration stage but
did not complete it after more than twenty minutes. No `gettext` Cellar entry,
`git` installation, `brew test`, strict audit, linkage test or runtime smoke
test completed.

Homebrew launched the formula build subprocess at nice level 10. An attempt to
raise that user-owned subprocess to normal priority was denied by macOS without
elevated privileges. The build was therefore stopped deliberately rather than
allowed to repeat the prior multi-hour low-priority attempt.

The validation harness preserved an install log and was corrected so each
future build, test, audit and linkage command records its own real exit status.
It no longer reports the exit status of a trailing `tail` command.

## What this does and does not show

- It confirms that the Git candidate formula resolves to the expected source
  closure in the Intel client and that the candidate tap can be selected and
  restored safely in an isolated prefix.
- It does **not** show that Git cannot build on Intel macOS.
- It does show that the current source-tier path has an unmeasured and
  potentially impractical `gettext` configuration cost on this host.
- The candidate must remain in `candidate_formulae` until a complete
  foreground source build, formula test, strict audit, linkage test and runtime
  smoke test exist on two independent Intel environments.

## Next attempt requirements

1. Run in a foreground terminal or dedicated builder where the process is not
   background-throttled.
2. Preserve the per-step logs emitted by the corrected validation harness.
3. Record actual wall-clock duration only after a complete successful or failed
   run. Do not quote an estimate from this abandoned attempt.
4. If the build remains impractical, keep `git` as a candidate and prioritize
   the bottle pipeline instead of promoting it on incomplete evidence.
