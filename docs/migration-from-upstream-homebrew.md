# Migration from upstream Homebrew

This guide is for Intel users after upstream Homebrew ends Intel support.

## Preconditions

- Intel Mac (`x86_64`) on supported macOS major version.
- Existing Homebrew-compatible client in `/usr/local`.
- Backup of current package list (`brew bundle dump`).

## Migration path

1. Run `x86macbrew-doctor` and resolve any host compatibility failures.
2. Tap the distribution repository.
3. Install only formulae that are present in the signed release manifest.
4. For formulas outside scope, either keep them self-managed or remove them.
5. When the client fork is announced as required, switch from upstream `brew` to `x86macbrew/brew` using the client repository migration instructions.

## Ongoing operations

- Use only x86MacBrew-published bottle versions for supported packages.
- Re-run `x86macbrew-doctor` after major OS updates or machine changes.
- Follow project advisories for bottle withdrawals or emergency revocations.
