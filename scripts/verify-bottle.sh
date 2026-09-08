#!/bin/sh
set -eu
[ "$#" -eq 1 ] || { printf '%s\n' "usage: $0 <formula>" >&2; exit 64; }
repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
"$repository_root/bin/x86macbrew-doctor"
brew install "$1"
brew test "$1"
brew audit --strict "$1"
