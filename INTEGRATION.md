# kebab へのサービス統合ガイド

kebab は標準的な OAuth 2.0 Authorization Code フロー(PKCE 必須)を提供する認証基盤です。
kebab を利用してサインインするすべてのサービス(kebab 自身の first-party フロントエンドを含む)は、
このガイドに沿って**自分専用の `client_id` を登録し、標準フローで統合してください**。

## なぜ標準フローに統一するのか

過去に「internal service callback」という簡易ショートカット(`/sign-in?callback=...` で
リダイレクトし、`accessToken`/`refreshToken` を URL クエリパラメータで直接受け取る方式)が
一部の first-party サービス向けに用意されていましたが、これは以下の問題を持っていました。

- 複数のサービスが同じ `client_id`(`'kebab'`)で refresh token を発行してしまい、
  あるサービスでの正常な token rotation が、無関係な別サービスの refresh token を
  reuse 扱いにして session ごと失効させてしまう(意図しない相互ログアウト)
- サービスごとの session の分離・独立した revoke ができない

標準の Authorization Code + PKCE フローでは、`refresh_token`/`refresh_token_families` が
**サービスの `client_id` ごとに完全に分離**されるため、この問題が構造的に起こりません。
新規に統合するサービスは、必ずこちらの標準フローを使ってください。

(internal service callback は既存の統合が残っている間は撤去しませんが、非推奨です。
新規統合では使用しないでください。)

## 1. client_id / redirect_uri の登録

kebab 側の `oauth_clients` / `oauth_client_redirect_uris` テーブルに、以下を登録してもらってください
(現時点ではセルフサービスの登録 UI はなく、kebab のリポジトリ管理者に依頼する形になります)。

- `client_id`: サービスを一意に表す文字列(例: `vitrina`, `ebi-editor`)。他サービスの client_id
  (特に kebab 自身が使う `'kebab'`)を流用しないでください。
- `redirect_uri`: サインイン完了後にユーザーを戻す URL(1つのサービスに複数登録可)

このシステムは public client(client_secret を発行しない、PKCE のみで安全性を担保する方式)を
前提としています。

## 2. サインインを開始する(`/authorize`)

1. ランダムな `code_verifier`(43〜128文字の URL-safe 文字列)を生成し、ブラウザ側に一時保存する
   (例: `sessionStorage`。ページ遷移をまたぐため `localStorage` の変数では保持できません)
2. `code_verifier` から PKCE の `code_challenge` を計算する(`S256`: `code_verifier` を SHA-256
   した結果を base64url エンコード)
3. `state` にも予測不能なランダム値を使い、同様に一時保存する(CSRF対策)
4. 以下のクエリパラメータを付けて `${KEBAB_ISSUER}/authorize` にリダイレクトする

```text
GET {KEBAB_ISSUER}/authorize
  ?client_id={your_client_id}
  &redirect_uri={your_redirect_uri}      // 登録済みの redirect_uri と完全一致させる
  &state={state}
  &code_challenge={code_challenge}
  &code_challenge_method=S256
  &nonce={optional}
  &scope={optional}
```

kebab のサインイン画面(Google / Passkey / メールリンク)を経て、認証に成功すると
`redirect_uri` に `code` と `state` を付けてリダイレクトされます。

## 3. コールバックで `code` を受け取り、`state` を検証する

```text
{your_redirect_uri}?code={code}&state={state}
```

一時保存しておいた `state` と一致することを必ず確認してください。一致しない場合は
リクエストを拒否してください。

## 4. `code` を token と交換する(`/token`)

サーバーサイドから(`code_verifier` を渡す必要があるため、通常はブラウザから直接ではなく、
自サービスのバックエンド経由で呼び出してください)以下を POST します。

```text
POST {KEBAB_ISSUER}/token
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code
&client_id={your_client_id}
&code={code}
&redirect_uri={your_redirect_uri}       // /authorize に渡したものと完全一致させる
&code_verifier={code_verifier}
```

レスポンス(成功時 200):

```json
{
  "access_token": "...",
  "refresh_token": "...",
  "id_token": "...",
  "expires_in": 900,
  "token_type": "Bearer"
}
```

`code` は 5 分で失効し、1 回しか使用できません。

## 5. Refresh Token でトークンを更新する

```text
POST {KEBAB_ISSUER}/token
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token
&client_id={your_client_id}
&refresh_token={refresh_token}
```

**Refresh Token は使用のたびにローテーションします**(新しい `refresh_token` が返るので、
古いものは破棄して新しいものを保存してください)。同一の refresh token に対して自サービス内で
複数箇所から同時に refresh を呼ばないよう、呼び出し側で single-flight にしてください
(同時に複数リクエストが発生し得る場合、kebab 側は最小限の緩和策を持っていますが、
呼び出し側で防ぐのが最も確実です)。

失敗時のレスポンスは概ね以下のいずれかです。

- `400 { "error": "invalid_grant" }` — refresh token が無効・失効・reuse検知済み。
  **この場合は保存している token を破棄し、再サインインを促してください。**
- `503 { "error": "temporarily_unavailable" }` — 一時的な障害。
  **token を破棄せず、リトライしてください。**

## 6. access_token の検証

自サービスのバックエンドで直接 JWT 検証する場合:

- JWKS: `{KEBAB_ISSUER}/.well-known/jwks.json`
- `iss` が kebab の issuer と一致すること
- `aud` が **自分の `client_id`** と一致すること(他サービスの client_id 宛の token を
  受理しないでください)
- カスタムクレーム `token_use` が `"access"` であること(同じ鍵で署名される `id_token` を
  誤って access token として受理しないため)

失効(RevokeSession)は署名検証だけでは検知できないため、即時性が必要な場合は
`AuthenticationService.ValidateToken` RPC を併用してください。

## 7. ログアウト(該当サービスの session のみを失効させる)

`AuthenticationService.RevokeSession(refresh_token)` を呼ぶと、その refresh token が属する
family(= 自サービスの session)のみが失効します。他サービスの session には影響しません。

## まとめ: 守るべきこと

- 自分専用の `client_id` を必ず使う。他サービス(特に `'kebab'`)の `client_id` を流用しない
- `code_verifier` / `state` は必ずサーバーサイドまたはページ遷移をまたげる形で一時保存し、検証する
- refresh token はローテーションのたびに保存し直す。古いものは使い回さない
- `invalid_grant` と `temporarily_unavailable` を区別し、後者では有効な token を破棄しない
