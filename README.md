[![JWT](http://jwt.io/assets/logo.svg)](https://jwt.io/)  
[![Build Status](https://travis-ci.org/yourkarma/JWT.svg?branch=master)](https://travis-ci.org/yourkarma/JWT)
[![Pod Version](http://img.shields.io/cocoapods/v/JWT.svg?style=flat)](http://cocoadocs.org/docsets/JWT)
[![Pod Platform](http://img.shields.io/cocoapods/p/JWT.svg?style=flat)](http://cocoadocs.org/docsets/JWT)
[![Reference Status](https://www.versioneye.com/objective-c/jwt/reference_badge.svg?style=flat)](https://www.versioneye.com/objective-c/jwt/references)

# JWT

A [JSON Web Token][] implementation in Objective-C.

[JSON Web Token]: http://self-issued.info/docs/draft-ietf-oauth-json-web-token.html

# Installation

Add the following to your [Cocoapods][] Podfile:

    pod "JWT"

[Cocoapods]: http://cocoapods.org

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

# Algorithms

The following algorithms are supported:

* HS512 - HMAC using SHA-512. 
* HS256
* None
    
Additional algorithms can be added by implementing the `JWTAlgorithm` protocol.

# Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
