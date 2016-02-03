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

- (NSDate *)notBeforeDate;
{
    if (!_notBeforeDate)
        _notBeforeDate = [NSDate distantPast];

    return _notBeforeDate;
}

- (NSDate *)issuedAt;
{
    if (!_issuedAt)
        _issuedAt = [NSDate date];

    return _issuedAt;
}

@end
