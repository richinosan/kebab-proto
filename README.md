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

## TypeScript の生成物と配布

`mise run generate`(`mise run docs` のエイリアス)を実行すると、`auth/gen/es/**` に
`protoc-gen-es`(`target=ts`)で生成した TypeScript も出力されます。`gen/es/` はリポジトリに
コミットしません(利用側で都度生成する前提のため)。

このリポジトリの proto を利用する方法は主に2通りあります。

1. **このリポジトリを直接参照して生成する**: このリポジトリを clone し、`mise run generate`
   (内部的には `buf generate`。プラグインは `@bufbuild/protoc-gen-es@2.12.1`)を実行して
   `auth/gen/es/**` を得る。依存先で `@bufbuild/protobuf` / `@connectrpc/connect` が必要。
2. **raw な `.proto` を自分のリポジトリに取り込んで生成する**(private な kebab が採用している
   方法): `.proto` ファイルのみをコピーし、取り込み側の `buf generate` 設定
   (`packages/gen-buf` など)で生成する。private の `internal.proto` / `internal_service.proto`
   をこの public proto にマージする必要がある取り込み側はこちらが適する。

いずれの方法でも、生成対象には `GetMe` / `ValidateToken` を含む `auth/auth/v1/*.proto` 配下の
全メッセージ・RPC が含まれます。

## 開発

```bash
mise run lint
mise run docs
mise run breaking
mise run check
```
