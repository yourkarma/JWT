//
//  JWTClaimsProviderBase.m
//  JWT
//
//  Created by Dmitry Lobanov on 22.05.2021.
//  Copyright © 2021 JWTIO. All rights reserved.
//

#import "JWTClaimsProviderBase.h"
#import "JWTClaimVariations.h"

@interface JWTClaimsProviderBase ()
@property (copy, nonatomic, readwrite) NSDictionary *claimsAndNames;
@end

@implementation JWTClaimsProviderBase
+ (NSDictionary *)createClaimsAndNames {
    __auto_type issuer = JWTClaimVariations.issuer;
    __auto_type subject = JWTClaimVariations.subject;
    __auto_type audience = JWTClaimVariations.audience;
    __auto_type expirationTime = JWTClaimVariations.expirationTime;
    __auto_type notBefore = JWTClaimVariations.notBefore;
    __auto_type issuedAt = JWTClaimVariations.issuedAt;
    __auto_type jwtId = JWTClaimVariations.jwtID;
    __auto_type type = JWTClaimVariations.type;
    __auto_type scope = JWTClaimVariations.scope;
    return @{
        issuer.name : issuer,
        subject.name : subject,
        audience.name : audience,
        expirationTime.name : expirationTime,
        notBefore.name : notBefore,
        issuedAt.name : issuedAt,
        jwtId.name : jwtId,
        type.name : type,
        scope.name : scope
    };
}

- (instancetype)init {
    if (self = [super init]) {
        self.claimsAndNames = [self.class createClaimsAndNames];
    }
    return self;
}

// MARK: - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    return [[self.class alloc] init];
}

// MARK: - JWTClaimsProviderProtocol
- (NSArray<NSString *> *)availableClaimsNames {
    return self.claimsAndNames.allKeys;
}

- (nonnull id<JWTClaimProtocol>)claimByName:(nonnull NSString *)name {
    return [self.claimsAndNames[name] copy];
}

@end
