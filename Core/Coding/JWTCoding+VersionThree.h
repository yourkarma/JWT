//
//  JWTCoding+VersionThree.h
//  JWT
//
//  Created by Lobanov Dmitry on 27.11.16.
//  Copyright © 2016 JWTIO. All rights reserved.
//

#import <JWT/JWTCoding.h>

// encode and decode options
@protocol JWTAlgorithm;
@class JWTCodingBuilder;
@class JWTEncodingBuilder;
@class JWTDecodingBuilder;
@class JWTAlgorithmDataHolderChain;
@protocol JWTAlgorithmDataHolderProtocol;
@class JWTCodingResultType;
@protocol JWTClaimsSetCoordinatorProtocol;
@protocol JWTStringCoderProtocol;

@interface JWT (VersionThree)
+ (JWTEncodingBuilder *)encodeWithHolders:(NSArray *)holders;
+ (JWTEncodingBuilder *)encodeWithChain:(JWTAlgorithmDataHolderChain *)chain;
+ (JWTDecodingBuilder *)decodeWithHolders:(NSArray *)holders;
+ (JWTDecodingBuilder *)decodeWithChain:(JWTAlgorithmDataHolderChain *)chain;
@end

@interface JWTCodingBuilder : NSObject
#pragma mark - Create
// each element should conform to JWTAlgorithmDataHolderProtocol
+ (instancetype)createWithHolders:(NSArray *)holders;
+ (instancetype)createWithChain:(JWTAlgorithmDataHolderChain *)chain;
+ (instancetype)createWithEmptyChain;

#pragma mark - Internal
@property (nonatomic, readonly) JWTAlgorithmDataHolderChain *internalChain;
@property (copy, nonatomic, readonly) NSNumber *internalOptions;
@property (strong, nonatomic, readonly) id <JWTStringCoderProtocol> internalTokenCoder;
@end

@interface JWTCodingBuilder (Sugar)
- (instancetype)and;
- (instancetype)with;
@end

@interface JWTCodingBuilder (Coding)
@property (nonatomic, readonly) JWTCodingResultType *result;
@end

@interface JWTEncodingBuilder : JWTCodingBuilder
#pragma mark - Create
+ (instancetype)encodePayload:(NSDictionary *)payload;
+ (instancetype)encodeClaimsSetWithCoordinator:(id<JWTClaimsSetCoordinatorProtocol>)coordinator;

#pragma mark - Internal
@property (copy, nonatomic, readonly) NSDictionary *internalPayload;
@property (copy, nonatomic, readonly) NSDictionary *internalHeaders;
@property (nonatomic, readonly) id<JWTClaimsSetCoordinatorProtocol> internalClaimsSetCoordinator;
@end

@interface JWTEncodingBuilder (Coding)
@property (nonatomic, readonly) JWTCodingResultType *encode;
@end

@interface JWTDecodingBuilder : JWTCodingBuilder
#pragma mark - Create
+ (instancetype)decodeMessage:(NSString *)message;

#pragma mark - Internal
@property (copy, nonatomic, readonly) NSString *internalMessage;
@property (nonatomic, readonly) id<JWTClaimsSetCoordinatorProtocol> internalClaimsSetCoordinator;
@end

@interface JWTDecodingBuilder (Coding)
@property (nonatomic, readonly) JWTCodingResultType *decode;
@end

#pragma mark - Setters
@interface JWTCodingBuilder (Setters)
- (instancetype)chain:(JWTAlgorithmDataHolderChain *)chain;
- (instancetype)options:(NSNumber *)options;
- (instancetype)addHolder:(id<JWTAlgorithmDataHolderProtocol>)holder;
- (instancetype)tokenCoder:(id<JWTStringCoderProtocol>)tokenCoder;
@end

@interface JWTEncodingBuilder (Setters)
- (instancetype)payload:(NSDictionary *)payload;
- (instancetype)headers:(NSDictionary *)headers;
- (instancetype)claimsSetCoordinator:(id<JWTClaimsSetCoordinatorProtocol>)claimsSetCoordinator;
@end

@interface JWTDecodingBuilder (Setters)
- (instancetype)message:(NSString *)message;
- (instancetype)claimsSetCoordinator:(id<JWTClaimsSetCoordinatorProtocol>)claimsSetCoordinator;
@end
