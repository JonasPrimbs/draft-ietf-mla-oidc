# Proof of Concept

This document describes our proof-of-concept implementation for the Message Layer Authentication with OpenID Connect.

The provided implementation is a [Go](https://golang.org/) application which implements a REST endpoint for the ID Assertion Token UserInfo endpoint.
Using a reverse proxy in front, it can be mounted to any OpenID Provider implementation.

**Warning:**
Keep in mind that this is the implementation of a research project!
We do not guarantee a secure implementation!
**Do not use this in production!!!**


## Documentation

The REST API is described in the provided OpenAPI format [here](./docs/openapi.yaml).

### Architecture

```
         +---------+                +----------+
         |         |       /*       |  OpenID  |
         |         |--------------->| Provider |
         |         |                +----------+
 Ingress | Reverse |
-------->|  Proxy  |
         |         |                +----------+
         |         | /userinfo/ridt |   IAT    |
         |         |--------------->| Endpoint |
         +---------+                +----------+
```

The provided Docker Compose composition uses the following implementations:

- Reverse Proxy: Traefik Proxy
- OpenID Provider: Keycloak


### Server Configuration

This section describes the configuration parameters of the IAT Endpoint.
They are applied by injecting them as environment variables to the running application.
This can be done by defining the variables in the Docker container or by placing an `.env` file in the execution directory.


#### Key File

Absolute or relative file path to the OpenID Provider's private key file.

Example:
```bash
KEY_FILE="/path/to/private_key"
```


#### Signing Algorithm

Signing algorithm for ID Assertion Token signatures.

Allowed values are:

- `RS256` for RSASSA-PKCS1-v1_5 using SHA-256
- `RS384` for RSASSA-PKCS1-v1_5 using SHA-384
- `RS512` for RSASSA-PKCS1-v1_5 using SHA-512
- `ES256` for ECDSA using P-256 and SHA-256 (recommended)
- `ES384` for ECDSA using P-384 and SHA-384
- `ES512` for ECDSA using P-521 and SHA-512

Example:
```bash
SIGNING_ALG="ES256"
```


#### Userinfo Endpoint

Absolute URI to the OpenID Provider's Userinfo Endpoint.

This URI is used by the IAT Endpoint to request the claims of the ID Assertion Token from the OpenID Provider.
**Make sure that the running IAT Endpoint can access the OpenID Provider's Userinfo Endpoint via this URI!**

Example 1:
```bash
USERINFO_EP="https://openid-provider.sample.org/userinfo"
```

Example 2:
```bash
USERINFO_EP="http://localhost:8080/userinfo"
```


#### Issuer Claim

The ID Assertion Token's Issuer.

This is the value of the `iss` claim of the issued ID Assertion Token.
Typically, this is the public URI of the OpenID Provider where `.well-known/openid-configuration` is added to request the OpenID configuration.

Example:
```bash
ISSUER="https://openid-provider.sample.org/"
```


#### Token Validity Period

The ID Assertion Token's validity period in seconds.

Default Value: `3600` (1 hour).

Example:
```bash
TOKEN_PERIOD=3600
```


### REST Endpoint
