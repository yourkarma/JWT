//
//  JWTClaimsSetsProtocols.h
//  JWT
//
//  Created by Dmitry Lobanov on 09.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JWTClaimsSetDSLBase;

NS_ASSUME_NONNULL_BEGIN

@protocol JWTClaimProtocol <NSCopying>
@property (copy, nonatomic, readonly, class) NSString *name;
@property (copy, nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSObject *value;
- (instancetype)copyWithValue:(NSObject *)value;
@end

@protocol JWTClaimVerifierProtocol
- (BOOL)verifyValue:(NSObject *)value withTrustedValue:(NSObject *)trustedValue;
@end

@protocol JWTClaimSerializerProtocol
- (NSObject *)serializedClaimValue:(id<JWTClaimProtocol>)claim;
- (NSObject *)deserializedClaimValue:(NSObject *)value forName:(NSString *)name;
@end

@protocol JWTClaimsSetProtocol <NSCopying>
@property (copy, nonatomic, readonly) NSArray <id<JWTClaimProtocol>>* claims;
- (instancetype)copyWithClaims:(NSArray <id<JWTClaimProtocol>>*)claims;
- (id<JWTClaimProtocol>)claimByName:(NSString *)name;
- (void)appendClaim:(id<JWTClaimProtocol>)claim;
- (void)removeClaimByName:(NSString *)name;
@property (assign, nonatomic, readonly) BOOL isEmpty;
@end

@protocol JWTClaimsProviderProtocol
@property (copy, nonatomic, readonly) NSArray <NSString *> *availableClaimsNames;
- (id<JWTClaimProtocol>)claimByName:(NSString *)name;
- (void)registerClaim:(id<JWTClaimProtocol>)claim forClaimName:(NSString *)name;
- (void)unregisterClaimForClaimName:(NSString *)name;
@end

@protocol JWTClaimsSetSerializerProtocol
@property (strong, nonatomic, readwrite) id <JWTClaimsProviderProtocol> claimsProvider;
@property (copy, nonatomic, readwrite) id <JWTClaimsSetProtocol> claimsSetStorage;
- (void)registerSerializer:(id<JWTClaimSerializerProtocol>)serializer forClaimName:(NSString *)name;
- (void)unregisterSerializerForClaimName:(NSString *)name;
- (NSDictionary *)dictionaryFromClaimsSet:(id<JWTClaimsSetProtocol>)claimsSet;
- (id<JWTClaimsSetProtocol>)claimsSetFromDictionary:(NSDictionary *)dictionary;
@end

@protocol JWTClaimsSetVerifierProtocol
@property (strong, nonatomic, readwrite) id <JWTClaimsProviderProtocol> claimsProvider;
- (void)registerVerifier:(id<JWTClaimVerifierProtocol>)verifier forClaimName:(NSString *)name;
- (void)unregisterVerifierForClaimName:(NSString *)name;
- (BOOL)verifyClaimsSet:(id<JWTClaimsSetProtocol>)theClaimsSet withTrustedClaimsSet:(id<JWTClaimsSetProtocol>)trustedClaimsSet;
@end

@protocol JWTClaimsSetCoordinatorProtocol
@property (strong, nonatomic, readwrite) id <JWTClaimsProviderProtocol> claimsProvider;
@property (copy, nonatomic, readwrite) id <JWTClaimsSetProtocol> claimsSetStorage;
@property (strong, nonatomic, readwrite) id <JWTClaimsSetSerializerProtocol> claimsSetSerializer;
@property (strong, nonatomic, readwrite) id <JWTClaimsSetVerifierProtocol> claimsSetVerifier;

@property (strong, nonatomic, readonly) JWTClaimsSetDSLBase *dslDesrciption;

- (instancetype)configureClaimsSet:(JWTClaimsSetDSLBase *(^)(JWTClaimsSetDSLBase *claimsSetDSL))claimsSet;

#if DEPLOYMENT_RUNTIME_SWIFT
#else
@property (copy, nonatomic, readonly) id <JWTClaimsSetCoordinatorProtocol> (^configureClaimsSet)(JWTClaimsSetDSLBase *(^)(JWTClaimsSetDSLBase *claimsSetDSL)) NS_SWIFT_UNAVAILABLE("");
#endif

- (void)registerClaim:(id<JWTClaimProtocol>)claim serializer:(id<JWTClaimSerializerProtocol>)serializer verifier:(id<JWTClaimVerifierProtocol>)verifier forClaimName:(NSString *)name;
- (void)unregisterClaimWithSerializerAndVerifierForClaimName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
