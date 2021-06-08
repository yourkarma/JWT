//
//  JWTClaimsSetVerifierBase.h
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JWT/JWTClaimsSetsProtocols.h>
#import <JWT/JWTClaimVerifierBase.h>
NS_ASSUME_NONNULL_BEGIN

@interface JWTClaimsSetVerifierBase : NSObject <JWTClaimsSetVerifierProtocol>
@property (strong, nonatomic, readwrite) id <JWTClaimsProviderProtocol> claimsProvider;
@property (nonatomic, readwrite) id <JWTClaimsSetSerializerProtocol> serializer;
@end

NS_ASSUME_NONNULL_END
