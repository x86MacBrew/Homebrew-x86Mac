#!/bin/sh
set -eu
repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repository_root"
ruby -ryaml -e 'YAML.load_file(ARGV.fetch(0)); YAML.load_file(ARGV.fetch(1)); puts "PASS  YAML policy and manifest parse"' config/support.yml config/release-manifest.yml
for script in bin/x86macbrew-doctor scripts/*.sh; do sh -n "$script"; done
printf '%s\n' "PASS  shell syntax"
if [ -e Formula/x86macbrew-doctor.rb ]; then
  if grep -q '__[A-Z_]*__' Formula/x86macbrew-doctor.rb; then
    printf '%s\n' "FAIL  generated formula contains unresolved release fields" >&2; exit 1
  fi
  printf '%s\n' "PASS  generated formula has no placeholders"
fi
