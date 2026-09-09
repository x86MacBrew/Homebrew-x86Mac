#!/bin/sh
# Build the x86macbrew-doctor source archive for a tagged release.
#
# The archive layout must match what Formula/x86macbrew-doctor.rb.template
# installs: bin/x86macbrew-doctor and config/support.yml.
set -eu
[ "$#" -eq 1 ] || { printf '%s\n' "usage: $0 <version>" >&2; exit 64; }
version=$1
repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repository_root"

declared=$(./bin/x86macbrew-doctor --version | awk '{print $2}')
if [ "$declared" != "$version" ]; then
  printf '%s\n' "refusing to build: bin/x86macbrew-doctor reports $declared, not $version" >&2
  exit 1
fi

scripts/check-repository.sh >/dev/null
scripts/test-doctor.sh >/dev/null

name="x86macbrew-doctor-$version"
staging=$(mktemp -d)
trap 'rm -rf "$staging"' EXIT HUP INT TERM
mkdir -p "$staging/$name"

# Ship the tooling the formula installs plus the documents that describe what
# the user is trusting. Build outputs and history are excluded.
for path in bin config docs scripts Formula .github LICENSE README.md SECURITY.md CONTRIBUTING.md; do
  [ -e "$path" ] && cp -R "$path" "$staging/$name/"
done

mkdir -p dist
archive="dist/$name.tar.gz"

# Make the archive depend only on file contents, so anyone can rebuild it from
# the tag and confirm the published checksum. Three sources of nondeterminism
# have to go: mtimes (cp -R resets them), ownership, and entry order. gzip -n
# drops the timestamp from the gzip header.
find "$staging/$name" -exec touch -t 200001010000.00 {} +
filelist=$(mktemp)
trap 'rm -rf "$staging" "$filelist"' EXIT HUP INT TERM
( cd "$staging" && find "$name" -print ) | LC_ALL=C sort > "$filelist"

# COPYFILE_DISABLE stops macOS tar embedding ._ AppleDouble entries.
# -n stops tar recursing into the directories the file list already names,
# which would otherwise archive every file twice.
COPYFILE_DISABLE=1 tar -cf - -C "$staging" -n \
  --uid 0 --gid 0 --numeric-owner -T "$filelist" | gzip -n -9 > "$archive"

printf '%s\n' "Wrote $archive"
printf 'sha256  %s\n' "$(shasum -a 256 "$archive" | awk '{print $1}')"
printf '%s\n' "Upload this file as a release asset, then run:"
printf '  scripts/render-doctor-formula.sh %s <asset-download-url>\n' "$version"
