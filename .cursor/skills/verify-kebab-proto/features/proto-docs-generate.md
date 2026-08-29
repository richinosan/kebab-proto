# Proto docs generate

Proto docs generate lets a contract author regenerate markdown API documentation from protos and confirm committed docs match generator output.

## Sub-features

- `docs-generate` runs `buf generate` inside `auth/` via mise.
- `docs-committed` requires `auth/README.md` to match generated output (no git diff).

## How to get to it (user POV)

- Run `mise run docs` from the repository root.
- Run `mise run generate` (alias) from the repository root.
- Run `verify-kebab-proto drive proto-docs-generate` for recorded evidence.

## Driving it with verify-kebab-proto

Preconditions:

- `verify-kebab-proto doctor` reports all checks as `ok`.
- `RUN_ID` is exported for this verification run.

- **Generate docs.** Run `verify-kebab-proto drive proto-docs-generate`. Exit code `0` from `buf generate`.
- **Committed output.** After generation, `git diff --exit-code auth/README.md` must succeed. When diff is non-zero, `docs-diff.patch` is written under the evidence directory for inspection.
- **Proof.** `meta.txt` records `exit_code=0` and `docs_diff_checked=true`. No `docs-diff.patch` file means committed docs already matched.

## Gotchas

- Generation overwrites `auth/README.md`; commit intentional doc updates separately from verification scaffolding.
- CI fails when generated docs drift; always inspect diff artifacts instead of assuming success from exit code alone.
- `protoc-gen-doc` must be available through mise (`doctor` checks this).
