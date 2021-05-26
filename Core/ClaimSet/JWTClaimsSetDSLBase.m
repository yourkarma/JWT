//
//  JWTClaimsSetDSLBase.m
//  JWT
//
//  Created by Dmitry Lobanov on 26.05.2021.
//  Copyright © 2021 JWTIO. All rights reserved.
//

#import "JWTClaimsSetDSLBase.h"
#import "JWTClaimVariations.h"

@interface JWTClaimsSetDSLBase ()
- (NSObject *)valueForName:(NSString *)name;
- (void)setValue:(NSObject *)value forName:(NSString *)name;
@end

@implementation JWTClaimsSetDSLBase
- (NSObject *)valueForName:(NSString *)name {
    __auto_type claim = [self.claimsProvider claimByName:name];
    if (claim == nil) {
        return nil;
    }
    NSInteger index = [self.claimsSetProvider.claims indexOfObjectPassingTest:^BOOL(id<JWTClaimProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.name isEqualToString:name];
    }];
    if (index != NSNotFound) {
        return self.claimsSetProvider.claims[index].value;
    }
    return nil;
}
- (void)setValue:(NSObject *)value forName:(NSString *)name {
    __auto_type claim = [self.claimsProvider claimByName:name];
    if (claim == nil) {
        return;
    }
    [self.claimsSetProvider removeClaimByName:name];
    [self.claimsSetProvider appendClaim:[claim copyWithValue:value]];
}

- (NSString *)issuer { return (NSString *)[self valueForName:JWTClaimBaseConcreteIssuer.name]; }
- (void)setIssuer:(NSString *)value { [self setValue:value forName:JWTClaimBaseConcreteIssuer.name]; }
- (NSString *)subject { return (NSString *)[self valueForName:JWTClaimBaseConcreteSubject.name]; }
- (void)setSubject:(NSString *)value { [self setValue:value forName:JWTClaimBaseConcreteSubject.name]; }
- (NSString *)audience { return (NSString *)[self valueForName:JWTClaimBaseConcreteAudienceEqualSingle.name]; }
- (void)setAudience:(NSString *)value { [self setValue:value forName:JWTClaimBaseConcreteAudienceEqualSingle.name]; }
- (NSDate *)expirationDate { return [self valueForName:JWTClaimBaseConcreteExpirationTime.name]; }
- (void)setExpirationDate:(NSDate *)value { [self setValue:value forName:JWTClaimBaseConcreteExpirationTime.name]; }
- (NSDate *)notBeforeDate { return [self valueForName:JWTClaimBaseConcreteNotBefore.name]; }
- (void)setNotBeforeDate:(NSDate *)value { [self setValue:value forName:JWTClaimBaseConcreteNotBefore.name]; }
- (NSDate *)issuedAt { return [self valueForName:JWTClaimBaseConcreteIssuedAt.name]; }
- (void)setIssuedAt:(NSDate *)value { [self setValue:value forName:JWTClaimBaseConcreteIssuedAt.name]; }
- (NSString *)identifier { return [self valueForName:JWTClaimBaseConcreteJWTID.name]; }
- (void)setIdentifier:(NSString *)value { [self setValue:value forName:JWTClaimBaseConcreteJWTID.name]; }
- (NSString *)type { return [self valueForName:JWTClaimBaseConcreteType.name]; }
- (void)setType:(NSString *)value { [self setValue:value forName:JWTClaimBaseConcreteType.name]; }
- (NSString *)scope { return [self valueForName:JWTClaimBaseConcreteScope.name]; }
- (void)setScope:(NSString *)value { [self setValue:value forName:JWTClaimBaseConcreteScope.name]; }
@end
