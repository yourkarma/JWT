//
//  JWTClaimsSetBase.m
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import "JWTClaimsSetBase.h"
#import "JWTClaimVariations.h"

@interface JWTClaimsSetBase ()
@property (strong, nonatomic, readwrite) NSMutableDictionary <NSString *, id<JWTClaimProtocol>> *namesAndClaims;
@end

@implementation JWTClaimsSetBase
- (instancetype)initWithClaims:(nonnull NSArray<id<JWTClaimProtocol>> *)claims {
    if (self = [super init]) {
        self.namesAndClaims = [NSMutableDictionary dictionaryWithObjects:claims forKeys:[claims valueForKey:@"name"]];
    }
    return self;
}

- (instancetype)init {
    return [self initWithClaims:@[]];
}

// MARK: - NSCopying
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return [self copyWithClaims:self.claims];
}

// MARK: - JWTClaimsSetProtocol
- (NSArray<id<JWTClaimProtocol>> *)claims {
    return self.namesAndClaims.allValues;
}

- (instancetype)copyWithClaims:(NSArray<id<JWTClaimProtocol>> *)claims {
    return [[self.class alloc] initWithClaims:claims];
}

- (id<JWTClaimProtocol>)claimByName:(NSString *)name {
    if (name == nil) {
        return nil;
    }
    return self.namesAndClaims[name];
}

- (void)appendClaim:(id<JWTClaimProtocol>)claim {
    if (claim == nil || claim.name == nil) {
        return;
    }
    
    if (self.namesAndClaims[claim.name]) {
        return;
    }
    
    self.namesAndClaims[claim.name] = claim;
}

- (void)removeClaimByName:(NSString *)name {
    if (name == nil) {
        return;
    }
    [self.namesAndClaims removeObjectForKey:name];
}

- (BOOL)isEmpty {
    return self.namesAndClaims.count == 0;
}
@end

@interface JWTClaimsSetBase (DSL_Support)
- (NSObject *)dslValueForName:(NSString *)name;
- (void)dslSetValue:(NSObject *)value forName:(NSString *)name;
@end

@implementation JWTClaimsSetBase (DSL_Support)
- (NSObject *)dslValueForName:(NSString *)name {
    __auto_type claim = [self.claimsProvider claimByName:name];
    if (claim == nil) {
        return nil;
    }
    return [self claimByName:name].value;
}
- (void)dslSetValue:(NSObject *)value forName:(NSString *)name {
    __auto_type claim = [self.claimsProvider claimByName:name];
    if (claim == nil) {
        return;
    }
    [self removeClaimByName:name];
    [self appendClaim:[claim copyWithValue:value]];
}
@end

@implementation JWTClaimsSetBase (DSL)


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
