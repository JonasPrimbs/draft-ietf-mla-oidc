# Communication Examples

This documentation shows examples for the communication between the Relying Party (`client.sample.org`) and the OpenID Provider (`accounts.sample.org`).

## Used Key Pairs

### OpenID Provider

For the OpenID Provider, we used the following key pairs:

PEM-encoded Private Key:

```pem
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQg1Yg2Y+jCncQwKSmg
JkumhRXvGXIaSb0s4YlUk5Bm+LGhRANCAAR5o7m0CwwXuaehj3nsbSCZoYa1cvFS
M4+KnirFYB1y7EWY7sZzjoiAXwySivItjMXdN4GMH9JvWudgHeFpWY+k
-----END PRIVATE KEY-----
```

PEM-encoded Public Key:

```pem
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEeaO5tAsMF7mnoY957G0gmaGGtXLx
UjOPip4qxWAdcuxFmO7Gc46IgF8MkoryLYzF3TeBjB/Sb1rnYB3haVmPpA==
-----END PUBLIC KEY-----
```

### Relying Party

For the Relying Party, we used the following key pairs:

JWK-encoded Private Key:

```json
{
    "kty": "EC",
    "crv": "P-256",
    "d": "FqtlOtLaWStvTzGCnl3WpFrq1lyAnMS4PUV0F50mTjU",
    "x": "cXQ8bdeNeeSwfLkHzMfAUFrHlLXZWvJrmoM2sCPGUng",
    "y": "7DpwmOoHInd0QcRERTKZACi9bwsa5gGKDGxFxm48GRA"
}
```

JWK-encoded Public Key:

```json
{
    "kty": "EC",
    "crv": "P-256",
    "x": "cXQ8bdeNeeSwfLkHzMfAUFrHlLXZWvJrmoM2sCPGUng",
    "y": "7DpwmOoHInd0QcRERTKZACi9bwsa5gGKDGxFxm48GRA"
}
```


## Token Request

Example for parsed JWT Header:

```json
{
  "alg": "ES256",
  "typ": "JWT",
  "jwk": {
    "kty": "EC",
    "crv": "P-256",
    "x": "cXQ8bdeNeeSwfLkHzMfAUFrHlLXZWvJrmoM2sCPGUng",
    "y": "7DpwmOoHInd0QcRERTKZACi9bwsa5gGKDGxFxm48GRA"
  }
}
```

Example for parsed JWT Payload:

```json
{
  "iss": "client.example.org",
  "sub": "john.smith@accounts.example.org",
  "aud": "https://accounts.example.org/",
  "iat": 1659355205,
  "nbf": 1659355205,
  "exp": 1659355235,
  "nonce": "VjfU46Z5ykIhn7jJzqZoWK+paq63EKuH",
  "token_claims": "name email email_verified",
  "token_lifetime": 3600,
  "token_nonce": "Bjxq27FUlB0XAW2ib+Zs6s57RQrcmUxA"
}
```

Example for Token Request JWT:

```jwt
eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImp3ayI6eyJrdHkiOiJFQyIsImNydiI6IlAtMjU2IiwieCI6ImNYUThiZGVOZWVTd2ZMa0h6TWZBVUZySGxMWFpXdkpybW9NMnNDUEdVbmciLCJ5IjoiN0Rwd21Pb0hJbmQwUWNSRVJUS1pBQ2k5YndzYTVnR0tER3hGeG00OEdSQSJ9fQ.eyJpc3MiOiJjbGllbnQuZXhhbXBsZS5vcmciLCJzdWIiOiJqb2huLnNtaXRoQGFjY291bnRzLmV4YW1wbGUub3JnIiwiYXVkIjoiaHR0cHM6Ly9hY2NvdW50cy5leGFtcGxlLm9yZy8iLCJpYXQiOjE2NTkzNTUyMDUsIm5iZiI6MTY1OTM1NTIwNSwiZXhwIjoxNjU5MzU1MjM1LCJub25jZSI6IlZqZlU0Nlo1eWtJaG43akp6cVpvV0srcGFxNjNFS3VIIiwidG9rZW5fY2xhaW1zIjoibmFtZSBlbWFpbCBlbWFpbF92ZXJpZmllZCIsInRva2VuX2xpZmV0aW1lIjozNjAwLCJ0b2tlbl9ub25jZSI6IkJqeHEyN0ZVbEIwWEFXMmliK1pzNnM1N1JRcmNtVXhBIn0.Z6uoiakqd7MAAJkQ8Bry6SHrp0dQJyd5PWBgsu1EJMHBygDfB1pC_UDiakcaB5QO6-Ec3eYkNlztTVw_XBR0Tg
```

Example for sufficient Access Token:

```jwt
eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6MSwianRpIjoid001QWo3ZTdBYlpSb1hDemZja3NhTTdhQW50QUNZeHoifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmV4YW1wbGUub3JnLyIsInN1YiI6ImpvaG4uc21pdGhAYWNjb3VudHMuZXhhbXBsZS5vcmciLCJhdWQiOiJodHRwczovL2FjY291bnRzLmV4YW1wbGUub3JnLyIsImlhdCI6MTY1OTM1NTIwMCwibmJmIjoxNjU5MzU1MjAwLCJleHAiOjE2NTkzNTg4MDAsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwifQ.pB00n8KtCmOPqEDC16_szsn383JoZfpbFQsjhjX_bybYYzo0X7LcbFiC2JJ3uraypQ_4DEWiaDDY7ZJdNt6Brg
```

Example for JWT HTTP Request:

```http
POST /userinfo/ridt HTTP/1.1
Host: accounts.example.org
Content-Type: application/jwt; charset=UTF-8
Authorization: Bearer eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6MSwianRpIjoid001QWo3ZTdBYlpSb1hDemZja3NhTTdhQW50QUNZeHoifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmV4YW1wbGUub3JnLyIsInN1YiI6ImpvaG4uc21pdGhAYWNjb3VudHMuZXhhbXBsZS5vcmciLCJhdWQiOiJodHRwczovL2FjY291bnRzLmV4YW1wbGUub3JnLyIsImlhdCI6MTY1OTM1NTIwMCwibmJmIjoxNjU5MzU1MjAwLCJleHAiOjE2NTkzNTg4MDAsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwifQ.pB00n8KtCmOPqEDC16_szsn383JoZfpbFQsjhjX_bybYYzo0X7LcbFiC2JJ3uraypQ_4DEWiaDDY7ZJdNt6Brg

eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImp3ayI6eyJrdHkiOiJFQyIsImNydiI6IlAtMjU2IiwieCI6ImNYUThiZGVOZWVTd2ZMa0h6TWZBVUZySGxMWFpXdkpybW9NMnNDUEdVbmciLCJ5IjoiN0Rwd21Pb0hJbmQwUWNSRVJUS1pBQ2k5YndzYTVnR0tER3hGeG00OEdSQSJ9fQ.eyJpc3MiOiJjbGllbnQuZXhhbXBsZS5vcmciLCJzdWIiOiJqb2huLnNtaXRoQGFjY291bnRzLmV4YW1wbGUub3JnIiwiYXVkIjoiaHR0cHM6Ly9hY2NvdW50cy5leGFtcGxlLm9yZy8iLCJpYXQiOjE2NTkzNTUyMDUsIm5iZiI6MTY1OTM1NTIwNSwiZXhwIjoxNjU5MzU1MjM1LCJub25jZSI6IlZqZlU0Nlo1eWtJaG43akp6cVpvV0srcGFxNjNFS3VIIiwidG9rZW5fY2xhaW1zIjoibmFtZSBlbWFpbCBlbWFpbF92ZXJpZmllZCIsInRva2VuX2xpZmV0aW1lIjozNjAwLCJ0b2tlbl9ub25jZSI6IkJqeHEyN0ZVbEIwWEFXMmliK1pzNnM1N1JRcmNtVXhBIn0.Z6uoiakqd7MAAJkQ8Bry6SHrp0dQJyd5PWBgsu1EJMHBygDfB1pC_UDiakcaB5QO6-Ec3eYkNlztTVw_XBR0Tg
```

## Userinfo Request Examples

Example for Userinfo Request:

```http
GET /userinfo HTTP/1.1
Host: accounts.example.org
Authorization: Bearer eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6MSwianRpIjoid001QWo3ZTdBYlpSb1hDemZja3NhTTdhQW50QUNZeHoifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmV4YW1wbGUub3JnLyIsInN1YiI6ImpvaG4uc21pdGhAYWNjb3VudHMuZXhhbXBsZS5vcmciLCJhdWQiOiJodHRwczovL2FjY291bnRzLmV4YW1wbGUub3JnLyIsImlhdCI6MTY1OTM1NTIwMCwibmJmIjoxNjU5MzU1MjAwLCJleHAiOjE2NTkzNTg4MDAsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUgZW1haWwifQ.pB00n8KtCmOPqEDC16_szsn383JoZfpbFQsjhjX_bybYYzo0X7LcbFiC2JJ3uraypQ_4DEWiaDDY7ZJdNt6Brg
```

## Userinfo Response Examples

Example for Body of Userinfo response:

```json
{
  "sub": "user@sample.org",
  "name": "John Smith",
  "given_name": "John",
  "family_name": "Smith",
  "email": "john.smith@mail.sample.org",
  "email_verified": true
}
```

Example for Userinfo HTTP response:

```http
HTTP/1.1 200 OK
Date: Mon, 1 Aug 2022 12:00:05 UTC
Content-Type: application/json; charset=UTF-8

{
  "sub": "user@sample.org",
  "name": "John Smith",
  "given_name": "John",
  "family_name": "Smith",
  "email": "john.smith@mail.sample.org",
  "email_verified": true
}
```

## Token Response Examples

Example for Remote ID Token Header:

```json
{
  "alg": "ES256",
  "typ": "JWT+DPOP",
  "kid": 1
}
```

Example for Remote ID Token Payload:

```json
{
  "iss": "https://accounts.example.org/",
  "sub": "john.smith@accounts.example.org",
  "iat": 1659355205,
  "nbf": 1659355205,
  "exp": 1659358805,
  "nonce": "VjfU46Z5ykIhn7jJzqZoWK+paq63EKuH",
  "cnf": {
    "jwk": {
      "kty": "EC",
      "crv": "P-256",
      "x": "cXQ8bdeNeeSwfLkHzMfAUFrHlLXZWvJrmoM2sCPGUng",
      "y": "7DpwmOoHInd0QcRERTKZACi9bwsa5gGKDGxFxm48GRA"
    }
  },
  "name": "John Smith",
  "email": "john.smith@mail.sample.org",
  "email_verified": true
}
```

Example for Remote ID Token:

```jwt
eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCtEUE9QIiwia2lkIjoxfQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmV4YW1wbGUub3JnLyIsInN1YiI6ImpvaG4uc21pdGhAYWNjb3VudHMuZXhhbXBsZS5vcmciLCJpYXQiOjE2NTkzNTUyMDUsIm5iZiI6MTY1OTM1NTIwNSwiZXhwIjoxNjU5MzU4ODA1LCJub25jZSI6IlZqZlU0Nlo1eWtJaG43akp6cVpvV0srcGFxNjNFS3VIIiwiY25mIjp7Imp3ayI6eyJrdHkiOiJFQyIsImNydiI6IlAtMjU2IiwieCI6ImNYUThiZGVOZWVTd2ZMa0h6TWZBVUZySGxMWFpXdkpybW9NMnNDUEdVbmciLCJ5IjoiN0Rwd21Pb0hJbmQwUWNSRVJUS1pBQ2k5YndzYTVnR0tER3hGeG00OEdSQSJ9fSwibmFtZSI6IkpvaG4gU21pdGgiLCJlbWFpbCI6ImpvaG4uc21pdGhAbWFpbC5zYW1wbGUub3JnIiwiZW1haWxfdmVyaWZpZWQiOnRydWV9.TEIehA9Xzmo72QoWMTwlkHA2FzypvGq8mAnGyJLD7H3TAYodrMzJnqyTaU7N36Qij2w5-8IpoPIzahGoKC6J_w
```

Example for JSON-encoded Response Object:

```json
{
  "remote_id_token": "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCtEUE9QIiwia2lkIjoxfQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmV4YW1wbGUub3JnLyIsInN1YiI6ImpvaG4uc21pdGhAYWNjb3VudHMuZXhhbXBsZS5vcmciLCJpYXQiOjE2NTkzNTUyMDUsIm5iZiI6MTY1OTM1NTIwNSwiZXhwIjoxNjU5MzU4ODA1LCJub25jZSI6IlZqZlU0Nlo1eWtJaG43akp6cVpvV0srcGFxNjNFS3VIIiwiY25mIjp7Imp3ayI6eyJrdHkiOiJFQyIsImNydiI6IlAtMjU2IiwieCI6ImNYUThiZGVOZWVTd2ZMa0h6TWZBVUZySGxMWFpXdkpybW9NMnNDUEdVbmciLCJ5IjoiN0Rwd21Pb0hJbmQwUWNSRVJUS1pBQ2k5YndzYTVnR0tER3hGeG00OEdSQSJ9fSwibmFtZSI6IkpvaG4gU21pdGgiLCJlbWFpbCI6ImpvaG4uc21pdGhAbWFpbC5zYW1wbGUub3JnIiwiZW1haWxfdmVyaWZpZWQiOnRydWV9.TEIehA9Xzmo72QoWMTwlkHA2FzypvGq8mAnGyJLD7H3TAYodrMzJnqyTaU7N36Qij2w5-8IpoPIzahGoKC6J_w",
  "expires_in": 3600,
  "claims": "name email email_verified"
}
```

Example for Token Response:

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
