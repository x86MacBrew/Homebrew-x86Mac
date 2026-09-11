#!/bin/sh
# Regression tests for scripts/check-repository.sh.
#
# A validator that only ever passes is worthless, and a rule that silently
# stops applying is worse than one that never existed. Each case breaks the
# repository in one specific way and asserts the validator rejects it.
set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM

passed=0
failed=0

# One pristine copy, re-cloned per case. dist/ and .git/ are build output and
# history; neither affects validation.
template="$work/template"
mkdir -p "$template"
( cd "$repository_root" && tar -cf - --exclude .git --exclude dist . ) | ( cd "$template" && tar -xf - )

# must_reject <name> <shell fragment that breaks the tree>
must_reject() {
  name=$1; break_it=$2
  case_dir="$work/case"
  rm -rf "$case_dir"
  cp -R "$template" "$case_dir"
  set +e
  ( cd "$case_dir" && eval "$break_it" >/dev/null 2>&1 && scripts/check-repository.sh >/dev/null 2>"$work/err" )
  status=$?
  set -e
  if [ "$status" -ne 0 ]; then
    printf 'ok      rejects %s\n' "$name"
    passed=$((passed + 1))
  else
    printf 'FAIL    accepted %s\n' "$name" >&2
    failed=$((failed + 1))
  fi
}

# The unmodified tree must pass, or every rejection below proves nothing.
if ( cd "$template" && scripts/check-repository.sh >/dev/null 2>&1 ); then
  printf 'ok      accepts the unmodified repository\n'
  passed=$((passed + 1))
else
  printf 'FAIL    unmodified repository does not validate\n' >&2
  failed=$((failed + 1))
fi

# --- formula integrity ----------------------------------------------------
must_reject "a class name that disagrees with the filename" \
  "sed -i '' 's/^class X86macbrewDoctor/class X86macbrewDocttor/' Formula/x86macbrew-doctor.rb"
must_reject "a non-HTTPS formula url" \
  "sed -i '' 's|^  url \"https://|  url \"http://|' Formula/x86macbrew-doctor.rb"
must_reject "a non-HTTPS homepage" \
  "sed -i '' 's|homepage \"https://|homepage \"http://|' Formula/x86macbrew-doctor.rb"
must_reject "a malformed sha256" \
  "sed -i '' 's/^  sha256 \"[0-9a-f]*/  sha256 \"ZZZZ/' Formula/x86macbrew-doctor.rb"
must_reject "an unresolved release placeholder" \
  "sed -i '' 's|^  version \".*\"|  version \"__VERSION__\"|' Formula/x86macbrew-doctor.rb"

# --- tap dependency boundary ---------------------------------------------
must_reject "a dependency on a foreign tap" \
  "printf '%s\\n' 'class ForeignDependency < Formula' '  url \"https://example.com/source.tar.gz\"' '  sha256 \"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef\"' '  depends_on \"someoneelse/tap/oniguruma\"' 'end' > Formula/foreign-dependency.rb"
must_reject "a tap dependency this tap does not define" \
  "printf '%s\\n' 'class MissingDependency < Formula' '  url \"https://example.com/source.tar.gz\"' '  sha256 \"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef\"' '  depends_on \"x86macbrew/x86mac/missinglib\"' 'end' > Formula/missing-dependency.rb"

# --- tap-owned artifacts must be recorded --------------------------------
# These are the fail-open cases: a version bump with no manifest entry must
# not pass merely because no entry was found to compare against.
must_reject "a tap-owned version bump with no manifest entry" \
  "sed -i '' -e 's|^  version \".*\"|  version \"0.9.9\"|' -e 's|^  url \".*\"|  url \"https://github.com/x86MacBrew/Homebrew-x86Mac/releases/download/v0.9.9/evil.tar.gz\"|' Formula/x86macbrew-doctor.rb"
must_reject "a tap-owned formula with no version" \
  "sed -i '' '/^  version \".*\"/d' Formula/x86macbrew-doctor.rb"
must_reject "a swapped tap-owned artifact url" \
  "sed -i '' 's|^  url \".*\"|  url \"https://github.com/x86MacBrew/Homebrew-x86Mac/releases/download/evil.tar.gz\"|' Formula/x86macbrew-doctor.rb"
must_reject "a swapped tap-owned artifact checksum" \
  "sed -i '' 's/^  sha256 \"[0-9a-f]*/  sha256 \"f/' Formula/x86macbrew-doctor.rb"
must_reject "a deleted source_releases entry" \
  "python3 -c \"
import pathlib
p = pathlib.Path('config/release-manifest.yml'); s = p.read_text()
p.write_text(s[:s.index('source_releases:')] + 'source_releases: []\n' + s[s.index('bottles: []'):])\""

# --- source-build tier ----------------------------------------------------
# Every shipped formula must be recorded in exactly one tier, and a source-tier
# entry must not be able to claim bottle status without going through bottles[].
must_reject "a formula with no tier entry at all" \
  "python3 -c \"
import pathlib
p = pathlib.Path('config/release-manifest.yml'); s = p.read_text()
i = s.index('  - formula: jq'); j = s.index('bottles: []')
p.write_text(s[:i] + s[j:])\""
must_reject "a source-tier entry claiming to be bottled" \
  "sed -i '' 's/^    bottled: false/    bottled: true/' config/release-manifest.yml"
must_reject "a source-tier checksum that disagrees with the formula" \
  "sed -i '' 's/    source_sha256: 71b8/    source_sha256: 71b9/' config/release-manifest.yml"
must_reject "a source-tier version that disagrees with the formula" \
  "sed -i '' 's/^    version: 1.8.2/    version: 9.9.9/' config/release-manifest.yml"
must_reject "a source-tier entry for a formula the tap lacks" \
  "sed -i '' 's/^  - formula: jq/  - formula: notshipped/' config/release-manifest.yml"
must_reject "a source-tier entry pointing at missing evidence" \
  "sed -i '' 's|    evidence: docs/evidence/2026-09-11-second-environment-validation.md|    evidence: docs/evidence/nope.md|' config/release-manifest.yml"

# --- manifest schema ------------------------------------------------------
must_reject "a source release with a bad checksum" \
  "sed -i '' 's/    sha256: 86fd.*/    sha256: deadbeef/' config/release-manifest.yml"
must_reject "a source release served over plain HTTP" \
  "sed -i '' 's|    url: https://|    url: http://|' config/release-manifest.yml"
must_reject "a missing manifest key" \
  "sed -i '' '/^bottles: \[\]/d' config/release-manifest.yml"

# --- bottle build authorization ------------------------------------------
must_reject "a bottle allowlist with an unknown formula" \
  "printf 'approved_formulae:\\n  - missing-formula\\n' > config/bottle-build-allowlist.yml"
must_reject "a bottle allowlist with a non-array value" \
  "printf 'approved_formulae: missing-formula\\n' > config/bottle-build-allowlist.yml"

# --- untrusted YAML -------------------------------------------------------
# CI runs this script from the pull request's own checkout, so config files are
# attacker-controlled on a fork PR.
must_reject "a YAML payload naming a Ruby class" \
  "printf 'evil: !ruby/object:Gem::Requirement {}\n' >> config/support.yml"
must_reject "a YAML alias" \
  "printf 'a: &x [1]\nb: *x\n' >> config/support.yml"
must_reject "malformed YAML" \
  "printf 'evil: [unclosed\n' >> config/support.yml"

# --- shell integrity ------------------------------------------------------
must_reject "a syntax error in a shipped script" \
  "printf 'if [ x\n' >> scripts/build-bottle.sh"

printf '\n%d passed, %d failed\n' "$passed" "$failed"
[ "$failed" -eq 0 ]
