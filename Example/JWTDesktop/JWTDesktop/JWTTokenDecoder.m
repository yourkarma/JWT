//
//  JWTTokenDecoder.m
//  JWTDesktop
//
//  Created by Lobanov Dmitry on 30.10.2017.
//  Copyright © 2017 JWT. All rights reserved.
//

#import "JWTTokenDecoder.h"
@interface JWTTokenDecoder ()
@property (strong, nonatomic, readwrite) JWTBuilder *builder;
@property (strong, nonatomic, readwrite) JWTCodingResultType *resultType;
@property (strong, nonatomic, readonly) JWTTokenDecoder *theDecoder;
@end

@interface JWTTokenDecoder (Subclass)
- (JWTCodingResultType *)_decodeToken:(NSString *)token skipSignatureVerification:(BOOL)skipVerification error:(NSError *__autoreleasing *)error necessaryDataObject:(id<JWTTokenDecoderNecessaryDataObject__Protocol>)object;
@end

@implementation JWTTokenDecoder (Subclass)
- (JWTCodingResultType *)_decodeToken:(NSString *)token skipSignatureVerification:(BOOL)skipVerification error:(NSError *__autoreleasing *)error necessaryDataObject:(id<JWTTokenDecoderNecessaryDataObject__Protocol>)object {
    return nil;
}
@end

@interface JWTTokenDecoder__V2: JWTTokenDecoder @end
@implementation JWTTokenDecoder__V2
- (JWTCodingResultType *)_decodeToken:(NSString *)token skipSignatureVerification:(BOOL)skipVerification error:(NSError *__autoreleasing *)error necessaryDataObject:(id<JWTTokenDecoderNecessaryDataObject__Protocol>)object {
    NSLog(@"JWT ENCODED TOKEN: %@", token);
    NSString *algorithmName = [object chosenAlgorithmName];
    NSLog(@"JWT Algorithm NAME: %@", algorithmName);
    
    JWTBuilder *builder = [JWTBuilder decodeMessage:token].algorithmName(algorithmName).options(@(skipVerification));
    
    NSData *secretData = [object chosenSecretData];
    NSString *secret = [object chosenSecret];
    BOOL isBase64EncodedSecret = [object isBase64EncodedSecret];
    
    if (![algorithmName isEqualToString:JWTAlgorithmNameNone]) {
        if (isBase64EncodedSecret && secretData) {
            builder.secretData(secretData);
        }
        else {
            builder.secret(secret);
        }
    }
    
    NSDictionary *decoded = builder.decode;
    NSLog(@"JWT ERROR: %@", builder.jwtError);
    NSLog(@"JWT DICTIONARY: %@", decoded);
    self.builder = builder;
    NSError *theError = builder.jwtError;
    JWTCodingResultType *resultType = theError ? [[JWTCodingResultType alloc] initWithErrorResult:[[JWTCodingResultTypeError alloc] initWithError:theError]] : nil;
    return resultType;
}
@end

@interface JWTTokenDecoder__V3: JWTTokenDecoder @end
@implementation JWTTokenDecoder__V3
- (JWTCodingResultType *)_decodeToken:(NSString *)token skipSignatureVerification:(BOOL)skipVerification error:(NSError *__autoreleasing *)error necessaryDataObject:(id<JWTTokenDecoderNecessaryDataObject__Protocol>)object {
    NSLog(@"JWT ENCODED TOKEN: %@", token);
    NSString *algorithmName = [object chosenAlgorithmName];
    NSLog(@"JWT Algorithm NAME: %@", algorithmName);
    NSData *secretData = [object chosenSecretData];
    NSString *secret = [object chosenSecret];
    BOOL isBase64EncodedSecret = [object isBase64EncodedSecret];
    
    NSError *theError = nil;
    id<JWTAlgorithm> algorithm = [JWTAlgorithmFactory algorithmByName:algorithmName];
    if (!algorithm) {
        return nil;
    }
    id<JWTAlgorithmDataHolderProtocol> holder = nil;
    if ([algorithm isKindOfClass:[JWTAlgorithmRSBase class]]) {
        NSError *keyError = nil;
        id<JWTCryptoKeyProtocol>key = [[JWTCryptoKeyPublic alloc] initWithPemEncoded:secret parameters:nil error:&keyError];
        theError = keyError;
        if (!theError) {
            holder = [JWTAlgorithmRSFamilyDataHolder new].verifyKey(key).algorithmName(algorithmName).secretData([NSData new]);
        }
    }
    else if ([algorithm isKindOfClass:[JWTAlgorithmHSBase class]]){
        JWTAlgorithmHSFamilyDataHolder *aHolder = [JWTAlgorithmHSFamilyDataHolder new];
        if (isBase64EncodedSecret && secretData) {
            aHolder.secretData(secretData);
        }
        else {
            aHolder.secret(secret);
        }
        holder = aHolder.algorithmName(algorithmName);
    }
    else if ([algorithm isKindOfClass:[JWTAlgorithmNone class]]) {
        holder = [JWTAlgorithmNoneDataHolder new];
    }
    
    if (theError) {
        NSLog(@"JWT internalError: %@", theError);
        if (error) {
            *error = theError;
        }
        return nil;
    }
    
    JWTCodingBuilder *builder = [JWTDecodingBuilder decodeMessage:token].addHolder(holder).options(@(skipVerification));
    JWTCodingResultType *result = builder.result;
    // TODO: Fix
    // signature is not verified well even for JWT.IO example.
    // it happens in case of base64 data corruption. (url encoded vs not url uncoded)
    NSLog(@"JWT ERROR: %@ -> %@", result.errorResult, result.errorResult.error);
    NSLog(@"JWT RESULT: %@ -> %@", result.successResult, result.successResult.headerAndPayloadDictionary);
    return result;
}
@end

@implementation JWTTokenDecoder
- (JWTTokenDecoder *)theDecoder {
    return [JWTTokenDecoder__V3 new];
}
- (NSDictionary *)decodeToken:(NSString *)token skipSignatureVerification:(BOOL)skipVerification error:(NSError *__autoreleasing *)error necessaryDataObject:(id<JWTTokenDecoderNecessaryDataObject__Protocol>)object {
    if (!object) {
        return nil;
    }
    // cheating!
    self.resultType = [self.theDecoder _decodeToken:token skipSignatureVerification:skipVerification error:error necessaryDataObject:object];
    return self.resultType.successResult.headerAndPayloadDictionary;
}
@end
