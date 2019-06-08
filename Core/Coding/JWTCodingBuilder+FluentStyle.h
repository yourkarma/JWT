//
//  JWTCodingBuilder+FluentStyle.h
//  JWT
//
//  Created by Dmitry Lobanov on 07/06/2019.
//  Copyright © 2019 JWTIO. All rights reserved.
//

#import "JWTCoding+VersionThree.h"
#import <CoreFoundation/CoreFoundation.h>
#import "JWTDeprecations.h"

NS_ASSUME_NONNULL_BEGIN

// Fluent ( Objective-C exclusive ).
@interface JWTCodingBuilder (FluentStyle)
@property (copy, nonatomic, readonly) JWTCodingBuilder *(^chain)(JWTAlgorithmDataHolderChain *chain) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;
@property (copy, nonatomic, readonly) JWTCodingBuilder *(^constructChain)(JWTAlgorithmDataHolderChain *(^block)(void)) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;
@property (copy, nonatomic, readonly) JWTCodingBuilder *(^modifyChain)(JWTAlgorithmDataHolderChain *(^block)(JWTAlgorithmDataHolderChain * chain)) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;
@property (copy, nonatomic, readonly) JWTCodingBuilder *(^options)(NSNumber *options) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;
@property (copy, nonatomic, readonly) JWTCodingBuilder *(^addHolder)(id<JWTAlgorithmDataHolderProtocol> holder) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;
@end

@interface JWTEncodingBuilder (FluentStyle)
@property (copy, nonatomic, readonly) JWTEncodingBuilder *(^payload)(NSDictionary *payload) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;
@property (copy, nonatomic, readonly) JWTEncodingBuilder *(^headers)(NSDictionary *headers) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;
@property (copy, nonatomic, readonly) JWTEncodingBuilder *(^claimsSet)(JWTClaimsSet *claimsSet) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;
@end

@interface JWTDecodingBuilder (FluentStyle)
@property (copy, nonatomic, readonly) JWTDecodingBuilder *(^message)(NSString *message) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;
@property (copy, nonatomic, readonly) JWTDecodingBuilder *(^claimsSet)(JWTClaimsSet *claimsSet) JWT_FLUENT_STYLE_FOR_SWIFT_UNAVAILABLE;
@end
NS_ASSUME_NONNULL_END
