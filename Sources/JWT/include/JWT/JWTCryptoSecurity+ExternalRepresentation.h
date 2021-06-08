//
//  JWTCryptoSecurity+ExternalRepresentation.h
//  JWT
//
//  Created by Dmitry Lobanov on 08.08.2018.
//  Copyright © 2018 JWTIO. All rights reserved.
//

#import <Security/Security.h>
#import <JWT/JWTCryptoSecurity.h>

@interface JWTCryptoSecurity (ExternalRepresentation)
+ (NSData *)externalRepresentationForKey:(SecKeyRef)key error:(NSError *__autoreleasing*)error;
@end
