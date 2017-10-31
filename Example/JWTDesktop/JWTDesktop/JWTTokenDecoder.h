//
//  JWTTokenDecoder.h
//  JWTDesktop
//
//  Created by Lobanov Dmitry on 30.10.2017.
//  Copyright © 2017 JWT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JWT/JWT.h>

@protocol JWTTokenDecoderNecessaryDataObject__Protocol <NSObject>
@property (copy, nonatomic, readonly) NSString *chosenAlgorithmName;
@property (copy, nonatomic, readonly) NSString *chosenSecret;
@property (copy, nonatomic, readonly) NSData *chosenSecretData;
@property (assign, nonatomic, readonly) BOOL isBase64EncodedSecret;
@end

@interface JWTTokenDecoder : NSObject
@property (strong, nonatomic, readonly) JWTBuilder *builder;
@property (strong, nonatomic, readonly) JWTCodingResultType *resultType;

- (NSDictionary *)decodeToken:(NSString *)token skipSignatureVerification:(BOOL)skipVerification error:(NSError *__autoreleasing*)error necessaryDataObject:(id<JWTTokenDecoderNecessaryDataObject__Protocol>)object;
@end
