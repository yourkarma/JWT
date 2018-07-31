//
//  JWTCryptoSecurity+Extraction.h
//  JWT
//
//  Created by Dmitry on 7/31/18.
//  Copyright © 2018 JWTIO. All rights reserved.
//

#import <JWT/JWT.h>

// content is Base64 string, all '\n' are removed.
@interface JWTCryptoSecurityComponent : NSObject
@property (copy, nonatomic, readwrite) NSString *content;
@property (copy, nonatomic, readwrite) NSString *type;
- (instancetype)initWithContent:(NSString *)content type:(NSString *)type;
@end

@interface JWTCryptoSecurityComponents : NSObject
@property (copy, nonatomic, readonly, class) NSString *Certificate;
@property (copy, nonatomic, readonly, class) NSString *PrivateKey;
@property (copy, nonatomic, readonly, class) NSString *PublicKey;
+ (NSArray *)components:(NSArray *)components ofType:(NSString *)type;
@end

@interface JWTCryptoSecurity (Extraction)
+ (NSArray *)componentsFromFile:(NSURL *)url;
+ (NSArray *)componentsFromFileContent:(NSString *)content;
@end
