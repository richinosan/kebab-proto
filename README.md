# kebab-proto

Kebab の public API contract を管理する repository です。

## Package

```text
kebab.auth.v1
```

## Resources

| Resource | RPC |
|---|---|
| `User` | `GetUser` |
| — | `RefreshSession` |

## User fields

* `id`
* `display_name`
* `image_url`

## ドキュメント

`authapis/README.md` を `mise run docs` で生成します。

## 開発

```bash
mise run lint
mise run docs
mise run breaking
mise run check
```
