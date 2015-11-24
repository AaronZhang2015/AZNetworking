//
//  AZURLResponse.m
//  AZNetworking
//
//  Created by ZhangMing on 11/24/15.
//  Copyright © 2015 Aaron Zhang. All rights reserved.
//

#import "AZURLResponse.h"
#import "NSURLRequest+AZNetworkingMethods.h"
#import "NSObject+AZNetworkingMethods.h"

@interface AZURLResponse ()

@property (nonatomic, assign, readwrite) AZURLResponseStatus status;
@property (nonatomic, copy, readwrite) NSString *responseString;
@property (nonatomic, copy, readwrite) id responseJSONObject;
@property (nonatomic, copy, readwrite) NSURLRequest *request;
@property (nonatomic, assign, readwrite) NSInteger requestId;
@property (nonatomic, copy, readwrite) NSData *responseData;
@property (nonatomic, assign, readwrite) BOOL isCache;

@end

@implementation AZURLResponse

#pragma mark - life cycle
- (instancetype)initWithResponseString:(NSString *)responseString request:(NSURLRequest *)request responseData:(NSData *)responseData status:(AZURLResponseStatus)status
{
    self = [super init];
    if (self) {
        self.responseString = responseString;
        self.responseJSONObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
        self.status = status;
        self.request = request;
        self.responseData = responseData;
        self.requestParams = request.requestParams;
        self.isCache = NO;
    }
    return self;
}

- (instancetype)initWithResponseString:(NSString *)responseString request:(NSURLRequest *)request responseData:(NSData *)responseData error:(NSError *)error
{
    self = [super init];
    if (self) {
        self.responseString = [responseString AZ_defaultValue:@""];
        self.status = [self responseStatusWithError:error];
        self.request = request;
        self.responseData = responseData;
        self.requestParams = request.requestParams;
        self.isCache = NO;
        
        if (responseData) {
            self.responseJSONObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
        } else {
            self.responseJSONObject = nil;
        }
    }
    return self;
}

#pragma mark - private methods
- (AZURLResponseStatus)responseStatusWithError:(NSError *)error
{
    if (error) {
        AZURLResponseStatus result = AZURLResponseStatusErrorNoNetwork;
        
        // 除了超时以外，所有错误都当成是无网络
        if (error.code == NSURLErrorTimedOut) {
            result = AZURLResponseStatusErrorNoNetwork;
        }
        return result;
    } else {
        return AZURLResponseStatusSuccess;
    }
}

@end
