# Proof of Concept

This document describes our proof-of-concept implementation for the Message Layer Authentication with OpenID Connect.

The provided implementation is a [Go](https://golang.org/) application which implements a REST endpoint for the Remote ID Token UserInfo endpoint.
Using a reverse proxy in front, it can be mounted to any OpenID Provider implementation.

**Warning:**
Keep in mind that this is the implementation of a research project!
We do not guarantee a secure implementation!
**Do not use this in production!!!**


## Documentation

This section provides an introduction to the architecture and the configuration of the Remote ID Token Endpoint.


### Architecture

The following figure shows the overall architecture how to use the provided Remote ID Token (RIDT) Endpoint with any OpenID Provider implementation.

```
                            +---------+                +----------+
                            |         |       *        |  OpenID  |
                            |         |--------------->| Provider |
   ------                   |         |                +----------+
 /        \  localhost:8080 | Reverse |
| Internet |--------------->|  Proxy  |
 \        /                 |         |                                                    +----------+
   ------                   |         | /realms/test/protocol/openid-connect/userinfo/ridt |   RIDT   |
                            |         |--------------------------------------------------->| Endpoint |
                            +---------+                                                    +----------+
```

The Docker Compose composition provided [here](./docker-compose.yaml) uses the following implementations:

- Reverse Proxy: [Traefik Proxy](https://traefik.io/traefik/)
- OpenID Provider: [Keycloak](https://www.keycloak.org/)


### Server Configuration

This section describes the configuration parameters of the RIDT Endpoint.
They are applied by injecting them as environment variables to the running application.
This can be done by defining the variables in the Docker container or by placing an `.env` file in the execution directory.


#### Key File

Absolute or relative file path to the OpenID Provider's private key file in PEM format.

Example:
```bash
KEY_FILE="/path/to/private_key.pem"
```


#### Key ID

The ID of the OpenID Provider's Public Key provided in the `jwks_uri` endpoint.

Example 1:
```bash
KID="abcdef"
```

Example 2:
```bash
KID=1
```


#### Signing Algorithm

Signing algorithm for Remote ID Token signatures.

Allowed values are:

- `RS256` for RSASSA-PKCS1-v1_5 using SHA-256
- `RS384` for RSASSA-PKCS1-v1_5 using SHA-384
- `RS512` for RSASSA-PKCS1-v1_5 using SHA-512
- `ES256` for ECDSA using P-256 and SHA-256 (recommended)
- `ES384` for ECDSA using P-384 and SHA-384
- `ES512` for ECDSA using P-521 and SHA-512

Default Value: `ES256`.

Example:
```bash
ALG="ES256"
```


#### Userinfo Endpoint

Absolute URI to the OpenID Provider's Userinfo Endpoint.

This URI is used by the RIDT Endpoint to request the claims of the Remote ID Token from the OpenID Provider.
**Make sure that the running RIDT Endpoint can access the OpenID Provider's Userinfo Endpoint via this URI!**

Example 1:
```bash
USERINFO="https://openid-provider.sample.org/userinfo"
```

Example 2 (Keycloak):
```bash
USERINFO="http://localhost:8080/realms/test/protocol/openid-connect/userinfo"
```


#### Issuer Claim

The Remote ID Token's Issuer.

This is the value of the `iss` claim of the issued Remote ID Token.
Typically, this is the public URI of the OpenID Provider where `.well-known/openid-configuration` is added to request the OpenID configuration.

Example 1:
```bash
ISSUER="https://accounts.sample.org/"
```

Example 2:
```bash
ISSUER="http://localhost:8080/realms/test"
```


#### Token Validity Period

The Remote ID Token's default validity period in seconds.

Default Value: `3600` (1 hour).

Example:
```bash
DEFAULT_TOKEN_PERIOD=3600
```


#### Maximum Token Validity Period

The Remote ID Token's maximum validity period in seconds.
If the requested token period is longer than this value, this value is used.

Default Value: `2592000` (30 days).

Example:
```bash
MAX_TOKEN_PERIOD=2592000
```


#### Port

The Port where the endpoint is running on.

Default Value: `8080`.

Example:
```bash
PORT=8080
```


### REST Endpoint

The REST API is described in the OpenAPI format provided [here](./docs/openapi.yaml).
