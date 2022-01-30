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
#import "JWTClaimsSetDSLBase.h"

@interface JWTClaimsSetCoordinatorBase ()
@property (copy, nonatomic, readwrite) id <JWTClaimsSetCoordinatorProtocol> (^configureClaimsSet)(JWTClaimsSetDSLBase *(^)(JWTClaimsSetDSLBase *claimsSetDSL));
@end

@implementation JWTClaimsSetCoordinatorBase
- (void)sanitize {
    self.claimsSetSerializer.claimsProvider = self.claimsProvider;
    self.claimsSetSerializer.claimsSetStorage = self.claimsSetStorage;
    self.claimsSetVerifier.claimsProvider = self.claimsProvider;
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

- (void)setClaimsSetStorage:(id<JWTClaimsSetProtocol>)claimsSetStorage {
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

- (JWTClaimsSetDSLBase *)dslDesrciption {
    return [[JWTClaimsSetDSLBase alloc] initWithClaimsProvider:self.claimsProvider claimsSetStorage:self.claimsSetStorage];
}

- (instancetype)configureClaimsSet:(JWTClaimsSetDSLBase *(^)(JWTClaimsSetDSLBase *claimsSetDSL))claimsSet {
    if (claimsSet) {
        __auto_type dsl = self.dslDesrciption;
        __auto_type value = claimsSet(dsl);
        self.claimsSetStorage = value.claimsSetStorage ?: [JWTClaimsSetBase new];
    }
    return self;
}

- (void)registerClaim:(id<JWTClaimProtocol>)claim serializer:(id<JWTClaimSerializerProtocol>)serializer verifier:(id<JWTClaimVerifierProtocol>)verifier forClaimName:(NSString *)name {
    [self.claimsProvider registerClaim:claim forClaimName:name];
    [self.claimsSetSerializer registerSerializer:serializer forClaimName:name];
    [self.claimsSetVerifier registerVerifier:verifier forClaimName:name];

}
- (void)unregisterClaimWithSerializerAndVerifierForClaimName:(NSString *)name {
    [self.claimsProvider unregisterClaimForClaimName:name];
    [self.claimsSetSerializer unregisterSerializerForClaimName:name];
    [self.claimsSetVerifier unregisterVerifierForClaimName:name];
}

// MARK: - Fluent
- (void)setupFluent {
    __weak typeof(self) weakSelf = self;
    self.configureClaimsSet = ^(JWTClaimsSetDSLBase *(^block)(JWTClaimsSetDSLBase *claimsSetDSL)) {
        return [weakSelf configureClaimsSet:block];
    };
}
@end
