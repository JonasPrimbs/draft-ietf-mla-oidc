# Workflow

This document describes a typical workflow starting at the authentication and authorization, obtaining the Remote ID Token, and performing an End-to-End Authentication.

## 1. Obtain Authorization

The Relying Party MUST obtain authorization to request a Remote ID Token.
This MUST be done using the Authorization Code Grant as specified in [RFC 6749, Section 4.1](https://www.rfc-editor.org/rfc/rfc6749.html#section-4.1) with the Proof Key for Code Exchange (PKCE) as specified in [RFC 7636](https://www.rfc-editor.org/rfc/rfc7636.html).

Therefore, the Relying Party first generates a Code Verifier from which it derives a Code Challenge.
Then, the Relying Party performs an Authorization Request to the OpenID Provider with the Code Challenge to obtain an Authorization Code.
Together with the Code Verifier, the Relying Party uses the Authorization Code and performs a Token Request to obtain an OAuth Access Token.

```
+-----------------+  +-------------+  +-----------------+
|  Relying Party  |  | User  Agent |  | OpenID Provider |
+-----------------+  +-------------+  +-----------------+
        |                   |                   |
  (1.1) |                   |                   |
        |       (1.2)       |       (1.2)       |
        | ----------------> | ----------------> |
        |                   |                   |
        |                   |                   | (1.3)
        |       (1.4)       |       (1.4)       |
        | <---------------- | <---------------- |
        |                   V                   |
  (1.5) |                                       |
        |                 (1.6)                 |
        | ------------------------------------> |
        |                                       |
        |                                       | (1.7)
        |                 (1.8)                 |
        | <------------------------------------ |
        |                                       |
  (1.9) |                                       |
        |                                       |
        V                                       V
```
Authorization Code Flow described in the following sections.

### 1.1. PKCE Preparation

The Relying Party generates a Code Verifier by generating a random string consisting of alphanumeric (A-Z, a-z, 0-9) characters and "-", ".", "_", or "~", e.g.:

```js
verifier = "ZMf0FMz9yBWpDyZYqyFwkLD9q_WAD0mY"
```

Then, the Relying Party derives a Code Challenge from the Code Verifier by hashing it with SHA-256, e.g.:

```js
challenge = sha256(verifier) = "a61f9d75848cb989dbf61998dd9d74745f36ed70ab57ccb880b02972d4c85f57"
```

The resulting Code Challenge Method for the SHA-256 algorithm is `S256`.

### 1.2. Authorization Request

To obtain a Remote ID Token, the Relying Party MUST request access to the Scope `openid`.
Other optional Scopes may be requested to obtain access to specific identity claims.
The standard scopes are specified in the [OpenID Connect Core Specification, Section 5.4](https://openid.net/specs/openid-connect-core-1_0.html#ScopeClaims) and in the [OpenID Connect Core Specification, Section 11](https://openid.net/specs/openid-connect-core-1_0.html#OfflineAccess).
The standard claims are specified in the [OpenID Connect Core Specification, Section 5.1](https://openid.net/specs/openid-connect-core-1_0.html#StandardClaims).

The Authorization Request parameters are derived from [RFC 6749, Section 4.1.1](https://www.rfc-editor.org/rfc/rfc6749.html#section-4.1.1), [OpenID Connect Core Specification, Section 3.1.2.1](https://openid.net/specs/openid-connect-core-1_0.html#AuthRequest), and [RFC 7636, Section 4.3](https://www.rfc-editor.org/rfc/rfc7636#section-4.3):

- `client_id`: REQUIRED. The OAuth 2.0 Client Identifier valid at the Authorization Server as described in [RFC 6749, Section 2.2](https://www.rfc-editor.org/rfc/rfc6749.html#section-2.2).
- `response_type`: REQUIRED. The OAuth 2.0 Response Type that determines the authorization processing flow to be used, including what parameters are returned from the endpoints used. Value MUST be set to `code` to use the Authorization Code Flow.
- `redirect_uri`: REQUIRED. The Redirection URI as described in [RFC 6749, Section 3.1.2](https://www.rfc-editor.org/rfc/rfc6749.html#section-3.1.2) to which the response will be sent. This URI MUST exactly match one of the Redirection URI values for the Client pre-registered at the OpenID Provider, with the matching performed as described in [RFC 3986, Section 6.2.1](https://www.rfc-editor.org/rfc/rfc3986.html#section-6.2.1). When using this flow, the Redirection URI SHOULD use the `https` scheme; however, it MAY use the `http` scheme, provided that the Client Type is `confidential`, as defined in [RFC 6749, Section 2.1](https://www.rfc-editor.org/rfc/rfc6749.html#section-2.1), and provided the OpenID Provider allows the use of `http` Redirection URIs in this case. The Redirection URI MAY use an alternative scheme, such as one that is intended to identify a callback into a native application.
- `scope`: REQUIRED. Scopes of the access request as described in [RFC 6749, Section 3.3](https://www.rfc-editor.org/rfc/rfc6749.html#section-3.3). Value MUST contain the Scope `openid`. Otherwise, the behavior is entirely unspecified. Other scope values MAY be present. Scope values used that are not understood by an implementation SHOULD be ignored. 
- `state`: RECOMMENDED. An opaque value used by the Relying Party to maintain state between the request and callback. The OpenID Provider includes this value when redirecting the user-agent back to the Relying Party. The parameter SHOULD be used for preventing Cross-Site Request Forgery (CSRF, XSRF) as described in [RFC 6749, Section 10.12](https://www.rfc-editor.org/rfc/rfc6749.html#section-10.12). Typically, such a CSRF mitigation is done by cryptographically binding the value of this parameter with a browser cookie.
- `code_challenge`: REQUIRED. The Code Challenge as described in [RFC 7636, Section 4.2](https://www.rfc-editor.org/rfc/rfc7636#section-4.2).
- `code_challenge_method`: OPTIONAL. The Code Challenge Method as described in [RFC 7636, Section 4.2](https://www.rfc-editor.org/rfc/rfc7636#section-4.2). It defaults to `plain` if not present in the request. Code Verifier transformation method is `S256` or `plain`.
- `nonce`: OPTIONAL. String value used to associate a Client session with an ID Token, and to mitigate replay attacks. The value is passed through unmodified from the Authentication Request to the ID Token. Sufficient entropy MUST be present in the `nonce` values used to prevent attackers from guessing values. For implementation notes, see [OpenID Connect Core Specification, Section 15.5.2](https://openid.net/specs/openid-connect-core-1_0.html#NonceNotes).

Other attributes which are described in the [OpenID Connect Core specification, Section 3.1.2.1](https://openid.net/specs/openid-connect-core-1_0.html#AuthRequest) MAY also be present.

The following example shows an HTTP Authorization Request for the Scopes `openid`, `profile`, and `email` of the Relying Party `client.example.org` to the OpenID Provider `accounts.example.org` (with line wraps within values for display purposes only):
```http
GET /authorize?
  client_id=client.example.org
  &response_type=code
  &redirect_uri=https%3A%2F%2Fclient.example.org%2F
  &scope=openid+profile+email
  &state=IasEdu47wMmAfYpJZ14fY2pEyyk3vO2o
  &code_challenge=a61f9d75848cb989dbf61998dd9d74745f36ed70ab57ccb880b02972d4c85f57
  &code_challenge_method=S256
  &nonce=vkZArEMheNHaoWpE5Se50Jszl_t03jvJ HTTP/1.1
Host: accounts.example.org
```

### 1.3. Authorization Request Validation

As stated in [RFC 6749, Section 4.1.2](https://www.rfc-editor.org/rfc/rfc6749.html#section-4.1.2) and [OpenID Connect Core Specification, Section 3.1.2.2](https://openid.net/specs/openid-connect-core-1_0.html#AuthRequestValidation), the OpenID Provider MUST validate the Authentication Request as follows:

1. Verify that the `client_id` is valid and is associated with the provided `redirect_uri`.
2. Associate the `client_id` with the `redirect_uri`, the `scope`, the `state`, the `nonce`, the `code_challenge`, and the `code_challenge_method`.
3. Verify that a `scope` parameter is present and contains the `openid` Scope value. If no `openid` Scope value is present, the request may still be a valid OAuth 2.0 request, but is not an OpenID Connect request, hence the resulting Access Token will be not sufficient to request a Remote ID Token.
4. Verify that all the REQUIRED parameters are present and their usage conforms to this specification.
5. Verify the End User's Identity, e.g., by checking active sessions or asking for credentials.
6. Let the End User grant access to the requested scopes.

### 1.4. Authorization Response

After successful authentication of the End User and authorization by the End User, the OpenID Provider responds with an Authorization Code.

The Authorization Response parameters are derived from [RFC 6749, Section 4.1.2](https://www.rfc-editor.org/rfc/rfc6749.html#section-4.1.2):

- `code`: REQUIRED. The Authorization Code generated by the OpenID Provider. The Authorization Code MUST expire shortly after it is issued (e.g., after 30 seconds) to mitigate the risk of leaks. A maximum Authorization Code lifetime of 10 minutes is RECOMMENDED. The Relying Party MUST NOT use the Authorization Code more than once. If an Authorization Code is used more than once, the OpenID Provider MUST deny the request and SHOULD revoke (when possible) all tokens previously issued based on that Authorization Code. The Authorization Code is bound to the Client Identifier `client_id` and Redirection URI `redirect_uri`.
- `state`: REQUIRED, if the `state` parameter was present in the Relying Party's Authorization Request. The exact value received from the Relying Party.

The following example shows an HTTP Authorization Response (with line wraps within values for display purposes only):
```http
HTTP/1.1 302 Found
Location: https://client.example.org/?
  code=4soGSp+Uchk+KET2N8P27yUQKfaIGPN0
  &state=IasEdu47wMmAfYpJZ14fY2pEyyk3vO2o
```

### 1.5. Authorization Response Validation

The Relying Party SHOULD verify that the `state` parameter of the Authorization Response matches the `state` parameter from the Authorization Request before it performs the Token Request.

### 1.6. Token Request

After the Relying Party obtained an Authorization Code, it exchanges the Authorization Code for an Access Token, an ID Token, and optionally a Refresh Token at the OpenID Provider.
Therefore, it sends a Token Request directly to the Token Endpoint of the OpenID Provider.

The Token Request parameters are derived from [RFC 6749, Section 4.1.3](https://www.rfc-editor.org/rfc/rfc6749.html#section-4.1.3), [RFC 7636, Section 4.5](https://www.rfc-editor.org/rfc/rfc7636#section-4.5), and [OpenID Connect Core Specification, Section 3.1.3.1](https://openid.net/specs/openid-connect-core-1_0.html#TokenRequest):

- `grant_type`: REQUIRED. Value MUST be set to `authorization code`.
- `code`: REQUIRED. The Authorization Code received from the OpenID Provider in the `code` query parameter.
- `redirect_uri`: REQUIRED, if the `redirect_uri` parameter was included in the Authorization Request as described in [RFC 6749, Section 4.1.1](https://www.rfc-editor.org/rfc/rfc6749.html#section-4.1.1). Their values MUST be identical.
- `client_id`: REQUIRED, if the Relying Party is not authenticating with the OpenID Provider as described in [RFC 6749, Section 3.2.1](https://www.rfc-editor.org/rfc/rfc6749.html#section-3.2.1).
- `code_verifier`: REQUIRED. Code Verifier.

The following example shows an HTTP Token Request to the OpenID Provider's (`accounts.example.org`) Token Endpoint `/token` (with line wraps within values for display purposes only):
```http
POST /token HTTP/1.1
Host: accounts.example.org
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code
&code=4soGSp+Uchk+KET2N8P27yUQKfaIGPN0
&redirect_uri=https%3A%2F%2Fclient.example.org%2F
&client_id=client.example.org
&code_verifier=ZMf0FMz9yBWpDyZYqyFwkLD9q_WAD0mY
```

### 1.7. Token Request Validation

As stated in [RFC 6749, Section 4.1.3](https://www.rfc-editor.org/rfc/rfc6749.html#section-4.1.3), [RFC 7636, Section 4.6](https://www.rfc-editor.org/rfc/rfc7636#section-4.6), and [OpenID Connect Core Specification, Section 3.1.3.2](https://openid.net/specs/openid-connect-core-1_0.html#TokenRequestValidation), the OpenID Provider MUST validate the Token Request as follows:

1. Authenticate the Client if it was issued Client Credentials or if it uses another Client Authentication method, per [OpenID Connect Core Specification, Section 9](https://openid.net/specs/openid-connect-core-1_0.html#ClientAuthentication).
2. Ensure the Authorization Code was issued to the authenticated Client by verifying the `redirect_uri` and `client_id`.
3. Verify that the Authorization Code is valid.
4. Verify that the `code_verifier` is valid by comparing `sha256(code_verifier)` with the `code_challenge` associated with the Authorization Code.
5. If possible, verify that the Authorization Code has not been previously used.
6. Ensure that the `redirect_uri` parameter value is identical to the `redirect_uri` parameter value that was included in the initial Authorization Request as described in [RFC 6749, Section 4.1.1](https://www.rfc-editor.org/rfc/rfc6749.html#section-4.1.1). If the `redirect_uri` parameter value is not present when there is only one registered `redirect_uri` value, the OpenID Provider MAY return an error (since the Relying Party should have included the parameter) or MAY proceed without an error (since OAuth 2.0 permits the parameter to be omitted in this case).
7. Verify that the Authorization Code used was issued in response to an OpenID Connect Authentication Request (so that an ID Token will be returned from the Token Endpoint).

### 1.8. Token Response

If the Token Request was valid, the OpenID Provider issues an OAuth Access Token and an OpenID Connect ID Token in the Token Response.

The Token Request parameters are derived from [RFC 6749, Section 5.1](https://www.rfc-editor.org/rfc/rfc6749.html#section-5.1) and [OpenID Connect Core Specification, Section 3.1.3.3](https://openid.net/specs/openid-connect-core-1_0.html#TokenResponse):

- `access_token`: REQUIRED. The Access Token.
- `token_type`: REQUIRED. The type of the token issued as described in [RFC 6749, Section 7.1](https://www.rfc-editor.org/rfc/rfc6749.html#section-7.1). Value is case insensitive and MUST be `bearer`.
- `expires_in`: RECOMMENDED. The lifetime in seconds of the Access Token. For example, the value `3600` denotes that the Access Token will expire in one hour from the time the response was generated. If omitted, the authorization server SHOULD provide the expiration time via other means or document the default value.
- `refresh_token`: The Refresh Token, which can be used to obtain new Access Tokens using the same Authorization Grant as described in [RFC 6749, Section 6](https://www.rfc-editor.org/rfc/rfc6749.html#section-6).
- `scope`: OPTIONAL, if identical to the Scope requested by the Relying Party; otherwise REQUIRED. The space delimited Scopes of the Access Token as described in [RFC 6749, Section 3.3](https://www.rfc-editor.org/rfc/rfc6749.html#section-3.3).
- `id_token`: REQUIRED, if the Scope `openid` was provided in the Token Request. ID Token value associated with the authenticated session.

Also, the OpenID Provider MAY add the following HTTP Headers according to [RFC 6749, Section 5.1](https://www.rfc-editor.org/rfc/rfc6749.html#section-5.1):

- `Cache-Control`: REQUIRED. Value MUST be `no-store` to prevent caching this response. See [Cache-Control Documentation](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control).
- `Pragma`: REQUIRED. Value MUST be `no-cache` to force user-agents to prevent caching. See [Pragma Documentation](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Pragma).

The following example shows an HTTP Access Token Response (with line wraps within values for display purposes only):
```http
HTTP/1.1 200 OK
Date: Mon, 1 Aug 2022 12:00:00 UTC
Content-Type: application/json; charset=UTF-8
Cache-Control: no-store
Pragma: no-cache

{
  "access_token": "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6MSwianRpIjoid001QWo3ZTdBYlpSb1hDemZja3NhTTdhQW50QUNZeHoifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmV4YW1wbGUub3JnLyIsInN1YiI6ImpvaG4uc21pdGhAYWNjb3VudHMuZXhhbXBsZS5vcmciLCJhdWQiOiJodHRwczovL2FjY291bnRzLmV4YW1wbGUub3JnLyIsImlhdCI6MTY1OTM1NTIwMCwibmJmIjoxNjU5MzU1MjAwLCJleHAiOjE2NTkzNTg4MDAsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwifQ.pB00n8KtCmOPqEDC16_szsn383JoZfpbFQsjhjX_bybYYzo0X7LcbFiC2JJ3uraypQ_4DEWiaDDY7ZJdNt6Brg",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "b0CbyzkDUNbCOmKS8BqB8FOaBNTVpWIz",
  "scope": "openid profile email",
  "id_token": "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6MX0.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmV4YW1wbGUub3JnLyIsInN1YiI6ImpvaG4uc21pdGhAYWNjb3VudHMuZXhhbXBsZS5vcmciLCJhdWQiOiJjbGllbnQuZXhhbXBsZS5vcmciLCJpYXQiOjE2NTkzNTUyMDAsIm5iZiI6MTY1OTM1NTIwMCwiZXhwIjoxNjU5MzU4ODAwLCJhdF9oYXNoIjoiV18tUEtfWng5eG81TmdWSEo0MkQyUSIsIm5vbmNlIjoidmtaQXJFTWhlTkhhb1dwRTVTZTUwSnN6bF90MDNqdkoiLCJuYW1lIjoiSm9obiBTbWl0aCIsImdpdmVuX25hbWUiOiJKb2huIiwiZmFtaWx5X25hbWUiOiJTbWl0aCIsImVtYWlsIjoiam9obi5zbWl0aEBtYWlsLmV4YW1wbGUub3JnIiwiZW1haWxfdmVyaWZpZWQiOnRydWV9.7_3S0FMRRtbA_0V5u8z2m0sN6Qu2IvNuWR2yiJi5Xdqw0lqSr8OAH_aC1-UzoD_JiITd400C7JaoASUPuPOfsg"
}
```

### 1.9. Token Response Validation

As described in [RFC 6749, Section 5.1](https://www.rfc-editor.org/rfc/rfc6749.html#section-5.1), [RFC 6749, Section 10.12](https://www.rfc-editor.org/rfc/rfc6749.html#section-10.12), and [OpenID Connect Core Specification, Section 3.1.3.5](https://openid.net/specs/openid-connect-core-1_0.html#TokenResponseValidation), the Relying Party MUST validate the Token Response as follows:

1. Verify that the REQUIRED parameters are contained. Unrecognized parameters MUST be ignored. The sizes of the tokens are undefined so the Relying Party should avoid making assumptions about its sizes.
2. Follow the ID Token validation rules in [OpenID Connect Core Specification, Section 3.1.3.7](https://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation).
3. Follow the Access Token validation rules in [OpenID Connect Core Specification, Section 3.1.3.8](https://openid.net/specs/openid-connect-core-1_0.html#CodeFlowTokenValidation).

## 2. Obtain a Remote ID Token

The Relying Party MUST obtain a Remote ID Token in order to authenticate end-to-end to other parties.

Therefore, the Relying Party first generates an asymmetric cryptographic key pair.
Then, the Relying Party performs a Remote ID Token Request to the OpenID Provider to obtain the Remote ID Token.

```
+-----------------+       +-----------------+
|  Relying Party  |       | OpenID Provider |
+-----------------+       +-----------------+
         |                         |
   (2.1) |                         |
         |          (2.2)          |
         | ----------------------> |
         |                         | (2.3)
         |                         |
         |                         | (2.4)
         |          (2.5)          |
         | <---------------------- |
   (2.6) |                         |
         V                         V
```
Remote ID Token Flow described in the following sections.

### 2.1. Key Pair Generation

The Relying Party generates an asymmetric cryptographic key pair (Elliptic Curve or RSA) for signing operations for each remote peer it wants to authenticate to.

In JavaScript, this can be done using the [Web Crypto API](https://www.w3.org/TR/WebCryptoAPI/).
The following example shows how an asymmetric Elliptic Curve key pair for signing with SHA-256 (`ES256`) can be generated:
```js
const keyPair = await window.crypto.subtle.generateKey(
  {
    name: "ECDSA",
    namedCurve: "P-256"
  },
  false, // Set this to true, if you want to export the key (NOT RECOMMENDED!)
  ["sign"]
);
```

The following example shows a generated EC Private Key JWK-encoded:
```json
{
    "kty": "EC",
    "crv": "P-256",
    "d": "FqtlOtLaWStvTzGCnl3WpFrq1lyAnMS4PUV0F50mTjU",
    "x": "cXQ8bdeNeeSwfLkHzMfAUFrHlLXZWvJrmoM2sCPGUng",
    "y": "7DpwmOoHInd0QcRERTKZACi9bwsa5gGKDGxFxm48GRA"
}
```

The following example shows a generated EC Public Key JWK-encoded:
```json
{
  "kty": "EC",
  "crv": "P-256",
  "x": "cXQ8bdeNeeSwfLkHzMfAUFrHlLXZWvJrmoM2sCPGUng",
  "y": "7DpwmOoHInd0QcRERTKZACi9bwsa5gGKDGxFxm48GRA"
}
```

### 2.2. Remote ID Token Request

To request a Remote ID Token, the Relying Party MUST:
- prove authorization by providing a valid Bearer Token with Scope `openid`,
- provide a public key to bind the Remote ID Token to, and
- prove possession of the related private key.

Hence, the Remote ID Token Request contains the following parameters:
- A **public key**: REQUIRED. The public key to bind the Remote ID Token to.
- A **validity time frame**: REQUIRED. A start and end date between which the signed request is valid.
- A **nonce**: REQUIRED. MUST be unique for the validity time frame and randomly generated with enough entropy to be not guessable. Used to prevent replay or other attacks.
- A **claims enumeration**: OPTIONAL. An enumeration of Identity Claims which should be provided in the Remote ID Token. If not provided, all available claims for which the provided Access Token is sufficient will be provided.
- A **subject**: REQUIRED. The identifier of the End User. This identifier MUST be equal to the related subject of the Access Token, e.g., the `sub` claim if the Access Token is a JWT.
- A valid signature over all parameters above.
- A valid Bearer Token.

To prove the possession of the related private key, this document provides multiple ways:
- With a self-issued JWT in the request body.
- With HTTP Message Signatures.

#### 2.2.1. Remote ID Token Request with JWT in Request Body

To prove authorization, the Relying Party MUST provide the Access Token from the Token Response in the `Authorization` header as a `Bearer` token.
This Access Token MUST be sufficient to access the Scope `openid`.

To provide a public key to bind the Remote ID Token to, the Relying Party creates a JWT with the following header claims:
- `alg`: OPTIONAL. The asymmetric signing algorithm used to sign this token. MUST be one of `ES256` (RECOMMENDED), `ES384`, `ES512`, `RS256`, `RS384`, or `RS512`. If not provided, `ES256` is assumed.
- `typ`: REQUIRED. Value MUST be `JWT`.
- `jwk`: REQUIRED. The public key of the Relying Party created in the Key Pair Generation which is used to sign this token, encoded as JSON Web Key (JWK), and will be used to authenticate to Remote Parties.

The JWT MAY contain the following payload claims:
- `iss` (issuer): REQUIRED. The Client Identifier of the Relying Party.
- `sub` (subject): REQUIRED. The unique identifier of the End User. This MUST be the value of the `sub` claim which is related to the provided Access Token. It can be extracted from the ID Token issued to the Relying Party.
- `aud` (audience): REQUIRED. The unique identifier (URI) of the OpenID Provider.
- `iat` (issued at): REQUIRED. The unix timestamp with second-precision when the token was issued.
- `nbf` (not before): OPTIONAL. The unix timestamp with second-precision when the token becomes valid.
- `exp` (expiration): REQUIRED. The unix timestamp with second-precision when the token expires. The token MUST be valid for at most 10 minutes. It is RECOMMENDED that the token is valid for at most 30 seconds.
- `nonce`: REQUIRED. An unguessable random nonce with enough entropy which is unique within the validity time of the token.
- `token_claims`: OPTIONAL. Space delimited claims of the requested Remote ID Token. If not provided, all available identity claims will be provided in the Remote ID Token.
- `token_lifetime`: OPTIONAL. Number of seconds that the Remote ID Token should be valid. This MUST be less than `2592000` (30 days). It is RECOMMENDED that this is set to not more than `3600`. If not provided, `3600` MAY be assumed.
- `token_nonce`: OPTIONAL. The nonce of the resulting Remote ID Token.

The following example shows such a Remote ID Token Request from the Relying Party (`client.example.org`) to the OpenID Provider's (`accounts.example.org`) Remote ID Token Endpoint `/userinfo/ridt` with a JWT in request body:
```http
POST /userinfo/ridt HTTP/1.1
Host: accounts.example.org
Content-Type: application/jwt; charset=UTF-8
Authorization: Bearer eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6MSwianRpIjoid001QWo3ZTdBYlpSb1hDemZja3NhTTdhQW50QUNZeHoifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmV4YW1wbGUub3JnLyIsInN1YiI6ImpvaG4uc21pdGhAYWNjb3VudHMuZXhhbXBsZS5vcmciLCJhdWQiOiJodHRwczovL2FjY291bnRzLmV4YW1wbGUub3JnLyIsImlhdCI6MTY1OTM1NTIwMCwibmJmIjoxNjU5MzU1MjAwLCJleHAiOjE2NTkzNTg4MDAsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwifQ.pB00n8KtCmOPqEDC16_szsn383JoZfpbFQsjhjX_bybYYzo0X7LcbFiC2JJ3uraypQ_4DEWiaDDY7ZJdNt6Brg

eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImp3ayI6eyJrdHkiOiJFQyIsImNydiI6IlAtMjU2IiwieCI6ImNYUThiZGVOZWVTd2ZMa0h6TWZBVUZySGxMWFpXdkpybW9NMnNDUEdVbmciLCJ5IjoiN0Rwd21Pb0hJbmQwUWNSRVJUS1pBQ2k5YndzYTVnR0tER3hGeG00OEdSQSJ9fQ.eyJpc3MiOiJjbGllbnQuZXhhbXBsZS5vcmciLCJzdWIiOiJqb2huLnNtaXRoQGFjY291bnRzLmV4YW1wbGUub3JnIiwiYXVkIjoiaHR0cHM6Ly9hY2NvdW50cy5leGFtcGxlLm9yZy8iLCJpYXQiOjE2NTkzNTUyMDUsIm5iZiI6MTY1OTM1NTIwNSwiZXhwIjoxNjU5MzU1MjM1LCJub25jZSI6IlZqZlU0Nlo1eWtJaG43akp6cVpvV0srcGFxNjNFS3VIIiwidG9rZW5fY2xhaW1zIjoibmFtZSBlbWFpbCBlbWFpbF92ZXJpZmllZCIsInRva2VuX2xpZmV0aW1lIjozNjAwLCJ0b2tlbl9ub25jZSI6IkJqeHEyN0ZVbEIwWEFXMmliK1pzNnM1N1JRcmNtVXhBIn0.Z6uoiakqd7MAAJkQ8Bry6SHrp0dQJyd5PWBgsu1EJMHBygDfB1pC_UDiakcaB5QO6-Ec3eYkNlztTVw_XBR0Tg
```

#### 2.2.2. Remote ID Token Request with HTTP Message Signatures

TODO

### 2.3. Remote ID Token Request Validation

The OpenID Provider MUST verify the received Remote ID Token Request as follows:
1. The provided Bearer Token MUST be valid. If the Access Token is a JWT, this means:
    1. The `alg` parameter must be a valid JWA signature algorithm.
    2. The `typ` parameter must be `JWT`.
    3. The `kid` must be a valid ID of the OpenID Provider's public keys which are provided at the JWK Endpoint whose URL can be found at `<openid-provider-uri>.well-known/openid-configuration`.
    4. The Signature must be valid.
    5. The `aud` claim must be sufficient to be accepted by the OpenID Provider.
    6. The `iss` claim is the Identifier of the OpenID Provider.
    7. The `sub` claim MUST be provided and be a valid End User Identifier.
    8. The current unix timestamp is between `iat`, or if provided, `nbf`, and `exp`, meaning that the JWT is valid at the request time.
2. The provided Bearer Token MUST be sufficient to access information about the requested End User. If the Access Token is a JWT, this means that the `scope` claim MUST contain the Scope `openid`.
3. The Remote ID Token Request MUST contain all REQUIRED parameters of the Remote ID Token Request.
4. The Remote ID Token Request MUST contain a public key and the request must have a valid signature which can be verified with the provided public key.
5. The Remote ID Token Request's subject identifier MUST be equal to related subject of the Bearer Token. If the Access Token is a JWT, this means that the `sub` claim of the Access Token MUST be equal to the `sub` claim of the ID Token Request's subject identifier.
6. The Request MUST NOT be sent more than once. This can be detected by verifying that the provided `nonce` was not used before. If the request is reused, any Remote ID Token which was generated with this request MUST be revoked if possible.

#### 2.3.1. Provided Implementation: JWT Request Body

The provided Implementation does not verify the Access Token on its own.
Instead, it uses the provided Bearer Token to request the Identity Claims from the Userinfo Endpoint.
The Userinfo Endpoint will validate the Bearer Token for our implementation.

```
+-----------------+   +-----------------+   +-----------------+
|  Relying Party  |   |  RIDT Endpoint  |   | OpenID Provider |
+-----------------+   +-----------------+   +-----------------+
         |                     |                     |
   (2.1) |                     |                     |
         |        (2.2)        |                     |
         | ------------------> |                     |
         |                     |        (2.3)        |
         |                     | ------------------> |
         |                     | <------------------ |
         |                     |                     |
         |                     | (2.4)               |
         |        (2.5)        |                     |
         | <------------------ |                     |
   (2.6) |                     |                     |
         V                     V                     |
```
Remote ID Token Flow of the provided implementation.

This means that the validation flow for the provided implementation is as follows if the Remote ID Token Request is with a JWT in the Request Body:
1. Verify that the JWT in the Request Body is valid, meaning
    1. The header and payload claims match the specification.
    2. The Signature is valid.
    3. The current time is in the validity interval.
    4. The `nonce` value is unique for the validity interval.
    5. The `aud` claim matches the OpenID Provider identifier from the `ISSUER` environment variable.
2. Send an HTTP `GET` request to the Userinfo Endpoint whose URI is provided in the `USERINFO` environment variable, and add the header `Authorization: Bearer <bearer-token>`. The OpenID Provider will validate the Bearer Token on its own and verify that the related End User (subject) exists.
3. Verify that the `sub` claim of the Userinfo Response matches the `sub` claim of the JWT payload in the Token Request.

The following example shows the Userinfo Request of the provided RIDT Endpoint implementation to the OpenID Provider's (`accounts.example.org`) Userinfo Endpoint `/userinfo`:
```http
GET /userinfo HTTP/1.1
Host: accounts.example.org
Authorization: Bearer eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6MSwianRpIjoid001QWo3ZTdBYlpSb1hDemZja3NhTTdhQW50QUNZeHoifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmV4YW1wbGUub3JnLyIsInN1YiI6ImpvaG4uc21pdGhAYWNjb3VudHMuZXhhbXBsZS5vcmciLCJhdWQiOiJodHRwczovL2FjY291bnRzLmV4YW1wbGUub3JnLyIsImlhdCI6MTY1OTM1NTIwMCwibmJmIjoxNjU5MzU1MjAwLCJleHAiOjE2NTkzNTg4MDAsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwifQ.pB00n8KtCmOPqEDC16_szsn383JoZfpbFQsjhjX_bybYYzo0X7LcbFiC2JJ3uraypQ_4DEWiaDDY7ZJdNt6Brg
```

The following example shows the Userinfo Response (with additional line wraps for display purposes only):
```http
HTTP/1.1 200 OK
Date: Mon, 1 Aug 2022 12:00:05 UTC
Content-Type: application/json; charset=UTF-8
Cache-Control: no-store
Pragma: no-cache

{
  "sub": "john.smith@accounts.example.org",
  "name": "John Smith",
  "given_name": "John",
  "family_name": "Smith",
  "email": "john.smith@mail.example.org",
  "email_verified": true
}
```

#### 2.3.2. Provided Implementation: HTTP Signature

TODO

### 2.4. Remote ID Token Generation

If the Remote ID Token Request was valid, the OpenID Provider generates the Remote ID Token.

The Remote ID Token's header contains the following claims:
- `alg`: OPTIONAL. The asymmetric signing algorithm used to sign the token. MUST be one of `ES256` (RECOMMENDED), `ES384`, `ES512`, `RS256`, `RS384`, or `RS512`. If not provided, `ES256` will be assumed.
- `typ`: REQUIRED. MUST be set to `JWT+DPOP`.
- `kid`: REQUIRED. MUST be a valid ID of the OpenID Provider's public keys which are provided at the JWK Endpoint whose URL can be found at `<openid-provider-uri>.well-known/openid-configuration`.

The Remote ID Token's payload contains the following claims:
- `iss` (Issuer): REQUIRED. The OpenID Provider's Identifier.
- `sub` (Subject): REQUIRED. The unique End User's Identifier.
- `iat` (Issued At): REQUIRED. The unix timestamp when the token was issued.
- `nbf` (Not before): OPTIONAL. The unix timestamp when the token becomes valid.
- `exp` (Expires At): REQUIRED. The unix timestamp when the token expires.
- `nonce`: REQUIRED. A random string or, if provided, the value of the `token_nonce` provided in the Remote ID Token Request.
- `cnf` (Confirmation): REQUIRED. The public key from the JWT in the Remote ID Token Request.
- The available identity claims which were requested in the `claims` parameter of the Remote ID Token Request.

The following example shows such a Remote ID Token:
```jwt
eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCtEUE9QIiwia2lkIjoxfQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmV4YW1wbGUub3JnLyIsInN1YiI6ImpvaG4uc21pdGhAYWNjb3VudHMuZXhhbXBsZS5vcmciLCJpYXQiOjE2NTkzNTUyMDUsIm5iZiI6MTY1OTM1NTIwNSwiZXhwIjoxNjU5MzU4ODA1LCJub25jZSI6IlZqZlU0Nlo1eWtJaG43akp6cVpvV0srcGFxNjNFS3VIIiwiY25mIjp7Imp3ayI6eyJrdHkiOiJFQyIsImNydiI6IlAtMjU2IiwieCI6ImNYUThiZGVOZWVTd2ZMa0h6TWZBVUZySGxMWFpXdkpybW9NMnNDUEdVbmciLCJ5IjoiN0Rwd21Pb0hJbmQwUWNSRVJUS1pBQ2k5YndzYTVnR0tER3hGeG00OEdSQSJ9fSwibmFtZSI6IkpvaG4gU21pdGgiLCJlbWFpbCI6ImpvaG4uc21pdGhAbWFpbC5zYW1wbGUub3JnIiwiZW1haWxfdmVyaWZpZWQiOnRydWV9.TEIehA9Xzmo72QoWMTwlkHA2FzypvGq8mAnGyJLD7H3TAYodrMzJnqyTaU7N36Qij2w5-8IpoPIzahGoKC6J_w
```

### 2.5. Remote ID Token Response

After the Remote ID Token Generation, the Relying Party responds with the Remote ID Token.

The Remote ID Token Response contains the following parameters:
- `remote_id_token`: REQUIRED. The Remote ID Token.
- `expires_in`: RECOMMENDED. The lifetime in seconds of the Remote ID Token. For example, the value `3600` denotes that the Remote ID Token will expire in one hour from the time the response was generated. If omitted, the OpenID Provider SHOULD provide the expiration time via other means or document the default value.
- `claims`: REQUIRED, if not identical to the claims requested in the Remote ID Token Request; otherwise OPTIONAL. The space-delimited claims provided in the Remote ID Token.

The following HTTP Headers MAY be provided in the HTTP Remote ID Token Response:
- `Cache-Control`: REQUIRED. Value MUST be `no-store` to prevent caching this response. See [Cache-Control Documentation](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control).
- `Pragma`: REQUIRED. Value MUST be `no-cache` to force user-agents to prevent caching. See [Pragma Documentation](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Pragma).

The following example shows an HTTP Remote ID Token Response (with line wraps for display purposes only):
```http
HTTP/1.1 201 Created
Date: Mon, 1 Aug 2022 12:00:05 UTC
Content-Type: application/json; charset=UTF-8
Cache-Control: no-store
Pragma: no-cache

{
  "remote_id_token": "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCtEUE9QIiwia2lkIjoxfQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmV4YW1wbGUub3JnLyIsInN1YiI6ImpvaG4uc21pdGhAYWNjb3VudHMuZXhhbXBsZS5vcmciLCJpYXQiOjE2NTkzNTUyMDUsIm5iZiI6MTY1OTM1NTIwNSwiZXhwIjoxNjU5MzU4ODA1LCJub25jZSI6IlZqZlU0Nlo1eWtJaG43akp6cVpvV0srcGFxNjNFS3VIIiwiY25mIjp7Imp3ayI6eyJrdHkiOiJFQyIsImNydiI6IlAtMjU2IiwieCI6ImNYUThiZGVOZWVTd2ZMa0h6TWZBVUZySGxMWFpXdkpybW9NMnNDUEdVbmciLCJ5IjoiN0Rwd21Pb0hJbmQwUWNSRVJUS1pBQ2k5YndzYTVnR0tER3hGeG00OEdSQSJ9fSwibmFtZSI6IkpvaG4gU21pdGgiLCJlbWFpbCI6ImpvaG4uc21pdGhAbWFpbC5zYW1wbGUub3JnIiwiZW1haWxfdmVyaWZpZWQiOnRydWV9.TEIehA9Xzmo72QoWMTwlkHA2FzypvGq8mAnGyJLD7H3TAYodrMzJnqyTaU7N36Qij2w5-8IpoPIzahGoKC6J_w",
  "expires_in": 3600,
  "claims": "name email email_verified"
}
```

### 2.6. Remote ID Token Response Validation

It is RECOMMENDED that the Relying Party verifies the received Remote ID Token before it uses it.

Therefore, it does the following:
- Verify that the Token is not expired using the `expires_in` attribute of the Remote ID Token Response.
- Verify that all the required claims are contained in the `claims` parameter of the Remote ID Token Response.

## 3. Perform E2E Authentication

TODO

```
+---------------+     +---------------+
| Relying Party |     | Remote  Party |
+---------------+     +---------------+
        |                     |
  (3.1) |                     |
        |        (3.2)        |
        | ------------------> |
        |                     | (3.3)
        |                     |
        |                     | (3.4)
        |        (3.5)        |
        | <------------------ |
  (3.6) |                     |
        |                     |
        V                     V
```

### 3.1. E2E Authentication Request Preparation

TODO: Generate JWT
  - typ: "JWT+EAQ" (E2e Auth reQuest)
  - Contains Relying Party's Remote ID Token
  - Contains HPKE Parameters (-> RFC 9180)
      - Indicates, whether only authentication is requested or also encryption
  - Signed by Relying Party's Private Key whose Public Key is provided in the Remote ID Token

### 3.2. E2E Authentication Request

TODO: Send JWT

#### 3.2.1. E2E Authentication Request via HTTP

TODO: Send JWT as `Authentication: E2EID <jwt>` HTTP Header.

#### 3.2.2. E2E Authentication Request via SDP

TODO: Send JWT as `a=e2eid:<jwt>` Attribute.

#### 3.2.3. E2E Authentication Request via SMTP

TODO: ?

### 3.3. E2E Authentication Request Validation

TODO: Validate
  - Signature of RIDT (-> Check if issuer is trusted)
  - Signature of E2E Auth Request

### 3.4. E2E Authentication Response Preparation

TODO: Generate JWT
  - type: "JWT+EAS" (E2e Auth reSponse)
  - Contains Remote Party's Remote ID Token
  - Contains HPKE Parameters (-> RFC 9180)
      - Indicates whether only authentication is required or also encryption
      - MAY contain symmetric shared secret which is encrypted with Relying Party's Public Key
  - Signed by Remote Party's Private Key whose Public Key is provided in the Remote ID Token

### 3.5. E2E Authentication Response

TODO: Send JWT

#### 3.5.1. E2E Authentication Response via HTTP

TODO: Send JWT as `Authentication: E2EID <jwt>` HTTP Header.

#### 3.5.2. E2E Authentication Response via SDP

TODO: Send JWT as `a=e2eid:<jwt>` Attribute.

#### 3.5.3. E2E Authentication Response via SMTP

TODO: ?

### 3.6. E2E Authentication Response Validation

TODO: Validate
  - Signature of RIDT (-> Check if issuer is trusted)
  - Signature of E2E Auth Response

## 4. E2E Encryption Communication

TODO

```
+---------------+     +---------------+
| Relying Party |     | Remote  Party |
+---------------+     +---------------+
        |                     |
  (4.1) |                     |
        |        (4.2)        |
        | ------------------> |
        |                     | (4.3)
        |                     |
                  ...
        |                     |
  (4.1) |                     |
        |        (4.2)        |
        | ------------------> |
        |                     | (4.3)
        |                     |
                  ...
        |                     |
        |                     | (4.4)
        |        (4.5)        |
        | <------------------ |
  (4.6) |                     |
        |                     |
                  ...
        |                     |
  (4.1) |                     |
        |        (4.2)        |
        | ------------------> |
        |                     | (4.3)
        |                     |
                  ...
        |                     |
        |                     | (4.4)
        |        (4.5)        |
        | <------------------ |
  (4.6) |                     |
        |                     |
                  ...
        |                     |
        |                     | (4.4)
        |        (4.5)        |
        | <------------------ |
  (4.6) |                     |
        |                     |
                  ...
        |                     |
        V                     V
```

### 4.1. Message Encryption: Relying Party

TODO:
  - Derive new symmetric sending key with Key Derivation Function (KDF)
  - Encrypt the plain message with the new symmetric key
  - Authenticate the cipher message

### 4.2. Message Transmission: Relying Party

TODO: Transmit the encrypted and authenticated message

### 4.3. Message Decryption: Remote Party

TODO:
  - Verify authenticity of cipher message
  - Derive new symmetric sending key with KDF
  - Decrypt the cipher message

### 4.4. Message Encryption: Remote Party

TODO:
  - Derive new symmetric sending key with Key Derivation Function (KDF)
  - Encrypt the plain message with the new symmetric key
  - Authenticate the cipher message

### 4.5. Message Transmission: Remote Party

TODO: Transmit the encrypted and authenticated message

### 4.6. Message Decryption: Relying Party

TODO:
  - Verify authenticity of cipher message
  - Derive new symmetric sending key with KDF
  - Decrypt the cipher message
