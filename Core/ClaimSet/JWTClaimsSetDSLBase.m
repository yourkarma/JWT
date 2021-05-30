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

- (NSString *)issuer { return (NSString *)[self valueForName:JWTClaimsNames.issuer]; }
- (void)setIssuer:(NSString *)value { [self setValue:value forName:JWTClaimsNames.issuer]; }
- (NSString *)subject { return (NSString *)[self valueForName:JWTClaimsNames.subject]; }
- (void)setSubject:(NSString *)value { [self setValue:value forName:JWTClaimsNames.subject]; }
- (NSString *)audience { return (NSString *)[self valueForName:JWTClaimsNames.audience]; }
- (void)setAudience:(NSString *)value { [self setValue:value forName:JWTClaimsNames.audience]; }
- (NSDate *)expirationDate { return (NSDate *)[self valueForName:JWTClaimsNames.expirationTime]; }
- (void)setExpirationDate:(NSDate *)value { [self setValue:value forName:JWTClaimsNames.expirationTime]; }
- (NSDate *)notBeforeDate { return (NSDate *)[self valueForName:JWTClaimsNames.notBefore]; }
- (void)setNotBeforeDate:(NSDate *)value { [self setValue:value forName:JWTClaimsNames.notBefore]; }
- (NSDate *)issuedAt { return (NSDate *)[self valueForName:JWTClaimsNames.issuedAt]; }
- (void)setIssuedAt:(NSDate *)value { [self setValue:value forName:JWTClaimsNames.issuedAt]; }
- (NSString *)identifier { return (NSString *)[self valueForName:JWTClaimsNames.jwtID]; }
- (void)setIdentifier:(NSString *)value { [self setValue:value forName:JWTClaimsNames.jwtID]; }
- (NSString *)type { return (NSString *)[self valueForName:JWTClaimsNames.type]; }
- (void)setType:(NSString *)value { [self setValue:value forName:JWTClaimsNames.type]; }
- (NSString *)scope { return (NSString *)[self valueForName:JWTClaimsNames.scope]; }
- (void)setScope:(NSString *)value { [self setValue:value forName:JWTClaimsNames.scope]; }
@end
