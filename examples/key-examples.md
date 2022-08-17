# Key Examples

This documentation shows examples for JSON- and PEM-encoded asymmetric Elliptic Curve (EC) Key Pairs.

## Public Key

Example for JWK-encoded Public Key:

```json
{
    "crv": "P-256",
    "ext": true,
    "key_ops": [
        "verify"
    ],
    "kty": "EC",
    "x": "cXQ8bdeNeeSwfLkHzMfAUFrHlLXZWvJrmoM2sCPGUng",
    "y": "7DpwmOoHInd0QcRERTKZACi9bwsa5gGKDGxFxm48GRA"
}
```

Example for minimum sufficient JWK-encoded Public Key:

```json
{
    "kty": "EC",
    "crv": "P-256",
    "x": "cXQ8bdeNeeSwfLkHzMfAUFrHlLXZWvJrmoM2sCPGUng",
    "y": "7DpwmOoHInd0QcRERTKZACi9bwsa5gGKDGxFxm48GRA"
}
```

Example for maximum sufficient JWK-encoded Public Key:

```json
{
    "kty": "EC",
    "use": "sig",
    "key_ops": [
        "verify"
    ],
    "ext": true,
    "alg": "ES256",
    "kid": 123456789,
    "crv": "P-256",
    "x": "cXQ8bdeNeeSwfLkHzMfAUFrHlLXZWvJrmoM2sCPGUng",
    "y": "7DpwmOoHInd0QcRERTKZACi9bwsa5gGKDGxFxm48GRA"
}
```

Example for PEM-encoded Public Key:

```pem
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEcXQ8bdeNeeSwfLkHzMfAUFrHlLXZ
WvJrmoM2sCPGUnjsOnCY6gcid3RBxERFMpkAKL1vCxrmAYoMbEXGbjwZEA==
-----END PUBLIC KEY-----
```

## Private Key

Example for JWK-encoded Private Key:

```json
{
    "crv": "P-256",
    "d": "FqtlOtLaWStvTzGCnl3WpFrq1lyAnMS4PUV0F50mTjU",
    "ext": true,
    "key_ops": [
        "sign"
    ],
    "kty": "EC",
    "x": "cXQ8bdeNeeSwfLkHzMfAUFrHlLXZWvJrmoM2sCPGUng",
    "y": "7DpwmOoHInd0QcRERTKZACi9bwsa5gGKDGxFxm48GRA"
}
```

Example for minimum sufficient JWK-encoded Private Key:

```json
{
    "kty": "EC",
    "crv": "P-256",
    "d": "FqtlOtLaWStvTzGCnl3WpFrq1lyAnMS4PUV0F50mTjU",
    "x": "cXQ8bdeNeeSwfLkHzMfAUFrHlLXZWvJrmoM2sCPGUng",
    "y": "7DpwmOoHInd0QcRERTKZACi9bwsa5gGKDGxFxm48GRA"
}
```

Example for maximum sufficient JWK-encoded Private Key:

```json
{
    "kty": "EC",
    "use": "sig",
    "key_ops": [
        "sign"
    ],
    "ext": true,
    "alg": "ES256",
    "kid": 123456789,
    "crv": "P-256",
    "d": "FqtlOtLaWStvTzGCnl3WpFrq1lyAnMS4PUV0F50mTjU",
    "x": "cXQ8bdeNeeSwfLkHzMfAUFrHlLXZWvJrmoM2sCPGUng",
    "y": "7DpwmOoHInd0QcRERTKZACi9bwsa5gGKDGxFxm48GRA"
}
```

Example for PEM-encoded Private Key:

```pem
-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgFqtlOtLaWStvTzGC
nl3WpFrq1lyAnMS4PUV0F50mTjWhRANCAARxdDxt14155LB8uQfMx8BQWseUtdla
8muagzawI8ZSeOw6cJjqByJ3dEHEREUymQAovW8LGuYBigxsRcZuPBkQ
-----END PRIVATE KEY-----
```
