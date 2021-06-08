//
//  JWTCodingBuilder+FluentStyle.h
//  JWT
//
//  Created by Dmitry Lobanov on 07/06/2019.
//  Copyright © 2019 JWTIO. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <JWT/JWTCoding+VersionThree.h>
#import <JWT/JWTDeprecations.h>

#if DEPLOYMENT_RUNTIME_SWIFT
#else
NS_ASSUME_NONNULL_BEGIN

// Fluent ( Objective-C exclusive ).
@interface JWTCodingBuilder (FluentStyle)
@property (copy, nonatomic, readonly) JWTCodingBuilder *(^chain)(JWTAlgorithmDataHolderChain *chain) NS_SWIFT_UNAVAILABLE("");
@property (copy, nonatomic, readonly) JWTCodingBuilder *(^constructChain)(JWTAlgorithmDataHolderChain *(^block)(void)) NS_SWIFT_UNAVAILABLE("");
@property (copy, nonatomic, readonly) JWTCodingBuilder *(^modifyChain)(JWTAlgorithmDataHolderChain *(^block)(JWTAlgorithmDataHolderChain * chain)) NS_SWIFT_UNAVAILABLE("");
@property (copy, nonatomic, readonly) JWTCodingBuilder *(^options)(NSNumber *options) NS_SWIFT_UNAVAILABLE("");
@property (copy, nonatomic, readonly) JWTCodingBuilder *(^addHolder)(id<JWTAlgorithmDataHolderProtocol> holder) NS_SWIFT_UNAVAILABLE("");
@property (copy, nonatomic, readonly) JWTCodingBuilder *(^tokenCoder)(id<JWTStringCoderProtocol> tokenCoder) NS_SWIFT_UNAVAILABLE("");
@end

@interface JWTEncodingBuilder (FluentStyle)
@property (copy, nonatomic, readonly) JWTEncodingBuilder *(^payload)(NSDictionary *payload) NS_SWIFT_UNAVAILABLE("");
@property (copy, nonatomic, readonly) JWTEncodingBuilder *(^headers)(NSDictionary *headers) NS_SWIFT_UNAVAILABLE("");
@property (copy, nonatomic, readonly) JWTEncodingBuilder *(^claimsSetCoordinator)(id<JWTClaimsSetCoordinatorProtocol> claimsSetCoordinator) NS_SWIFT_UNAVAILABLE("");
@end

@interface JWTDecodingBuilder (FluentStyle)
@property (copy, nonatomic, readonly) JWTDecodingBuilder *(^message)(NSString *message) NS_SWIFT_UNAVAILABLE("");
@property (copy, nonatomic, readonly) JWTEncodingBuilder *(^claimsSetCoordinator)(id<JWTClaimsSetCoordinatorProtocol> claimsSetCoordinator) NS_SWIFT_UNAVAILABLE("");
@end

NS_ASSUME_NONNULL_END
#endif
