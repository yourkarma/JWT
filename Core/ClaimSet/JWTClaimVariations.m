//
//  JWTClaimVariations.m
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import "JWTClaimVariations.h"
@interface JWTClaimBaseConcreteIssuer : JWTClaimBase @end
@interface JWTClaimBaseConcreteSubject : JWTClaimBase @end
@interface JWTClaimBaseConcreteAudience : JWTClaimBase @end
@interface JWTClaimBaseConcreteExpirationTime : JWTClaimBase @end
@interface JWTClaimBaseConcreteNotBefore : JWTClaimBase @end
@interface JWTClaimBaseConcreteIssuedAt : JWTClaimBase @end
@interface JWTClaimBaseConcreteJWTID : JWTClaimBase @end
@interface JWTClaimBaseConcreteType : JWTClaimBase @end
@interface JWTClaimBaseConcreteScope : JWTClaimBase @end

@implementation JWTClaimVariations
+ (id<JWTClaimProtocol>)issuer {
    return [JWTClaimBaseConcreteIssuer new];
}
+ (id<JWTClaimProtocol>)subject {
    return [JWTClaimBaseConcreteSubject new];
}
+ (id<JWTClaimProtocol>)audience {
    return [JWTClaimBaseConcreteAudience new];
}
+ (id<JWTClaimProtocol>)expirationTime {
    return [JWTClaimBaseConcreteExpirationTime new];
}
+ (id<JWTClaimProtocol>)notBefore {
    return [JWTClaimBaseConcreteNotBefore new];
}
+ (id<JWTClaimProtocol>)issuedAt {
    return [JWTClaimBaseConcreteIssuedAt new];
}
+ (id<JWTClaimProtocol>)jwtID {
    return [JWTClaimBaseConcreteJWTID new];
}
+ (id<JWTClaimProtocol>)type {
    return [JWTClaimBaseConcreteType new];
}
+ (id<JWTClaimProtocol>)scope {
    return [JWTClaimBaseConcreteScope new];
}
@end

// MARK: - Base Concrete Claims
@implementation JWTClaimBaseConcreteIssuer
+ (NSString *)name { return @"iss"; }
@end

@implementation JWTClaimBaseConcreteSubject
+ (NSString *)name { return @"sub"; }
@end

@implementation JWTClaimBaseConcreteAudience
+ (NSString *)name { return @"aud"; }
@end

@implementation JWTClaimBaseConcreteExpirationTime
+ (NSString *)name { return @"exp"; }
@end

@implementation JWTClaimBaseConcreteNotBefore
+ (NSString *)name { return @"nbf"; }
@end

@implementation JWTClaimBaseConcreteIssuedAt
+ (NSString *)name { return @"iat"; }
@end

@implementation JWTClaimBaseConcreteJWTID
+ (NSString *)name { return @"jti"; }
@end

@implementation JWTClaimBaseConcreteType
+ (NSString *)name { return @"typ"; }
@end

@implementation JWTClaimBaseConcreteScope
+ (NSString *)name { return @"scope"; }
@end
