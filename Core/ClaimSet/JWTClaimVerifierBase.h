//
//  JWTClaimVerifierBase.h
//  JWT
//
//  Created by Dmitry Lobanov on 30.05.2021.
//  Copyright © 2021 JWTIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JWT/JWTClaimsSetsProtocols.h>

NS_ASSUME_NONNULL_BEGIN

@interface JWTClaimVerifierBase : NSObject <JWTClaimVerifierProtocol>

@end

NS_ASSUME_NONNULL_END
