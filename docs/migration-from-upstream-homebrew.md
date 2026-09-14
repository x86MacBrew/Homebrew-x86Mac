# Migration from upstream Homebrew

This guide is for Intel users after upstream Homebrew ends Intel support.

## Preconditions

- Intel Mac (`x86_64`) on supported macOS major version.
- Existing Homebrew-compatible client in `/usr/local`.
- Backup of current package list (`brew bundle dump`).

## Migration path

1. Tap the distribution repository:

   ```sh
   brew tap x86macbrew/x86mac
   ```

2. Install and run the host diagnostic:

   ```sh
   brew install x86macbrew/x86mac/x86macbrew-doctor
   x86macbrew-doctor
   ```

3. Install only formulae in the stable source-build or bottled tiers. For
   example, the current source-build tier includes:

   ```sh
   brew install x86macbrew/x86mac/jq
   ```

4. Treat source-build formulas as local compilation, not as x86MacBrew binary
   releases. No bottles have been published.
5. For formulas outside scope, either keep them self-managed or remove them.
6. Keep a working upstream `/usr/local` client as the bootstrap path until
   x86MacBrew publishes a clean-host-tested client installer and migration
   procedure. Do not substitute a manual Git checkout for that installer.

## Ongoing operations

- Use the stable source-build tier only for the listed formulas. Use published
  bottles only after x86MacBrew actually lists them in the release manifest.
- Re-run `x86macbrew-doctor` after major OS updates or machine changes.
- Follow project advisories for bottle withdrawals or emergency revocations.
