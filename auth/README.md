# Protocol Documentation
<a name="top"></a>

## Table of Contents

- [auth/v1/user.proto](#auth_v1_user-proto)
    - [SessionTokens](#auth-v1-SessionTokens)
    - [User](#auth-v1-User)
  
- [auth/v1/auth_api.proto](#auth_v1_auth_api-proto)
    - [GetMeRequest](#auth-v1-GetMeRequest)
    - [GetMeResponse](#auth-v1-GetMeResponse)
    - [GetUserRequest](#auth-v1-GetUserRequest)
    - [GetUserResponse](#auth-v1-GetUserResponse)
    - [RefreshSessionRequest](#auth-v1-RefreshSessionRequest)
    - [RefreshSessionResponse](#auth-v1-RefreshSessionResponse)
    - [RevokeSessionRequest](#auth-v1-RevokeSessionRequest)
    - [RevokeSessionResponse](#auth-v1-RevokeSessionResponse)
    - [ValidateTokenRequest](#auth-v1-ValidateTokenRequest)
    - [ValidateTokenResponse](#auth-v1-ValidateTokenResponse)
  
- [auth/v1/api.proto](#auth_v1_api-proto)
    - [AuthenticationService](#auth-v1-AuthenticationService)
  
- [Scalar Value Types](#scalar-value-types)



<a name="auth_v1_user-proto"></a>
<p align="right"><a href="#top">Top</a></p>

## auth/v1/user.proto



<a name="auth-v1-SessionTokens"></a>

### SessionTokens
SessionTokens は token 再発行結果。


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| access_token | [string](#string) |  |  |
| refresh_token | [string](#string) |  |  |
| id_token | [string](#string) |  |  |
| expires_in | [int64](#int64) |  |  |
| token_type | [string](#string) |  |  |






<a name="auth-v1-User"></a>

### User
User は User リソースの公開表現。


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| id | [string](#string) |  |  |
| display_name | [string](#string) |  |  |
| image_url | [string](#string) |  |  |
| username | [string](#string) |  | username はユーザー自身が指定する一意な識別子。id と異なり、 ユーザーが設定・変更できる。未設定の場合は空文字列を返す。 |





 

 

 

 



<a name="auth_v1_auth_api-proto"></a>
<p align="right"><a href="#top">Top</a></p>

## auth/v1/auth_api.proto



<a name="auth-v1-GetMeRequest"></a>

### GetMeRequest
GetMeRequest は access_token の主体(呼び出し元自身)の User を取得する。

GetUser(users/{id_or_username}) と異なり、呼び出し元が自分自身の id /
username を事前に知らなくても、Authorization ヘッダの access_token だけで
自分の User を取得できる。未認証(access_token が不正・期限切れ・失効済み)
の場合は Unauthenticated を返す。






<a name="auth-v1-GetMeResponse"></a>

### GetMeResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| user | [User](#auth-v1-User) |  |  |






<a name="auth-v1-GetUserRequest"></a>

### GetUserRequest
GetUserRequest は users/{user_id} 形式で User を取得する。
{user_id} には内部 id または username（User.username、ユーザー自身が
指定する識別子）のいずれかを指定できる。


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| name | [string](#string) |  |  |






<a name="auth-v1-GetUserResponse"></a>

### GetUserResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| user | [User](#auth-v1-User) |  |  |






<a name="auth-v1-RefreshSessionRequest"></a>

### RefreshSessionRequest
RefreshSessionRequest は Refresh Token を更新する。


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| refresh_token | [string](#string) |  |  |
| client_id | [string](#string) |  |  |






<a name="auth-v1-RefreshSessionResponse"></a>

### RefreshSessionResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| tokens | [SessionTokens](#auth-v1-SessionTokens) |  |  |






<a name="auth-v1-RevokeSessionRequest"></a>

### RevokeSessionRequest
RevokeSessionRequest はセッションを失効する。


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| refresh_token | [string](#string) |  |  |






<a name="auth-v1-RevokeSessionResponse"></a>

### RevokeSessionResponse







<a name="auth-v1-ValidateTokenRequest"></a>

### ValidateTokenRequest
ValidateTokenRequest は access_token の有効性を検証する。

access_token は kebab の JWKS で署名検証できるため、通常はサービス側で
直接検証すれば十分だが、JWT の署名検証だけでは RevokeSession による
失効を即座には検知できない。ValidateToken は失効チェックを含めた
検証結果を返す、署名検証を代替しないセカンダリの検証手段。


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| access_token | [string](#string) |  | 検証対象の access_token(id_token / refresh_token は対象外)。 |






<a name="auth-v1-ValidateTokenResponse"></a>

### ValidateTokenResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| valid | [bool](#bool) |  | access_token が有効(署名・期限が正しく、かつ失効していない)なら true。 |
| user_id | [string](#string) |  | valid が true の場合の、トークンの主体(User.id)。 |





 

 

 

 



<a name="auth_v1_api-proto"></a>
<p align="right"><a href="#top">Top</a></p>

## auth/v1/api.proto


 

 

 


<a name="auth-v1-AuthenticationService"></a>

### AuthenticationService
AuthenticationService は認証 API を提供する。

| Method Name | Request Type | Response Type | Description |
| ----------- | ------------ | ------------- | ------------|
| GetUser | [GetUserRequest](#auth-v1-GetUserRequest) | [GetUserResponse](#auth-v1-GetUserResponse) |  |
| GetMe | [GetMeRequest](#auth-v1-GetMeRequest) | [GetMeResponse](#auth-v1-GetMeResponse) |  |
| ValidateToken | [ValidateTokenRequest](#auth-v1-ValidateTokenRequest) | [ValidateTokenResponse](#auth-v1-ValidateTokenResponse) |  |
| RefreshSession | [RefreshSessionRequest](#auth-v1-RefreshSessionRequest) | [RefreshSessionResponse](#auth-v1-RefreshSessionResponse) |  |
| RevokeSession | [RevokeSessionRequest](#auth-v1-RevokeSessionRequest) | [RevokeSessionResponse](#auth-v1-RevokeSessionResponse) |  |

 



## Scalar Value Types

| .proto Type | Notes | C++ | Java | Python | Go | C# | PHP | Ruby |
| ----------- | ----- | --- | ---- | ------ | -- | -- | --- | ---- |
| <a name="double" /> double |  | double | double | float | float64 | double | float | Float |
| <a name="float" /> float |  | float | float | float | float32 | float | float | Float |
| <a name="int32" /> int32 | Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint32 instead. | int32 | int | int | int32 | int | integer | Bignum or Fixnum (as required) |
| <a name="int64" /> int64 | Uses variable-length encoding. Inefficient for encoding negative numbers – if your field is likely to have negative values, use sint64 instead. | int64 | long | int/long | int64 | long | integer/string | Bignum |
| <a name="uint32" /> uint32 | Uses variable-length encoding. | uint32 | int | int/long | uint32 | uint | integer | Bignum or Fixnum (as required) |
| <a name="uint64" /> uint64 | Uses variable-length encoding. | uint64 | long | int/long | uint64 | ulong | integer/string | Bignum or Fixnum (as required) |
| <a name="sint32" /> sint32 | Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int32s. | int32 | int | int | int32 | int | integer | Bignum or Fixnum (as required) |
| <a name="sint64" /> sint64 | Uses variable-length encoding. Signed int value. These more efficiently encode negative numbers than regular int64s. | int64 | long | int/long | int64 | long | integer/string | Bignum |
| <a name="fixed32" /> fixed32 | Always four bytes. More efficient than uint32 if values are often greater than 2^28. | uint32 | int | int | uint32 | uint | integer | Bignum or Fixnum (as required) |
| <a name="fixed64" /> fixed64 | Always eight bytes. More efficient than uint64 if values are often greater than 2^56. | uint64 | long | int/long | uint64 | ulong | integer/string | Bignum |
| <a name="sfixed32" /> sfixed32 | Always four bytes. | int32 | int | int | int32 | int | integer | Bignum or Fixnum (as required) |
| <a name="sfixed64" /> sfixed64 | Always eight bytes. | int64 | long | int/long | int64 | long | integer/string | Bignum |
| <a name="bool" /> bool |  | bool | boolean | boolean | bool | bool | boolean | TrueClass/FalseClass |
| <a name="string" /> string | A string must always contain UTF-8 encoded or 7-bit ASCII text. | string | String | str/unicode | string | string | string | String (UTF-8) |
| <a name="bytes" /> bytes | May contain any arbitrary sequence of bytes. | string | ByteString | str | []byte | ByteString | string | String (ASCII-8BIT) |

