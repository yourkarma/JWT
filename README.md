# JWT

A [JSON Web Token][] implementation in Objective-C.

[JSON Web Token]: http://self-issued.info/docs/draft-ietf-oauth-json-web-token.html

# Installation

Add the following to your [Cocoapods][] Podfile:

    pod 'JWT', git: 'https://github.com/yourkarma/JWT.git', tag: '1.0.0'

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

The library currently only supports HS512 - HMAC using SHA-512. Additional algorithms can be added by implementing the `KWTAlgorithm` protocol.

# Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
