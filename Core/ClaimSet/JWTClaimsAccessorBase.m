//
//  JWTClaimsAccessorBase.m
//  JWT
//
//  Created by Dmitry Lobanov on 22.05.2021.
//  Copyright © 2021 JWTIO. All rights reserved.
//

#import "JWTClaimsAccessorBase.h"
#import "JWTClaimVariations.h"

@interface JWTClaimsAccessorBase ()
@property (copy, nonatomic, readwrite) NSDictionary *claimsAndNames;
@end

@implementation JWTClaimsAccessorBase
+ (NSDictionary *)createClaimsAndNames {
    __auto_type issuer = [JWTClaimBaseConcreteIssuer new];
    __auto_type subject = [JWTClaimBaseConcreteSubject new];
    __auto_type audience = [JWTClaimBaseConcreteAudience new];
    __auto_type expirationTime = [JWTClaimBaseConcreteExpirationTime new];
    __auto_type notBefore = [JWTClaimBaseConcreteNotBefore new];
    __auto_type issuedAt = [JWTClaimBaseConcreteIssuedAt new];
    __auto_type jwtId = [JWTClaimBaseConcreteJWTID new];
    __auto_type type = [JWTClaimBaseConcreteType new];
    __auto_type scope = [JWTClaimBaseConcreteScope new];
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
    self = [super init];
    if (self) {
        self.claimsAndNames = [self.class createClaimsAndNames];
    }
    return self;
}

- (NSArray<NSString *> *)availableClaimsNames {
    return self.claimsAndNames.allKeys;
}

- (nonnull id<JWTClaimProtocol>)claimByName:(nonnull NSString *)name {
    return self.claimsAndNames[name];
}

@end
