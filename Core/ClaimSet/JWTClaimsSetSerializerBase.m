//
//  JWTClaimsSetSerializerBase.m
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import "JWTClaimsSetSerializerBase.h"

@implementation JWTClaimsSetSerializerBase

@synthesize claimBuilder = _claimBuilder;
@synthesize claimsSetBuilder = _claimsSetBuilder;

- (nonnull id<JWTClaimsSetProtocol>)claimsSetFromDictionary:(nonnull NSDictionary *)dictionary {
    
    if (dictionary.count == 0) {
        return nil;
    }
    
    __auto_type result = [NSMutableArray new];
    
    for (NSString *key in dictionary) {
        __auto_type claim = [self.claimsProvider claimByName:key];
        if (claim != nil) {
            [self.claimBuilder claimWithName:claim.name value:claim.value];
            [result addObject:claim];
        }
    }
    
    if (result.count == 0) {
        return nil;
    }
    
    return [self.claimsSetBuilder claimsSetWithClaims:result];
}

- (nonnull NSDictionary *)dictionaryFromClaimsSet:(nonnull id<JWTClaimsSetProtocol>)claimsSet {
    ///
    if (claimsSet.claims.count == 0) {
        return nil;
    }
    
    __auto_type result = [NSMutableDictionary new];
    
    for (id<JWTClaimProtocol> value in claimsSet.claims) {
        if ([self.claimsProvider claimByName:value.name] != nil) {
            result[value.name] = value.value;
        }
    }
    
    if (result.count == 0) {
        return nil;
    }
    
    return [NSDictionary dictionaryWithDictionary:result];
}

@end
