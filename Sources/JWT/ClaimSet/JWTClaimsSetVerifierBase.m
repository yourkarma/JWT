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
@property (strong, nonatomic, readwrite) NSMutableDictionary <NSString *, id<JWTClaimVerifierProtocol>> *namesAndVerifiers;
@end

@implementation JWTClaimsSetVerifierBase
+ (NSDictionary *)createNamesAndVerifiers {
    __auto_type issuer = JWTClaimsNames.issuer;
    __auto_type subject = JWTClaimsNames.subject;
    __auto_type audience = JWTClaimsNames.audience;
    __auto_type expirationTime = JWTClaimsNames.expirationTime;
    __auto_type notBefore = JWTClaimsNames.notBefore;
    __auto_type issuedAt = JWTClaimsNames.issuedAt;
    __auto_type jwtId = JWTClaimsNames.jwtID;
    __auto_type type = JWTClaimsNames.type;
    __auto_type scope = JWTClaimsNames.scope;
    return @{
        issuer : JWTClaimVerifierVariations.issuer,
        subject : JWTClaimVerifierVariations.subject,
        audience : JWTClaimVerifierVariations.audienceEqualSingle,
        expirationTime : JWTClaimVerifierVariations.expirationTime,
        notBefore : JWTClaimVerifierVariations.notBefore,
        issuedAt : JWTClaimVerifierVariations.issuedAt,
        jwtId : JWTClaimVerifierVariations.jwtID,
        type : JWTClaimVerifierVariations.type,
        scope : JWTClaimVerifierVariations.scope,
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
