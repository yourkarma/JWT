//
//  JWTCryptoKey.h
//  JWT
//
//  Created by Lobanov Dmitry on 04.02.17.
//  Copyright © 2017 JWTIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@protocol JWTCryptoKeyProtocol <NSObject>
@property (copy, nonatomic, readonly) NSString *tag;
@property (assign, nonatomic, readonly) SecKeyRef key;
@end

@interface JWTCryptoKeyBuilder : NSObject
@property (assign, nonatomic, readonly) BOOL public;
@property (assign, nonatomic, readonly) NSString *type;
- (instancetype)forPublic;
- (instancetype)forPrivate;
- (instancetype)forRSA;
- (instancetype)forEC;
@end

@interface JWTCryptoKey : NSObject<JWTCryptoKeyProtocol>
- (instancetype)initWithData:(NSData *)data; //NS_DESIGNATED_INITIALIZER
- (instancetype)initWithBase64String:(NSString *)base64String;
- (instancetype)initWithPemEncoded:(NSString *)encoded;
- (instancetype)initWithPemAtURL:(NSURL *)url;
@end

@interface JWTCryptoKeyPublic : JWTCryptoKey
- (instancetype)initWithCertificateData:(NSData *)certificateData; //NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCertificateBase64String:(NSString *)certificateString;
@end

@interface JWTCryptoKeyPrivate : JWTCryptoKey
- (instancetype)initWithP12Data:(NSData *)p12Data withPassphrase:(NSString *)passphrase; //NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithP12AtURL:(NSURL *)url withPassphrase:(NSString *)passphrase;
@end
