//
//  JWTClaimsSetVerifierBase.m
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import "JWTClaimsSetVerifierBase.h"

@implementation JWTClaimsSetVerifierBase
- (BOOL)verifyClaimsSet:(id<JWTClaimsSetProtocol>)theClaimsSet withTrustedClaimsSet:(id<JWTClaimsSetProtocol>)trustedClaimsSet {
    __auto_type untrustedDictionary = [self.serializer dictionaryFromClaimsSet:theClaimsSet];
    
    __auto_type trustedDictionary = [self.serializer dictionaryFromClaimsSet:trustedClaimsSet];
    
    if (trustedDictionary == nil) {
        return YES;
    }
    
    if (untrustedDictionary == nil) {
        return NO;
    }
        
    for (NSString *key in self.claimsProvider.availableClaimsNames) {
        __auto_type claim = [self.claimsProvider claimByName:key];
        if (claim == nil) {
            return NO;
        }
        __auto_type trustedValue = (NSObject *)trustedDictionary[key];
        __auto_type untrustedValue = (NSObject *)untrustedDictionary[key];
        
        if (!trustedValue) {
            continue;
        }
        
        if (![claim verifyValue:untrustedValue withTrustedValue:trustedValue]) {
            return NO;
        }
    }
    
    return YES;
}

@end
