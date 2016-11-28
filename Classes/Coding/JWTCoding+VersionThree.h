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
@class JWTClaimsSet;
@class JWTCodingBuilder;
@class JWTEncodingBuilder;
@class JWTDecodingBuilder;
@class JWTAlgorithmDataHolderChain;
@protocol JWTAlgorithmDataHolderProtocol;

//TODO:
//Add strings for @"payload" @"header"
//Add NS_Options for algorithm options
//Place JWTCodingResultType in separate header.
//Refactor JWTCodingResultType (could be simpler than now)
@class JWTCodingResultType;

@interface JWT (VersionThree)
+ (JWTEncodingBuilder *)encodeWithAlgorithmsAndData:(NSArray *)items;
+ (JWTEncodingBuilder *)encodeWithAlgorithmsAndDataChain:(JWTAlgorithmDataHolderChain *)chain;
+ (JWTDecodingBuilder *)decodeWithAlgorithmsAndData:(NSArray *)items;
+ (JWTDecodingBuilder *)decodeWithAlgorithmsAndDataChain:(JWTAlgorithmDataHolderChain *)chain;
@end

@interface JWTCodingBuilder : NSObject
#pragma mark - Create
// each element should apply to JWTAlgorithmDataHolderProtocol
+ (instancetype)createWithAlgorithmsAndData:(NSArray *)items;
+ (instancetype)createWithAlgorithmsAndDataChain:(JWTAlgorithmDataHolderChain *)chain;

#pragma mark - Internal
@property (nonatomic, readonly) JWTAlgorithmDataHolderChain *internalAlgorithmsAndDataChain;
@property (nonatomic, readonly) NSNumber *internalOptions;

#pragma mark - Fluent
@property (nonatomic, readonly) JWTCodingBuilder *(^constructChain)(JWTAlgorithmDataHolderChain *(^block)());
@property (nonatomic, readonly) JWTCodingBuilder *(^chain)(JWTAlgorithmDataHolderChain *chain);
@property (nonatomic, readonly) JWTCodingBuilder *(^options)(NSNumber *options);
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
+ (instancetype)encodeClaimsSet:(JWTClaimsSet *)claimsSet;

#pragma mark - Internal
@property (nonatomic, readonly) NSDictionary *internalPayload;
@property (nonatomic, readonly) NSDictionary *internalHeaders;
@property (nonatomic, readonly) JWTClaimsSet *internalClaimsSet;

#pragma mark - Fluent
@property (nonatomic, readonly) JWTEncodingBuilder *(^payload)(NSDictionary *payload);
@property (nonatomic, readonly) JWTEncodingBuilder *(^headers)(NSDictionary *headers);
@property (nonatomic, readonly) JWTEncodingBuilder *(^claimsSet)(JWTClaimsSet *claimsSet);

@end

@interface JWTEncodingBuilder (Coding)
@property (nonatomic, readonly) JWTCodingResultType *encode;
@end

@interface JWTDecodingBuilder : JWTCodingBuilder
#pragma mark - Create
+ (instancetype)decodeMessage:(NSString *)message;

#pragma mark - Internal
@property (nonatomic, readonly) NSString *internalMessage;

#pragma mark - Fluent
@property (nonatomic, readonly) JWTDecodingBuilder *(^message)(NSString *message);

@end

@interface JWTDecodingBuilder (Coding)
@property (nonatomic, readonly) JWTCodingResultType *decode;
@end

@interface JWT (VersionThreeExamples)
@end
