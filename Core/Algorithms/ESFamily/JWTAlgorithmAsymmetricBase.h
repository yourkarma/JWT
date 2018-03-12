//
//  JWTAlgorithmAsymmetricBase.h
//  Base64
//
//  Created by Lobanov Dmitry on 12.03.2018.
//

#import <Foundation/Foundation.h>
#import "JWTRSAlgorithm.h"

@interface JWTAlgorithmAsymmetricBase : NSObject @end

@interface JWTAlgorithmAsymmetricBase (JWTAsymmetricKeysAlgorithm) <JWTRSAlgorithm> @end

@interface JWTAlgorithmAsymmetricBase (Create)

// default.
+ (instancetype)withRS;
+ (instancetype)withES;
- (instancetype)with256;
- (instancetype)with384;
- (instancetype)with512;

@end

