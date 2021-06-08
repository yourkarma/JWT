//
//  JWTClaimVerifierBase.m
//  JWT
//
//  Created by Dmitry Lobanov on 30.05.2021.
//  Copyright © 2021 JWTIO. All rights reserved.
//

#import <JWT/JWTClaimVerifierBase.h>

@implementation JWTClaimVerifierBase
- (BOOL)verifyValue:(NSObject *)value withTrustedValue:(NSObject *)trustedValue {
    return NO;
}
@end
