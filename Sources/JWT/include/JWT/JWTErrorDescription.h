//
//  JWTErrorDescription.h
//  JWT
//
//  Created by Lobanov Dmitry on 27.11.16.
//  Copyright © 2016 JWTIO. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *JWTErrorDomain;

typedef NS_ENUM(NSInteger, JWTError) {
    JWTUnexpectedError = -99,
    JWTInvalidFormatError,
    JWTUnsupportedAlgorithmError,
    JWTAlgorithmNameMismatchError,
    JWTInvalidSignatureError,
    JWTNoPayloadError,
    JWTNoHeaderError,
    JWTEncodingHeaderError,
    JWTEncodingPayloadError,
    JWTEncodingSigningError,
    JWTClaimsSetVerificationFailed,
    JWTInvalidSegmentSerializationError,
    JWTUnspecifiedAlgorithmError,
    JWTBlacklistedAlgorithmError,
    JWTDecodingHeaderError,
    JWTDecodingPayloadError,
    JWTDecodingHoldersChainEmptyError,
    JWTHolderSecretDataNotSetError
};

@interface JWTErrorDescription : NSObject
+ (NSError *)errorWithCode:(JWTError)code;
@end
