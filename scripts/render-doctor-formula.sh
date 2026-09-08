#!/bin/sh
set -eu
[ "$#" -eq 2 ] || { printf '%s\n' "usage: $0 <version> <https-source-release-url>" >&2; exit 64; }
version=$1
release_url=$2
case "$release_url" in https://*) ;; *) printf '%s\n' "release URL must use HTTPS" >&2; exit 64 ;; esac
repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
archive=$(mktemp)
trap 'rm -f "$archive"' EXIT HUP INT TERM
curl --fail --location --proto '=https' --tlsv1.2 --output "$archive" "$release_url"
checksum=$(shasum -a 256 "$archive" | awk '{print $1}')
sed -e "s|__VERSION__|$version|g" -e "s|__RELEASE_URL__|$release_url|g" -e "s|__SHA256__|$checksum|g" "$repository_root/Formula/x86macbrew-doctor.rb.template" > "$repository_root/Formula/x86macbrew-doctor.rb"
printf '%s\n' "Wrote Formula/x86macbrew-doctor.rb with SHA-256 $checksum"
