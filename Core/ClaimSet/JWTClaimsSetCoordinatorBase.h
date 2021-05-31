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
@property (copy, nonatomic, readwrite) id <JWTClaimsSetStorageProtocol> claimsSetStorage;
@property (strong, nonatomic, readwrite) id <JWTClaimsSetSerializerProtocol> claimsSetSerializer;
@property (strong, nonatomic, readwrite) id <JWTClaimsSetVerifierProtocol> claimsSetVerifier;
@property (copy, nonatomic, readonly) id <JWTClaimsSetCoordinatorProtocol> (^configureClaimsSet)(JWTClaimsSetBase *(^)(JWTClaimsSetBase *claimsSetDSL));
- (instancetype)configureClaimsSet:(JWTClaimsSetBase *(^)(JWTClaimsSetBase *claimsSetDSL))claimsSet;
@end

NS_ASSUME_NONNULL_END
