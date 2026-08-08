# kebab-proto

Kebab の public API contract を管理する repository です。

## Package

```text
kebab.v1
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

`PROTO.md` は `mise run generate` で生成します。

## 開発

```bash
mise run lint
mise run generate
mise run breaking
mise run check
```
