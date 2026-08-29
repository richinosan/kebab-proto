# Buf lint

Buf lint lets a contract author confirm every `.proto` file in the auth module satisfies buf STANDARD lint rules before opening a pull request.

## Sub-features

- `lint-auth-module` runs buf lint on the `auth` module declared in `buf.yaml`.
- `lint-zero-exit` requires a clean lint with exit code 0.

## How to get to it (user POV)

- Run `mise run lint` from the repository root.
- Run `buf lint` from the repository root when buf is on PATH through mise.
- Run `verify-kebab-proto drive buf-lint` for recorded evidence.

## Driving it with verify-kebab-proto

Preconditions:

- `verify-kebab-proto doctor` reports all checks as `ok`.
- `RUN_ID` is exported for this verification run.

- **Lint auth module.** Run `verify-kebab-proto drive buf-lint`. Exit code `0` and `stdout.txt` contains no ERROR lines from buf.
- **Proof.** Inspect `tmp/verify-kebab-proto/evidence/$RUN_ID/buf-lint/meta.txt` for `exit_code=0` and `feature_id=buf-lint`.

## Gotchas

- Lint reads `buf.yaml` at the repo root; run commands from the repository root, not `auth/`.
- `buf lint` does not regenerate docs; a lint pass alone does not prove docs are current.
- Fix lint violations in source `.proto` files; do not disable rules without an explicit project decision.
