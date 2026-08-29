---
name: verify-kebab-proto
description: "Drive kebab-proto contract verification locally via mise and buf — lint protos, generate docs, check breaking changes, and assert AuthenticationService RPCs. Use when proving proto contract changes or CI-equivalent checks without production deploy."
---

# verify-kebab-proto

kebab-proto is a ConnectRPC contract repository, not a running auth server. Verification means driving the same buf/mise tasks CI uses and capturing command evidence. There is no browser, no OAuth flow, and no production endpoint to hit.

## Launch

From the repository root:

```bash
mise install
export RUN_ID="${RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)-$$}"
export PATH="$PWD/.cursor/skills/verify-kebab-proto/helpers:$PATH"
```

Readiness means `mise exec -- buf --version` succeeds and `auth/auth/v1/api.proto` exists. No server stays running between drives.

Teardown is per-run cleanup (see Cleanup). Failed iterations must still call cleanup so scratch dirs do not accumulate.

## Doctor

Run before the first drive and again after any failed drive:

```bash
verify-kebab-proto doctor
```

Require every line to start with `ok` and a final `doctor ok` summary. A failing doctor means the toolchain or repo layout is wrong — fix Launch preconditions before driving.

## Drive

Harness: shell helper `verify-kebab-proto` plus mise/buf commands recorded in feature files.

Pick a feature from `features/README.md`, then:

```bash
verify-kebab-proto drive <feature-id>
```

Example (buf lint):

```bash
verify-kebab-proto drive buf-lint
```

The helper writes evidence under `tmp/verify-kebab-proto/evidence/$RUN_ID/<feature-id>/` with `meta.txt`, `stdout.txt`, and `stderr.txt` (plus feature-specific files such as `rpc-check.txt`).

Drive rules:

- Use the exact feature id from the map.
- Do not edit generated `auth/README.md` during verification unless the feature explicitly regenerates docs.
- `breaking-change-check` fetches `origin/main`; ensure network access to the git remote.
- Prefer one feature per drive invocation; `full-check` is the aggregate recipe.

## Evidence

Proof root:

```text
tmp/verify-kebab-proto/evidence/<RUN_ID>/
```

Standards:

- Exercise the real developer/CI path (`mise run …` or `buf …`), not ad-hoc proto edits.
- Capture command, stdout, stderr, and exit code for each drive.
- For contract checks, capture the RPC/message assertions file (`rpc-check.txt`).
- Record `feature_id`, `run_id`, and entry point in `meta.txt`.
- A zero exit code alone is insufficient when the feature requires generated docs to match committed output — also inspect `docs-diff.*` artifacts for `proto-docs-generate`.

Initialize or print the evidence directory:

```bash
verify-kebab-proto evidence-dir
```

## Cleanup

After each drive (including failed attempts):

```bash
verify-kebab-proto cleanup
```

Cleanup removes only `tmp/verify-kebab-proto/scratch/$RUN_ID` if present. It never deletes `tmp/verify-kebab-proto/evidence/$RUN_ID`. Confirm evidence still exists after cleanup:

```bash
test -d "tmp/verify-kebab-proto/evidence/$RUN_ID"
```

Never kill processes by name; this repo has no verification server to stop.

## Helpers

Script: `.cursor/skills/verify-kebab-proto/helpers/verify-kebab-proto.sh` (must be executable).

```bash
chmod +x .cursor/skills/verify-kebab-proto/helpers/verify-kebab-proto.sh
export PATH="$PWD/.cursor/skills/verify-kebab-proto/helpers:$PATH"

verify-kebab-proto doctor
verify-kebab-proto evidence-dir
verify-kebab-proto drive buf-lint
verify-kebab-proto cleanup
```

Environment variables:

- `RUN_ID` — evidence subdirectory (default: UTC timestamp + pid)
- `KEBAB_PROTO_EVIDENCE_ROOT` — override evidence root (default: `tmp/verify-kebab-proto/evidence` under repo root)

Maintenance: run `/maintain-verification-skill` when protos, mise tasks, or CI change.
