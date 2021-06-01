//
//  JWTClaimsSetDSLBase.m
//  JWT
//
//  Created by Dmitry Lobanov on 31.05.2021.
//  Copyright © 2021 JWTIO. All rights reserved.
//

#import "JWTClaimsSetDSLBase.h"
#import "JWTClaimVariations.h"

@interface JWTClaimsSetDSLBase ()
@property (strong, nonatomic, readwrite) id <JWTClaimsProviderProtocol> claimsProvider;
@property (copy, nonatomic, readwrite) id <JWTClaimsSetProtocol> claimsSetStorage;
@end

@implementation JWTClaimsSetDSLBase
- (instancetype)initWithClaimsProvider:(id<JWTClaimsProviderProtocol>)claimsProvider claimsSetStorage:(id<JWTClaimsSetProtocol>)claimsSetStorage {
    if (self = [self init]) {
        self.claimsProvider = claimsProvider;
        self.claimsSetStorage = claimsSetStorage;
    }
    return self;
}
@end

@implementation JWTClaimsSetDSLBase (DSL)
- (NSObject *)dslValueForName:(NSString *)name {
    __auto_type claim = [self.claimsProvider claimByName:name];
    if (claim == nil) {
        return nil;
    }
    return [self.claimsSetStorage claimByName:name].value;
}
- (void)dslSetValue:(NSObject *)value forName:(NSString *)name {
    __auto_type claim = [self.claimsProvider claimByName:name];
    if (claim == nil) {
        return;
    }
    [self.claimsSetStorage removeClaimByName:name];
    [self.claimsSetStorage appendClaim:[claim copyWithValue:value]];
}

// MARK: - DSL
- (NSString *)issuer { return (NSString *)[self dslValueForName:JWTClaimsNames.issuer]; }
- (void)setIssuer:(NSString *)value { [self dslSetValue:value forName:JWTClaimsNames.issuer]; }
- (NSString *)subject { return (NSString *)[self dslValueForName:JWTClaimsNames.subject]; }
- (void)setSubject:(NSString *)value { [self dslSetValue:value forName:JWTClaimsNames.subject]; }
- (NSString *)audience { return (NSString *)[self dslValueForName:JWTClaimsNames.audience]; }
- (void)setAudience:(NSString *)value { [self dslSetValue:value forName:JWTClaimsNames.audience]; }
- (NSDate *)expirationDate { return (NSDate *)[self dslValueForName:JWTClaimsNames.expirationTime]; }
- (void)setExpirationDate:(NSDate *)value { [self dslSetValue:value forName:JWTClaimsNames.expirationTime]; }
- (NSDate *)notBeforeDate { return (NSDate *)[self dslValueForName:JWTClaimsNames.notBefore]; }
- (void)setNotBeforeDate:(NSDate *)value { [self dslSetValue:value forName:JWTClaimsNames.notBefore]; }
- (NSDate *)issuedAt { return (NSDate *)[self dslValueForName:JWTClaimsNames.issuedAt]; }
- (void)setIssuedAt:(NSDate *)value { [self dslSetValue:value forName:JWTClaimsNames.issuedAt]; }
- (NSString *)identifier { return (NSString *)[self dslValueForName:JWTClaimsNames.jwtID]; }
- (void)setIdentifier:(NSString *)value { [self dslSetValue:value forName:JWTClaimsNames.jwtID]; }
- (NSString *)type { return (NSString *)[self dslValueForName:JWTClaimsNames.type]; }
- (void)setType:(NSString *)value { [self dslSetValue:value forName:JWTClaimsNames.type]; }
- (NSString *)scope { return (NSString *)[self dslValueForName:JWTClaimsNames.scope]; }
- (void)setScope:(NSString *)value { [self dslSetValue:value forName:JWTClaimsNames.scope]; }
@end
