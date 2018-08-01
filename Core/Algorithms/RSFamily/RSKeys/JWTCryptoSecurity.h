//
//  JWTCryptoSecurity.h
//  JWT
//
//  Created by Lobanov Dmitry on 04.02.17.
//  Copyright © 2017 JWTIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
// Thanks for https://github.com/TakeScoop/SwiftyRSA!
@interface JWTCryptoSecurity : NSObject
+ (NSString *)keyTypeRSA;
+ (NSString *)keyTypeEC;
+ (SecKeyRef)addKeyWithData:(NSData *)data asPublic:(BOOL)public tag:(NSString *)tag type:(NSString *)type error:(NSError *__autoreleasing*)error;
+ (SecKeyRef)addKeyWithData:(NSData *)data asPublic:(BOOL)public tag:(NSString *)tag error:(NSError *__autoreleasing*)error;
+ (SecKeyRef)keyByTag:(NSString *)tag error:(NSError *__autoreleasing*)error;
+ (void)removeKeyByTag:(NSString *)tag error:(NSError *__autoreleasing*)error;
@end

@interface JWTCryptoSecurity (Certificates)
+ (OSStatus)extractIdentityAndTrustFromPKCS12:(CFDataRef)inPKCS12Data password:(CFStringRef)password identity:(SecIdentityRef *)outIdentity trust:(SecTrustRef *)outTrust __deprecated;
+ (OSStatus)extractIdentityAndTrustFromPKCS12:(CFDataRef)inPKCS12Data password:(CFStringRef)password identity:(SecIdentityRef *)outIdentity trust:(SecTrustRef *)outTrust error:(CFErrorRef *)error;
+ (SecKeyRef)publicKeyFromCertificate:(NSData *)certificateData;
@end

//API_DEPRECATED("Use methods from JWTCryptoSecurity+Extraction.h", macos(10.4, 10.8), ios(2.0, 3.0), watchos(2.0, 3.0), tvos(9.0, 10.0))
__deprecated
@interface JWTCryptoSecurity (Pem)
+ (NSString *)certificateFromPemFileContent:(NSString *)content __deprecated;
+ (NSString *)keyFromPemFileContent:(NSString *)content __deprecated;
+ (NSArray *)itemsFromPemFileContent:(NSString *)content byRegex:(NSRegularExpression *)expression __deprecated;
+ (NSString *)certificateFromPemFileWithName:(NSString *)name __deprecated;
+ (NSString *)keyFromPemFileWithName:(NSString *)name __deprecated;
+ (NSArray *)itemsFromPemFileWithName:(NSString *)name byRegex:(NSRegularExpression *)expression __deprecated;
+ (NSString *)stringByRemovingPemHeadersFromString:(NSString *)string __deprecated;
@end

@interface JWTCryptoSecurity (PublicKey)
+ (NSData *)dataByRemovingPublicKeyHeader:(NSData *)data error:(NSError *__autoreleasing*)error;
+ (NSData *)dataByExtractingKeyFromANS1:(NSData *)data error:(NSError *__autoreleasing*)error;
@end
