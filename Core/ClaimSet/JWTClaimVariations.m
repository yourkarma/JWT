//
//  JWTClaimVariations.m
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import "JWTClaimVariations.h"

NSString *JWTRegisteredClaimNameIssuer = @"iss";
NSString *JWTRegisteredClaimNameSubject = @"sub";
NSString *JWTRegisteredClaimNameAudience = @"aud";
NSString *JWTRegisteredClaimNameExpirationTime = @"exp";
NSString *JWTRegisteredClaimNameNotBefore = @"nbf";
NSString *JWTRegisteredClaimNameIssuedAt = @"iat";
NSString *JWTRegisteredClaimNameJWTID = @"jti";
NSString *JWTRegisteredClaimNameType = @"typ";
NSString *JWTRegisteredClaimNameScope = @"scope";

@implementation JWTClaimsNames
+ (NSString *)issuer { return JWTRegisteredClaimNameIssuer; }
+ (NSString *)subject { return JWTRegisteredClaimNameSubject; }
+ (NSString *)audience { return JWTRegisteredClaimNameAudience; }
+ (NSString *)expirationTime { return JWTRegisteredClaimNameExpirationTime; }
+ (NSString *)notBefore { return JWTRegisteredClaimNameNotBefore; }
+ (NSString *)issuedAt { return JWTRegisteredClaimNameIssuedAt; }
+ (NSString *)jwtID { return JWTRegisteredClaimNameJWTID; }
+ (NSString *)type { return JWTRegisteredClaimNameType; }
+ (NSString *)scope { return JWTRegisteredClaimNameScope; }
@end

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
+ (NSString *)name { return JWTRegisteredClaimNameIssuer; }
@end

@implementation JWTClaimBaseConcreteSubject
+ (NSString *)name { return JWTRegisteredClaimNameSubject; }
@end

@implementation JWTClaimBaseConcreteAudience
+ (NSString *)name { return JWTRegisteredClaimNameAudience; }
@end

@implementation JWTClaimBaseConcreteExpirationTime
+ (NSString *)name { return JWTRegisteredClaimNameExpirationTime; }
@end

@implementation JWTClaimBaseConcreteNotBefore
+ (NSString *)name { return JWTRegisteredClaimNameNotBefore; }
@end

@implementation JWTClaimBaseConcreteIssuedAt
+ (NSString *)name { return JWTRegisteredClaimNameIssuedAt; }
@end

@implementation JWTClaimBaseConcreteJWTID
+ (NSString *)name { return JWTRegisteredClaimNameJWTID; }
@end

@implementation JWTClaimBaseConcreteType
+ (NSString *)name { return JWTRegisteredClaimNameType; }
@end

@implementation JWTClaimBaseConcreteScope
+ (NSString *)name { return JWTRegisteredClaimNameScope; }
@end
