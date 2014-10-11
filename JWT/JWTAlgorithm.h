//
//  JWTAlgorithm.h
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright (c) 2013 Karma. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JWTAlgorithm <NSObject>

@required
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, copy) NSMutableDictionary *headers;

- (id)initWithSecret:(NSString *)theSecret;

- (NSData *)encodePayload:(NSString *)theString withSecret:(NSString *)theSecret;

@end
