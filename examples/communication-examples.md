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
  "iss": "client.sample.org",
  "sub": "user@sample.org",
  "aud": "https://accounts.sample.org/",
  "iat": 1659355200,
  "nbf": 1659355200,
  "exp": 1659355260,
  "nonce": "VjfU46Z5ykIhn7jJzqZoWK+paq63EKuH",
  "claims": "name email email_verified"
}
```

Example for Token Request JWT:

```jwt
eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImp3ayI6eyJrdHkiOiJFQyIsImNydiI6IlAtMjU2IiwieCI6ImNYUThiZGVOZWVTd2ZMa0h6TWZBVUZySGxMWFpXdkpybW9NMnNDUEdVbmciLCJ5IjoiN0Rwd21Pb0hJbmQwUWNSRVJUS1pBQ2k5YndzYTVnR0tER3hGeG00OEdSQSJ9fQ.eyJpc3MiOiJjbGllbnQuc2FtcGxlLm9yZyIsInN1YiI6InVzZXJAc2FtcGxlLm9yZyIsImF1ZCI6Imh0dHBzOi8vYWNjb3VudHMuc2FtcGxlLm9yZy8iLCJpYXQiOjE2NTkzNTUyMDAsIm5iZiI6MTY1OTM1NTIwMCwiZXhwIjoxNjU5MzU1MjYwLCJub25jZSI6IlZqZlU0Nlo1eWtJaG43akp6cVpvV0srcGFxNjNFS3VIIiwiY2xhaW1zIjoibmFtZSBlbWFpbCBlbWFpbF92ZXJpZmllZCJ9.6iGZaJrC5dcbYWZbgZKSNq9k0GZvL0jeXrD-8iv_wt1ZYgEuI6SLoZWc5TGayheDS7Kr1uwKTIa6Nm8RCv0TYQ
```

Example for sufficient Access Token:

```jwt
eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6MX0.eyJpc3MiOiJodHRwczovL2FjY291bnRzLnNhbXBsZS5vcmcvIiwic3ViIjoidXNlckBzYW1wbGUub3JnIiwiYXVkIjoiaHR0cHM6Ly9hY2NvdW50cy5zYW1wbGUub3JnLyIsImlhdCI6MTY1OTM1NDMwMCwibmJmIjoxNjU5MzU0MzAwLCJleHAiOjE2NTkzNTYxMDAsIm5vbmNlIjoid001QWo3ZTdBYlpSb1hDemZja3NhTTdhQW50QUNZeHoiLCJzY29wZXMiOiJvcGVuaWQgcHJvZmlsZSBlbWFpbCJ9.uT4yYOLwEgSCaq88DRe-4jIhVAeSEJDJBCfp4iC2Sx0J0tmOFq9hESiqox67n-i4adbzm028GvzYc0oR1nhouw
```

Example for JWT HTTP Request:

```http
POST /userinfo/ridt HTTP/1.1
Host: accounts.sample.org
Content-Type: application/jwt; charset=UTF-8
Authorization: Bearer eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FjY291bnRzLnNhbXBsZS5vcmcvIiwic3ViIjoidXNlckBzYW1wbGUub3JnIiwiYXVkIjoiaHR0cHM6Ly9hY2NvdW50cy5zYW1wbGUub3JnLyIsImlhdCI6MTY1OTM1NDMwMCwibmJmIjoxNjU5MzU0MzAwLCJleHAiOjE2NTkzNTYxMDAsInNjb3BlcyI6Im9wZW5pZCBwcm9maWxlIGVtYWlsIn0.pg5tN_67oONdG4aKGl7hJBvOjebjp9AGGYNxRbWSDetqbziepWYnWHk14gHpxAaxF6q54AWri4v5zHdq8O6Wrg

eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImp3ayI6eyJrdHkiOiJFQyIsImNydiI6IlAtMjU2IiwieCI6ImNYUThiZGVOZWVTd2ZMa0h6TWZBVUZySGxMWFpXdkpybW9NMnNDUEdVbmciLCJ5IjoiN0Rwd21Pb0hJbmQwUWNSRVJUS1pBQ2k5YndzYTVnR0tER3hGeG00OEdSQSJ9fQ.eyJpc3MiOiJjbGllbnQuc2FtcGxlLm9yZyIsInN1YiI6InVzZXJAc2FtcGxlLm9yZyIsImF1ZCI6Imh0dHBzOi8vYWNjb3VudHMuc2FtcGxlLm9yZy8iLCJpYXQiOjE2NTkzNTUyMDAsIm5iZiI6MTY1OTM1NTIwMCwiZXhwIjoxNjU5MzU1MjYwLCJub25jZSI6IlZqZlU0Nlo1eWtJaG43akp6cVpvV0srcGFxNjNFS3VIIiwiY2xhaW1zIjoibmFtZSBlbWFpbCBlbWFpbF92ZXJpZmllZCJ9.6iGZaJrC5dcbYWZbgZKSNq9k0GZvL0jeXrD-8iv_wt1ZYgEuI6SLoZWc5TGayheDS7Kr1uwKTIa6Nm8RCv0TYQ
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
  "iss": "https://accounts.sample.org/",
  "sub": "user@sample.org",
  "iat": 1659355205,
  "nbf": 1659355205,
  "exp": 1659358805,
  "nonce": "/T176qtEw/u35QOrXTGV1nlUDU5EaEzW",
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
eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCtEUE9QIiwia2lkIjoxfQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLnNhbXBsZS5vcmcvIiwic3ViIjoidXNlckBzYW1wbGUub3JnIiwiaWF0IjoxNjU5MzU1MjA1LCJuYmYiOjE2NTkzNTUyMDUsImV4cCI6MTY1OTM1ODgwNSwibm9uY2UiOiIvVDE3NnF0RXcvdTM1UU9yWFRHVjFubFVEVTVFYUV6VyIsImNuZiI6eyJqd2siOnsia3R5IjoiRUMiLCJjcnYiOiJQLTI1NiIsIngiOiJjWFE4YmRlTmVlU3dmTGtIek1mQVVGckhsTFhaV3ZKcm1vTTJzQ1BHVW5nIiwieSI6IjdEcHdtT29ISW5kMFFjUkVSVEtaQUNpOWJ3c2E1Z0dLREd4RnhtNDhHUkEifX0sIm5hbWUiOiJKb2huIFNtaXRoIiwiZW1haWwiOiJqb2huLnNtaXRoQG1haWwuc2FtcGxlLm9yZyIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlfQ.Y_ag4noTNgauNoFrhUP8dPbZAK2dC4iaFtEuM2yX_Me-Rlvy-oCR7CQvkZc7-Ejq4l617Ke-6ywV408OvRV-MQ
```

Example for JSON-encoded Response Object:

```json
{
  "remote_id_token": "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCtEUE9QIiwia2lkIjoxfQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLnNhbXBsZS5vcmcvIiwic3ViIjoidXNlckBzYW1wbGUub3JnIiwiaWF0IjoxNjU5MzU1MjA1LCJuYmYiOjE2NTkzNTUyMDUsImV4cCI6MTY1OTM1ODgwNSwibm9uY2UiOiIvVDE3NnF0RXcvdTM1UU9yWFRHVjFubFVEVTVFYUV6VyIsImNuZiI6eyJqd2siOnsia3R5IjoiRUMiLCJjcnYiOiJQLTI1NiIsIngiOiJjWFE4YmRlTmVlU3dmTGtIek1mQVVGckhsTFhaV3ZKcm1vTTJzQ1BHVW5nIiwieSI6IjdEcHdtT29ISW5kMFFjUkVSVEtaQUNpOWJ3c2E1Z0dLREd4RnhtNDhHUkEifX0sIm5hbWUiOiJKb2huIFNtaXRoIiwiZW1haWwiOiJqb2huLnNtaXRoQG1haWwuc2FtcGxlLm9yZyIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlfQ.Y_ag4noTNgauNoFrhUP8dPbZAK2dC4iaFtEuM2yX_Me-Rlvy-oCR7CQvkZc7-Ejq4l617Ke-6ywV408OvRV-MQ",
  "expires_in": 3595,
  "claims": [
    "name",
    "email",
    "email_verified"
  ]
}
```

Example for Token Response:

```http
HTTP/1.1 201 Created
Date: Mon, 1 Aug 2022 12:00:05 UTC
Content-Type: application/json
Connection: Closed

{
  "remote_id_token": "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCtEUE9QIiwia2lkIjoxfQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLnNhbXBsZS5vcmcvIiwic3ViIjoidXNlckBzYW1wbGUub3JnIiwiaWF0IjoxNjU5MzU1MjA1LCJuYmYiOjE2NTkzNTUyMDUsImV4cCI6MTY1OTM1ODgwNSwibm9uY2UiOiIvVDE3NnF0RXcvdTM1UU9yWFRHVjFubFVEVTVFYUV6VyIsImNuZiI6eyJqd2siOnsia3R5IjoiRUMiLCJjcnYiOiJQLTI1NiIsIngiOiJjWFE4YmRlTmVlU3dmTGtIek1mQVVGckhsTFhaV3ZKcm1vTTJzQ1BHVW5nIiwieSI6IjdEcHdtT29ISW5kMFFjUkVSVEtaQUNpOWJ3c2E1Z0dLREd4RnhtNDhHUkEifX0sIm5hbWUiOiJKb2huIFNtaXRoIiwiZW1haWwiOiJqb2huLnNtaXRoQG1haWwuc2FtcGxlLm9yZyIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlfQ.Y_ag4noTNgauNoFrhUP8dPbZAK2dC4iaFtEuM2yX_Me-Rlvy-oCR7CQvkZc7-Ejq4l617Ke-6ywV408OvRV-MQ",
  "expires_in": 3595,
  "claims": [
    "name",
    "email",
    "email_verified"
  ]
}
```
