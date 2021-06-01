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
