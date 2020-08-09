//
//  JWTClaimsSetsProtocols.h
//  JWT
//
//  Created by Dmitry Lobanov on 09.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JWTClaimsSetsProtocols : NSObject

@end

@protocol JWTClaimProtocol <NSCopying>
@property (copy, nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSObject *value;
- (BOOL)verifyValue:(NSObject *)value withTrustedValue:(NSObject *)trustedValue;
- (instancetype)initWithValue:(NSObject *)value;
@end

@protocol JWTClaimsAccessorProtocol
@property (copy, nonatomic, readonly) NSArray <NSString *> *availableClaimsNames;
- (id<JWTClaimProtocol>)claimByName:(NSString *)name;
@end

@protocol JWTClaimsSetProtocol <NSCopying>
@property (nonatomic, readonly) NSArray <id<JWTClaimProtocol>>* claims;
- (instancetype)initWithClaims:(NSArray <id<JWTClaimProtocol>>*)claims;
@end

@protocol JWTClaimsSetFieldSerializerProtocol
/// Serialize one type of field (?)
/// For example, you could serialize date or time or any field.
@end

@protocol JWTClaimsSetSerializerProtocol
- (NSDictionary *)dictionaryFromClaimsSet:(id<JWTClaimsSetProtocol>)claimsSet;
- (id<JWTClaimsSetProtocol>)claimsSetFromDictionary:(NSDictionary *)dictionary;
@end

@protocol JWTClaimsSetVerifierProtocol
@property (nonatomic, readonly) id <JWTClaimsAccessorProtocol> accessor;
- (BOOL)verifyClaimsSet:(id<JWTClaimsSetProtocol>)theClaimsSet withTrustedClaimsSet:(id<JWTClaimsSetProtocol>)trustedClaimsSet;
@end

@protocol JWTClaimsSetFacadeProtocol <JWTClaimsAccessorProtocol, JWTClaimsSetSerializerProtocol, JWTClaimsSetVerifierProtocol>
@end

NS_ASSUME_NONNULL_END
