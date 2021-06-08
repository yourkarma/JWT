//
//  JWTClaimsSetVerifier.h
//  JWT
//
//  Created by Lobanov Dmitry on 13.02.16.
//  Copyright © 2016 Karma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JWT/JWTClaimsSet.h>

@interface JWTClaimsSetVerifier : NSObject

+ (BOOL)verifyClaimsSet:(JWTClaimsSet *)theClaimsSet withTrustedClaimsSet:(JWTClaimsSet *)trustedClaimsSet;

@end
