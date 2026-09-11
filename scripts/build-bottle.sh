#!/bin/sh
# Build a bottle for one approved formula on a dedicated Intel builder.
#
# DESTRUCTIVE: this replaces the host's x86macbrew/x86mac tap with a clone of
# the reviewed checkout, so the build cannot silently use a stale public tap.
# That is correct on a dedicated builder and damaging on a personal machine,
# which is why X86MACBREW_BUILDER=1 must be set explicitly.
set -eu

[ "$#" -eq 1 ] || { printf '%s\n' "usage: $0 <formula>" >&2; exit 64; }
formula=$1
case "$formula" in
  *[!A-Za-z0-9@+_.-]*|'') printf '%s\n' "invalid formula name: $formula" >&2; exit 64 ;;
esac

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
allowlist="$repository_root/config/bottle-build-allowlist.yml"

approved=$(ruby -ryaml -e '
  raw = File.read(ARGV.fetch(0))
  data = if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.1")
           YAML.safe_load(raw, aliases: false)
         else
           YAML.safe_load(raw, [], [], false)
         end
  abort "invalid bottle build allowlist" unless data.is_a?(Hash) && data["approved_formulae"].is_a?(Array)
  data.fetch("approved_formulae").each { |name| puts name }
' "$allowlist")

if ! printf '%s\n' "$approved" | grep -Fx -- "$formula" >/dev/null; then
  printf '%s\n' "refusing bottle build: $formula is not approved in config/bottle-build-allowlist.yml" >&2
  exit 65
fi

"$repository_root/bin/x86macbrew-doctor"

# Build exactly the reviewed checkout. A persistent builder must not silently
# use an old public tap clone when a workflow has checked out a newer revision.
tap=x86macbrew/x86mac

# Replacing the tap destroys whatever the host had installed. Require explicit
# confirmation so running this on a maintainer's own Mac cannot quietly discard
# their real tap. The bottle-build workflow sets this for the builder.
if [ "${X86MACBREW_BUILDER:-}" != "1" ]; then
  printf '%s\n' "refusing to run: this replaces the host's $tap tap with $repository_root" >&2
  printf '%s\n' "set X86MACBREW_BUILDER=1 to confirm this is a dedicated Intel builder" >&2
  exit 78
fi

brew untap --force "$tap" >/dev/null 2>&1 || true
brew tap "$tap" "$repository_root"

# Assert the intent above actually held. If the tap resolved to the public
# repository instead, the build would use unreviewed formulae while reporting
# success, which is the failure this whole section exists to prevent.
tap_root=$(brew --repository "$tap")
tap_origin=$(git -C "$tap_root" remote get-url origin 2>/dev/null || printf '')
if [ "$(cd "$tap_origin" 2>/dev/null && pwd -P)" != "$(cd "$repository_root" && pwd -P)" ]; then
  printf '%s\n' "tap $tap resolves to '$tap_origin', not the reviewed checkout $repository_root" >&2
  exit 70
fi

qualified_formula="$tap/$formula"
brew uninstall --force "$qualified_formula" >/dev/null 2>&1 || true
brew install --build-bottle "$qualified_formula"
brew test "$qualified_formula"
brew audit --strict "$qualified_formula"
brew bottle --json --no-rebuild "$qualified_formula"
