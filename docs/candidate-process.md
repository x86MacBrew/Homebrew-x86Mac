# Candidate process

How a formula moves from "someone wants it" to something users can install.
Each step raises the claim being made, and each has to be earned separately.

## Tiers

| Stage | Where it lives | Claim made | Recorded in |
| --- | --- | --- | --- |
| Candidate | `candidates/<name>` branch | None. Checksum pinned while evaluated. | `candidate_formulae` |
| Source build | `main` | Source matches a checksum; build reproduced on named Intel environments. | `source_build_formulae` |
| Bottled | `main` | A binary this project built, tested on a clean host, and vouches for. | `bottles` |

`main` must always carry `candidate_formulae: []`. `scripts/check-stable-branch.sh`
enforces that in CI, so a candidate cannot reach users by being merged.

## Choosing a candidate

Upstream Homebrew no longer builds Intel bottles, so **every dependency is
compiled on the user's machine**. Dependency closure is therefore user compile
time, and it is the main selection criterion.

```sh
brew deps --formula <name>                 # runtime closure
brew deps --include-build --formula <name> # what the user actually compiles
```

Avoid formulae whose build closure pulls a language toolchain. As of
2026-09-11, `ripgrep`, `fd` and `bat` each pull Rust — 17 to 25 build
dependencies including LLVM — which makes them poor source-tier candidates
regardless of their popularity.

## Opening a candidate

1. Branch from `main`: `git switch -c candidates/<name> origin/main`.
2. Add the formula under `Formula/<first-letter>/<name>.rb`.
3. Add an entry to `candidate_formulae` with `formula`, `version`,
   `source_sha256` and `status: candidate`. The checksum must match the
   formula, and `scripts/check-repository.sh` will fail if it does not.
4. Push the branch. Do not open a pull request to `main` yet.

## Validating a candidate

Run on an Intel host meeting the support policy:

```sh
brew install --build-from-source x86macbrew/x86mac/<name>
brew test x86macbrew/x86mac/<name>
brew audit --strict x86macbrew/x86mac/<name>
brew linkage --test x86macbrew/x86mac/<name>
```

Then a runtime smoke test that exercises the tool's actual purpose, and
`otool -L` on the installed binary to confirm it links what the formula
declares rather than a bundled fallback.

Record the result in `docs/evidence/<date>-<subject>.md`, including what the
run does **not** prove. An evidence file that only lists passes is not useful
for deciding whether to promote.

## Promoting to the source-build tier

Requires the above reproduced on **at least two independent Intel
environments**, then:

1. Move the entry from `candidate_formulae` to `source_build_formulae`, adding
   `bottled: false`, `independent_environments` and `evidence`.
2. Open a pull request to `main`.
3. Delete the candidate branch once merged, so no second copy of the formula
   can drift.

## Promoting to the bottled tier

Requires everything above plus the clean-host gates in
[release-policy.md](release-policy.md), and the formula must be named in
`config/bottle-build-allowlist.yml` before a builder will build it.
