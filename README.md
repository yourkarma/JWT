[![JWT](http://jwt.io/assets/logo.svg)](https://jwt.io/)

[![Build Status](https://travis-ci.org/yourkarma/JWT.svg?branch=master)](https://travis-ci.org/yourkarma/JWT)
[![Pod Version](http://img.shields.io/cocoapods/v/JWT.svg?style=flat)](http://cocoadocs.org/docsets/JWT)
[![Pod Platform](http://img.shields.io/cocoapods/p/JWT.svg?style=flat)](http://cocoadocs.org/docsets/JWT)
[![Code Climate](https://codeclimate.com/github/yourkarma/JWT/badges/gpa.svg)](https://codeclimate.com/github/yourkarma/JWT)
[![Test Coverage](https://codeclimate.com/github/yourkarma/JWT/badges/coverage.svg)](https://codeclimate.com/github/yourkarma/JWT/coverage)
[![Reference Status](https://www.versioneye.com/objective-c/jwt/reference_badge.svg?style=flat)](https://www.versioneye.com/objective-c/jwt/references)

# JWT

A [JSON Web Token][] implementation in Objective-C.

[JSON Web Token]: http://self-issued.info/docs/draft-ietf-oauth-json-web-token.html

# What's new in master and bleeding edge.
These features are experiments! No warranties!
## Whitelists possible algorithms.
When you need to decode jwt by several algorithms you could specify their names in whitelist.
Later this feature possible will migrate to options.
For example, someone returns result or error.
### Limitations
Restricted to pair (algorithm or none) due to limitations of unique `secret`.
```
    NSString *jwtResultOrError = /*...*/;
    NSString *secret = @"secret";
    JWTBuilder *builder = [JWT decodeMessage:jwtResultOrError].secret(@"secret").whitelist(@[@"HS256", @"none"]);
    NSDictionary *decoded = builder.decode;
    if (builder.jwtError) {
        // oh!
    }
    else {
        NSDictionary *payload = decoded[@"payload"];
        NSDictionary *header = decoded[@"header"];
        NSArray *tries = decoded[@"tries"]; // will be evolded into something appropriate later.
    }
```

# What's new in Version 2.0
Old plain style deprecated.
Use modern fluent style instead.

```
    NSDictionary *payload = @{@"foo" : @"bar"};
    NSString *secret = @"secret";
    id<JWTAlgorithm> algorithm = [JWTAlgorithmFactory algorithmByName:@"HS256"];
    // Deprecated
    [JWT encodePayload:payload withSecret:secret algorithm:algorithm];

    // Modern
    [JWTBuilder encodePayload:payload].secret(secret).algorithm(algorithm).encode;
```

# Installation

Add the following to your [CocoaPods][] Podfile:

    pod "JWT"

[CocoaPods]: http://cocoapods.org

Install via Cartfile:

    github "yourkarma/JWT" "master"

and `import JWT`

# Documentation
# Usage

## JWTBuilder

To encode & decode JWTs, use fluent style with the `JWTBuilder` interface

    + (JWTBuilder *)encodePayload:(NSDictionary *)payload;
    + (JWTBuilder *)encodeClaimsSet:(JWTClaimsSet *)claimsSet;
    + (JWTBuilder *)decodeMessage:(NSString *)message;

As you can see, JWTBuilder has interface from both decoding and encoding.

Note: some attributes are encode-only or decode-only.

    #pragma mark - Encode only
    *payload;
    *headers;
    *algorithm;

    #pragma mark - Decode only
    *message
    *options // as forcedOption from jwt decode functions interface.
    *whitelist  //optional array of algorithm names to whitelist for decoding

You can inspect JWTBuilder by `jwt`-prefixed attributes.

You can set JWTBuilder attributes by fluent style (block interface).

You can encode arbitrary payloads like so:

    NSDictionary *payload = @{@"foo" : @"bar"};
    NSString *secret = @"secret";
    id<JWTAlgorithm> algorithm = [JWTAlgorithmFactory algorithmByName:@"HS256"];

    [JWTBuilder encodePayload:payload].secret(@"secret").algorithm(algorithm).encode;

If you're using reserved claim names you can encode your claim set like so (all properties are optional):

    JWTClaimsSet *claimsSet = [[JWTClaimsSet alloc] init];
    claimsSet.issuer = @"Facebook";
    claimsSet.subject = @"Token";
    claimsSet.audience = @"http://yourkarma.com";
    claimsSet.expirationDate = [NSDate distantFuture];
    claimsSet.notBeforeDate = [NSDate distantPast];
    claimsSet.issuedAt = [NSDate date];
    claimsSet.identifier = @"thisisunique";
    claimsSet.type = @"test";

    NSString *secret = @"secret";
    id<JWTAlgorithm> algorithm = [JWTAlgorithmFactory algorithmByName:@"HS256"];

    [JWTBuilder encodeClaimsSet:claimsSet].secret(secret).algorithm(algorithm).encode;

You can decode a JWT like so:

	NSString *jwtToken = @"header.payload.signature";
	NSString *secret = @"secret";
	NSString *algorithmName = @"HS256"; //Must specify an algorithm to use

	NSDictionary *payload = [JWTBuilder decodeMessage:jwtToken].secret(secret).algorithmName(algorithmName).decode;

If you want to check claims while decoding, you could use next sample of code (all properties are optional):

    // Trusted Claims Set
    JWTClaimsSet *trustedClaimsSet = [[JWTClaimsSet alloc] init];
    trustedClaimsSet.issuer = @"Facebook";
    trustedClaimsSet.subject = @"Token";
    trustedClaimsSet.audience = @"http://yourkarma.com";
    trustedClaimsSet.expirationDate = [NSDate date];
    trustedClaimsSet.notBeforeDate = [NSDate date];
    trustedClaimsSet.issuedAt = [NSDate date];
    trustedClaimsSet.identifier = @"thisisunique";
    trustedClaimsSet.type = @"test";

    NSString *message = @"encodedJwt";
    NSString *secret = @"secret";
    NSString *algorithmName = @"chosenAlgorithm"

    JWTBuilder *builder = [JWTBuilder decodeMessage:jwt].secret(secret).algorithmName(algorithmName).claimsSet(trustedClaimsSet);
    NSDictionary *payload = builder.decode;

    if (!builder.jwtError) {
        // do your work here
    }
    else {
        // handle error
    }

If you want to enforce a whitelist of valid algorithms:

	NSArray *whitelist = @[@"HS256", @"HS512"];
	NSString *jwtToken = @"header.payload.signature";
	NSString *secret = @"secret";
	NSString *algorithmName = @"HS256";

	//Returns nil
	NSDictionary *payload = [JWTBuilder decodeMessage:jwtToken].secret(secret).algorithmName(algorithmName).whitelist(@[]).decode;

	//Returns the decoded payload
	NSDictionary *payload = [JWTBuilder decodeMessage:jwtToken].secret(secret).algorithmName(algorithmName).whitelist(whitelist).decode;

### Encode / Decode Example

    // suppose, that you create ClaimsSet
    JWTClaimsSet *claimsSet = [[JWTClaimsSet alloc] init];
    // fill it
    claimsSet.issuer = @"Facebook";
    claimsSet.subject = @"Token";
    claimsSet.audience = @"http://yourkarma.com";

    // encode it
    NSString *secret = @"secret";
    NSString *algorithmName = @"HS384";
    NSDictionary *headers = @{@"custom":@"value"};
    id<JWTAlgorithm> algorithm = [JWTAlgorithmFactory algorithmByName:algorithmName];

    JWTBuilder *encodeBuilder = [JWT encodeClaimsSet:claimsSet];
    NSString *encodedResult = encodeBuilder.secret(secret).algorithm(algorithm).headers(headers).encode;

    if (encodeBuilder.jwtError) {
        // handle error
        NSLog(@"encode failed, error: %@", encodeBuilder.jwtError);
    }
    else {
        // handle encoded result
        NSLog(@"encoded result: %@", encodedResult);
    }

    // decode it
    // you can set any property that you want, all properties are optional
    JWTClaimsSet *trustedClaimsSet = [claimsSet copy];

    // decode forced ? try YES
    BOOL decodeForced = NO;
    NSNumber *options = @(decodeForced);
    NSString *yourJwt = encodedResult; // from previous example
    NSString *yourSecret = secret; // from previous example
    NSString *yourAlgorithm = algorithmName; // from previous example
    JWTBuilder *decodeBuilder = [JWT decodeMessage:yourJwt];
    NSDictionary *decodedResult = decodeBuilder.message(yourJwt).secret(yourSecret).algorithmName(yourAlgorithm).claimsSet(trustedClaimsSet).options(options).decode;
    if (decodeBuilder.jwtError) {
        // handle error
        NSLog(@"decode failed, error: %@", decodeBuilder.jwtError);
    }
    else {
        // handle decoded result
        NSLog(@"decoded result: %@", decodedResult);
    }

#### NSData
You can also encode/decode using a secret that is represented as an NSData object

	//Encode
	NSData *secretData = <your data>
	NSString *algorithmName = @"HS384";
    NSDictionary *headers = @{@"custom":@"value"};
    id<JWTAlgorithm> algorithm = [JWTAlgorithmFactory algorithmByName:algorithmName];

    JWTBuilder *encodeBuilder = [JWT encodeClaimsSet:claimsSet];
    NSString *encodedResult = encodeBuilder.secretData(secretData).algorithm(algorithm).headers(headers).encode;

    //Decode
    NSString *jwtToken = @"header.payload.signature";
	NSData *secretData = <your data>
	NSString *algorithmName = @"HS256"; //Must specify an algorithm to use

	NSDictionary *payload = [JWTBuilder decodeMessage:jwtToken].secretData(secretData).algorithmName(algorithmName).decode;

# Algorithms

The following algorithms are supported:

* RS256
* HS512 - HMAC using SHA-512.
* HS256 / HS384 / HS512
* None

## RS256 usage.
For example, you have your file with privateKey: `file.p12`.
And you have a secret passphrase for that file: `secret`.

    // Encode
    NSDictionary *payload = @{@"payload" : @"hidden_information"};
    NSString *algorithmName = @"RS256";

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"secret_key" ofType:@"p12"];
    NSData *privateKeySecretData = [NSData dataWithContentsOfFile:filePath];

    NSString *passphraseForPrivateKey = @"secret";

    JWTBuilder *builder = [JWTBuilder encodePayload:payload].secretData(privateKeySecretData).privateKeyCertificatePassphrase(passphraseForPrivateKey).algorithmName(algorithmName);
    NSString *token = builder.encode;

    // check error
    if (builder.jwtError) {
        // error occurred.
    }

    // Decode
    // Suppose, that you get token from previous example. You need a valid public key for a private key in previous example.
    // Private key stored in @"secret_key.p12". So, you need public key for that private key.
    NSString *publicKey = @"..."; // load public key. Or use it as raw string.

    algorithmName = @"RS256";

    JWTBuilder *decodeBuilder = [JWTBuilder decodeMessage:token].secret(publicKey).algorithmName(algorithmName);
    NSDictionary *envelopedPayload = decodeBuilder.decode;

    // check error
    if (decodeBuilder.jwtError) {
        // error occurred.
    }


Additional algorithms can be added by implementing the `JWTAlgorithm` protocol.

## Before pull request

Please, read [Contribution notes](https://github.com/yourkarma/JWT/blob/master/.github/CONTRIBUTING.md) before make pull request.