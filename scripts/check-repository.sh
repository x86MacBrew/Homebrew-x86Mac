#!/bin/sh
set -eu
repository_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repository_root"
ruby -ryaml -rdate <<'RUBY'
SUPPORT_PATH = 'config/support.yml'
MANIFEST_PATH = 'config/release-manifest.yml'
SHA256 = /\A[0-9a-f]{64}\z/

failures = []
def fail!(failures, message)
  failures << message
end

# YAML.load_file deserialises arbitrary Ruby objects on the Ruby versions this
# project targets. CI runs this script from the pull request's own checkout, so
# the input is untrusted. safe_load takes keywords from 3.1 and positionals
# before that.
def load_yaml(path)
  raw = File.read(path)
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3.1')
    YAML.safe_load(raw, permitted_classes: [Date, Time], aliases: false)
  else
    YAML.safe_load(raw, [Date, Time], [], false)
  end
rescue Psych::DisallowedClass, Psych::BadAlias => e
  abort "FAIL  #{path} contains disallowed YAML content: #{e.message}"
rescue Psych::SyntaxError => e
  abort "FAIL  #{path} is not valid YAML: #{e.message}"
end

support = load_yaml(SUPPORT_PATH)
manifest = load_yaml(MANIFEST_PATH)

abort 'FAIL  support policy must be a mapping' unless support.is_a?(Hash)
abort 'FAIL  manifest must be a mapping' unless manifest.is_a?(Hash)

# ---------------------------------------------------------------- support policy
[
  %w[supported architecture],
  %w[supported prefix],
  %w[supported macos_major],
  %w[supported cpu_baseline]
].each do |path|
  value = support.dig(*path)
  fail!(failures, "missing support policy value #{path.join('.')}") if value.nil? || value.to_s.empty?
end

requirements = support['release_requirements']
unless requirements.is_a?(Array) && !requirements.empty?
  fail!(failures, 'support release_requirements must be a non-empty array')
end

# --------------------------------------------------------------------- manifest
%w[release generated_at support_policy repositories security source_releases bottles].each do |key|
  fail!(failures, "missing manifest key #{key}") unless manifest.key?(key)
end

unless manifest['support_policy'] == SUPPORT_PATH
  fail!(failures, "manifest support_policy must point to #{SUPPORT_PATH}")
end

repositories = manifest['repositories']
if repositories.is_a?(Hash)
  %w[compatibility_client formula_catalogue distribution_tap].each do |key|
    value = repositories[key]
    fail!(failures, "repositories.#{key} must be set") if value.nil? || value.to_s.empty?
  end
else
  fail!(failures, 'repositories must be a mapping')
end

security = manifest['security']
if security.is_a?(Hash)
  %w[advisory_feed signing_key_fingerprint].each do |key|
    fail!(failures, "missing security.#{key}") unless security.key?(key)
  end
else
  fail!(failures, 'security must be a mapping')
end

# -------------------------------------------------------------- source releases
source_releases = manifest['source_releases'] || []
fail!(failures, 'source_releases must be an array') unless source_releases.is_a?(Array)

released = {}
Array(source_releases).each_with_index do |entry, index|
  unless entry.is_a?(Hash)
    fail!(failures, "source_releases[#{index}] must be a mapping")
    next
  end
  %w[artifact version tag url sha256 prerelease signed].each do |key|
    fail!(failures, "source_releases[#{index}].#{key} must be set") unless entry.key?(key)
  end
  unless entry['sha256'].to_s.match?(SHA256)
    fail!(failures, "source_releases[#{index}].sha256 must be 64 lowercase hex characters")
  end
  unless entry['url'].to_s.start_with?('https://')
    fail!(failures, "source_releases[#{index}].url must use HTTPS")
  end
  released[[entry['artifact'], entry['version'].to_s]] = entry
end

# --------------------------------------------------------------------- bottles
bottles = manifest['bottles']
fail!(failures, 'bottles must be an array') unless bottles.is_a?(Array)

required_bottle_keys = %w[
  formula version rebuild url sha256 builder_macos builder_xcode
  source_build_log brew_test_log clean_host_install_log
  runtime_smoke_test_log provenance
]

seen = {}
Array(bottles).each_with_index do |bottle, index|
  unless bottle.is_a?(Hash)
    fail!(failures, "bottles[#{index}] must be a mapping")
    next
  end
  required_bottle_keys.each do |key|
    value = bottle[key]
    fail!(failures, "bottles[#{index}].#{key} must be set") if value.nil? || value.to_s.empty?
  end
  unless bottle['sha256'].to_s.match?(SHA256)
    fail!(failures, "bottles[#{index}].sha256 must be 64 lowercase hex characters")
  end
  %w[url source_build_log brew_test_log clean_host_install_log runtime_smoke_test_log provenance].each do |key|
    next if bottle[key].nil?
    fail!(failures, "bottles[#{index}].#{key} must use HTTPS") unless bottle[key].to_s.start_with?('https://')
  end
  identity = [bottle['formula'], bottle['version'], bottle['rebuild']]
  fail!(failures, "duplicate bottle entry #{identity.join('@')}") if seen[identity]
  seen[identity] = true
end

# --------------------------------------------------------------------- formulae
# Homebrew derives a formula's class name from its filename; a mismatch makes
# the formula unloadable from the tap.
def class_s(name)
  klass = name.capitalize
  klass.gsub!(/[-_.\s]([a-zA-Z0-9])/) { Regexp.last_match(1).upcase }
  klass.tr!('+', 'x')
  klass.sub!(/(.)@(\d)/, '\1AT\2')
  klass
end

formulae = Dir.glob('Formula/**/*.rb').sort
fail!(failures, 'no formulae found under Formula/') if formulae.empty?

formulae.each do |path|
  body = File.read(path)
  stem = File.basename(path, '.rb')

  if body.match?(/__[A-Z][A-Z0-9_]*__/)
    fail!(failures, "#{path} contains unresolved release placeholders")
  end

  expected_class = class_s(stem)
  unless body.match?(/^class #{Regexp.escape(expected_class)} < Formula\b/)
    fail!(failures, "#{path} must define `class #{expected_class} < Formula`")
  end

  body.scan(/^\s*(?:url|homepage|head)\s+"([^"]+)"/) do |(value)|
    next if value.start_with?('https://')
    next if value.start_with?('git+https://')
    fail!(failures, "#{path} references non-HTTPS URL #{value}")
  end

  body.scan(/^\s*sha256\s+"([^"]+)"/) do |(value)|
    fail!(failures, "#{path} has malformed sha256 #{value}") unless value.match?(SHA256)
  end

  # A tap-local dependency must name this tap, or brew resolves it to core.
  body.scan(/^\s*depends_on\s+"([^"]+)"/) do |(value)|
    next unless value.include?('/')
    unless value.start_with?('x86macbrew/x86mac/')
      fail!(failures, "#{path} depends on #{value} outside x86macbrew/x86mac")
    end
    dep = value.split('/').last
    unless formulae.any? { |f| File.basename(f, '.rb') == dep }
      fail!(failures, "#{path} depends on #{value}, which this tap does not define")
    end
  end
end

# A formula this project publishes itself must point at an artifact the
# manifest actually records. Skipping formulae with no matching entry would
# fail open: bumping a version without adding an entry would pass silently.
# Third-party formulae (jq, oniguruma) fetch from their own upstreams and are
# deliberately exempt.
TAP_ARTIFACT_HOST = %r{\Ahttps://github\.com/x86MacBrew/}i

tap_owned = 0
formulae.each do |path|
  body = File.read(path)
  name = File.basename(path, '.rb')
  url = body[/^\s*url\s+"([^"]+)"/, 1]
  next if url.nil? || !url.match?(TAP_ARTIFACT_HOST)

  tap_owned += 1
  version = body[/^\s*version\s+"([^"]+)"/, 1]
  sha = body[/^\s*sha256\s+"([^"]+)"/, 1]

  if version.nil?
    fail!(failures, "#{path} publishes a tap-owned artifact and must declare a version")
    next
  end

  entry = released[[name, version]]
  if entry.nil?
    fail!(failures, "#{path} points at tap-owned #{name} #{version}, which has no source_releases entry")
    next
  end

  unless entry['sha256'] == sha
    fail!(failures, "#{path} sha256 does not match source_releases entry #{name} #{version}")
  end
  unless url == entry['url']
    fail!(failures, "#{path} url does not match source_releases entry #{name} #{version}")
  end
end

if failures.empty?
  puts "PASS  support policy and release manifest schema"
  puts "PASS  #{formulae.length} formula file(s): class name, HTTPS, checksum, tap dependencies"
  puts "PASS  #{tap_owned} tap-owned artifact(s) match their source_releases entry"
else
  failures.each { |message| warn "FAIL  #{message}" }
  abort "#{failures.length} validation failure(s)"
end
RUBY
for script in bin/x86macbrew-doctor scripts/*.sh; do sh -n "$script"; done
printf '%s\n' "PASS  shell syntax"
