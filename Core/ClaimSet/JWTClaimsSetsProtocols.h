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
- (instancetype)copyWithValue:(NSObject *)value;
@end

@protocol JWTClaimsSetProtocol <NSCopying>
@property (copy, nonatomic, readonly) NSArray <id<JWTClaimProtocol>>* claims;
- (instancetype)copyWithClaims:(NSArray <id<JWTClaimProtocol>>*)claims;
- (void)appendClaim:(id<JWTClaimProtocol>)claim;
- (void)removeClaimByName:(NSString *)name;
@end

@protocol JWTClaimsProviderProtocol
@property (copy, nonatomic, readonly) NSArray <NSString *> *availableClaimsNames;
- (id<JWTClaimProtocol>)claimByName:(NSString *)name;
@end

@protocol JWTClaimsSetSerializerProtocol
@property (nonatomic, readonly) id <JWTClaimsProviderProtocol> claimsProvider;
@property (nonatomic, readonly) id <JWTClaimsSetProtocol> claimsSetProvider;
- (NSDictionary *)dictionaryFromClaimsSet:(id<JWTClaimsSetProtocol>)claimsSet;
- (id<JWTClaimsSetProtocol>)claimsSetFromDictionary:(NSDictionary *)dictionary;
@end

@protocol JWTClaimsSetVerifierProtocol
@property (nonatomic, readonly) id <JWTClaimsProviderProtocol> claimsProvider;
- (BOOL)verifyClaimsSet:(id<JWTClaimsSetProtocol>)theClaimsSet withTrustedClaimsSet:(id<JWTClaimsSetProtocol>)trustedClaimsSet;
@end

NS_ASSUME_NONNULL_END
