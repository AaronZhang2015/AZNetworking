//
//  NSArray+AZNetworkingMethods.m
//  AZNetworkDemo
//
//  Created by ZhangMing on 11/20/15.
//  Copyright © 2015 Aaron Zhang. All rights reserved.
//

#import "NSArray+AZNetworkingMethods.h"

@implementation NSArray (AZNetworkingMethods)

/** 字母排序之后形成的参数字符串 */
- (NSString *)AZ_paramsString
{
    NSMutableString *paramString = [[NSMutableString alloc] init];
    
    NSArray *sortedParams = [self sortedArrayUsingSelector:@selector(compare:)];
    [sortedParams enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([paramString length] == 0) {
            [paramString appendFormat:@"%@", obj];
        } else {
            [paramString appendFormat:@"&%@", obj];
        }
    }];
    
    return paramString;
}

@end
