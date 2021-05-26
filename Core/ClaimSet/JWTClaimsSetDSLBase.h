//
//  JWTClaimsSetDSLBase.h
//  JWT
//
//  Created by Dmitry Lobanov on 26.05.2021.
//  Copyright © 2021 JWTIO. All rights reserved.
//

#import <JWT/JWT.h>
#import "JWTClaimsSetsProtocols.h"
NS_ASSUME_NONNULL_BEGIN

@interface JWTClaimsSetDSLBase : JWTClaimsSetBase
@property (copy, nonatomic, readwrite) id <JWTClaimsProviderProtocol> claimsProvider;
@property (copy, nonatomic, readwrite) id <JWTClaimsSetProtocol> claimsSetProvider;
@end

@interface JWTClaimsSetDSLBase (DSL)
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
