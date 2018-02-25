//
//  ViewController+Model.h
//  JWTDesktop
//
//  Created by Lobanov Dmitry on 30.10.2017.
//  Copyright © 2017 JWT. All rights reserved.
//

#import "ViewController.h"
#import "JWTTokenTextTypeDescription.h"
#import "SignatureValidationDescription.h"
#import "JWTTokenDecoder.h"

@interface ViewController (Model)

@end

@interface ViewController__Model : NSObject
@property (strong, nonatomic, readwrite) JWTTokenTextTypeDescription *tokenDescription;
@property (strong, nonatomic, readwrite) JWTTokenTextTypeSerialization *tokenSerialization;
@property (strong, nonatomic, readwrite) JWTTokenTextTypeAppearance *tokenAppearance;
@property (strong, nonatomic, readwrite) SignatureValidationDescription *signatureValidationDescription;
@property (strong, nonatomic, readwrite) JWTTokenDecoder *decoder;
@end

@interface ViewController__Model (JWTAlgorithms)
@property (strong, nonatomic, readonly) NSArray *availableAlgorithms;
@property (strong, nonatomic, readonly) NSArray *availableAlgorithmsNames;
@end

@interface ViewController__DataSeed: NSObject
@property (copy, nonatomic, readonly) NSString *algorithmName;
@property (copy, nonatomic, readonly) NSString *secret;
@property (copy, nonatomic, readonly) NSString *token;
@end

@interface ViewController__DataSeed (Create)
+ (instancetype)defaultDataSeed;
+ (instancetype)HS256;
+ (instancetype)RS256;
+ (instancetype)HS256__WithoutClaimsSet;
+ (instancetype)HS256__LongSecret__32;
+ (instancetype)RS256__Corrupted;
@end
