#!/bin/sh
# Behavioural tests for bin/x86macbrew-doctor.
#
# These run on any architecture so CI can catch diagnostic regressions without
# Intel hardware. The checks that genuinely require an Intel host are skipped
# with a reported reason rather than silently passing.
set -eu

repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
doctor="$repository_root/bin/x86macbrew-doctor"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT HUP INT TERM

passed=0
failed=0
skipped=0

ok()   { printf 'ok      %s\n' "$1"; passed=$((passed + 1)); }
bad()  { printf 'FAIL    %s: %s\n' "$1" "$2" >&2; failed=$((failed + 1)); }
skip() { printf 'skip    %s (%s)\n' "$1" "$2"; skipped=$((skipped + 1)); }

# Build an installed-layout tree (bin/ + share/x86macbrew/) so these tests
# exercise the same resolution path Homebrew produces.
make_install_tree() {
  tree=$1; arch=$2; macos=$3; prefix=$4; cpu=$5
  mkdir -p "$tree/bin" "$tree/share/x86macbrew"
  cp "$doctor" "$tree/bin/x86macbrew-doctor"
  cat > "$tree/share/x86macbrew/support.yml" <<YAML
supported:
  architecture: $arch
  prefix: $prefix
  macos_major: '$macos'
  cpu_baseline: $cpu
release_requirements:
  - build_from_source
YAML
}

run() {
  # run <tree> <args...>; sets $out and $status
  tree=$1; shift
  set +e
  out=$("$tree/bin/x86macbrew-doctor" "$@" 2>&1)
  status=$?
  set -e
}

# ---------------------------------------------------------------- option handling
run "$repository_root" --help
if [ "$status" -eq 0 ] && printf '%s' "$out" | grep -q '^usage: x86macbrew-doctor'; then
  ok '--help exits 0 with a usage line'
else
  bad '--help' "status $status, output: $out"
fi

run "$repository_root" --version
case $out in
  "x86macbrew-doctor "*) [ "$status" -eq 0 ] && ok '--version reports a version' || bad '--version' "status $status" ;;
  *) bad '--version' "unexpected output: $out" ;;
esac

run "$repository_root" --bogus
if [ "$status" -eq 64 ]; then
  ok 'unknown option exits 64'
else
  bad 'unknown option' "expected 64, got $status"
fi

# --help must work even when the policy is unreadable, so a broken install can
# still tell the user what the tool is.
bare="$work/bare"; mkdir -p "$bare/bin"; cp "$doctor" "$bare/bin/x86macbrew-doctor"
run "$bare" --help
if [ "$status" -eq 0 ]; then
  ok '--help works without a support policy'
else
  bad '--help without policy' "expected 0, got $status"
fi

run "$bare"
if [ "$status" -eq 2 ]; then
  ok 'missing support policy exits 2'
else
  bad 'missing policy' "expected 2, got $status"
fi

# ------------------------------------------------------------------ failure path
# A policy no host can satisfy must fail closed on every architecture.
impossible="$work/impossible"
make_install_tree "$impossible" nosucharch 99 /nonexistent/prefix NOSUCHFEATURE
run "$impossible"
if [ "$status" -eq 1 ] && printf '%s' "$out" | grep -q '^FAIL'; then
  ok 'unsatisfiable policy exits 1 and reports failures'
else
  bad 'unsatisfiable policy' "expected 1, got $status"
fi

run "$impossible" --json
if [ "$status" -eq 1 ] && printf '%s' "$out" | grep -q '"supported": false'; then
  ok '--json reports supported:false on failure'
else
  bad '--json failure' "status $status, output: $out"
fi

if printf '%s' "$out" | python3 -c 'import json,sys; d=json.load(sys.stdin); sys.exit(0 if len(d["checks"])==4 and d["failed"]==4 else 1)'; then
  ok '--json emits valid JSON with all four checks'
else
  bad '--json validity' "not parseable or wrong check count: $out"
fi

# ------------------------------------------------------------------ success path
# Synthesise a policy describing this host, so the pass path is exercised
# wherever a CPU baseline can actually be read.
host_arch=$(uname -m)
host_macos=$(sw_vers -productVersion 2>/dev/null | cut -d. -f1 || printf 'unknown')
host_prefix=$(brew --prefix 2>/dev/null || printf '')
host_cpu=$(sysctl -n machdep.cpu.features 2>/dev/null | tr ' ' '\n' | head -1 || printf '')

if [ -z "$host_prefix" ]; then
  skip 'host-matching policy passes' 'brew is not installed'
elif [ -z "$host_cpu" ]; then
  skip 'host-matching policy passes' "no machdep.cpu.features on $host_arch"
else
  matching="$work/matching"
  make_install_tree "$matching" "$host_arch" "$host_macos" "$host_prefix" "$host_cpu"
  run "$matching"
  if [ "$status" -eq 0 ] && ! printf '%s' "$out" | grep -q '^FAIL'; then
    ok 'host-matching policy exits 0 with no failures'
  else
    bad 'host-matching policy' "status $status, output: $out"
  fi

  run "$matching" --json
  if printf '%s' "$out" | python3 -c 'import json,sys; d=json.load(sys.stdin); sys.exit(0 if d["supported"] is True and d["failed"]==0 else 1)'; then
    ok '--json reports supported:true when the host matches'
  else
    bad '--json success' "output: $out"
  fi
fi

# Quoted policy values must be unquoted by the parser.
quoted="$work/quoted"
make_install_tree "$quoted" "$host_arch" "$host_macos" "$host_prefix" NOSUCHFEATURE
run "$quoted" --json
if printf '%s' "$out" | grep -q "\"name\": \"macos-major\", \"expected\": \"$host_macos\""; then
  ok "parser strips quotes around policy values"
else
  bad 'quoted policy value' "expected macos_major $host_macos, output: $out"
fi

printf '\n%d passed, %d failed, %d skipped\n' "$passed" "$failed" "$skipped"
[ "$failed" -eq 0 ]
