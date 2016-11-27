//
//  JWTCoding+VersionThree.h
//  JWT
//
//  Created by Lobanov Dmitry on 27.11.16.
//  Copyright © 2016 JWTIO. All rights reserved.
//

#import <JWT/JWTCoding.h>

// encode and decode options

@class JWTCodingBuilder;
@class JWTEncodingBuilder;
@class JWTDecodingBuilder;
@interface JWT (VersionThree)
+ (JWTEncodingBuilder *)encodePayload:(NSDictionary *)payload;
+ (JWTEncodingBuilder *)encodeClaimsSet:(JWTClaimsSet *)claimsSet;
+ (JWTDecodingBuilder *)decodeMessage:(NSString *)message;
@end

@interface JWTCodingBuilder : NSObject
@property (nonatomic, readonly) id jwtAlgorithmsAndDataChain;
@end

@interface JWTEncodingBuilder : JWTCodingBuilder
@property (nonatomic, readonly) id jwtPayload;
@property (nonatomic, readonly) id jwtHeaders;
@property (nonatomic, readonly) id jwtClaimsSet;
@property (nonatomic, readonly) id encode;
@end

@interface JWTDecodingBuilder : JWTCodingBuilder
@property (nonatomic, readonly) id jwtMessage;
@property (nonatomic, readonly) id decode;
@end
