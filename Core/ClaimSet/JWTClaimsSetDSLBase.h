//
//  JWTClaimsSetDSLBase.h
//  JWT
//
//  Created by Dmitry Lobanov on 31.05.2021.
//  Copyright © 2021 JWTIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JWT/JWTClaimsSetsProtocols.h>

NS_ASSUME_NONNULL_BEGIN

@interface JWTClaimsSetDSLBase : NSObject
@property (strong, nonatomic, readonly) id <JWTClaimsProviderProtocol> claimsProvider;
@property (copy, nonatomic, readonly) id <JWTClaimsSetProtocol> claimsSetStorage;
- (instancetype)initWithClaimsProvider:(id <JWTClaimsProviderProtocol>)claimsProvider claimsSetStorage:(id <JWTClaimsSetProtocol>)claimsSetStorage;
@end

@interface JWTClaimsSetDSLBase (DSL)
- (NSObject *)dslValueForName:(NSString *)name;
- (void)dslSetValue:(NSObject *)value forName:(NSString *)name;
@property (copy, nonatomic, readwrite) NSString *issuer;
@property (copy, nonatomic, readwrite) NSString *subject;
@property (copy, nonatomic, readwrite) NSString *audience;
@property (copy, nonatomic, readwrite) NSDate *expirationDate;
@property (copy, nonatomic, readwrite) NSDate *notBeforeDate;
@property (copy, nonatomic, readwrite) NSDate *issuedAt;
@property (copy, nonatomic, readwrite) NSString *identifier;
@property (copy, nonatomic, readwrite) NSString *type;
@property (copy, nonatomic, readwrite) NSString *scope;

@end

NS_ASSUME_NONNULL_END
