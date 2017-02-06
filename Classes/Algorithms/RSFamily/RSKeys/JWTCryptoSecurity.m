//
//  JWTCryptoSecurity.m
//  JWT
//
//  Created by Lobanov Dmitry on 04.02.17.
//  Copyright © 2017 JWTIO. All rights reserved.
//

#import "JWTCryptoSecurity.h"

@implementation JWTCryptoSecurity
+ (NSDictionary *)dictionaryByCombiningDictionaries:(NSArray *)dictionaries {
    NSMutableDictionary *result = [@{} mutableCopy];
    for (NSDictionary *dictionary in dictionaries) {
        [result addEntriesFromDictionary:dictionary];
    }
    return [result copy];
}
+ (NSString *)keyTypeRSA {
    return (__bridge NSString *)kSecAttrKeyTypeRSA;
}
+ (NSString *)keyTypeEC {
//    extern const CFStringRef kSecAttrKeyTypeEC
//    __OSX_AVAILABLE_STARTING(__MAC_10_9, __IPHONE_4_0);
//    extern const CFStringRef kSecAttrKeyTypeECSECPrimeRandom
//    __OSX_AVAILABLE_STARTING(__MAC_10_12, __IPHONE_10_0);
    return (__bridge NSString *)kSecAttrKeyTypeEC;
}
+ (SecKeyRef)addKeyWithData:(NSData *)data asPublic:(BOOL)public tag:(NSString *)tag type:(NSString *)type error:(NSError *__autoreleasing*)error; {
    NSString *keyClass = (__bridge NSString *)(public ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate);
    NSInteger sizeInBits = data.length * 8;
    NSDictionary *attributes = @{
        (__bridge NSString*)kSecAttrKeyType : type,
        (__bridge NSString*)kSecAttrKeyClass : keyClass,
        (__bridge NSString*)kSecAttrKeySizeInBits : @(sizeInBits)
    };

    BOOL createKeyWithDataAvailable = &SecKeyCreateWithData != NULL;
    if (createKeyWithDataAvailable) {
        CFErrorRef createError = NULL;
        SecKeyRef key = SecKeyCreateWithData((__bridge CFDataRef)data, (__bridge CFDictionaryRef)attributes, &createError);
        if (error && createError != nil) {
            *error = (__bridge NSError*)createError;
        }
        return key;
    }
    // oh... not avaialbe API :/
    else {

        CFTypeRef result = NULL;
        NSData *tagData = [tag dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *commonAttributes = @{
            (__bridge NSString*)kSecClass: (__bridge NSString*)kSecClassKey,
            (__bridge NSString*)kSecAttrApplicationTag: tagData,
            (__bridge NSString*)kSecAttrAccessible: (__bridge NSString*)kSecAttrAccessibleWhenUnlocked
        };


        NSDictionary *addItemAttributes = @{
           (__bridge NSString*)kSecValueData: data,
           (__bridge NSString*)kSecReturnPersistentRef: @(YES),
        };

        OSStatus addItemStatus = SecItemAdd((__bridge CFDictionaryRef)[self dictionaryByCombiningDictionaries:@[attributes, commonAttributes, addItemAttributes]], &result);
        if (addItemStatus != errSecSuccess && addItemStatus != errSecDuplicateItem) {
            // add item error
            // not duplicate and not added to keychain.
            return NULL;
        }

        NSDictionary *copyAttributes = @{
                (__bridge NSString*)kSecReturnRef: @(YES),
        };

        CFTypeRef key = NULL;
        OSStatus copyItemStatus = SecItemCopyMatching((__bridge CFDictionaryRef)[self dictionaryByCombiningDictionaries:@[attributes, commonAttributes, copyAttributes]], &key);
        if (key == NULL) {
            // copy item error
        }
        return (SecKeyRef)key;
    }

    return NULL;
}
+ (SecKeyRef)addKeyWithData:(NSData *)data asPublic:(BOOL)public tag:(NSString *)tag error:(NSError *__autoreleasing*)error; {

    return [self addKeyWithData:data asPublic:public tag:tag type:[self keyTypeRSA] error:error];
//    CFStringRef keyClass = public ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate;
//    BOOL createKeyWithDataAvailable = &SecKeyCreateWithData != NULL;
//    if (createKeyWithDataAvailable) {
//        NSInteger sizeInBits = data.length * 8;
//        NSDictionary *attributes = @{
//                                     (__bridge NSString*)kSecAttrKeyType : (__bridge NSString*)kSecAttrKeyTypeRSA,
//                                     (__bridge NSString*)kSecAttrKeyClass : (__bridge NSString*)keyClass,
//                                     (__bridge NSString*)kSecAttrKeySizeInBits : @(sizeInBits)
//                                     };
//        CFErrorRef createError = NULL;
//        SecKeyRef key = SecKeyCreateWithData((__bridge CFDataRef)data, (__bridge CFDictionaryRef)attributes, &createError);
//        if (error && createError != nil) {
//            *error = (__bridge NSError*)createError;
//        }
//        return key;
//    }
//    // oh... not avaialbe API :/
//    else {
//        CFTypeRef result = NULL;
//        NSData *tagData = [tag dataUsingEncoding:NSUTF8StringEncoding];
//        NSDictionary *addItemAttributes = @{
//                                           (__bridge NSString*)kSecClass: (__bridge NSString*)kSecClassKey,
//                                           (__bridge NSString*)kSecAttrApplicationTag: tagData,
//                                           (__bridge NSString*)kSecAttrKeyType: (__bridge NSString*)kSecAttrKeyTypeRSA,
//                                           (__bridge NSString*)kSecValueData: data,
//                                           (__bridge NSString*)kSecAttrKeyClass: (__bridge NSString*)keyClass,
//                                           (__bridge NSString*)kSecReturnPersistentRef: @(YES),
//                                           (__bridge NSString*)kSecAttrAccessible: (__bridge NSString*)kSecAttrAccessibleWhenUnlocked
//                                           };
//        OSStatus addItemStatus = SecItemAdd((__bridge CFDictionaryRef)addItemAttributes, &result);
//        if (addItemStatus != errSecSuccess && addItemStatus != errSecDuplicateItem) {
//            // add item error
//            // not duplicate and not added to keychain.
//            return NULL;
//        }
//
//        NSDictionary *copyAttributes = @{
//                (__bridge NSString*)kSecClass: (__bridge NSString*)kSecClassKey,
//                (__bridge NSString*)kSecAttrApplicationTag: tagData,
//                (__bridge NSString*)kSecAttrKeyType: (__bridge NSString*)kSecAttrKeyTypeRSA,
//                (__bridge NSString*)kSecAttrKeyClass: (__bridge NSString*)keyClass,
//                (__bridge NSString*)kSecAttrAccessible: (__bridge NSString*)kSecAttrAccessibleWhenUnlocked,
//                (__bridge NSString*)kSecReturnRef: @(YES),
//        };
//        CFTypeRef key = NULL;
//        OSStatus copyItemStatus = SecItemCopyMatching((__bridge CFDictionaryRef)copyAttributes, &key);
//        if (key == NULL) {
//            // copy item error
//        }
//        return (SecKeyRef)key;
//    }
//
//    return NULL;
}

+ (SecKeyRef)keyByTag:(NSString *)tag error:(NSError *__autoreleasing*)error; {
    return NULL;
}

+ (void)removeKeyByTag:(NSString *)tag error:(NSError *__autoreleasing*)error; {
    NSData *tagData = [tag dataUsingEncoding:NSUTF8StringEncoding];
    if (tagData == nil) {
        // tell that nothing to remove.
        return;
    }
    NSDictionary *removeAttributes = @{
            (__bridge NSString*)kSecClass: (__bridge NSString*)kSecClassKey,
            (__bridge NSString*)kSecAttrKeyType: (__bridge NSString*)kSecAttrKeyTypeRSA,
            (__bridge NSString*)kSecAttrApplicationTag: tagData,
    };
    SecItemDelete((__bridge CFDictionaryRef)removeAttributes);
}
@end

@implementation JWTCryptoSecurity (Certificates)
+ (OSStatus)extractIdentityAndTrustFromPKCS12:(CFDataRef)inPKCS12Data password:(CFStringRef)password identity:(SecIdentityRef *)outIdentity trust:(SecTrustRef *)outTrust {

    OSStatus securityError = errSecSuccess;


    const void *keys[] =   { kSecImportExportPassphrase };
    const void *values[] = { password };
    CFDictionaryRef optionsDictionary = NULL;

    /* Create a dictionary containing the passphrase if one
     was specified.  Otherwise, create an empty dictionary. */
    optionsDictionary = CFDictionaryCreate(
                                           NULL, keys,
                                           values, (password ? 1 : 0),
                                           NULL, NULL);  // 1

    CFArrayRef items = NULL;
    securityError = SecPKCS12Import(inPKCS12Data,
                                    optionsDictionary,
                                    &items);                    // 2


    //
    if (securityError == 0) {                                   // 3
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue (myIdentityAndTrust,
                                             kSecImportItemIdentity);
        CFRetain(tempIdentity);
        *outIdentity = (SecIdentityRef)tempIdentity;
        const void *tempTrust = NULL;
        tempTrust = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemTrust);

        CFRetain(tempTrust);
        *outTrust = (SecTrustRef)tempTrust;
    }

    if (optionsDictionary)                                      // 4
        CFRelease(optionsDictionary);

    if (items)
        CFRelease(items);

    return securityError;
}

+ (SecKeyRef)publicKeyFromCertificate:(NSData *)certificateData {
    SecCertificateRef certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)certificateData);
    if (certificate != NULL) {
        SecPolicyRef secPolicy = SecPolicyCreateBasicX509();
        SecTrustRef trust;
        SecTrustCreateWithCertificates(certificate, secPolicy, &trust);
        SecTrustResultType resultType;
        SecTrustEvaluate(trust, &resultType);
        SecKeyRef publicKey = SecTrustCopyPublicKey(trust);
        (CFRelease(trust));
        (CFRelease(secPolicy));
        (CFRelease(certificate));
        return publicKey;
    }
    return NULL;
}
@end

@implementation JWTCryptoSecurity (Pem)
+ (NSString *)stringByRemovingPemHeadersFromString:(NSString *)string {
    NSArray *lines = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSArray *linesWithoutHeaders = [lines filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *_Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return !([evaluatedObject hasPrefix:@"-----BEGIN"] || [evaluatedObject hasPrefix:@"-----END"]);
    }]];
    return [linesWithoutHeaders componentsJoinedByString:@""];
}
@end

@implementation JWTCryptoSecurity (PublicKey)
+ (NSData *)dataByRemovingPublicKeyHeader:(NSData *)data {
    return data;
}
@end
