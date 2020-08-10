//
//  JWTClaimsSetSerializerBase.h
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JWTClaimsSetsProtocols.h"

NS_ASSUME_NONNULL_BEGIN

@interface JWTClaimsSetSerializerBase : NSObject <JWTClaimsSetSerializerProtocol>
@property (nonatomic, readwrite) id <JWTClaimsAccessorProtocol> accessor;
@property (nonatomic, readwrite) id <JWTClaimBuilderProtocol> claimBuilder;
@property (nonatomic, readwrite) id <JWTClaimsSetBuilderProtocol> claimsSetBuilder;
@end

NS_ASSUME_NONNULL_END
