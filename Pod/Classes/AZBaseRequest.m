//
//  AZBaseRequest.m
//  AZNetworking
//
//  Created by ZhangMing on 11/24/15.
//  Copyright © 2015 Aaron Zhang. All rights reserved.
//

#import "AZBaseRequest.h"
#import "AZNetworkAgent.h"
#import "AZURLResponse.h"

@interface AZBaseRequest ()

@property (nonatomic, strong, readwrite) id fetchedRawData;

@property (nonatomic, copy, readwrite) NSString *errorMessage;
@property (nonatomic, assign, readwrite) AZRequestErrorType errorType;
@property (nonatomic, strong, readwrite) NSDictionary *requestParams;

@end

@implementation AZBaseRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([self conformsToProtocol:@protocol(AZRequest)]) {
            self.child = (id<AZRequest>)self;
        } else {
            NSAssert(NO, @"AZBaseRequest subclass must be conforms protocol AZRequest.");
        }
    }
    return self;
}

- (void)start
{
    NSDictionary *params = [self.paramSource paramsForRequest:self];
    self.requestParams = [self reformParams:params];
    if ([self shouldCallRequestWithParams:self.requestParams]) {
        if ([self.validator request:self isCorrectWithParamsData:self.requestParams]) {
            // 检查一下是否有缓存
            if ([self shouldCache] && [self hasCacheWithParams:self.requestParams]) {
                return;
            }
            
            if (self.isReachable) {
                // 进行网络请求
               [[AZNetworkAgent sharedInstance] addRequest:(AZBaseRequest<AZRequest> *)self.child];
//                NSMutableDictionary *requestedParams = [self.requestParams mutableCopy];
//                [self afterCallingRequestWithParams:requestedParams];
            } else {
                self.errorType = AZRequestErrorTypeNoNetwork;
            }
        } else {
            self.errorType = AZRequestErrorTypeParamsError;
        }
    }
}

// Interceptor
- (void)beforePerformFinished:(AZURLResponse *)response
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(request:beforePerformFinished:)]) {
        [self.interceptor request:self beforePerformFinished:response];
    }
}

- (void)afterPerformFinished:(AZURLResponse *)response
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(request:afterPerformFinished:)]) {
        [self.interceptor request:self afterPerformFinished:response];
    }
}

- (void)beforePerformFailed:(AZURLResponse *)response
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(request:beforePerformFailed:)]) {
        [self.interceptor request:self beforePerformFailed:response];
    }
}

- (void)afterPerformFailed:(AZURLResponse *)response
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(request:afterPerformFailed:)]) {
        [self.interceptor request:self afterPerformFailed:response];
    }
}

- (BOOL)shouldCallRequestWithParams:(NSDictionary *)params
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(request:shouldCallRequestWithParams:)]) {
        return [self.interceptor request:self shouldCallRequestWithParams:params];
    } else {
        return YES;
    }
}

- (void)afterCallingRequestWithParams:(NSDictionary *)params
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(request:afterCallingRequestWithParams:)]) {
        [self.interceptor request:self afterCallingRequestWithParams:params];
    }
}

- (void)requestDidFinished:(AZURLResponse *)response
{
    // 检验数据
    if (response.status == AZURLResponseStatusSuccess) {
        if (response.responseJSONObject) {
            self.fetchedRawData = [response.responseJSONObject copy];
        }
        if ([self.validator request:self isCorrectWithCallbackData:self.fetchedRawData]) {
            self.errorType = AZRequestErrorTypeSuccess;
            if ([self shouldCache] && !response.isCache) {
                // 缓存数据
            }
            [self beforePerformFinished:response];
            if ([self.delegate respondsToSelector:@selector(request:didFinished:)]) {
                [self.delegate request:self didFinished:response];
            }
            [self afterPerformFinished:response];
            return;
        }
    }
    self.errorType = AZRequestErrorTypeTimeout;
    [self requestDidFailed:response];
}

- (void)requestDidFailed:(AZURLResponse *)response
{
    [self beforePerformFailed:response];
    if ([self.delegate respondsToSelector:@selector(request:didFailed:)]) {
        [self.delegate request:self didFailed:response];
    }
    [self afterPerformFailed:response];
}

#pragma mark - private methods
- (BOOL)hasCacheWithParams:(NSDictionary *)params
{
    return YES;
}

// Override methods
- (NSDictionary *)reformParams:(NSDictionary *)params
{
    return params;
}

- (NSTimeInterval)requestTimeoutInterval
{
    return -1;
}

- (AZRequestSerializerType)requestSerializerType
{
    return AZRequestSerializerTypeHTTP;
}

- (NSArray *)requestAuthorizationHeaderFieldArray
{
    return nil;
}

- (NSDictionary *)requestHeaderFieldValueDictionary
{
    return nil;
}

- (AFConstructingBlock)constructingBodyBlock
{
    return nil;
}

- (NSString *)resumableDownloadPath
{
    return nil;
}

- (AFDownloadProgressBlock)resumableDownloadProgressBlock
{
    return nil;
}

- (NSURLRequest *)buildCustomURLRequest
{
    return nil;
}

- (BOOL)shouldCache
{
    return NO;
}


#pragma mark - getters
- (BOOL)isReachable
{
    return YES;
}
@end
