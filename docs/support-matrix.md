# Support matrix

| Area | Supported | Notes |
| --- | --- | --- |
| Hardware | Intel x86_64 physical Macs | Virtualized and non-Intel systems are out of scope. |
| macOS | Major version 15 | Future major versions require explicit announcement. |
| Homebrew prefix | `/usr/local` | Checked by `x86macbrew-doctor`. |
| CPU baseline | `ssse3` | Checked by `x86macbrew-doctor` against host CPU features. |
| Formula availability | Only artifacts in release manifest | No blanket parity guarantee with upstream package set. |
| Published bottles | **None yet** | The project is pre-general-availability; see [governance.md](governance.md). |
| Artifact signing | Not implemented | Integrity currently rests on recorded SHA-256 values alone. |
| Casks | No | Explicitly out of scope for this continuation tap. |
