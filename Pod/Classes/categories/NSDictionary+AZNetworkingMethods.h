//
//  NSDictionary+AZNetworkingMethods.h
//  AZNetworkDemo
//
//  Created by ZhangMing on 11/20/15.
//  Copyright © 2015 Aaron Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (AZNetworkingMethods)

- (NSString *)AZ_urlParamsStringSignature:(BOOL)isForSignature;
- (NSString *)AZ_jsonString;
- (NSArray *)AZ_transformedUrlParamsArraySignature:(BOOL)isForSignature;

@end
