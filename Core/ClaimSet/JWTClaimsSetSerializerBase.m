//
//  JWTClaimsSetSerializerBase.m
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import "JWTClaimsSetSerializerBase.h"
#import "JWTClaimVariations.h"

@implementation JWTClaimsSetSerializerBase

- (NSObject *)deserializedValue:(NSObject *)value forClaimWithName:(NSString *)name {
    if ([name isEqualToString:JWTClaimBaseConcreteNotBefore.name] ||
        [name isEqualToString:JWTClaimBaseConcreteExpirationTime.name] ||
        [name isEqualToString:JWTClaimBaseConcreteIssuedAt.name]
        ) {
        /// We have to apply date time conversion.
        if ([value isKindOfClass:NSNumber.class]) {
            return [NSDate dateWithTimeIntervalSince1970:[(NSNumber *)value doubleValue]];
        }
    }
    return value;
}

- (NSObject *)serializedClaimValue:(id<JWTClaimProtocol>)claim {
    __auto_type name = claim.name;
    __auto_type value = claim.value;
    if ([name isEqualToString:JWTClaimBaseConcreteNotBefore.name] ||
        [name isEqualToString:JWTClaimBaseConcreteExpirationTime.name] ||
        [name isEqualToString:JWTClaimBaseConcreteIssuedAt.name]
        ) {
        /// We have to apply date time conversion.
        if ([value isKindOfClass:NSDate.class]) {
            return @([(NSDate *)value timeIntervalSince1970]);
        }
    }
    return value;
}

- (nonnull id<JWTClaimsSetProtocol>)claimsSetFromDictionary:(nonnull NSDictionary *)dictionary {
    
    if (dictionary.count == 0) {
        return nil;
    }
    
    __auto_type result = [NSMutableArray new];
    
    for (NSString *key in dictionary) {
        __auto_type claim = [self.claimsProvider claimByName:key];
        if (claim != nil) {
            __auto_type value = [self deserializedValue:dictionary[key] forClaimWithName:key];
            [result addObject:[claim copyWithValue:value]];
        }
    }
    
    if (result.count == 0) {
        return nil;
    }
    
    return [self.claimsSetProvider copyWithClaims:result];
}

- (nonnull NSDictionary *)dictionaryFromClaimsSet:(nonnull id<JWTClaimsSetProtocol>)claimsSet {
    ///
    if (claimsSet.claims.count == 0) {
        return nil;
    }
    
    __auto_type result = [NSMutableDictionary new];
    
    for (id<JWTClaimProtocol> value in claimsSet.claims) {
        if ([self.claimsProvider claimByName:value.name] != nil) {
            result[value.name] = [self serializedClaimValue:value];
        }
    }
    
    if (result.count == 0) {
        return nil;
    }
    
    return [NSDictionary dictionaryWithDictionary:result];
}

@end
