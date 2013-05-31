//
//  JWTClaimsSetSerializer.m
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright (c) 2013 Karma. All rights reserved.
//

#import "JWTClaimsSetSerializer.h"

@implementation JWTClaimsSetSerializer

+ (NSDictionary *)dictionaryWithClaimsSet:(JWTClaimsSet *)theClaimsSet;
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [self dictionary:dictionary setObjectIfNotNil:theClaimsSet.issuer forKey:@"iss"];
    [self dictionary:dictionary setObjectIfNotNil:theClaimsSet.subject forKey:@"sub"];
    [self dictionary:dictionary setObjectIfNotNil:theClaimsSet.audience forKey:@"aud"];
    [self dictionary:dictionary setObjectIfNotNil:@([theClaimsSet.expirationDate timeIntervalSince1970]) forKey:@"exp"];
    [self dictionary:dictionary setObjectIfNotNil:@([theClaimsSet.notBeforeDate timeIntervalSince1970]) forKey:@"nbf"];
    [self dictionary:dictionary setObjectIfNotNil:@([theClaimsSet.issuedAt timeIntervalSince1970]) forKey:@"iat"];
    [self dictionary:dictionary setObjectIfNotNil:theClaimsSet.identifier forKey:@"jti"];
    [self dictionary:dictionary setObjectIfNotNil:theClaimsSet.type forKey:@"typ"];
    return dictionary;
}

+ (void)dictionary:(NSMutableDictionary *)theDictionary setObjectIfNotNil:(id)theObject forKey:(id<NSCopying>)theKey;
{
    if (!theObject)
        return;
    
    [theDictionary setObject:theObject forKey:theKey];
}

@end
