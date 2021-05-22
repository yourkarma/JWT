//
//  JWTClaimsSetsProtocols.h
//  JWT
//
//  Created by Dmitry Lobanov on 09.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JWTClaimProtocol <NSCopying>
@property (copy, nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSObject *value;
- (BOOL)verifyValue:(NSObject *)value withTrustedValue:(NSObject *)trustedValue;
- (instancetype)initWithValue:(NSObject *)value;
@end

@protocol JWTClaimsSetProtocol <NSCopying>
@property (copy, nonatomic, readonly) NSArray <id<JWTClaimProtocol>>* claims;
- (instancetype)initWithClaims:(NSArray <id<JWTClaimProtocol>>*)claims;
@end

@protocol JWTClaimsAccessorProtocol
@property (copy, nonatomic, readonly) NSArray <NSString *> *availableClaimsNames;
- (id<JWTClaimProtocol>)claimByName:(NSString *)name;
@end

@protocol JWTClaimsSetFieldSerializerProtocol
/// Serialize one type of field (?)
/// For example, you could serialize date or time or any field.
@end

@protocol JWTClaimBuilderProtocol
- (id<JWTClaimProtocol>)claimWithName:(NSString *)name value:(NSObject *)value;
@end

@protocol JWTClaimsSetBuilderProtocol
- (id<JWTClaimsSetProtocol>)claimsSetWithClaims:(NSArray <id<JWTClaimProtocol>>*)claims;
@end

@protocol JWTClaimsSetSerializerProtocol
@property (nonatomic, readonly) id <JWTClaimsAccessorProtocol> accessor;
@property (nonatomic, readonly) id <JWTClaimBuilderProtocol> claimBuilder;
@property (nonatomic, readonly) id <JWTClaimsSetBuilderProtocol> claimsSetBuilder;
- (NSDictionary *)dictionaryFromClaimsSet:(id<JWTClaimsSetProtocol>)claimsSet;
- (id<JWTClaimsSetProtocol>)claimsSetFromDictionary:(NSDictionary *)dictionary;
@end

@protocol JWTClaimsSetVerifierProtocol
@property (nonatomic, readonly) id <JWTClaimsAccessorProtocol> accessor;
- (BOOL)verifyClaimsSet:(id<JWTClaimsSetProtocol>)theClaimsSet withTrustedClaimsSet:(id<JWTClaimsSetProtocol>)trustedClaimsSet;
@end

NS_ASSUME_NONNULL_END
