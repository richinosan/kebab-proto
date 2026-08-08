# kebab-proto

Kebab の public API contract を管理する repository です。

ConnectRPC の URL は private 実装と同一です（例: `/auth.v1.AuthenticationService/GetUser`）。

## Package

```text
auth.v1
```

## Layout

```text
auth/
  buf.gen.yaml
  auth/v1/*.proto
```

## ドキュメント

`auth/README.md` を `mise run docs` で生成します。

## 開発

```bash
mise run lint
mise run docs
mise run breaking
mise run check
```
