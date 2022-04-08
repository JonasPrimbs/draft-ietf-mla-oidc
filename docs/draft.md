# Message Layer Authentication with OpenID Connect


## Abstract

This document describes a message layer End-to-End Authentication (E2EA) mechanism for OpenID Connect (OIDC).
It can be used to authenticate messages on the application layer of the ISO/OSI model even through multiple servers like, e.g., proxies.
This includes messages of instant messengers, emails, audio or video streams, signalling messages, or any other kinds of messages which are exchanged between the Relying Parties of two End Users.
Thereby, End Users authenticate themselves with a special kind of OpenID ID Token, called the ID Assertion Token (IAT).
The IAT is a sender-constraint JWT that the End User's Relying Party uses to demonstrate Proof-of-Possession (dPoP) of this token.
Therefore, the IAT contains a public key whose corresponding private key can be used to authenticate messages.
This authentication mechanism also works between End Users of different OpenID Providers (OP) if End Users trust each other's OP.
This document also describes how to extend the mechanism to initialize End-to-End Encryption (E2EE) for full End-to-End Security.


## Table of Content

- [Message Layer Authentication with OpenID Connect](#message-layer-authentication-with-openid-connect)
  - [Abstract](#abstract)
  - [Table of Content](#table-of-content)
  - [1. Introduction](#1-introduction)
    - [1.1. Requirements Notation and Conventions](#11-requirements-notation-and-conventions)
    - [1.2. Terminology](#12-terminology)
  - [2. Overview](#2-overview)
    - [2.1. End User Authentication](#21-end-user-authentication)
    - [2.2. Relying Party Registration](#22-relying-party-registration)
    - [2.3. Relying Party Authentication](#23-relying-party-authentication)
    - [2.4. Message Authentication](#24-message-authentication)
    - [2.5. Encryption Extension](#25-encryption-extension)
  - [3. ID Assertion Token](#3-id-assertion-token)
  - [4. Authentication Flow](#4-authentication-flow)
    - [4.1. End User Authentication](#41-end-user-authentication)
    - [4.2. Token Request](#42-token-request)
  - [5. Relying Party Authentication](#5-relying-party-authentication)
    - [5.1. Authentication of RP A](#51-authentication-of-rp-a)
    - [5.2. Authentication of RP B](#52-authentication-of-rp-b)
    - [5.3. Relying Party Authentication with Elliptic Curve Certificates](#53-relying-party-authentication-with-elliptic-curve-certificates)
    - [5.4. Relying Party Authentication with Diffie-Hellman Key Exchange](#54-relying-party-authentication-with-diffie-hellman-key-exchange)
  - [6. Advanced Security Features](#6-advanced-security-features)
    - [6.1. Initialization of End-to-End Encryption](#61-initialization-of-end-to-end-encryption)
      - [6.1.1. E2EE with ECC and Diffie-Hellman](#611-e2ee-with-ecc-and-diffie-hellman)
      - [6.1.2. E2EE with RSA and AES](#612-e2ee-with-rsa-and-aes)
    - [6.2. Double Ratchet Initialization](#62-double-ratchet-initialization)


## 1. Introduction

Suppose, Alice and Bob want to exchange messages via any Message eXchange Service (MXS), e.g., an instant messenger.
Alice and Bob don't know each other yet and have never exchanged any information before.
They also do not trust the MXS which could manipulate or introspect exchanged messages.
But they trust each other's OpenID Provider (OP) to validate the identity of their End User accounts correctly.

With the technique proposed in this document, Alice can send authenticated messages to Bob.
If Bob trusts Alice's OP, he can verify that the message was sent by a Relying Party of Alice.
This works mutually as long as Alice and Bob trust each other's OP, even if Bob's and Alice's OP are different.

To authenticate an End User to another Relying Party, this document introduces a special kind of ID Token, called the ID Assertion Token (IAT).
Unlike the normal ID Token, the IAT's purpose is to be sent to remote Relying Parties or servers to authenticate the End User of the IAT to other Relying Parties.
Because of this, the introduction of an IAT is required since a normal ID Token might leak undesired data (e.g., internal End User ID, email address, ...) if transferred to another End User.

The structure of the IAT relies on the Proof-of-Possession Key Semantics for JSON Web Tokens, defined in [RFC7800](https://www.rfc-editor.org/rfc/rfc7800).
Therefore, it contains the public key of an asymmetric key pair.
The Relying Party uses the related private key to authenticate sent messages and thereby proves the possession of the IAT.

To achieve full End-to-End Security, this document also describes how to achieve End-to-End Encryption (E2EE) for uni- and bidirectional communication channels on the application layer.


### 1.1. Requirements Notation and Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC2119](https://datatracker.ietf.org/doc/html/rfc2119).


### 1.2. Terminology

This specification uses the terms "Access Token", "Refresh Token", "Authorization Code", "Authorization Endpoint", "Authorization Grant", "Refresh Token", "Response Type", and "Token Endpoint" defined by The OAuth 2.0 Authorization Framework in [RFC6749](https://datatracker.ietf.org/doc/rfc6749/), the terms "Claim Name", "Claim Value", "JSON Web Token (JWT)", and "JWT Claims Set" defined by JSON Web Token (JWT) in [RFC7519](https://datatracker.ietf.org/doc/7519/), and the terms "Authentication Request", "Relying Party (RP)", "End User (EU)", "ID Token", and "OpenID Provider (OP)" defined by [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html).

This specification also defines the following terms:

**ID Assertion Token (IDT)**
A JWT which is signed by an OP and contains information to identify its End User.
It follows the Proof-of-Possession Key Semantics for JSON Web Tokens of [RFC7800](https://www.rfc-editor.org/rfc/rfc7800) and therefore contains the public key of the End User's Relying Party.
It is an ID Token, as defined in [OpenID Connect](https://openid.net/specs/openid-connect-core-1_0.html), but it contains a configurable subset of granted claims since it is meant to be transferred to other End User's Relying Parties and MUST NOT leak any undesired data.


## 2. Overview

The mechanism has the following three basic steps, as depicted in Fig. 1:

1. **End User Authentication**: The End User MUST authenticate to its own OpenID Provider. This is done in the OpenID Authentication Request.
2. **Relying Party Registration**: The Relying Party MUST register a public key and prove possession of the related private key to the OpenID Provider. The OpenID Provider then issues an ID Assertion Token in the Token Response.
3. **End User Authentication**: The Relying Parties MUST authenticate as their End Users to each other by presenting the ID Assertion Token and proving possession of their private keys. This typically happens in the first message exchanges between the Relying Parties where they can optionally exchange authenticated secrets for End-to-End Encryption.
4. **Secure Communication**: Now, each Relying Party knows the identity of the remote End User and the public key of the remote Relying Party. From now on, they can communicate authenticated, and optionally also encrypted.

```
     +------------+                              +------------+
     |            |                              |            |
     |    OP A    |                              |    OP B    |
     |            |                              |            |
     +------------+                              +------------+
       ^        ^                                  ^        ^    
       |        |                                  |        |    
      (1)      (2)                                (1)      (2)   
     AuthN    Token                              AuthN    Token  
    Request  Request                            Request  Request 
       |        |                                  |        |    
       v        v                                  v        v    
     +------------+   (3) EU Authentication      +------------+
     |            |<---------------------------->|            |
     |    RP A    |   (4) Secure Communication   |    RP B    |
     |            |<---------------------------->|            |
     +------------+                              +------------+
```
Fig. 1: The four steps to establish secure communication between two Relying Parties.

The next subsections describe an overview over the most important parts of these four steps.


### 2.1. End User Authentication

This section describes how an End User authenticates to the OpenID Provider.

To initialize the End User Authentication, the Relying Party performs an Authentication Request (step (1) of Fig. 2) as described in [Section 3.1.2.1 of the OpenID Connect Specification](https://openid.net/specs/openid-connect-core-1_0.html#AuthRequest).
The target of the Authentication Request is that the End User authenticates to the OpenID Provider so that the Relying Party can request an ID Assertion Token containing claims in it which identify the End User.

```
     +---------------+                      +-----------------+
     |               |  (1) AuthN Request   |                 |
     |               |--------------------->|    End User     |
     |               |     scope: openid    |                 |
     |               |                      +-----------------+
     |               |                              |          
     | Relying Party |                        (2) AuthZ grant  
     |               |                              v          
     |               |                      +-----------------+
     |               |                      |                 |
     |               |  (3) AuthN Response  | OpenID Provider |
     |               |<---------------------|                 |
     +---------------+                      +-----------------+
```
Fig. 2: The OpenID Connect Authentication Request and Response.

Just like in OpenID Connect, the Relying Party MUST request a `scope` parameter which MUST contain the value `openid`.
The End User can then decide whether to grant the `openid` scope or to reject it.
If the scope `openid` is not provided, or the End User rejects it, the OpenID Provider MUST NOT issue an ID Assertion Token.

If the Relying Party needs more than the basic `openid` claims in the ID Assertion Token, the Relying Party MUST request additional scopes like for the ID Token or the UserInfo Endpoint.
This means that if additional claims (e.g., `name`, `given_name`, or `family_name`) SHOULD be present in the ID Assertion Token, the Relying Party MUST request access to the related scope (e.g., `profile`).
If the End User rejects some of the requested scopes, the related claims MUST NOT be present, neither in the ID Token or UserInfo Endpoint, nor in the ID Assertion Token.
So, the set of claims which MAY be present in the ID Assertion Token MUST be equal to the set of claims which MAY be present in the ID Token or the UserInfo Endpoint.

In the Authentication Request, the Relying Party MAY configure the minimal or optional present claims in the ID Token or UserInfo Endpoint with the OPTIONAL `claims` parameter, as defined in [Section 5.5 of the OpenID Connect Specification](https://openid.net/specs/openid-connect-core-1_0.html#ClaimsParameter).
So, by default, all the available claims will be present in the ID Token or the UserInfo Endpoint, unless they are configured to not be present, similar to a black-list approach.

For the ID Assertion Token, present claims can also be configured, but with a white-list approach, to reveal only explicitly intended claims in the ID Assertion Token.
So, any identity claim which is not present in the OPTIONAL `claims` parameter's attribute `id_assertion_token`, will not be present in the ID Assertion Token.

An exception of this are the default JWT claims `iss`, `sub`, `aud`, `exp`, `nbf`, `iat`, `jti`, and `cnf`.
These JWT claims MAY be always present in the ID Assertion Token and their presence MUST NOT be configurable.

```json
{
  "id_token": {
    "given_name": null,
    "email": {"essential": true}
  },
  "id_assertion_token": {
    "given_name": {"essential": true},
    "family_name": {"essential": true},
    "nickname": null
  }
}
```
Fig. 3: Example for the OPTIONAL `claims` parameter in the Authentication Request.

**Example:**

The Relying Party performs an Authentication Request.
Thereby, the Relying Party requests the scopes `openid`, `profile`, and `email` and defines the `scope` parameter as described in Fig. 3.
Then the End User grants access to the requested scopes, so the granted claims will be `given_name`, `family_name`, `nickname`, `name`, `email`, and `email_verified`.

When the Relying Party performs a valid Token Request, the OpenID Provider issues an ID Token which contains all the granted claims and it fails, if no email address is provided, or access was not granted.
The issued ID Assertion Token will then contain only the scopes `given_name`, `family_name`, and `nickname`, since these were the only claims which were explicitly requested.
If `given_name` or `family_name` is not granted or given, the request will fail, if `nickname` is not granted or given, the `nickname` claim is not present in the ID Assertion Token.

Since the ID Assertion Token does not permit a remote Relying Party to access the UserInfo Endpoint of the local End User, the remote Relying Party has only access to the claims which are provided in the ID Assertion Token.
The local Relying Party can use this to hide, e.g., the email address of the End User.


### 2.2. Relying Party Registration

This section describes how a Relying Party registers its asymmetric key pair to the OpenID Provider and how it requests an ID Assertion Token.

If the End User has not granted the `openid` scope, the OpenID Provider MUST NOT issue an ID Assertion Token and the Token Request will be exactly as described in [Section 3.1.3.1 of the OpenID Connect Specification](https://openid.net/specs/openid-connect-core-1_0.html#TokenRequest).
Otherwise, if the End User has granted the `openid` scope, the Token Response will be extended as described in this section.

First, the Relying Party MUST get an asymmetric key pair.
It is RECOMMENDED to create a new one, but the Relying Party can also use an already existing key pair, e.g., an X.509 certificate.

Then, the Relying Party MUST perform the Token Request, as depicted in step (1) of Fig. 4.
Thereby, the Relying Party MUST let the OpenID Provider know to which public key the OpenID Provider MUST bind the ID Assertion Token.
It is RECOMMENDED that the Relying Party provides a new public key to the OpenID Provider in the Token Request.
But the Relying Party can also reference to a public key which is already known to the OpenID Provider, e.g., a pre-registered X.509 certificate.

The Relying Party also MUST prove possession of the related private key in the Token Request.
The process how the Relying Party proves the possession of the related private key to the OpenID Provider is not covered by this document.
So the Relying Party can prove possession of the related private key with a [DPoP challenge](https://datatracker.ietf.org/doc/draft-ietf-oauth-dpop/), [HTTP Message Signatures](https://httpwg.org/http-extensions/draft-ietf-httpbis-message-signatures.html), a [Mutual TLS challenge](https://datatracker.ietf.org/doc/html/rfc8705), or any other kind of proof.

```
     +---------------+  (1) Token Request   +-----------------+
     |               |--------------------->|                 |
     |               |  Proof-of-Possession |                 |
     | Relying Party |                      | OpenID Provider |
     |               |  (2) Token Response  |                 |
     |               |<---------------------|                 |
     +---------------+  ID Assertion Token  +-----------------+
```
Fig. 4: The OpenID Connect Token Request and Response.

An example for how the Relying Party MAY provide an Elliptic Curve key pair together with a Proof-of-Possession in the Token Request is provided in [Section 5.3](#53-relying-party-authentication-with-elliptic-curve-certificates) of this document.
In some cases, the public key and the prove cannot be provided in the same requests, e.g., for a Diffie-Hellman key pair, as described in [Section 5.4](#54-relying-party-authentication-with-diffie-hellman-key-exchange) of this document.

If the Token Request is valid and the Relying Party proved possession of the related private key, the OpenID Provider MUST respond with a Token Response (step (2) of Fig. 4) as specified in [Section 3.1.3.3 of the OpenID Connect Specification](https://openid.net/specs/openid-connect-core-1_0.html#TokenResponse).
Thereby, the OpenID Provider MUST also issue an ID Assertion Token in the `id_assertion_token` parameter.

This ID Assertion Token is a JWT, which contains the claims to identify the End User.
These claims can be configured in the Authentication Request, as described in [Section 2.1](#21-end-user-authentication) of this document.
In its header, the ID Assertion Token contains the verified public key to identify the Relying Party.
A detailed specification of the ID Assertion Token is provided in [Section 3](#3-id-assertion-token) of this document.


### 2.3. Relying Party Authentication

This section describes how two Relying Parties authenticate to each other.

Before Relying Party A (RP A) and Relying Party B (RP B) can exchange End-to-End authenticated messages, the Relying Parties MUST authenticate themselves.
Therefore, they MUST exchange their ID Assertion Tokens and provide a Proof-of-Possession (PoP) of their private keys whose related public key is contained in the ID Assertion Token.
This Proof-of-Possession MUST contain protection of Replay Attack, e.g., an identifier of the recipient and a unique message identifier.
After this Relying Party Authentication process (step 1 and 2 of Fig. 5), each Relying Party knows the other Relying Party's public key, and its identity claims, provided in the ID Assertion Token.

The exchange of the ID Assertion Tokens is not covered by this document.
So, Fig. 5 is just an example how such an exchange MAY happen if the Relying Parties can communicate with each other directly or via message exchange servers like instant messengers or email.

```
     +------------+   (1) RP A AuthN          +------------+
     |            |-------------------------->|            |
     |            |       IAT A + PoP A       |            |
     |    RP A    |                           |    RP B    |
     |            |   (2) RP B AuthN          |            |
     |            |<--------------------------|            |
     +------------+       IAT B + PoP B       +------------+
```
Fig. 5: Example for mutual authentication between Relying Party (RP) A and B.


### 2.4. Message Authentication

This section describes how Relying Parties can exchange signed messages after initial Relying Party Authentication.

To exchange authenticated messages between Relying Party A and Relying Party B, as depicted in Fig. 6, the Relying Parties MUST use the public key from the remote Relying Party's ID Assertion Token to verify the integrity of any received message.

In other words: Relying Party B MUST verify that the received message was sent by Relying Party A.
Relying Party B can verify this with Relying Party A's public key from Relying Party A's ID Assertion Token.

```
     +------------+  (1) Signed Message 1   +------------+
     |            |------------------------>|            |
     |            |    msg1 + sign(msg1)    |            |
     |    RP A    |                         |    RP B    |
     |            |  (2) Signed Message 2   |            |
     |            |<------------------------|            |
     +------------+    msg2 + sign(msg2)    +------------+
```
Fig. 6: Example for bidirectional communication after mutual authentication between Relying Party (RP) A and B.

The way how messages are authenticated heavily depends on the type of key pair from the ID Assertion Token.
E.g., in case of an Elliptic Curve public key, the sending Relying Party can directly sign the message with its private key and the receiving Relying Party can verify the signature with the public key from the sending Relying Party's ID Assertion Token.
In case of a Diffie-Hellman public key, both Relying Parties MUST first compute the shared Diffie-Hellman Secret, then the sending Relying Party can sign the message with the shared secret which the receiving Relying Party can use to verify the signature.

In each case, every message must contain a Replay Attack prevention, e.g., a message counter.


### 2.5. Encryption Extension

This section describes an example how the protocol MAY be extended to establish End-to-End Encryption (E2EE).

Depending on the application, it might be useful to use the two-way communication in [Section 2.3](#23-relying-party-authentication) to establish an E2EE channel.
This can be done, e.g., by performing an authenticated Diffie-Hellman key exchange (DHE) on the application layer as depicted in Fig. 7:

```
     +------------+   (1) RP A AuthN        +------------+
     |            |------------------------>|            |
     |            |        IAT+DH A         |            |
     |            |     + PoP=sign(DH A)    |            |
     |    RP A    |                         |    RP B    |
     |            |   (2) RP B AuthN        |            |
     |            |<------------------------|            |
     |            |        IAT+DH B         |            |
     |            |     + PoP=sign(DH B)    |            |
     +------------+ (+ enc(msg1+sign(msg1)) +------------+
```
Fig. 7: Extension of Relying Party Authentication for E2EE channel initialization.

Relying Party A generates and sends the public DHE parameters in its first message to Relying Party B.
These DHE parameters MUST be included in the signed part of the message to prevent Man-in-the-Middle (MITM) attacks.

Relying Party B responds to Relying Party A with its ID Assertion Token and its own public DHE parameters.
These DHE parameters MUST also be included in the signed part of the message for MITM attack prevention purposes.

Relying Party B can also use this message to send data to Relying Party B which are encrypted with the shared Diffie-Hellman secret.
This shared secret can already be generated by Relying Party B after receiving the first message of Relying Party A.
Relying Party A can compute this shared secret after receiving the signed part of Relying Party B's message and therefore decrypt the encrypted part of the message.

After this E2EE channel initialization, Relying Party A and B can communicate bidirectionally by encrypting messages with the shared Diffie-Hellman secret, as depicted in Fig. 8.

```
     +------------+ (1) Encrypted Message 1 +------------+
     |            |------------------------>|            |
     |            |  enc(msg1 + sign(msg1)) |            |
     |    RP A    |                         |    RP B    |
     |            | (2) Encrypted Message 2 |            |
     |            |<------------------------|            |
     +------------+  enc(msg2 + sign(msg2)) +------------+
```
Fig. 8: Extension of message exchange for E2EE channel.


## 3. ID Assertion Token

This section describes the format of an ID Assertion Token in full detail.

An ID Assertion Token is a JSON Web Token (JWT), as specified in [RFC7519](https://datatracker.ietf.org/doc/html/rfc7519).
It follows the Proof-of-Possession (PoP) semantics for JWTs, as specified in [RFC7800](https://datatracker.ietf.org/doc/html/rfc7800).

TODO


## 4. Authentication Flow

This section describes, how the document extends the OpenID Connect End User Authentication Flow and the Token Request.


### 4.1. End User Authentication

TODO


### 4.2. Token Request

TODO


## 5. Relying Party Authentication

This section describes, how two Relying Parties (RP A and RP B) authenticate themselves to each other.


### 5.1. Authentication of RP A

TODO


### 5.2. Authentication of RP B

TODO


### 5.3. Relying Party Authentication with Elliptic Curve Certificates

TODO: Generate ECC key pair, provide ECC public key in DPoP header and sign it with ECC private key.


### 5.4. Relying Party Authentication with Diffie-Hellman Key Exchange

TODO: Generate Diffie-Hellman parameters `p`, `q`, and `a`. Compute `g^a mod p = A`. Send `p`, `g` and `A` to a new endpoint of the OpenID Provider. The OpenID Provider generates b and computes `g^b mod p = B` and responds with `B`. In the Token Request, the Relying Party sends an HMAC signature of the Token Request which is signed with the symmetric Diffie-Hellman Secret `s = B^a mod p`. The OpenID Provider can verify this signature with `s = A^b mod p`. If the signature is valid, the OpenID Provider as verified, that the Relying Party possesses the Diffie-Hellman private key `a` to the provided Diffie-Hellman public key `{A,p,g}`.


## 6. Advanced Security Features

This section describes optional and more advanced extensions of the protocol.


### 6.1. Initialization of End-to-End Encryption

This section describes how End-to-End Encryption (E2EE) can be established between RP A and RP B.


#### 6.1.1. E2EE with ECC and Diffie-Hellman

TODO


#### 6.1.2. E2EE with RSA and AES

TODO


### 6.2. Double Ratchet Initialization

TODO
