//
//  JWTClaimsSetBase.h
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JWT/JWTClaimsSetsProtocols.h>

NS_ASSUME_NONNULL_BEGIN

@interface JWTClaimsSetBase : NSObject <JWTClaimsSetProtocol>
@property (copy, nonatomic, readwrite) id <JWTClaimsProviderProtocol> claimsProvider;
@end

@interface JWTClaimsSetBase (DSL)
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
