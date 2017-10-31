//
//  NSArrayExtension.m
//  JWTDesktop
//
//  Created by Lobanov Dmitry on 30.10.2017.
//  Copyright © 2017 JWT. All rights reserved.
//

#import "NSArrayExtension.h"

@implementation NSArrayExtension
+ (id)extendedArray:(NSArray *)array objectAtIndex:(NSInteger)index {
    if (array.count) {
        return index >= array.count ? nil : [array objectAtIndex:index];
    }
    return nil;
}
@end
