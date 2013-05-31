//
//  JWTClaimsSerializerSpec.m
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright 2013 Karma. All rights reserved.
//

#import "Kiwi.h"

#import "JWTClaimsSetSerializer.h"

SPEC_BEGIN(JWTClaimsSerializerSpec)

context(@"serialization", ^{
    __block JWTClaimsSet *claimsSet;
    __block NSDictionary *serialized;
    
    beforeEach(^{
        claimsSet = [[JWTClaimsSet alloc] init];
        claimsSet.issuer = @"Facebook";
        claimsSet.subject = @"Token";
        claimsSet.audience = @"http://yourkarma.com";
        claimsSet.expirationDate = [NSDate distantFuture];
        claimsSet.notBeforeDate = [NSDate distantPast];
        claimsSet.issuedAt = [NSDate date];
        claimsSet.identifier = @"thisisunique";
        claimsSet.type = @"test";
        serialized = [JWTClaimsSetSerializer dictionaryWithClaimsSet:claimsSet];
    });
    
    it(@"serializes the issuer property", ^{
        [[serialized should] haveValue:claimsSet.issuer forKey:@"iss"];
    });

    it(@"serializes the subject property", ^{
        [[serialized should] haveValue:claimsSet.subject forKey:@"sub"];
    });

    it(@"serializes the audience property", ^{
        [[serialized should] haveValue:claimsSet.audience forKey:@"aud"];
    });

    it(@"serializes the expiration date property", ^{
        [[serialized should] haveValue:theValue([claimsSet.expirationDate timeIntervalSince1970]) forKey:@"exp"];
    });

    it(@"serializes the not before date property", ^{
        [[serialized should] haveValue:theValue([claimsSet.notBeforeDate timeIntervalSince1970])  forKey:@"nbf"];
    });

    it(@"serializes the issued at property", ^{
        [[serialized should] haveValue:theValue([claimsSet.issuedAt timeIntervalSince1970]) forKey:@"iat"];
    });

    it(@"serializes the JWT ID property", ^{
        [[serialized should] haveValue:claimsSet.identifier forKey:@"jti"];
    });

    it(@"serializes the type property", ^{
        [[serialized should] haveValue:claimsSet.type forKey:@"typ"];
    });
});

context(@"deserialization", ^{
    __block JWTClaimsSet *deserialized;
    __block NSDictionary *serialized;
    
    beforeEach(^{
        serialized = @{
            @"iss": @"Facebook",
            @"sub": @"Token",
            @"aud": @"http://yourkarma.com",
            @"exp": @(64092211200),
            @"nbf": @(-62135769600),
            @"iat": @(1370005175.80196),
            @"jti": @"thisisunique",
            @"typ": @"test"
        };
        deserialized = [JWTClaimsSetSerializer claimsSetWithDictionary:serialized];
    });
    
    it(@"deserializes the issuer property", ^{
        [[deserialized.issuer should] equal:[serialized objectForKey:@"iss"]];
    });
    
    it(@"deserializes the subject property", ^{
        [[deserialized.subject should] equal:[serialized objectForKey:@"sub"]];
    });
    
    it(@"deserializes the audience property", ^{
        [[deserialized.audience should] equal:[serialized objectForKey:@"aud"]];
    });
    
    it(@"deserializes the expiration date property", ^{
        [[deserialized.expirationDate should] equal:[NSDate dateWithTimeIntervalSince1970:[[serialized objectForKey:@"exp"] doubleValue]]];
    });
    
    it(@"deserializes the not before date property", ^{
        [[deserialized.notBeforeDate should] equal:[NSDate dateWithTimeIntervalSince1970:[[serialized objectForKey:@"nbf"] doubleValue]]];
    });
    
    it(@"deserializes the issued at property", ^{
        [[deserialized.issuedAt should] equal:[NSDate dateWithTimeIntervalSince1970:[[serialized objectForKey:@"iat"] doubleValue]]];
    });
    
    it(@"deserializes the JWT ID property", ^{
        [[deserialized.identifier should] equal:[serialized objectForKey:@"jti"]];
    });
    
    it(@"deserializes the type property", ^{
        [[deserialized.type should] equal:[serialized objectForKey:@"typ"]];
    });
});
        

SPEC_END


