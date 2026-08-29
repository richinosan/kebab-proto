# kebab-proto verification map

This directory is the maintained source for verifying kebab-proto contract tooling. Read this index before driving checks, then open the matching feature file for the recipe.

## Baseline preconditions

- Repository root contains `buf.yaml` and `auth/auth/v1/*.proto`.
- Run `mise install` so `buf` and `protoc-gen-doc` are available through mise.
- Export a disposable `RUN_ID` and put `verify-kebab-proto` on `PATH` from `.cursor/skills/verify-kebab-proto/helpers`.
- Run `verify-kebab-proto doctor` and require all checks to pass.
- Do not treat manual proto edits as proof; drive the same commands CI uses.

## Driving conventions

- Start from a clean git tree unless the feature regenerates docs.
- Run terminal actions through `verify-kebab-proto drive <feature-id>`.
- Keep quoted RPC names, file paths, and mise task names unchanged.
- After every drive (pass or fail), run `verify-kebab-proto cleanup` and confirm evidence remains.

## Proof and skip reporting

- Capture the command, stdout, stderr, and exit code for every drive.
- Contract proof includes `rpc-check.txt` or buf output showing the expected RPCs/messages.
- Docs proof includes whether `auth/README.md` matches generated output after `buf generate`.
- Record `feature_id`, `run_id`, and entry point in each artifact directory.
- Report unreachable features with the attempted command and missing prerequisite.
- Do not mark a feature verified through a different feature's entry point.

## Feature entry contract

Each feature file starts with an H1 title and one paragraph describing the user-visible behavior. It then uses exactly four H2 sections in this order.

1. `Sub-features` lists short IDs with one line for each behavior.
2. `How to get to it (user POV)` lists every user entry point.
3. `Driving it with verify-kebab-proto` starts with `Preconditions:` and uses labeled bullets that pair each action with an exact command and observable result.
4. `Gotchas` lists traps that can waste or invalidate a verification run.

## Features

- [Buf lint](./buf-lint.md) runs `buf lint` across the auth module.
- [Proto docs generate](./proto-docs-generate.md) regenerates `auth/README.md` and checks it matches git.
- [Breaking change check](./breaking-change-check.md) runs `buf breaking` against `origin/main`.
- [Authentication service contract](./authentication-service-contract.md) asserts `AuthenticationService` RPCs and core messages exist.
- [Full check](./full-check.md) runs `mise run check` (lint, generate, breaking).
