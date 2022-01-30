//
//  JWTAlgorithmErrorDescription.h
//  JWT
//
//  Created by Dmitry on 7/29/18.
//  Copyright © 2018 JWTIO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JWTAlgorithmErrorDescription : NSObject
+ (NSError *)errorWithCode:(NSInteger)code;
+ (NSError *)errorWithExternalError:(NSError *)error;
@end
