//
// Created by Marcelo Schroeder on 12/03/2016.
// Copyright (c) 2016 Karma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JWTAlgorithm.h"
@protocol JWTCryptoKeyProtocol;
@protocol JWTRSAlgorithm <JWTAlgorithm>

@required

@property(nonatomic, readwrite, copy) NSString *privateKeyCertificatePassphrase;

@optional
@property(nonatomic, readwrite, copy) NSString *keyExtractorType;
@property(nonatomic, readwrite, strong) id<JWTCryptoKeyProtocol> signKey;
@property(nonatomic, readwrite, strong) id<JWTCryptoKeyProtocol> verifyKey;
@end
