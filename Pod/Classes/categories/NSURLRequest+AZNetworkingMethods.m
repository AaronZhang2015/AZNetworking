//
//  NSURLRequest+AIFNetworkingMethods.m
//  RTNetworking
//
//  Created by casa on 14-5-26.
//  Copyright (c) 2014年 anjuke. All rights reserved.
//

#import "NSURLRequest+AZNetworkingMethods.h"
#import <objc/runtime.h>

static void *AZNetworkingRequestParams;

@implementation NSURLRequest (AZNetworkingMethods)

- (void)setRequestParams:(NSDictionary *)requestParams
{
    objc_setAssociatedObject(self, &AZNetworkingRequestParams, requestParams, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)requestParams
{
    return objc_getAssociatedObject(self, &AZNetworkingRequestParams);
}

@end
