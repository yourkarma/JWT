//
//  JWTAlgorithmHSFamily.h
//  JWT
//
//  Created by Lobanov Dmitry on 23.02.16.
//  Copyright © 2016 Karma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JWTAlgorithm.h"

NSString *JWTAlgorithmHSFamilyLength256 = @"HS256";
NSString *JWTAlgorithmHSFamilyLength384 = @"HS384";
NSString *JWTAlgorithmHSFamilyLength512 = @"HS512";
@interface JWTAlgorithmHSFamily : NSObject

+ (id<JWTAlgorithm>)jwtAlgorithmWithName:(NSString *)name;

@end