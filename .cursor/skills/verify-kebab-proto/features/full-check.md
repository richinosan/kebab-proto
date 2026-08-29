# Full check

Full check lets a contract author run the same aggregate gate as local `mise run check` and CI: lint, generate, and breaking.

## Sub-features

- `check-lint` runs lint as part of `mise run check`.
- `check-generate` runs docs generation as part of `mise run check`.
- `check-breaking` runs breaking comparison as part of `mise run check`.

## How to get to it (user POV)

- Run `mise run check` from the repository root.
- Run `verify-kebab-proto drive full-check` for recorded evidence.

## Driving it with verify-kebab-proto

Preconditions:

- `verify-kebab-proto doctor` reports all checks as `ok`.
- Network access to `origin` is available (breaking step fetches `main`).
- `RUN_ID` is exported for this verification run.

- **Aggregate gate.** Run `verify-kebab-proto drive full-check`. Exit code `0`.
- **Proof.** `stdout.txt` shows lint, generate, and breaking steps completing; `meta.txt` records `exit_code=0` and command `mise run check`.

## Gotchas

- A failure does not identify which sub-step broke; use individual feature drives to debug.
- `mise run check` does not run the CI "docs up to date" git diff step explicitly; run `proto-docs-generate` when doc drift is suspected.
- Prefer individual features while iterating; use full check before opening a PR.
