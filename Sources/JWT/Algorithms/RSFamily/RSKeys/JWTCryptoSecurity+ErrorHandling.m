//
//  JWTCryptoSecurity+ErrorHandling.m
//  JWT
//
//  Created by Dmitry Lobanov on 08.08.2018.
//  Copyright © 2018 JWTIO. All rights reserved.
//

#import "JWTCryptoSecurity+ErrorHandling.h"
#import "JWTDeprecations.h"

@implementation JWTCryptoSecurity (ErrorHandling)
+ (NSError *)securityErrorWithOSStatus:(OSStatus)status {
    if (status == errSecSuccess) {
        return nil;
    }
//  if  @available(macOS 10.3, iOS 11.3, tvOS 11.3, watchOS 4.3, *)
    // appropriate for Xcode 9 and higher.
    // rewrite it later?
#if JWT_COMPILE_TIME_AVAILABILITY(JWT_macOS(1030), JWT_iOS(110300), JWT_tvOS(110300), JWT_watchOS(40300))
    NSString *message = (NSString *)CFBridgingRelease(SecCopyErrorMessageString(status, NULL)) ?: @"Unknown error message";
    return [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:@{NSLocalizedDescriptionKey : message}];
#else
    return [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
#endif
}
@end
