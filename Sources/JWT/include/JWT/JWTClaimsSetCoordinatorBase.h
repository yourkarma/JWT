//
//  JWTClaimsSetCoordinatorBase.h
//  JWT
//
//  Created by Dmitry Lobanov on 31.05.2021.
//  Copyright © 2021 JWTIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JWT/JWTClaimsSetsProtocols.h>

NS_ASSUME_NONNULL_BEGIN

@interface JWTClaimsSetCoordinatorBase : NSObject <JWTClaimsSetCoordinatorProtocol>
@property (strong, nonatomic, readwrite) id <JWTClaimsProviderProtocol> claimsProvider;
@property (copy, nonatomic, readwrite) id <JWTClaimsSetProtocol> claimsSetStorage;
@property (strong, nonatomic, readwrite) id <JWTClaimsSetSerializerProtocol> claimsSetSerializer;
@property (strong, nonatomic, readwrite) id <JWTClaimsSetVerifierProtocol> claimsSetVerifier;
- (instancetype)configureClaimsSet:(JWTClaimsSetDSLBase *(^)(JWTClaimsSetDSLBase *claimsSetDSL))claimsSet;
#if DEPLOYMENT_RUNTIME_SWIFT
#else
@property (copy, nonatomic, readonly) id <JWTClaimsSetCoordinatorProtocol> (^configureClaimsSet)(JWTClaimsSetDSLBase *(^)(JWTClaimsSetDSLBase *claimsSetDSL)) NS_SWIFT_UNAVAILABLE("");
#endif
@end

NS_ASSUME_NONNULL_END
