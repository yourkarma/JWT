//
//  JWTClaimVariations.h
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JWT/JWTClaimBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface JWTClaimVariations : NSObject
+ (id<JWTClaimProtocol>)issuer;
+ (id<JWTClaimProtocol>)subject;
+ (id<JWTClaimProtocol>)audience;
+ (id<JWTClaimProtocol>)expirationTime;
+ (id<JWTClaimProtocol>)notBefore;
+ (id<JWTClaimProtocol>)issuedAt;
+ (id<JWTClaimProtocol>)jwtID;
+ (id<JWTClaimProtocol>)type;
+ (id<JWTClaimProtocol>)scope;
@end

NS_ASSUME_NONNULL_END
