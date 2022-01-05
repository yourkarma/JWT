//
//  JWTDeprecations.h
//  JWT
//
//  Created by Lobanov Dmitry on 31.08.16.
//  Copyright © 2016 Karma. All rights reserved.
//

#ifndef JWTDeprecations_h
#define JWTDeprecations_h
#import <Availability.h>

#define JWT_STR(str) #str
#define JWTVersion_2_1_0 2.1
#define JWTVersion_2_2_0 2.2
#define JWTVersion_3_0_0 3.0
#define __first_deprecated_in_release_version(version) __deprecated_msg("first deprecated in release version: " JWT_STR(version))
#define __deprecated_and_will_be_removed_in_release_version(version) __deprecated_msg("deprecated. will be removed in release version: "JWT_STR(version))
#define __available_in_release_version(version) __deprecated_msg("will be introduced in release version: " JWT_STR(version))
#define __jwt_technical_debt(debt) __deprecated_msg("Don't forget to inspect it later." JWT_STR(debt))
#define __deprecated_with_replacement(msg) __deprecated_msg("Use " JWT_STR(msg))
#endif /* JWTDeprecations_h */

#ifndef JWT_macOS
#define JWT_macOS(VALUE) VALUE
#endif

#ifndef JWT_iOS
#define JWT_iOS(VALUE) VALUE
#endif

#ifndef JWT_tvOS
#define JWT_tvOS(VALUE) VALUE
#endif

#ifndef JWT_watchOS
#define JWT_watchOS(VALUE) VALUE
#endif

#ifndef JWT_COMPILE_TIME_AVAILABILITY
#define JWT_COMPILE_TIME_AVAILABILITY(macOS, iOS, tvOS, watchOS) defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && (__MAC_OS_X_VERSION_MIN_REQUIRED >= macOS) \
|| defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && (__IPHONE_OS_VERSION_MIN_REQUIRED >= iOS) \
|| defined(__TV_OS_VERSION_MIN_REQUIRED) && (__TV_OS_VERSION_MIN_REQUIRED >= tvOS) \
|| defined(__WATCH_OS_VERSION_MIN_REQUIRED) && (__WATCH_OS_VERSION_MIN_REQUIRED >= watchOS)
#endif
