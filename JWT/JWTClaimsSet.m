//
//  JWTClaimsSet.m
//  JWT
//
//  Created by Klaas Pieter Annema on 31-05-13.
//  Copyright (c) 2013 Karma. All rights reserved.
//

#import "JWTClaimsSet.h"

@implementation JWTClaimsSet

- (NSDate *)expirationDate;
{
    if (!_expirationDate)
        _expirationDate = [NSDate distantFuture];

    return _expirationDate;
}

@end
