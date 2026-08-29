# Breaking change check

Breaking change check lets a contract author confirm proto edits do not break wire or schema compatibility against `main`.

## Sub-features

- `breaking-fetch-main` fetches `origin/main` before comparison.
- `breaking-compare` runs `buf breaking` with FILE rules against `origin/main`.
- `breaking-zero-exit` requires no breaking changes reported.

## How to get to it (user POV)

- Run `mise run breaking` from the repository root after `git fetch origin main`.
- Run `verify-kebab-proto drive breaking-change-check` for recorded evidence.

## Driving it with verify-kebab-proto

Preconditions:

- `verify-kebab-proto doctor` reports all checks as `ok`.
- Network access to `origin` is available for `git fetch`.
- `RUN_ID` is exported for this verification run.

- **Fetch and compare.** Run `verify-kebab-proto drive breaking-change-check`. Exit code `0` and `stdout.txt` shows no breaking change violations.
- **Proof.** `meta.txt` records `exit_code=0` and command `buf breaking --against '.git#ref=origin/main'`.

## Gotchas

- Breaking rules use `FILE` semantics from root `buf.yaml`; compare against the correct remote ref.
- If `main` has no `.proto` files yet, project CI may skip breaking — this repo expects protos on `main`.
- Intentional breaking changes require a explicit release process; a failing drive is a real compatibility signal.
