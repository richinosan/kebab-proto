# kebab-proto

Kebab の **public API contract** を管理する repository です。

Account / Authentication の private implementation proto とは分離し、他サービスが User identity 解決と token reissue に利用する最小 contract のみを公開します。

## Package

```text
party.kanade.kebab.v1
```

## Public Resources / RPC

| Resource | RPC | 備考 |
|---|---|---|
| `User` | `GetUser` | RBAC identifier 解決用 |
| — | `RefreshSession` | access token reissue（kebab 既存 RPC 名を維持） |

## Public User に含める field

* `id`
* `display_name`
* `image_url`

## Public に含めないもの

* `Identity`
* `PasskeyCredential`
* Firebase / Passkey 登録・認証 RPC
* OAuth authorize / token exchange の内部 detail
* private account metadata

## kebab 実装との対応

| public contract | kebab private (`kebab.auth.v1`) |
|---|---|
| `GetUser` | `AuthenticationService.GetUser` |
| `RefreshSession` | `AuthenticationService.RefreshSession` |

public contract 側で authentication semantics を変更しません。

## Lint

```bash
mise run lint
```
