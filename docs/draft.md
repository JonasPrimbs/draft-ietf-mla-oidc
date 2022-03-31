# Message Layer Authentication with OpenID Connect


## Abstract

This document describes a message layer End-to-End Authentication (E2EA) mechanism for OpenID Connect (OIDC).
It can be used to authenticate messages on the application layer of the ISO/OSI model even through multiple servers like e.g., proxies.
This includes messages of instant messengers, emails, audio or video streams, signalling messages, or any other kinds of messages which are exchanged between the Relying Parties of two End Users.
Thereby, End Users authenticate themselves with a special kind of OpenID ID Token, called ID Assertion Token (IAT).
The IAT is a sender-constraint JWT that the End User's Relying Party uses do demonstrate Proof-of-Possession (dPoP) of this token.
Therefore, the IAT contains a public key whose corresponding private key can be used to authenticate messages.
This authentication mechanism also works between End Users of different OpenID Providers (OP) if End Users trust each others OP.
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
  - [5. Client Authentication](#5-client-authentication)
    - [5.1. Authentication of RP A](#51-authentication-of-rp-a)
    - [5.2. Authentication of RP B](#52-authentication-of-rp-b)
    - [5.3. Client Authentication with Elliptic Curve Certificates](#53-client-authentication-with-elliptic-curve-certificates)
    - [5.4. Client Authentication with Diffie-Hellman Key Exchange](#54-client-authentication-with-diffie-hellman-key-exchange)
  - [6. Advanced Security Features](#6-advanced-security-features)
    - [6.1. Initialization of End-to-End Encryption](#61-initialization-of-end-to-end-encryption)
      - [6.1.1. E2EE with ECC and Diffie-Hellman](#611-e2ee-with-ecc-and-diffie-hellman)
      - [6.1.2. E2EE with RSA and AES](#612-e2ee-with-rsa-and-aes)
    - [6.2. Double Ratchet Initialization](#62-double-ratchet-initialization)

## 1. Introduction

Suppose, Alice and Bob want to exchange messages via any Message eXchange Service (MXS), e.g., an instant messenger.
Alice and Bob don't know each other yet and have never exchanged any information before.
They also do not trust the MXS which could manipulate or introspect exchanged messages.
But they trust each others OpenID Provider (OP) to validate the identity of their End User accounts correctly.

With the technique proposed in this document, Alice can send authenticated messages to Bob.
If Bob trusts Alice's OP, he can verify that the message was sent by a Relying Party of Alice.
This works also the other way around, even if Bob's and Alice's OP differ from each other.

To authenticate an End User to another Relying Party, this document introduces a special kind of ID Token, called the ID Assertion Token (IAT).
Unlike the normal ID Token, the IAT's purpose is to be sent to remote Relying Parties or servers to authenticate the End User of the IAT to other End Users.
Because of this, the introduction of an IAT is required, since a normal ID Token might leak undesired data (e.g., internal End User ID, email address, ...) if transferred to another End User.

The structure of the IAT relies on the Proof-of-Possession Key Semantics for JSON Web Tokens, defined in [RFC 7800](https://www.rfc-editor.org/rfc/rfc7800).
Therefore, it contains the public key of an asymmetric key pair.
The Relying Party uses the related private key to authenticate sent messages and thereby proves the possession of the IAT.

To achieve full End-to-End Security, this document also describes how to establish an End-to-End Encryption (E2EE) for uni- and bidirectional communication channels on the application layer.


### 1.1. Requirements Notation and Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119 [3].


### 1.2. Terminology

This specification uses the terms "Access Token", "Refresh Token", "Authorization Code", "Authorization Endpoint", "Authorization Grant", "Authorization Server", "Client", "Client Authentication", "Client Identifier", "Client Secret", "Grant Type", "Protected Resource", "Refresh Token", "Resource Owner", "Resource Server", "Response Type", and "Token Endpoint" defined by The OAuth 2.0 Authorization Framework in [RFC 6749](https://datatracker.ietf.org/doc/rfc6749/), the terms "Claim Name", "Claim Value", "JSON Web Token (JWT)", and "JWT Claims Set" defined by JSON Web Token (JWT) in [RFC 7519](https://datatracker.ietf.org/doc/7519/), and the terms "Authentication Request", "Relying Party (RP)", "End User (EU)", "ID Token", and "OpenID Provider (OP)" defined by [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html).

This specification also defines the following terms:

**ID Assertion Token (IDT)**
A JWT which is signed by an OP and contains information to identify its End User.
It follows the Proof-of-Possession Key Semantics for JSON Web Tokens of [RFC 7800](https://www.rfc-editor.org/rfc/rfc7800) and therefore contains the public key of the End User's Relying Party.
It is an ID Token, as defined in [OpenID Connect](https://openid.net/specs/openid-connect-core-1_0.html), but it contains a configurable subset of claims, since it is meant to be transferred to other End User's Relying Parties and MUST NOT leak any undesired data.


## 2. Overview

The mechanism has the following three basic steps:

1. **End User Authentication**: The End User MUST authenticate to its own OpenID Provider. This is done in the OpenID Authentication Request.
2. **Relying Party Registration**: The Relying Party MUST register a public key and prove possession of the related private key to the OpenID Provider. The OpenID Provider then issues and ID Assertion Token in the Token Response.
3. **End User Authentication**: The Relying Parties MUST authenticate as their End Users to each other by presenting the ID Assertion Token and proving possession of their private keys. This typically happens in the first message exchanges between the Relying Parties where they can also exchange authenticated secrets for End-to-End Encryption.
4. **Secure Communication**: Now, each Relying Party knows the identity of the remote End User and the public key of the remote Relying Party. From now on, they can communicate in a secure way.

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

To initialize the End User Authentication, the Relying Party performs an Authentication Request as described in [section 3.1.2.1 of the OpenID Connect Specification](https://openid.net/specs/openid-connect-core-1_0.html#AuthRequest).
The target of the Authentication Request is that the End User authenticates to the OpenID Provider so that the Relying Party can request an ID Assertion Token with claims in it which identify the End User.

```
     +---------------+  (1) AuthN Request   +-----------------+
     |               |--------------------->|                 |
     | Relying Party |  (2) AuthN Response  | OpenID Provider |
     |               |<---------------------|                 |
     +---------------+                      +-----------------+
```
Fig. 2: The OpenID Connect Authentication Request and Response.

Just like in OpenID Connect, the Relying Party MUST request a `scope` parameter which MUST contain the value `openid`.
The End User can then decide whether to grant the `openid` scope or to reject it.
If the scope `openid` is not provided, or the End User rejects it, the OpenID Provider MUST NOT issue an ID Assertion Token.

If the Relying Party needs more than the basic `openid` claims in the ID Assertion Token, the Relying Party MUST request additional scopes like for the ID Token or the UserInfo Endpoint.
This means, that if additional claims (e.g., `name`, `given_name`, or `family_name`) SHOULD be present in the ID Assertion Token, the Relying Party MUST request access to the related scope (e.g., `profile`).
If the End User rejects some of the requested scopes, the related claims MUST NOT be present, neither in the ID Token or UserInfo Endpoint, nor in the ID Assertion Token.
So, the set of claims which MAY be present in the ID Assertion Token MUST be equal to the set of claims which MAY be present in the ID Token or the UserInfo Endpoint.

Just like the claims for the ID Token or the UserInfo Endpoint, Relying Party MAY further restrict the claims which will be present in the ID Assertion Token.
This will prevent that e.g., the remote Relying Party which receives the ID Assertion Token, gets the email address of the End User via the ID Assertion Token, while the local Relying Party needs the email address from the ID Token.

So, the claims provided in the ID Assertion Token are a subset of the claims permitted by the End User.
This subset can be defined using the OPTIONAL `claims` parameter in the Authorization Request as defined in [section 5.5 of the OpenID Connect Specification](https://openid.net/specs/openid-connect-core-1_0.html#ClaimsParameter).
The claims which will be present in the ID Assertion Token can be defined with the new `id_assertion_token` attribute of the `claims` parameter as in Fig.3.

```json
{
  "UserInfo": {
    "given_name": {"essential": true},
    "nickname": {"essential": true},
    "email": {"essential": true},
    "email_verified": {"essential": true},
  },
  "id_token": {
    "given_name": {"essential": true},
    "email": {"essential": true},
    "email_verified": {"essential": true}
  },
  "id_assertion_token": {
    "given_name": {"essential": true},
    "nickname": {"essential": true},
    "family_name": {"essential": true}
  }
}
```
Fig. 3: Example for the OPTIONAL `claims` parameter in the Authentication Request.

If the Relying Party does not specify the `id_assertion_token` parameter or it does not specify the OPTIONAL `claims` parameter, the ID Assertion Token MUST contain all the permitted claims.

**Example:**

The Relying Party performs an Authorization Request.
Thereby, the Relying Party requests the scopes `openid`, `profile`, and `email` and defines the `scope` parameter as described in Fig.3.
Then the End User grants access to the requested scopes.

When the Relying Party performs a valid Token Request, the OpenID Provider issues an ID Token which contains the claims `given_name`, `email`, and `email_verified` in the ID Token, and an ID Assertion Token which contains the claims `given_name`, `nickname`, and `family_name`.
When the Relying Party contacts the UserInfo Endpoint, the OpenID Provider issues the claims `given_name`, `nickname`, `email`, and `email_verified`.

Since the ID Assertion Token does not permit a remote Relying Party to access information about the Resource Owner, the remote Relying Party has only access to the claims which are provided in the ID Assertion Token.
The local Relying Party can use this to hide e.g., the email address of the Resource Owner.

### 2.2. Relying Party Registration

This section describes how a Relying Party registers its asymmetric key pair to the OpenID Provider and how it requests an ID Assertion Token.

If the End User has not granted the `openid` scope, the OpenID Provider MUST NOT issue an ID Assertion Token and the Token Request will be exactly as described in [section 3.1.3.1 of the OpenID Connect Specification](https://openid.net/specs/openid-connect-core-1_0.html#TokenRequest).
Otherwise, if the End User has granted the `openid` scope, the Token Response will be extended as described in this section.

First, the Relying Party MUST get an asymmetric key pair.
It is RECOMMENDED to create a new one, but the Relying Party can also use an already existing key pair, e.g., an X.509 certificate.

Then, the Relying Party MUST perform the Token Request.
Thereby, the Relying Party MUST let the OpenID Provider know, to which public key the OpenID Provider MUST bind the ID Assertion Token to.
It is RECOMMENDED that the Relying Party provides a new public key to the OpenID Provider in the Token Request.
But the Relying Party can also reference to a public key which is already known to the OpenID Provider, e.g., a pre-registered X.509 certificate.

The Relying Party also MUST prove possession of the related private key in the Token Request.
The process how the Relying Party proves the possession of the related private key to the OpenID Provider is not covered by this document.
So the Relying Party can prove possession of the related private key with a [DPoP challenge](https://datatracker.ietf.org/doc/draft-ietf-oauth-dpop/), [HTTP Message Signatures](https://httpwg.org/http-extensions/draft-ietf-httpbis-message-signatures.html), a [Mutual TLS challenge](https://datatracker.ietf.org/doc/html/rfc8705), or any other kind of proof.

```
     +---------------+  (1) Token Request   +-----------------+
     |               |--------------------->|                 |
     | Relying Party |  (2) Token Response  | OpenID Provider |
     |               |<---------------------|                 |
     +---------------+                      +-----------------+
```
Fig. 4: The OpenID Connect Token Request and Response.

An example for how the Relying Party MAY provide an Elliptic Curve key pair together with a Proof-of-Possession in the Token Request is provided in [section 5.3](#53-client-authentication-with-elliptic-curve-certificates) of this document.
In some cases, the public key and the prove cannot be provided in the same requests, e.g., for a Diffie-Hellman key pair, as described in [section 5.4](#54-client-authentication-with-diffie-hellman-key-exchange) of this document.

If the Token Request is valid and the Relying Party proved possession of the related private key, the OpenID Provider MUST respond with a Token Response as specified in [section 3.1.3.3 of the OpenID Connect Specification](https://openid.net/specs/openid-connect-core-1_0.html#TokenResponse).
Thereby, the OpenID Provider MUST also issue an ID Assertion Token in the `id_assertion_token` parameter.

This ID Assertion Token is a JWT, which contains the claims which were specified in the Authentication Request, as described in [section 2.1](#21-end-user-authentication) of this document.
In its header, the ID Assertion Token contains the verified public key to identify the Relying Party.
A detailed specification of the ID Assertion Token is provided in [section 3](#3-id-assertion-token) of this document.


### 2.3. Relying Party Authentication

To exchange authenticated messages between Client A and Client B, the Clients MUST authenticate themselves.
Therefore, they MUST exchange their ID Assertion Tokens and validate them.
Then, Client B knows the key pair of Client A, and the identity claims of Client A's End User and vice-versa.

The exchange of the ID Assertion Tokens is not covered by this document.
Thereby, the Clients MAY NOT prove the possession of the related private key.

```
   +----------------+      (1) Client A AuthN         +----------------+
   |                |-------------------------------->|                |
   |    Client A    |      (2) Client B AuthN         |    Client B    |
   |                |<--------------------------------|                |
   +----------------+                                 +----------------+
```
Example for exchange of ID Assertion Tokens between Client A and Client B.


### 2.4. Message Authentication

To exchange authenticated messages between Client A and Client B, the Clients MUST use the public key from the remote Client's ID Assertion Token to verify the integrity of the received message.
In other words: Client B MUST verify that the received message was sent by Client A.
Client B can verify this with Client A's public key from Client A's ID Assertion Token.

The way how messages are authenticated depends heavily on the type of key pair from the ID Assertion Token.
E.g., in case of an Elliptic Curve public key, the sending Client can directly Sign the message with its private key and the receiving Client can verify the signature with the public key from the sending Client's ID Assertion Token.
In case of a Diffie-Hellman public key, both Clients MUST first compute the shared Diffie-Hellman Secret, then the sending Client can sign the message with the shared secret, which the receiving Client can use to verify the signature.

```
   +----------------+      (1) sign(message1)         +----------------+
   |                |-------------------------------->|                |
   |    Client A    |      (2) sign(message2)         |    Client B    |
   |                |<--------------------------------|                |
   +----------------+                                 +----------------+
```

<!--
In the first message that Client A sends to Client B, Client A provides its ID Assertion Token.
Client B MUST NOT trust, that this message originally comes from Client A, before Client A proved possession of the ID Assertion Token.
Anyway, proving possession of the ID Assertion Token MAY be done with this first message, e.g., by signing the message with that private key, whose public key is contained in the ID Assertion Token's header.

This can be done in any direction and with every message.

Here is an example, how such an End-to-End authenticated communication might happen, if Client A and Client B use Elliptic Curve Cryptography with the ECC public keys in their ID Assertion Token's header:

Client A sends its ID Assertion Token, and a random string to prevent replay attacks, to Client B and signs the whole message with its ECC private key.
Client B validates the ID Assertion Token and verifies the signature using the ECC public key from the ID Assertion Token of Client A.

Then Client B responds with its own ID Assertion Token, and a random string to prevent replay attacks, to Client A and signs the whole message with its own ECC private key.
Client A validates the ID Assertion Token and verifies the signature using the ECC public key from the ID Assertion Token of Client B.

In both cases, validating the ID Assertion Token MAY require an End User interaction to request from the Client's Resource Owner, whether he/she trusts the OpenID Provider of the remote Client.

From now on, both Clients know the identity of each other and they can exchanged messages which are signed with their ECC private keys.
-->


### 2.5. Encryption Extension

Depending on the application, it might be useful to use the two-way communication in [section 2.3](#23-client-authentication) to establish an End-to-End Encryption (E2EE) channel.
This can be done, e.g., by performing an authenticated Diffie-Hellman key exchange (DHE) on application layer as follows:

Client A generates and sends the public DHE parameters in its first message to Client B.
These DHE parameters MUST be included in the signed part of the message to prevent Man-in-the-Middle (MITM) attacks.

Client B responds to Client A with his ID Assertion Token and its own public DHE parameters.
These DHE parameters MUST also be included in the signed part of the message for MITM attack prevention purposes.

Client B can also use this message to send data to Client B which are encrypted with the shared Diffie-Hellman secret.
This shared secret can already be generated by Client B after receiving the first message of Client A.
Client A can compute this shared secret after receiving the signed part of Client B's message and therefore decrypt the encrypted part of the message.

```
   +----------------+ (1) sign(DHE + IAT)             +----------------+
   |                |-------------------------------->|                |
   |    Client A    | (2) sign(DHE + IAT) + enc(data) |    Client B    |
   |                |<--------------------------------|                |
   +----------------+                                 +----------------+
```


## 3. ID Assertion Token

This section describes the format of an ID Assertion Token in full detail.

An ID Assertion Token is a JSON Web Token (JWT), as specified in [RFC 7519](https://datatracker.ietf.org/doc/html/rfc7519)
It follows the Proof-of-Possession (PoP) semantics for JWTs, as specified in [RFC 7800](https://datatracker.ietf.org/doc/html/rfc7800).

TODO


## 4. Authentication Flow

This section describes exactly, how the document extends the OpenID Connect End User Authentication Flow and the Token Request.


### 4.1. End User Authentication

TODO


### 4.2. Token Request

TODO


## 5. Client Authentication

This section describes exactly, how two Relying Parties (RP A and RP B) authenticate themselves to each other.


### 5.1. Authentication of RP A

TODO


### 5.2. Authentication of RP B

TODO


### 5.3. Client Authentication with Elliptic Curve Certificates

TODO: Generate ECC key pair, provide ECC public key in DPoP header and sign it with ECC private key.

<!--
Thereby, the Client MUST provide a public key and a proof to own the related private key.
This MAY work exactly like in [section 5 of the OAuth 2.0 Demonstrating Proof-of-Possession at the Application Layer Draft](https://www.ietf.org/archive/id/draft-ietf-oauth-dpop-06.html#name-dpop-access-token-request):
The Client provides a JSON Web Token (JWT) as specified in [RFC 7519](https://datatracker.ietf.org/doc/html/rfc7519) in the DPoP header.
This JWT contains the Client's public key as JSON Web Key (see [RFC 7517](https://datatracker.ietf.org/doc/html/rfc7517)) in its header and is signed by the Client with the related private key.
The type of asymmetric Client authentication (certificates, ...) and the way of proving possession is explicitly open for future implementations.
Anyway, this will be specified for RSA and Elliptic Curve Certificates in [section 5](#)
-->

### 5.4. Client Authentication with Diffie-Hellman Key Exchange

TODO: Generate Diffie-Hellman parameters p, g and a. Compute g^a mod p = A. Send p, g and A to a new endpoint of the OpenID Provider. The OpenID Provider generates b and computes g^b mod p = B and responds with B. In Token Request, the Client sends an HMAC signature of the Token Request which is signed with the symmetric Diffie-Hellman Secret s = B^a mod p. The OpenID Provider can verify this signature with s = A^b mod p. If the signature is valid, the OpenID Provider as verified, that the Client possesses the Diffie-Hellman private key a to the provided Diffie-Hellman public key {A,p,g}.


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


<!-- OLD / OUTDATED !



## 3. Authentication Flow

This chapter describes the whole mechanism. Section 3.1 gives an overview to the whole flow. The other sections describe the mechanism in more detail on an implementation-level.
3.1.	Overview
The key-concept is to bind ID Tokens of authenticated Resource Owners (e.g., Alice and Bob) to the RTC Certificates of the Resource Owner’s Clients. Then, the ID Tokens can only be used by authorized Clients and the Clients can be associated with their Resource Owners. This works like in RFC 8705, but with Certificate-bound ID Tokens instead of Certificate-bound Access Tokens.
The flow to authenticate Alice / Bob to the Apricot / Banana OpenID Provider (OP) and to authenticate Clients with their Resource Owner’s identity to each other is described in Figure 1:
 
Figure 1: WebRTC Client Authentication with Certificate-bound ID Tokens
1.	The Clients generate new RTC Certificates, extract their Fingerprints and provide them in the Token Request to the OPs at the OP’s Token Endpoint.
2.	The OPs include the provided Fingerprints and sign these ID Tokens with their private keys. Since these ID Tokens will only be accepted when their owners prove possession of the related RTC Certificate’s private key, this ID Token is called a Certificate-bound ID Token.
3.	Client A generates ID Challenge A by hashing its Certificate-bound ID Token and sends ID Challenge A via Signaling Channel to Client B.
4.	Client B generates ID Challenge B by hashing its Certificate-bound ID Token and sends ID Challenge B via Signaling Channel to Client A.
5.	Client A generates a Session Description Offer, adds its Certificate-bound ID Token, and sends it via Signaling Channel to Client B. Client B verifies whether the hash of the ID Token from Session Description Offer matches ID Challenge A and whether the Offer’s Fingerprint matches the Fingerprint in Client A’s ID Token. If any verification fails, the flow ends here. If not, Client B applies the Offer.
6.	Client B generates a Session Description Answer, adds its Certificate-bound ID Token, and sends it via Signaling Channel to Client A. Client A verifies whether the hash of the ID Token from Session Description Answer matches ID Challenge B and whether the Answer’s Fingerprint matches the Fingerprint in Client B’s ID Token. If any verification fails, the flow ends here. If not, Client A applies the Answer.
7.	Client A and Client B establish a mutually authenticated DTLS Connection. WebRTC will verify on its own, that the remote client belongs to the Fingerprint in the applied Session Description.
The used Signaling Channel thereby must not necessarily be a secure channel. Manipulations of Session Descriptions or ID Tokens will be detected and are therefore no security issue. Anyway, Session Descriptions and ID Tokens contain personal information about Clients or their Resource Owners, such as IP addresses, or ID Token claims which results into privacy issues, when leaked. So, the Signaling Channel SHOULD be encrypted.
Keep in mind, that the identity of the Remote Peer MUST NOT be considered as verified before a connection is established successfully! Since the OpenID Provider cannot verify that a Client possesses the private key of an RTC Certificate which the Client requests an ID Token for, every Resource Owner can obtain a valid ID Token from its own OpenID Provider which is bound to an RTC Certificate that the Client does not possess! So, the identity from the ID Token MUST NOT be accepted when possession of a private key is not verified.
The following sections describe this workflow on an implementation-level.
3.2.	Certificate Generation and Fingerprint Extraction
The Client MUST use the static RTCPeerConnection.generateCertificate() Method from WebRTC API to generate a new X.509 Peer Certificate. After that the Client MUST use the RTCPeerCertificate.getFingerprints() Method of the returned RTC Peer Certificate instance to extract the HEX-encoded public key fingerprint as a String value. Since the Token Endpoint expects a Base64-encoded fingerprint, the Client MUST perform the transformation.
A sample code is provided in Figure 2. Additional line breaks are for displaying purposes only.
 
Figure 2: Sample code for RTC Certificate generation and fingerprint extraction.
When creating a new RTCPeerConnection instance, the RTCCertificate instance MUST be applied using the optional certificates attribute of the optional configuration parameter of RTCPeerConnection’s constructor.
ANY Cient MUST do this step for ANY connection to ANY other Client for security reasons! So, a Client MUST use a new RTCPeerConnection with a new RTCCertificate for each connection to each remote Client!
3.3.	Token Request
The Client requests an ID Token from the Authorization Server at the Token Endpoint as specified in OpenID Connect.
This ID Token will be bound to an RTC Client Certificate. Therefore, the Client provides the following additional POST body parameters:
x5t_val
OPTIONAL. Base64 encoded Fingerprint.
x5t_alg
OPTIONAL. Algorithm used to generate Fingerprint, e.g., "S256" for SHA-256. If not provided by Client, "S256" will be used.
An example request is described in Figure 3. Additional line breaks are for display purposes only.
 
Figure 3: Example for Token Request with Certificate-bound ID Token parameters
If the x5t_val parameter is provided in the Token Request, the Authorization Server MUST add the confirmation "cnf" claim to the generated ID Token.
The Authorization Server MUST verify if the x5t_alg parameter is a supported hashing algorithm for a fingerprint. If no fingerprint is given, "S256" will be used which stands for SHA-256.
The Authorization Server MUST verify if the x5t_val contains a valid Base64 URL encoded hash corresponding to the length of the given hash algorithm.
If both is valid, the Authorization server adds both parameters to the confirmation claim in the ID Token which looks as described in Figure 4. Additional line breaks are for display purposes only.
 
Figure 4: Example for Certificate-bound ID Token Payload.
The Authorization Server then responds with the Certificate-bound ID Token to the Client as described in Figure 5. Additional line breaks are for display purposes only.
 
Figure 5: Example for Token Response with Certificate-bound ID Token.
3.4.	ID Challenge Exchange
This section describes how ID Challenges are generated and exchanged between both Clients.
3.4.1.	ID Challenge Generation
The Client uses the Certificate-bound ID Token from Token Response and hashes it using any collision-free hashing algorithm, e.g., SHA-256.
After that the Client generates a JSON Object which will be the ID Challenge. This JSON Object contains the following two parameters:
challenge
	Base64url encoded Hash of Certificate-bound ID Token.
algorithm
	Used hashing algorithm.
The JSON Object will look like described in Figure 6. Additional line breaks are for display purposes only.
 
Figure 6: Example for ID Challenge.
3.4.2.	ID Challenge Transfer
The Client sends the generated ID Challenge via the not necessarily trusted Signaling Channel to the Remote Client.
The Remote Client stores this ID Challenge and associates it with a new RTC Certificate generated for connection with the Client who sent this ID Challenge.
3.5.	Session Description Exchange
This section describes how the Session Descriptions are exchanged between two WebRTC Peers.
The way to generate a Session Description depends on which Client initiated the connection. The calling Client generates a Session Description Offer as described in Section 3.5.1. The Called Client generates a Session Description Answer as described in Section 3.5.2. The validation of the Session Descriptions on the receiving Client is described in Section 3.5.3.
3.5.1.	Session Description Offer
The Client which calls another Client generates a Session Description Offer using the WebRTC API method RTCPeerConnection.generateOffer(). This will return a Promise which returns a JSON object containing the Session Description Protocol message in its "sdp" attribute. An example for this JSON object is depicted in Figure 7. Additional line breaks are for display purposes only.
 
Figure 7: Example for Session Description Offer.
The Client MUST then add an SDP attribute "identity" to the "sdp" attribute of the JSON object whose value is the Certificate-bound ID Token. This SDP attribute is depicted in Figure 8. Additional line breaks are for display purposes only.
 
Figure 8: Additional Identity attribute in SDP.
After that, the Client sends the Session Description Offer via a not necessarily trusted Signaling Channel to the called Client. The called Client then validates the received Session Description Offer as described in Section 3.6 and sets it as remote description if validation was successful.
3.5.2.	Session Description Answer
The Client which is called by another Client generates a Session Description Answer using the WebRTC API method RTCPeerConnection.generateAnswer(). This will return a Promise which returns a JSON object containing the Session Description Protocol message in its "sdp" attribute. An example for this JSON object is depicted in Figure 9. Additional line breaks are for display purposes only.
 
Figure 9: Example for Session Description Answer.
The Client MUST then add an SDP attribute "identity" to the "sdp" attribute of the JSON object whose value is the Certificate-bound ID Token. This SDP attribute is depicted in Figure 8.
After that, the Client sends the Session Description Answer via a not necessarily trusted Signaling Channel to the called Client. The calling Client then validates the received Session Description Answer as described in Section 3.6 and sets it as remote description if validation was successful.
3.6.	Session Description Validation
Whenever a Client receives a Session Description Offer or Answer, the Client MUST validate it.
Session Description validation contains of three steps:
1.	ID Challenge Verification as described in Section 3.6.1.
2.	ID Token Validation as described in Section 3.6.2.
3.	Fingerprint Verification as described in Section 3.6.3.
3.6.1.	ID Challenge Verification
The Client MUST extract the "identity" attribute from the Session Description and generate its hash using the "algorithm" indicated in the ID Challenge. The Client MUST compare the hash value with the Base64url encoded "challenge" from the ID Challenge.
If the values match, the ID Challenge Verification passes.
If not, either the ID Challenge or the ID Token from Session Description was changed. Then and the Client MUST inform the user, and connection establishment MUST stop here.
3.6.2.	ID Token Validation
The Client MUST extract the ID Token from the Session Description and validate it as described in Section 3.1.3.7 of the OpenID Connect Core specification [2].
Validation of the ID Token signature requires, that the user of the validating Client trusts the Identity Provider of the user whose Client sent the ID Token. If it is not clear weather the Client can trust the Identity Provider, either the user MUST be asked to trust this Identity Provider, or the ID Token Validation MUST fail.
In addition to Section 3.1.3.7 of the OpenID Connect Core specification, the ID Token MUST contain a confirmation "cnf" attribute in its payload. If not, the Validation MUST fail.
If the ID Token Validation fails, the Client MUST inform the user, and connection establishment MUST stop here.
3.6.3.	Fingerprint Verification
The Client MUST extract the "fingerprint" attribute from the Session Description and compare its value with the "cnf" attribute of the ID Token.
The Client MUST verify that…
1.	… the hash algorithms match.
2.	… the Base64url encoded fingerprint from the ID Token and the HEX encoded fingerprint form the Session Description match.
If one of these verifications fail, the Client MUST inform the user, and connection establishment MUST stop here.
3.7.	Connection Establishment
After both Clients set the received Session Descriptions as remote description, WebRTC automatically starts the establishment of the P2P connection between both Clients. Thereby, the Clients use their RTCCertificate’s public keys to mutually authenticate themselves. WebRTC will automatically verify, if the fingerprints set in the remote description match the hashes of remote client’s public key.
If they do not match, WebRTC will cancel connection establishment with an error. If so, the Client MUST inform the user about that, and connection establishment MUST stop here. If not, connection will be established, and the remote user is verified.
4.	Security Considerations
This section is about security considerations to help implementers to understand what is useful to consider for a secure implementation.
4.1.	Non-Repudiation of Resource Owner’s Identity
TODO
4.2.	Validity of Identities
Identities of remote Client’s users, provided by ID Tokens, are only valid after connection establishment. So, the user SHOULD NOT be given the impression, that the calling client’s user was verified before connection was established.
In fact, a valid Session Description containing a valid ID Token does not indicate, that the user identified by this ID Token was involved in the call. The whole Session Description could also have been replayed by an attacker. The identity of the user indicated by the ID Token can only be verified by a successful DTLS handshake which results into a successful connection establishment.
4.3.	Protection-worthy Information
This Section describes the confidentiality of transferred information.
4.3.1.	ID Challenge
The ID challenge is not confidential. Neither in terms of security, nor in terms of privacy.
4.3.2.	Certificate-bound ID Token
Since the ID Token is bound to an RTC Certificate, the ID Token cannot be used by the Client which owns the RTC Certificate, this ID Token is issued for. Therefore, the ID Token is not confidential in terms of security.
Since the ID Token may contain personal information about the user, the ID Token is confidential in terms of privacy and SHOULD be encrypted in transfer.
4.3.3.	RTC Certificate
The private key of the RTC Certificate is confidential. Clients MUST NOT expose them!
The RTC Certificate’s fingerprint and public are not confidential in terms of security, but confidential in terms of privacy since they uniquely identify a Client, which in combination with the ID Token may identify its user. Therefore, the Client SHOULD transfer Session Descriptions encrypted.
4.3.4.	Session Description
Session Descriptions are not confidential in terms of security, but since Session Descriptions contain personal information about the user, such as IP addresses, they are confidential in terms of privacy. Therefore, the Client SHOULD transfer Session Descriptions encrypted.
5.	Privacy Considerations
See Security Considerations.
6.	IANA Considerations
TODO


7.	References

[1] 	N. Sakimura, J. Bradley, M. Jones, B. de Medeiros and C. Mortimore, OpenID Connect Core 1.0, https://openid.net/specs/openid-connect-core-1_0.html: OpenID Foundation, 2014. 
[2] 	D. Hardt, The OAuth 2.0 Authorization Framework, https://datatracker.ietf.org/doc/rfc6749/: IETF, 2012. 
[3] 	S. Bradner, Key words for use in RFCs to Indicate Requirement Levels, https://datatracker.ietf.org/doc/rfc2119/: IETF, 1997. 
[4] 	M. Jones, J. Bradley and N. Sakimura, RFC 7519: JSON Web Token (JWT), https://datatracker.ietf.org/doc/rfc7519/: IETF, 2015. 
[5] 	A. Begen, P. Kyzivat, C. Perkins and M. Handley, RFC 8866: SDP: Session Description Protocol, https://datatracker.ietf.org/doc/rfc8866/: IETF, 2021. 
[6] 	C. Jennings, H. Boström and J.-I. Bruaroey, WebRTC 1.0: Real-Time Communication Between Browsers, https://www.w3.org/TR/webrtc/: W3C, 2021. 
[7] 	E. Rescorla and N. Modadugu, RFC 6347: Datagram Transport Layer Security Version 1.2, IETF, 2012. 
[8] 	T. Bray, RFC 7159: The JavaScript Object Notation (JSON) Data Interchange Format, https://datatracker.ietf.org/doc/rfc7159/: IETF, 2014. 
[9] 	B. Campbell, J. Bradley, N. Sakimura and T. Lodderstedt, RFC 8705: OAuth 2.0 Mutual-TLS Client Authentication and Certificate-Bound Access Tokens, https://datatracker.ietf.org/doc/rfc8705/: IETF, 2020. 
[10] 	S. Boeyen, S. Santesson, T. Polk, R. Housley, S. Farrell and D. Cooper, RFC 5280: Internet X.509 Public Key Infrastructure Certificate and Certificate Revocation List (CRL) Profile, https://datatracker.ietf.org/doc/rfc5280/: IETF, 2008. 
[11] 	M. Jones, RFC 7518: JSON Web Algorithms (JWA), https://datatracker.ietf.org/doc/rfc7518/: IETF, 2015. 
[12] 	M. Jones, RFC 7517: JSON Web Key (JWK), https://datatracker.ietf.org/doc/rfc7517/: IETF, 2015. 
[13] 	M. Jones and J. Hildebrand, RFC 7516: JSON Web Encryption (JWE), https://datatracker.ietf.org/doc/rfc7516/: IETF, 2015. 
[14] 	M. Jones, J. Bradley and N. Sakimura, RFC 7515: JSON Web Signature (JWS), https://datatracker.ietf.org/doc/rfc7515/: IETF, 2015. 
[15] 	D. Fett, B. Campbell, J. Bradley, T. Lodderstedt, M. Jones and D. Waite, OAuth 2.0 Demonstrating Proof-of-Possession at the Application Layer (DPoP), https://datatracker.ietf.org/doc/draft-ietf-oauth-dpop/04/: IETF, 2021. 


Appendix A. Authentication Examples
TODO
Appendix B. Acknowledgements
TODO
Appendix C. Document History
Author's Addresses
Jonas Primbs Uni Tübingen
Email: mail@jonasprimbs.de
URI: https://jonasprimbs.de/
Michael Menth Uni Tübingen
Email: menth@uni-tuebingen.de

-->