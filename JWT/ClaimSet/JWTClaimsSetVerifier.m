//
//  JWTClaimsSetVerifier.m
//  JWT
//
//  Created by Lobanov Dmitry on 13.02.16.
//  Copyright © 2016 Karma. All rights reserved.
//

#import "JWTClaimSetVerifier.h"
#import "JWTClaimsSetSerializer.h"
#import "JWTClaim.h"

@implementation JWTClaimsSetVerifier

+ (BOOL)verifyDictionary:(NSDictionary *)dictionary withTrustedDictionary:(NSDictionary *)trustedDictionary byKey:(NSString *)key {
    NSObject *value = dictionary[key];
    NSObject *trustedValue = trustedDictionary[key];
    
    BOOL result = YES;
    
    if (trustedValue) {
        result = [[JWTClaim claimByName:key] verifyValue:value withTrustedValue:trustedValue];
    }
    
    return result;
}

+ (BOOL)verifyClaimsSet:(JWTClaimsSet *)theClaimsSet withTrustedClaimsSet:(JWTClaimsSet *)trustedClaimsSet {
    
    NSDictionary *dictionary = [JWTClaimsSetSerializer dictionaryWithClaimsSet:theClaimsSet];
    
    NSDictionary *trustedDictionary = [JWTClaimsSetSerializer dictionaryWithClaimsSet:trustedClaimsSet];
    
    NSArray *claimsSets = [JWTClaimsSetSerializer claimsSetKeys];
    
    BOOL result = YES;
    for (NSString *key in claimsSets) {
        result = result && [self verifyDictionary:dictionary withTrustedDictionary:trustedDictionary byKey:key];
    }
    
    return result;
}

@end