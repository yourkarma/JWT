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

extern NSString *JWTRegisteredClaimNameIssuer;
extern NSString *JWTRegisteredClaimNameSubject;
extern NSString *JWTRegisteredClaimNameAudience;
extern NSString *JWTRegisteredClaimNameExpirationTime;
extern NSString *JWTRegisteredClaimNameNotBefore;
extern NSString *JWTRegisteredClaimNameIssuedAt;
extern NSString *JWTRegisteredClaimNameJWTID;
extern NSString *JWTRegisteredClaimNameType;
extern NSString *JWTRegisteredClaimNameScope;

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

@interface JWTClaimsNames : NSObject
@property(copy, nonatomic, readwrite, class) NSString *issuer;
@property(copy, nonatomic, readwrite, class) NSString *subject;
@property(copy, nonatomic, readwrite, class) NSString *audience;
@property(copy, nonatomic, readwrite, class) NSString *expirationTime;
@property(copy, nonatomic, readwrite, class) NSString *notBefore;
@property(copy, nonatomic, readwrite, class) NSString *issuedAt;
@property(copy, nonatomic, readwrite, class) NSString *jwtID;
@property(copy, nonatomic, readwrite, class) NSString *type;
@property(copy, nonatomic, readwrite, class) NSString *scope;
@end

NS_ASSUME_NONNULL_END
