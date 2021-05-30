//
//  JWTClaimsSetVerifierBase.m
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import "JWTClaimsSetVerifierBase.h"
#import "JWTClaimVariations.h"
#import "JWTClaimVerifierVariations.h"

@interface JWTClaimsSetVerifierBase ()
@property (copy, nonatomic, readwrite) NSMutableDictionary <NSString *, id<JWTClaimVerifierProtocol>> *namesAndVerifiers;
@end

@implementation JWTClaimsSetVerifierBase
+ (NSDictionary *)createNamesAndVerifiers {
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
        issuer.name : JWTClaimVerifierVariations.issuer,
        subject.name : JWTClaimVerifierVariations.subject,
        audience.name : JWTClaimVerifierVariations.audienceEqualSingle,
        expirationTime.name : JWTClaimVerifierVariations.expirationTime,
        notBefore.name : JWTClaimVerifierVariations.notBefore,
        issuedAt.name : JWTClaimVerifierVariations.issuedAt,
        jwtId.name : JWTClaimVerifierVariations.jwtID,
        type.name : JWTClaimVerifierVariations.type,
        scope.name : JWTClaimVerifierVariations.scope,
    };
}
- (instancetype)init {
    if (self = [super init]) {
        self.namesAndVerifiers = [NSMutableDictionary dictionaryWithDictionary:self.class.createNamesAndVerifiers];
    }
    return self;
}

- (BOOL)verifyClaim:(id<JWTClaimProtocol>)claim withValue:(NSObject *)value withTrustedValue:(NSObject *)trustedValue {
    __auto_type verifier = self.namesAndVerifiers[claim.name] ?: [JWTClaimVerifierBase new];
    return [verifier verifyValue:value withTrustedValue:trustedValue];
}

// MARK: - JWTClaimsSetVerifierProtocol
- (void)registerVerifier:(id<JWTClaimVerifierProtocol>)verifier forClaimName:(NSString *)name {
    if (name != nil) {
        self.namesAndVerifiers[name] = verifier;
    }
}

- (void)unregisterVerifierForClaimName:(NSString *)name {
    if (name != nil) {
        [self.namesAndVerifiers removeObjectForKey:name];
    }
}

- (BOOL)verifyClaimsSet:(id<JWTClaimsSetProtocol>)theClaimsSet withTrustedClaimsSet:(id<JWTClaimsSetProtocol>)trustedClaimsSet {
    __auto_type untrustedDictionary = [self.serializer dictionaryFromClaimsSet:theClaimsSet];
    
    __auto_type trustedDictionary = [self.serializer dictionaryFromClaimsSet:trustedClaimsSet];
    
    if (trustedDictionary == nil) {
        return YES;
    }
    
    if (untrustedDictionary == nil) {
        return NO;
    }
        
    for (NSString *key in self.claimsProvider.availableClaimsNames) {
        __auto_type claim = [self.claimsProvider claimByName:key];
        if (claim == nil) {
            return NO;
        }
        __auto_type trustedValue = (NSObject *)trustedDictionary[key];
        __auto_type untrustedValue = (NSObject *)untrustedDictionary[key];
        
        if (!trustedValue) {
            continue;
        }
        
        __auto_type claimVerified = [self verifyClaim:claim withValue:untrustedValue withTrustedValue:trustedValue];
        if (!claimVerified) {
            return NO;
        }
    }
    
    return YES;
}

@end
