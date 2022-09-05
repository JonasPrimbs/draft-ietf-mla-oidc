# Code Examples

This documentation shows code examples which can be used to generate Nonces and Elliptic Curve (EC) key pairs for signing easily in JavaScript.

## Nonce Generation

```js
function generateNonce() {
    const bytes = new Uint8Array(24);
    const nonceBytes = window.crypto.getRandomValues(bytes);
    const nonceChars = String.fromCharCode(...nonceBytes);
    return window.btoa(nonceChars);
}

const nonce = generateNonce();
// Example result: "VjfU46Z5ykIhn7jJzqZoWK+paq63EKuH"
```

## Key Pair Generation and Export

Generate new Key Pair and export public and private key in JWK format:

```js
async function generateEs256KeyPair() {
    return await window.crypto.subtle.generateKey(
        {
            name: "ECDSA",
            namedCurve: "P-256",
        },
        true,
        [
            "sign",
            "verify",
        ]
    );
}

async function generateRsa256KeyPair() {
    return await window.crypto.subtle.generateKey(
        {
            name: "RSASSA-PKCS1-v1_5",
            modulusLength: 2048,
            publicExponent: new Uint8Array([1, 0, 1]),
            hash: {
                name: "SHA-256"
            }
        },
        true,
        [
            "sign",
            "verify",
        ]
    );
}

async function exportPublicKeyJwk(keyPair) {
    return await window.crypto.subtle.exportKey(
        "jwk",
        keyPair.publicKey,
    );
}

async function exportPrivateKeyJwk(keyPair) {
    return await window.crypto.subtle.exportKey(
        "jwk",
        keyPair.privateKey,
    );
}

const sampleKeyPair = await generateEs256KeyPair();
const publicKeyJwk = await exportPublicKeyJwk(sampleKeyPair);
const privateKeyJwk = await exportPrivateKeyJwk(sampleKeyPair);
```

## Key Pair Conversion to PEM:

Convert Private Key to PEM:

```js
async function privateJwkToPem(keyPair) {
    const privateKeyPkcs8 = await window.crypto.subtle.exportKey(
        "pkcs8",
        keyPair.privateKey
    );
    const privateKeyPkcs8AsString = String.fromCharCode.apply(
        null,
        new Uint8Array(privateKeyPkcs8)
    );
    const privateKeyPkcs8AsBase64 = window.btoa(
        privateKeyPkcs8AsString
    );
    return `-----BEGIN PRIVATE KEY-----\n${privateKeyPkcs8AsBase64}\n-----END PRIVATE KEY-----`;
}

const privateKeyPem = privateJwkToPem(privateKeyJwk);
```

Convert Public Key to PEM:

```js
async function publicJwkToPem(keyPair) {
    const publicKeySpki = await window.crypto.subtle.exportKey(
        "spki",
        keyPair.publicKey
    );
    const publicKeySpkiAsString = String.fromCharCode.apply(
        null,
        new Uint8Array(publicKeySpki)
    );
    const publicKeySpkiAsBase64 = window.btoa(
        publicKeySpkiAsString
    );
    return `-----BEGIN PUBLIC KEY-----\n${publicKeySpkiAsBase64}\n-----END PUBLIC KEY-----`;
}

const privateKeyPem = publicJwkToPem(publicKeyJwk);
```
