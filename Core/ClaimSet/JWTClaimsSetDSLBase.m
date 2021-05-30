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

- (NSString *)issuer { return (NSString *)[self valueForName:JWTClaimVariations.issuer.name]; }
- (void)setIssuer:(NSString *)value { [self setValue:value forName:JWTClaimVariations.issuer.name]; }
- (NSString *)subject { return (NSString *)[self valueForName:JWTClaimVariations.subject.name]; }
- (void)setSubject:(NSString *)value { [self setValue:value forName:JWTClaimVariations.subject.name]; }
- (NSString *)audience { return (NSString *)[self valueForName:JWTClaimVariations.audience.name]; }
- (void)setAudience:(NSString *)value { [self setValue:value forName:JWTClaimVariations.audience.name]; }
- (NSDate *)expirationDate { return (NSDate *)[self valueForName:JWTClaimVariations.expirationTime.name]; }
- (void)setExpirationDate:(NSDate *)value { [self setValue:value forName:JWTClaimVariations.expirationTime.name]; }
- (NSDate *)notBeforeDate { return (NSDate *)[self valueForName:JWTClaimVariations.notBefore.name]; }
- (void)setNotBeforeDate:(NSDate *)value { [self setValue:value forName:JWTClaimVariations.notBefore.name]; }
- (NSDate *)issuedAt { return (NSDate *)[self valueForName:JWTClaimVariations.issuedAt.name]; }
- (void)setIssuedAt:(NSDate *)value { [self setValue:value forName:JWTClaimVariations.issuedAt.name]; }
- (NSString *)identifier { return (NSString *)[self valueForName:JWTClaimVariations.jwtID.name]; }
- (void)setIdentifier:(NSString *)value { [self setValue:value forName:JWTClaimVariations.jwtID.name]; }
- (NSString *)type { return (NSString *)[self valueForName:JWTClaimVariations.type.name]; }
- (void)setType:(NSString *)value { [self setValue:value forName:JWTClaimVariations.type.name]; }
- (NSString *)scope { return (NSString *)[self valueForName:JWTClaimVariations.scope.name]; }
- (void)setScope:(NSString *)value { [self setValue:value forName:JWTClaimVariations.scope.name]; }
@end
