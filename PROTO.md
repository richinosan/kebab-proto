# Protocol Documentation
<a name="top"></a>

## Table of Contents

- [party/kanade/kebab/v1/user.proto](#party_kanade_kebab_v1_user-proto)
    - [User](#party-kanade-kebab-v1-User)
  
- [party/kanade/kebab/v1/auth_api.proto](#party_kanade_kebab_v1_auth_api-proto)
    - [GetUserRequest](#party-kanade-kebab-v1-GetUserRequest)
    - [GetUserResponse](#party-kanade-kebab-v1-GetUserResponse)
    - [RefreshSessionRequest](#party-kanade-kebab-v1-RefreshSessionRequest)
    - [RefreshSessionResponse](#party-kanade-kebab-v1-RefreshSessionResponse)
  
    - [PublicAuthenticationService](#party-kanade-kebab-v1-PublicAuthenticationService)
  
- [Scalar Value Types](#scalar-value-types)



<a name="party_kanade_kebab_v1_user-proto"></a>
<p align="right"><a href="#top">Top</a></p>

## party/kanade/kebab/v1/user.proto



<a name="party-kanade-kebab-v1-User"></a>

### User
User は公開 User 表現。


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| id | [string](#string) |  |  |
| display_name | [string](#string) |  |  |
| image_url | [string](#string) |  |  |





 

 

 

 



<a name="party_kanade_kebab_v1_auth_api-proto"></a>
<p align="right"><a href="#top">Top</a></p>

## party/kanade/kebab/v1/auth_api.proto



<a name="party-kanade-kebab-v1-GetUserRequest"></a>

### GetUserRequest
GetUserRequest は users/{user_id} 形式で User を取得する。


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| name | [string](#string) |  |  |






<a name="party-kanade-kebab-v1-GetUserResponse"></a>

### GetUserResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| user | [User](#party-kanade-kebab-v1-User) |  |  |






<a name="party-kanade-kebab-v1-RefreshSessionRequest"></a>

### RefreshSessionRequest
RefreshSessionRequest は access token 期限切れ時の token 再発行（reissue）に利用する。


| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| refresh_token | [string](#string) |  |  |
| client_id | [string](#string) |  |  |






<a name="party-kanade-kebab-v1-RefreshSessionResponse"></a>

### RefreshSessionResponse



| Field | Type | Label | Description |
| ----- | ---- | ----- | ----------- |
| access_token | [string](#string) |  |  |
| refresh_token | [string](#string) |  |  |
| expires_in | [int64](#int64) |  |  |
| token_type | [string](#string) |  |  |





 

 

 


<a name="party-kanade-kebab-v1-PublicAuthenticationService"></a>

### PublicAuthenticationService
PublicAuthenticationService は他サービス向けの最小認証 contract。

| Method Name | Request Type | Response Type | Description |
| ----------- | ------------ | ------------- | ------------|
| GetUser | [GetUserRequest](#party-kanade-kebab-v1-GetUserRequest) | [GetUserResponse](#party-kanade-kebab-v1-GetUserResponse) |  |
| RefreshSession | [RefreshSessionRequest](#party-kanade-kebab-v1-RefreshSessionRequest) | [RefreshSessionResponse](#party-kanade-kebab-v1-RefreshSessionResponse) |  |

 



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

