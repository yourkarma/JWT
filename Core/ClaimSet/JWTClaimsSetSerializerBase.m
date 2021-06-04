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
@property (strong, nonatomic, readwrite) NSMutableDictionary <NSString *, id<JWTClaimSerializerProtocol>> *namesAndSerializers;
@end

@implementation JWTClaimsSetSerializerBase
+ (NSDictionary *)createNamesAndSerializers {
    __auto_type expirationTime = JWTClaimsNames.expirationTime;
    __auto_type notBefore = JWTClaimsNames.notBefore;
    __auto_type issuedAt = JWTClaimsNames.issuedAt;
    return @{
        expirationTime : JWTClaimSerializerVariations.dateAndTimestampTransform,
        notBefore : JWTClaimSerializerVariations.dateAndTimestampTransform,
        issuedAt : JWTClaimSerializerVariations.dateAndTimestampTransform,
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
    if (dictionary == nil) {
        return nil;
    }
    
    if (dictionary.count == 0) {
        return nil;
    }
    
    __auto_type result = [NSMutableArray new];
    
    for (NSString *key in dictionary) {
        __auto_type claim = [self.claimsProvider claimByName:key];
        __auto_type skipVerification = self.skipClaimsProviderLookupCheck;
        if (skipVerification || claim != nil) {
            __auto_type value = [self deserializedClaimValue:dictionary[key] forName:key];
            [result addObject:[claim copyWithValue:value]];
        }
    }
    
    if (result.count == 0) {
        return nil;
    }
    
    return [self.claimsSetStorage copyWithClaims:result];
}

- (nonnull NSDictionary *)dictionaryFromClaimsSet:(nonnull id<JWTClaimsSetProtocol>)claimsSet {
    if (claimsSet == nil) {
        return nil;
    }
    
    if (claimsSet.isEmpty) {
        return nil;
    }
    
    __auto_type result = [NSMutableDictionary new];
    
    for (id<JWTClaimProtocol> value in claimsSet.claims) {
        __auto_type claim = [self.claimsProvider claimByName:value.name];
        __auto_type skipVerification = self.skipClaimsProviderLookupCheck;
        if (skipVerification || claim != nil) {
            result[value.name] = [self serializedClaimValue:value];
        }
    }
    
    if (result.count == 0) {
        return nil;
    }
    
    return [NSDictionary dictionaryWithDictionary:result];
}

@end
