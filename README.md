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

# Installation

Add the following to your [CocoaPods][] Podfile:

    pod "JWT"

[CocoaPods]: http://cocoapods.org

# Usage

You can encode arbitrary payloads like so:

    [JWT encodePayload:@{@"foo": @"bar"} withSecret:@"secret"];

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
    [JWT encodeClaimsSet:claimsSet withSecret:@"secret"];

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

    JWTBuilder *builder = [JWT decodeMessage:jwt].secret(secret).claimsSet(trustedClaimsSet);
    NSDictionary *payload = builder.decode;
    
    if (!builder.jwtError) {
        // do your work here
    }
    else {
        // handle error
    }

## Fluent Style

If you want to use fluent style, you could start with `JWTBuilder` interface and use it via JWT methods

    + (JWTBuilder *)encodePayload:(NSDictionary *)payload;
    + (JWTBuilder *)encodeClaimsSet:(JWTClaimsSet *)claimsSet;
    + (JWTBuilder *)decodeMessage:(NSString *)message;

As you can see, JWTBuilder has interface from both decoding and encoding.

Note: some attributes are encode-only or decode-only.

    #pragma mark - Encode only
    *payload;
    *headers;
    *algorithm;
    *algorithmName;

    #pragma mark - Decode only
    *message
    *options // as forcedOption from jwt decode functions interface.

You can inspect JWTBuilder by `jwt`-prefixed attributes.

You can set JWTBuilder attributes by fluent style (block interface).

### Fluent Example

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
    JWTBuilder *encodeBuilder = [JWT encodeClaimsSet:claimsSet];
    NSString *encodedResult = encodeBuilder.secret(secret).algorithmName(algorithmName).headers(headers).encode;
    
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
    JWTBuilder *decodeBuilder = [JWT decodeMessage:yourJwt];
    NSDictionary *decodedResult = decodeBuilder.message(yourJwt).secret(yourSecret).claimsSet(trustedClaimsSet).options(options).decode;
    if (decodeBuilder.jwtError) {
        // handle error
        NSLog(@"decode failed, error: %@", decodeBuilder.jwtError);
    }
    else {
        // handle decoded result
        NSLog(@"decoded result: %@", decodedResult);
    }

# Algorithms

The following algorithms are supported:

* HS512 - HMAC using SHA-512. 
* HS256 / HS384 / HS512
* None
    
Additional algorithms can be added by implementing the `JWTAlgorithm` protocol.

# Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
