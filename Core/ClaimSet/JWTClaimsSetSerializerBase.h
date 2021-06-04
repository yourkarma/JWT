//
//  JWTClaimsSetSerializerBase.h
//  JWT
//
//  Created by Dmitry Lobanov on 10.08.2020.
//  Copyright © 2020 JWTIO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JWT/JWTClaimsSetsProtocols.h>
#import <JWT/JWTClaimSerializerBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface JWTClaimsSetSerializerBase : NSObject <JWTClaimsSetSerializerProtocol>
@property (strong, nonatomic, readwrite) id <JWTClaimsProviderProtocol> claimsProvider;
@property (copy, nonatomic, readwrite) id <JWTClaimsSetProtocol> claimsSetStorage;
@property (assign, nonatomic, readwrite) BOOL skipClaimsProviderLookupCheck;
@end

NS_ASSUME_NONNULL_END
