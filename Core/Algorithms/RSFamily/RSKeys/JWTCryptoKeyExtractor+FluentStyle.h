//
//  JWTCryptoKeyExtractor+FluentStyle.h
//  JWT
//
//  Created by Dmitry Lobanov on 07/06/2019.
//  Copyright © 2019 JWTIO. All rights reserved.
//

#import "JWTCryptoKeyExtractor.h"

NS_ASSUME_NONNULL_BEGIN

// Fluent ( Objective-C exclusive ).
#if !DEPLOYMENT_RUNTIME_SWIFT
@interface JWTCryptoKeyExtractor (FluentStyle)
@property (copy, nonatomic, readonly) JWTCryptoKeyExtractor * (^keyBuilder)(JWTCryptoKeyBuilder *keyBuilder);
@end
#endif

NS_ASSUME_NONNULL_END
