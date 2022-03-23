# Message Layer Authentication with OpenID Connect

## Abstract

This document describes a message layer authentication mechanism for OpenID Connect.
It can be used to authenticate messages on the application layer of the ISO/OSI model.
This includes messages of instant messengers, emails, audio or video streams, signalling messages or any other kind of messages which are exchanged between the Clients of two users.
Users authenticate themselves with a special kind of OpenID ID Token, called Identity Assertion Token (IAT) which contains a public key whose corresponding private key is used by the sending Client to authenticate as its user.
This authentication mechanism also works between users of different OpenID Providers (OP) if users trust each others OP.
 
## Table of Content

- [Message Layer Authentication with OpenID Connect](#message-layer-authentication-with-openid-connect)
  - [Abstract](#abstract)
  - [Table of Content](#table-of-content)
  - [1. Introduction](#1-introduction)
    - [1.1. Requirements Notation and Conventions](#11-requirements-notation-and-conventions)
    - [1.2. Terminology](#12-terminology)
  - [2. Overview](#2-overview)
    - [2.1. User Authentication](#21-user-authentication)
    - [2.2. Client Registration](#22-client-registration)
    - [2.3. Client Authentication](#23-client-authentication)
    - [2.4. Advanced Usage](#24-advanced-usage)
  - [3. ID Assertion Token](#3-id-assertion-token)

## 1. Introduction

Suppose, Alice and Bob want to exchange messages via any Message eXchange Service (MXS), e.g., an instant messenger.
Alice and Bob don't know each other yet and have never exchanged any information.
They also do not trust the MXS which could manipulate or introspect exchanged messages.
But they trust each others Identity Provider (IdP) to validate authentication of their user accounts correctly.

With the technique proposed in this document, Alice can send an authenticated message to Bob.
If Bob trusts Alice's IdP, he can verify that the message was sent by Alice's Client.
This works also the other way around, even if Bob's and Alice's IdP differ from each other.

To authenticate a user to another Client, this document introduces a special kind of ID Token, called the Identity Assertion Token (IAT).
Unlike the normal ID Token, the IAT's purpose is to be sent to Clients or servers of other users.
Because of this, a the introduction of an IAT is required, since a normal ID Token might leak internal data between the Client and the OP (e.g., internal user IDs, email addresses, ...) if transferred to another user.

For advanced security, this document also describes how to establish an End-to-End Encryption (E2EE) for uni- and bidirectional communication channels on the application layer.


### 1.1. Requirements Notation and Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119 [3].


### 1.2. Terminology

This specification uses the terms "Access Token", "Refresh Token", "Authorization Code", "Authorization Endpoint", "Authorization Grant", "Authorization Server", "Client", "Client Authentication", "Client Identifier", "Client Secret", "Grant Type", "Protected Resource", "Refresh Token", "Resource Owner", "Resource Server", "Response Type", and "Token Endpoint" defined by The OAuth 2.0 Authorization Framework in [RFC 6749](https://datatracker.ietf.org/doc/rfc6749/), the terms "Claim Name", "Claim Value", "JSON Web Token (JWT)", and "JWT Claims Set" defined by JSON Web Token (JWT) in [RFC 7519](https://datatracker.ietf.org/doc/7519/), and the terms "Authentication Request", "ID Token", and "OpenID Provider (OP)" defined by [OpenID Connect Core 1.0](https://openid.net/specs/openid-connect-core-1_0.html).

This specification also defines the following terms:

**ID Assertion Token (IDT)**
A JWT which is signed by an OP and contains information about its owner.
It also contains the public key of the owner's Client.
It is similar to an ID Token as defined in [OpenID Connect](https://openid.net/specs/openid-connect-core-1_0.html), but it is meant to be transferred to other users, so it does not contain any internal data.


## 2. Overview

The mechanism has three basic steps which are:

1. **User Authentication**: The Resource Owner (= User) MUST authenticate to its own OpenID Provider.
2. **Client Registration**: The Resource Owner MUST register an asymmetric key pair for its Client at the OpenID Provider which issues an ID Assertion Token.
3. **Client Authentication**: The Client uses its key pair and the ID Assertion Token to authenticate as its Resource Owner to other Resource Owners.

```
   +----------------+                                 +----------------+
   |                |                                 |                |
   |   Apricot OP   |                                 |   Banana OP    |
   |                |                                 |                |
   +----------------+                                 +----------------+
       ^        ^                                         ^        ^    
       |        |                                         |        |    
      (1)      (2)                                       (1)      (2)   
     AuthN    Token                                     AuthN    Token  
    Request  Request                                   Request  Request 
       |        |                                         |        |    
       v        v                                         v        v    
   +----------------+                                 +----------------+
   |                |-------------------------------->|                |
   |    Client A    |   (3) (Mutual) Authentication   |    Client B    |
   |                |<--------------------------------|                |
   +----------------+                                 +----------------+
```


### 2.1. User Authentication

The Client performs an Authentication Request as described in the [OpenID Connect Specification in section 3.1.2.1](https://openid.net/specs/openid-connect-core-1_0.html#AuthRequest).

If the `scope` parameter contains a value of `public_openid`, the OpenID Provider MUST request authorization from user to issue an ID Assertion Token which contains information about the user.

```
   +--------------+     (1) AuthN Request        +---------------------+
   |              |----------------------------->|                     |
   |    Client    |     (3) AuthN Response       |   OpenID Provider   |
   |              |<-----------------------------|                     |
   +--------------+                              +---------------------+
```


### 2.2. Client Registration

The Client performs a Token Request as described in the [OpenID Connect Specification in section 3.1.3.1](https://openid.net/specs/openid-connect-core-1_0.html#TokenRequest).

Thereby, the Client MUST provide a public key and a proof to own the related private key.
This works exactly like in [section 5 of the OAuth 2.0 Demonstrating Proof-of-Possession at the Application Layer Draft](https://www.ietf.org/archive/id/draft-ietf-oauth-dpop-06.html#name-dpop-access-token-request):
The Client provides a JSON Web Token (JWT) as specified in [RFC 7519](https://datatracker.ietf.org/doc/html/rfc7519) in the DPoP header.
This JWT contains the Client's public key as JSON Web Key (see [RFC 7517](https://datatracker.ietf.org/doc/html/rfc7517)) in its header and is signed by the Client with the related private key.

If validation succeeded, the OpenID Provider responds with a Token Response as specified in [section 3.1.3.3 of the OpenID Connect Specification](https://openid.net/specs/openid-connect-core-1_0.html#TokenResponse).
In addition, this response contains the parameter `id_assertion_token` which contains the ID Assertion Token.
This ID Assertion Token is a JWT, just like the ID Token, but with the JWK encoded public key from the DPoP header in its header.
A detailed specification of the ID Assertion Token is provided in [section 3](#3-id-assertion-token).

```
   +--------------+     (1) Token Request        +---------------------+
   |              |----------------------------->|                     |
   |    Client    |     (3) Token Response       |   OpenID Provider   |
   |              |<-----------------------------|                     |
   +--------------+                              +---------------------+
```


### 2.3. Client Authentication

In the first message that Client A sends to Client B, Client A provides its ID Assertion Token and signs a unique part of the message with the private key whose related public key is in the header of the ID Assertion Token.

Client B verifies the identity of Client A by first checking the validity of the ID Assertion Token.
Therefore, Client B checks that the ID Assertion Token is signed by a trusted OpenID Provider, which may require interaction with the user of Client B.
If the ID Assertion Token is valid, Client B verifies the signature of the message with the public key provided the ID Assertion Token's header.
If the signature is valid, Client B knows that the message comes from a Client which was authorized by the Resource Owner stated as subject in the ID Assertion Token.

Depending on the application, the flow might end here, since this is enough to transport a user-authenticated message from one client to another.
Now Client B MAY answer this message by doing exactly the same thing.


```
   +----------------+      (1) Client A AuthN         +----------------+
   |                |-------------------------------->|                |
   |    Client A    |      (2) Client B AuthN         |    Client B    |
   |                |<--------------------------------|                |
   +----------------+                                 +----------------+
```


### 2.4. Advanced Usage

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