# Authentication service contract

Authentication service contract lets a contract author confirm the public `AuthenticationService` RPC surface and core request messages remain defined in source protos.

## Sub-features

- `contract-rpcs` asserts `GetUser`, `GetMe`, `ValidateToken`, `RefreshSession`, and `RevokeSession` RPCs exist.
- `contract-get-user-request` asserts `GetUserRequest` is defined in `auth_api.proto`.
- `contract-package` records package `auth.v1` alignment.

## How to get to it (user POV)

- Read `auth/auth/v1/api.proto` and `auth/auth/v1/auth_api.proto` manually.
- Run `verify-kebab-proto drive authentication-service-contract` for recorded assertions.

## Driving it with verify-kebab-proto

Preconditions:

- `verify-kebab-proto doctor` reports all checks as `ok`.
- `RUN_ID` is exported for this verification run.

- **RPC surface.** Run `verify-kebab-proto drive authentication-service-contract`. Exit code `0`.
- **Assertion log.** `rpc-check.txt` lists each expected RPC with `ok` and includes `package auth.v1 ok`.
- **Proof.** `meta.txt` records `exit_code=0` and `feature_id=authentication-service-contract`.

## Gotchas

- This is a source contract check, not a live ConnectRPC call — no tokens or network endpoints are involved.
- Renaming or removing RPCs requires updating this feature map and consumer services together.
- Message field semantics are not validated here; use buf lint and breaking checks for schema rules.
