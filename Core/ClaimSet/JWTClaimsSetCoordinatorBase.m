//
//  JWTClaimsSetCoordinatorBase.m
//  JWT
//
//  Created by Dmitry Lobanov on 31.05.2021.
//  Copyright © 2021 JWTIO. All rights reserved.
//

#import "JWTClaimsSetCoordinatorBase.h"
#import "JWTClaimsProviderBase.h"
#import "JWTClaimsSetBase.h"
#import "JWTClaimsSetSerializerBase.h"
#import "JWTClaimsSetVerifierBase.h"

@interface JWTClaimsSetCoordinatorBase ()
@property (copy, nonatomic, readwrite) id <JWTClaimsSetCoordinatorProtocol> (^configureClaimsSet)(JWTClaimsSetBase *(^)(JWTClaimsSetBase *claimsSetDSL));
@end

@implementation JWTClaimsSetCoordinatorBase
- (void)sanitize {
    self.claimsSetSerializer.claimsProvider = self.claimsProvider;
    self.claimsSetSerializer.claimsSetStorage = self.claimsSetStorage;
    self.claimsSetVerifier.claimsProvider = self.claimsProvider;
    ((JWTClaimsSetBase *)self.claimsSetStorage).claimsProvider = self.claimsProvider;
}
- (instancetype)init {
    if (self = [super init]) {
        self.claimsProvider = [JWTClaimsProviderBase new];
        self.claimsSetStorage = [JWTClaimsSetBase new];
        self.claimsSetSerializer = [JWTClaimsSetSerializerBase new];
        self.claimsSetVerifier = [JWTClaimsSetVerifierBase new];
        
        [self setupFluent];
        [self sanitize];
    }
    return self;
}

// MARK: - JWTClaimsSetCoordinatorProtocol
- (void)setClaimsProvider:(id<JWTClaimsProviderProtocol>)claimsProvider {
    _claimsProvider = claimsProvider;
    [self sanitize];
}

- (void)setClaimsSetStorage:(id<JWTClaimsSetStorageProtocol>)claimsSetStorage {
    _claimsSetStorage = claimsSetStorage;
    [self sanitize];
}

- (void)setClaimsSetSerializer:(id<JWTClaimsSetSerializerProtocol>)claimsSetSerializer {
    _claimsSetSerializer = claimsSetSerializer;
    [self sanitize];
}

- (void)setClaimsSetVerifier:(id<JWTClaimsSetVerifierProtocol>)claimsSetVerifier {
    _claimsSetVerifier = claimsSetVerifier;
    [self sanitize];
}

- (instancetype)configureClaimsSet:(JWTClaimsSetBase *(^)(JWTClaimsSetBase *claimsSetDSL))claimsSet {
    if (claimsSet) {
        __auto_type value = claimsSet((JWTClaimsSetBase *)self.claimsSetStorage);
        self.claimsSetStorage = value ?: [JWTClaimsSetBase new];
    }
    return self;
}

// MARK: - Fluent
- (void)setupFluent {
    __weak typeof(self) weakSelf = self;
    self.configureClaimsSet = ^(JWTClaimsSetBase *(^block)(JWTClaimsSetBase *claimsSetDSL)) {
        return [weakSelf configureClaimsSet:block];
    };
}
@end
