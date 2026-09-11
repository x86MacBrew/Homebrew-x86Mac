#!/bin/sh
# Assert the invariants that must hold on the stable branch specifically.
#
# check-repository.sh validates any branch. This adds the rules that only make
# sense for main, so a candidate cannot reach users by being merged.
set -eu
repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repository_root"

ruby -ryaml -rdate <<'RUBY'
raw = File.read('config/release-manifest.yml')
manifest = if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.1')
             YAML.safe_load(raw, permitted_classes: [Date, Time], aliases: false)
           else
             YAML.safe_load(raw, [Date, Time], [], false)
           end

failures = []

candidates = manifest['candidate_formulae']
unless candidates.is_a?(Array) && candidates.empty?
  named = Array(candidates).map { |c| c.is_a?(Hash) ? c['formula'] : c }.join(', ')
  failures << "candidate_formulae must be empty on the stable branch (found: #{named})"
end

# A bottle entry on stable without the evidence keys would be a support claim
# with nothing behind it. check-repository.sh already enforces the schema; this
# is the belt-and-braces check that stable never ships an unreviewed bottle.
Array(manifest['bottles']).each do |bottle|
  next unless bottle.is_a?(Hash)
  %w[clean_host_install_log runtime_smoke_test_log provenance].each do |key|
    failures << "bottle #{bottle['formula']} on stable is missing #{key}" if bottle[key].to_s.empty?
  end
end

if failures.empty?
  puts 'PASS  stable branch invariants'
else
  failures.each { |f| warn "FAIL  #{f}" }
  abort "#{failures.length} stable-branch violation(s)"
end
RUBY
