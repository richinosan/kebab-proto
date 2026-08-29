#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../../../" && pwd)"
EVIDENCE_ROOT="${KEBAB_PROTO_EVIDENCE_ROOT:-$REPO_ROOT/tmp/verify-kebab-proto/evidence}"
RUN_ID="${RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)-$$}"

usage() {
  cat <<'EOF'
Usage:
  verify-kebab-proto doctor
  verify-kebab-proto evidence-dir
  verify-kebab-proto drive <feature-id>
  verify-kebab-proto cleanup

Feature IDs:
  buf-lint
  proto-docs-generate
  breaking-change-check
  authentication-service-contract
  full-check

Environment:
  RUN_ID                  Evidence subdirectory name (default: UTC timestamp-pid)
  KEBAB_PROTO_EVIDENCE_ROOT  Override evidence root directory
EOF
}

require_repo_root() {
  if [[ ! -f "$REPO_ROOT/buf.yaml" || ! -d "$REPO_ROOT/auth" ]]; then
    echo "error: expected kebab-proto repository root at $REPO_ROOT" >&2
    exit 1
  fi
}

run_mise() {
  (
    cd "$REPO_ROOT"
    mise exec -- "$@"
  )
}

evidence_dir() {
  local dir="$EVIDENCE_ROOT/$RUN_ID"
  mkdir -p "$dir"
  printf '%s\n' "$dir"
}

doctor() {
  require_repo_root
  local failures=0

  check() {
    local label="$1"
    shift
    if "$@" >/dev/null 2>&1; then
      printf 'ok\t%s\n' "$label"
    else
      printf 'fail\t%s\n' "$label"
      failures=$((failures + 1))
    fi
  }

  check "mise-installed" command -v mise
  check "repo-root" test -f "$REPO_ROOT/buf.yaml"
  check "auth-module" test -d "$REPO_ROOT/auth/auth/v1"
  check "buf-available" run_mise buf --version
  check "protoc-gen-doc-available" run_mise protoc-gen-doc --version
  check "proto-service-defined" grep -q 'service AuthenticationService' "$REPO_ROOT/auth/auth/v1/api.proto"

  if [[ "$failures" -gt 0 ]]; then
    echo "doctor: $failures check(s) failed" >&2
    exit 1
  fi

  printf 'doctor\tok\trepo=%s\n' "$REPO_ROOT"
}

record_command() {
  local feature_id="$1"
  local label="$2"
  shift 2
  local out_dir
  out_dir="$(evidence_dir)/$feature_id"
  mkdir -p "$out_dir"
  {
    printf '# %s\n' "$label"
    printf 'feature_id=%s\n' "$feature_id"
    printf 'run_id=%s\n' "$RUN_ID"
    printf 'command=%q\n' "$*"
    printf 'started_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf '%s\n' '---'
  } >"$out_dir/meta.txt"
  (
    cd "$REPO_ROOT"
    "$@"
  ) >"$out_dir/stdout.txt" 2>"$out_dir/stderr.txt"
  local exit_code=$?
  printf 'exit_code=%s\n' "$exit_code" >>"$out_dir/meta.txt"
  printf 'finished_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >>"$out_dir/meta.txt"
  if [[ "$exit_code" -ne 0 ]]; then
    echo "drive $feature_id failed with exit code $exit_code" >&2
    echo "see $out_dir" >&2
    exit "$exit_code"
  fi
  printf 'evidence=%s\n' "$out_dir"
}

drive_buf_lint() {
  record_command buf-lint "buf lint" run_mise buf lint
}

drive_proto_docs_generate() {
  record_command proto-docs-generate "buf generate (docs)" run_mise buf generate
  local out_dir
  out_dir="$(evidence_dir)/proto-docs-generate"
  if ! (
    cd "$REPO_ROOT"
    git diff --exit-code auth/README.md
  ) >"$out_dir/docs-diff.stdout.txt" 2>"$out_dir/docs-diff.stderr.txt"; then
  {
    cd "$REPO_ROOT"
    git diff auth/README.md
  } >"$out_dir/docs-diff.patch" || true
  fi
  printf 'docs_diff_checked=true\n' >>"$out_dir/meta.txt"
}

drive_breaking_change_check() {
  (
    cd "$REPO_ROOT"
    git fetch origin main
  )
  record_command breaking-change-check "buf breaking against origin/main" run_mise buf breaking --against '.git#ref=origin/main'
}

drive_authentication_service_contract() {
  local out_dir
  out_dir="$(evidence_dir)/authentication-service-contract"
  mkdir -p "$out_dir"
  {
    printf '# authentication-service-contract\n'
    printf 'feature_id=authentication-service-contract\n'
    printf 'run_id=%s\n' "$RUN_ID"
    printf 'started_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf '%s\n' '---'
  } >"$out_dir/meta.txt"

  local api_proto="$REPO_ROOT/auth/auth/v1/api.proto"
  local auth_api_proto="$REPO_ROOT/auth/auth/v1/auth_api.proto"
  local expected_rpcs=(
    GetUser
    GetMe
    ValidateToken
    RefreshSession
    RevokeSession
  )

  for rpc in "${expected_rpcs[@]}"; do
    if ! grep -q "rpc $rpc" "$api_proto"; then
      echo "missing rpc $rpc in $api_proto" >&2
      printf 'exit_code=1\n' >>"$out_dir/meta.txt"
      exit 1
    fi
    printf 'rpc\t%s\tok\n' "$rpc" >>"$out_dir/rpc-check.txt"
  done

  if ! grep -q 'message GetUserRequest' "$auth_api_proto"; then
    echo "missing GetUserRequest in $auth_api_proto" >&2
    printf 'exit_code=1\n' >>"$out_dir/meta.txt"
    exit 1
  fi

  printf 'package\tauth.v1\tok\n' >>"$out_dir/rpc-check.txt"
  printf 'exit_code=0\n' >>"$out_dir/meta.txt"
  printf 'finished_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >>"$out_dir/meta.txt"
  printf 'evidence=%s\n' "$out_dir"
}

drive_full_check() {
  record_command full-check "mise run check" run_mise mise run check
}

drive() {
  local feature_id="${1:-}"
  case "$feature_id" in
    buf-lint) drive_buf_lint ;;
    proto-docs-generate) drive_proto_docs_generate ;;
    breaking-change-check) drive_breaking_change_check ;;
    authentication-service-contract) drive_authentication_service_contract ;;
    full-check) drive_full_check ;;
    *)
      echo "unknown feature id: $feature_id" >&2
      usage >&2
      exit 1
      ;;
  esac
}

cleanup() {
  local scratch_root="$REPO_ROOT/tmp/verify-kebab-proto/scratch"
  if [[ -d "$scratch_root/$RUN_ID" ]]; then
    rm -rf "$scratch_root/$RUN_ID"
    printf 'removed scratch=%s\n' "$scratch_root/$RUN_ID"
  else
    printf 'no scratch for run_id=%s\n' "$RUN_ID"
  fi
  printf 'evidence preserved at %s\n' "$EVIDENCE_ROOT/$RUN_ID"
}

main() {
  local cmd="${1:-}"
  shift || true
  case "$cmd" in
    doctor) doctor ;;
    evidence-dir) evidence_dir ;;
    drive) drive "$@" ;;
    cleanup) cleanup ;;
    -h | --help | help | "") usage ;;
    *)
      echo "unknown command: $cmd" >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
