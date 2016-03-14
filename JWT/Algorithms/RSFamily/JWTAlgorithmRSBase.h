//
//  JWTAlgorithmRSBase.h
//  JWT
//
//  Created by Lobanov Dmitry on 13.03.16.
//  Copyright © 2016 Karma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JWTRSAlgorithm.h"

@interface JWTAlgorithmRSBase : NSObject <JWTRSAlgorithm>

@property (assign, nonatomic, readonly) size_t ccSHANumberDigestLength;
@property (assign, nonatomic, readonly) uint32_t secPaddingPKCS1SHANumber;
- (unsigned char *)CC_SHANumberWithData:(const void *)data withLength:(uint32_t)len withHashBytes:(unsigned char *)hashBytes;

@end

@interface JWTAlgorithmRSBase (Create)

+ (instancetype)algorithm256;
+ (instancetype)algorithm384;
+ (instancetype)algorithm512;

@end