//
//  JWTClaimsSetBase.m
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import "JWTClaimsSetBase.h"

@interface JWTClaimsSetBase ()
@property (copy, nonatomic, readwrite) NSArray <id<JWTClaimProtocol>>* claims;
@end

@implementation JWTClaimsSetBase
@synthesize claims = _claims;
- (instancetype)initWithClaims:(nonnull NSArray<id<JWTClaimProtocol>> *)claims {
    if (self = [super init]) {
        self.claims = claims;
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
- (instancetype)copyWithClaims:(NSArray<id<JWTClaimProtocol>> *)claims {
    return [[self.class alloc] initWithClaims:claims];
}

- (void)appendClaim:(id<JWTClaimProtocol>)claim {
    if (claim == nil) {
        return;
    }
    __auto_type value = (NSMutableArray *)[self.claims mutableCopy];
    [value addObject:claim];
    self.claims = [value copy];
}

- (void)removeClaimByName:(NSString *)name {
    if (name == nil) {
        return;
    }
    
    NSInteger index = [self.claims indexOfObjectPassingTest:^BOOL(id<JWTClaimProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj.name isEqualToString:name];
    }];
    
    if (index != NSNotFound) {
        __auto_type value = (NSMutableArray *)[self.claims mutableCopy];
        [value removeObjectAtIndex:index];
        self.claims = [value copy];
    }
}
@end
