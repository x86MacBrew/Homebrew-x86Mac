# Release policy

A bottle may be listed in `config/release-manifest.yml` only after the release attaches its exact formula revision, builder macOS and Xcode versions, SHA-256, source-build log, `brew test` result, clean-host installation log, and runtime smoke test.

The publication key is held outside the self-hosted builder. Builders upload artifacts for review; a protected release job signs and publishes approved artifacts. An emergency withdrawal removes the bottle from the manifest and publishes a signed advisory. It does not delete original evidence.
