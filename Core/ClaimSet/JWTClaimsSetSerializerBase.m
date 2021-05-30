//
//  JWTClaimsSetSerializerBase.m
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import "JWTClaimsSetSerializerBase.h"
#import "JWTClaimVariations.h"
#import "JWTClaimSerializerVariations.h"

@interface JWTClaimsSetSerializerBase ()
@property (copy, nonatomic, readwrite) NSMutableDictionary <NSString *, id<JWTClaimSerializerProtocol>> *namesAndSerializers;
@end

@implementation JWTClaimsSetSerializerBase
+ (NSDictionary *)createNamesAndSerializers {
    __auto_type expirationTime = JWTClaimVariations.expirationTime;
    __auto_type notBefore = JWTClaimVariations.notBefore;
    __auto_type issuedAt = JWTClaimVariations.issuedAt;
    return @{
        expirationTime.name : JWTClaimSerializerVariations.dateAndTimestamp,
        notBefore.name : JWTClaimSerializerVariations.dateAndTimestamp,
        issuedAt.name : JWTClaimSerializerVariations.dateAndTimestamp,
    };
}
- (instancetype)init {
    if (self = [super init]) {
        self.namesAndSerializers = [NSMutableDictionary dictionaryWithDictionary:self.class.createNamesAndSerializers];
    }
    return self;
}

- (NSObject *)deserializedClaimValue:(NSObject *)value forName:(NSString *)name {
    __auto_type serializer = self.namesAndSerializers[name] ?: [JWTClaimSerializerBase new];
    return [serializer deserializedClaimValue:value forName:name];
}

- (NSObject *)serializedClaimValue:(id<JWTClaimProtocol>)claim {
    __auto_type name = claim.name;
    __auto_type serializer = self.namesAndSerializers[name] ?: [JWTClaimSerializerBase new];
    return [serializer serializedClaimValue:claim];
}

// MARK: - JWTClaimsSetSerializerProtocol
- (void)registerSerializer:(id<JWTClaimSerializerProtocol>)serializer forClaimName:(NSString *)name {
    if (name != nil) {
        self.namesAndSerializers[name] = serializer;
    }
}
- (void)unregisterSerializerForClaimName:(NSString *)name {
    if (name != nil) {
        [self.namesAndSerializers removeObjectForKey:name];
    }
}

- (nonnull id<JWTClaimsSetProtocol>)claimsSetFromDictionary:(nonnull NSDictionary *)dictionary {
    
    if (dictionary.count == 0) {
        return nil;
    }
    
    __auto_type result = [NSMutableArray new];
    
    for (NSString *key in dictionary) {
        __auto_type claim = [self.claimsProvider claimByName:key];
        if (claim != nil) {
            __auto_type value = [self deserializedClaimValue:dictionary[key] forName:key];
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
