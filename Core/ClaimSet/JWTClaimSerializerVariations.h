//
//  JWTClaimSerializerVariations.h
//  JWT
//
//  Created by Dmitry Lobanov on 30.05.2021.
//  Copyright © 2021 JWTIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JWTClaimSerializerBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface JWTClaimSerializerVariations : NSObject
+ (id<JWTClaimSerializerProtocol>)dateAndTimestamp;
@end

@interface JWTClaimSerializerBaseConcreteDateAndTimestamp : JWTClaimSerializerBase
@end

NS_ASSUME_NONNULL_END
