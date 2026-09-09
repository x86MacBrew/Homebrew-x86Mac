#!/bin/sh
set -eu
repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repository_root"
ruby -ryaml <<'RUBY'
SUPPORT_PATH = 'config/support.yml'
MANIFEST_PATH = 'config/release-manifest.yml'

support = YAML.load_file(SUPPORT_PATH)
manifest = YAML.load_file(MANIFEST_PATH)

abort 'FAIL  support policy must be a mapping' unless support.is_a?(Hash)
abort 'FAIL  manifest must be a mapping' unless manifest.is_a?(Hash)

required_support_keys = [
  ['supported', 'architecture'],
  ['supported', 'prefix'],
  ['supported', 'macos_major'],
  ['supported', 'cpu_baseline']
]
required_support_keys.each do |path|
  value = support.dig(*path)
  abort "FAIL  missing support policy value #{path.join('.')}" if value.nil? || value.to_s.empty?
end

requirements = support['release_requirements']
abort 'FAIL  support release_requirements must be a non-empty array' unless requirements.is_a?(Array) && !requirements.empty?

required_manifest_keys = %w[release generated_at support_policy repositories security bottles]
required_manifest_keys.each do |key|
  abort "FAIL  missing manifest key #{key}" unless manifest.key?(key)
end

abort 'FAIL  manifest support_policy must point to config/support.yml' unless manifest['support_policy'] == SUPPORT_PATH

repositories = manifest['repositories']
abort 'FAIL  repositories must be a mapping' unless repositories.is_a?(Hash)
%w[compatibility_client formula_catalogue distribution_tap].each do |key|
  value = repositories[key]
  abort "FAIL  repositories.#{key} must be set" if value.nil? || value.to_s.empty?
end

security = manifest['security']
abort 'FAIL  security must be a mapping' unless security.is_a?(Hash)
%w[advisory_feed signing_key_fingerprint].each do |key|
  abort "FAIL  missing security.#{key}" unless security.key?(key)
end

bottles = manifest['bottles']
abort 'FAIL  bottles must be an array' unless bottles.is_a?(Array)

required_bottle_keys = %w[
  formula
  version
  rebuild
  url
  sha256
  builder_macos
  builder_xcode
  source_build_log
  brew_test_log
  clean_host_install_log
  runtime_smoke_test_log
  provenance
]

seen = {}
bottles.each_with_index do |bottle, index|
  abort "FAIL  bottles[#{index}] must be a mapping" unless bottle.is_a?(Hash)
  required_bottle_keys.each do |key|
    value = bottle[key]
    abort "FAIL  bottles[#{index}].#{key} must be set" if value.nil? || value.to_s.empty?
  end

  abort "FAIL  bottles[#{index}].sha256 must be 64 lowercase hex characters" unless bottle['sha256'].match?(/\A[0-9a-f]{64}\z/)

  %w[url source_build_log brew_test_log clean_host_install_log runtime_smoke_test_log provenance].each do |key|
    abort "FAIL  bottles[#{index}].#{key} must use HTTPS" unless bottle[key].start_with?('https://')
  end

  identity = [bottle['formula'], bottle['version'], bottle['rebuild']]
  abort "FAIL  duplicate bottle entry #{identity.join('@')}" if seen[identity]
  seen[identity] = true
end

puts 'PASS  support policy and release manifest schema'
RUBY
for script in bin/x86macbrew-doctor scripts/*.sh; do sh -n "$script"; done
printf '%s\n' "PASS  shell syntax"
if [ -e Formula/x86macbrew-doctor.rb ]; then
  if grep -q '__[A-Z_]*__' Formula/x86macbrew-doctor.rb; then
    printf '%s\n' "FAIL  generated formula contains unresolved release fields" >&2; exit 1
  fi
  printf '%s\n' "PASS  generated formula has no placeholders"
fi
