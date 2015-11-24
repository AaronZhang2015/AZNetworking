//
//  AZBaseRequest.h
//  AZNetworking
//
//  Created by ZhangMing on 11/24/15.
//  Copyright © 2015 Aaron Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "AFDownloadRequestOperation.h"

// 在调用成功之后的params字典里面，用这个key可以取出requestID
static NSString * const kAZAPIBaseRequestID = @"kAZAPIBaseRequestID";

typedef NS_ENUM(NSInteger, AZRequestMethod) {
    AZRequestMethodGet = 0,
    AZRequestMethodPost,
};

typedef NS_ENUM(NSInteger, AZRequestSerializerType) {
    AZRequestSerializerTypeHTTP = 0,
    AZRequestSerializerTypeJSON,
};

typedef NS_ENUM(NSInteger,AZRequestErrorType) {
    AZRequestErrorTypeDefault = 0,
    AZRequestErrorTypeSuccess,
    AZRequestErrorTypeNoContent,
    AZRequestErrorTypeParamsError,
    AZRequestErrorTypeTimeout,
    AZRequestErrorTypeNoNetwork,
};

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);
typedef void (^AFDownloadProgressBlock)(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile);

@class AZBaseRequest;
@class AZURLResponse;

@protocol AZRequestDelegate <NSObject>

@optional
- (void)request:(AZBaseRequest *)request didFinished:(AZURLResponse *)response;
- (void)request:(AZBaseRequest *)request didFailed:(AZURLResponse *)response;
- (void)clearRequest;

@end

@protocol AZRequestParamSource <NSObject>

@required
- (NSDictionary *)paramsForRequest:(AZBaseRequest *)request;

@end

@protocol AZRequestValidator <NSObject>

@required
- (BOOL)request:(AZBaseRequest *)request isCorrectWithParamsData:(NSDictionary *)data;
- (BOOL)request:(AZBaseRequest *)request isCorrectWithCallbackData:(NSDictionary *)data;

@end

@protocol AZRequestInterceptor <NSObject>

@optional
- (void)request:(AZBaseRequest *)request beforePerformFinished:(AZURLResponse *)response;
- (void)request:(AZBaseRequest *)request afterPerformFinished:(AZURLResponse *)response;

- (void)request:(AZBaseRequest *)request beforePerformFailed:(AZURLResponse *)response;
- (void)request:(AZBaseRequest *)request afterPerformFailed:(AZURLResponse *)response;

- (BOOL)request:(AZBaseRequest *)request shouldCallRequestWithParams:(NSDictionary *)params;
- (void)request:(AZBaseRequest *)request afterCallingRequestWithParams:(NSDictionary *)params;

@end

@protocol AZRequest <NSObject>

@required
- (NSString *)requestURL;
- (AZRequestMethod)requestMethod;
- (NSString *)serviceType;

@optional
- (BOOL)useSignature;

@end

@interface AZBaseRequest : NSObject

@property (nonatomic, weak) id<AZRequestDelegate> delegate;
@property (nonatomic, weak) id<AZRequestParamSource> paramSource;
@property (nonatomic, weak) id<AZRequestValidator> validator;
@property (nonatomic, weak) id<AZRequestInterceptor> interceptor;

@property (nonatomic, weak) NSObject<AZRequest> *child;

@property (nonatomic, strong) AFHTTPRequestOperation *operation;

@property (nonatomic, copy, readonly) NSString *errorMessage;
@property (nonatomic, assign, readonly) AZRequestErrorType errorType;
@property (nonatomic, strong, readonly) NSDictionary *requestParams;

@property (nonatomic, assign, readonly) BOOL isReachable;
@property (nonatomic, assign, readonly) BOOL isExecuting;

- (void)start;

// Interceptor
- (void)beforePerformFinished:(AZURLResponse *)response;
- (void)afterPerformFinished:(AZURLResponse *)response;

- (void)beforePerformFailed:(AZURLResponse *)response;
- (void)afterPerformFailed:(AZURLResponse *)response;

- (BOOL)shouldCallRequestWithParams:(NSDictionary *)params;
- (void)afterCallingRequestWithParams:(NSDictionary *)params;

- (void)requestDidFinished:(AZURLResponse *)response;
- (void)requestDidFailed:(AZURLResponse *)response;

// Override methods
- (NSTimeInterval)requestTimeoutInterval;
- (AZRequestSerializerType)requestSerializerType;
- (NSArray *)requestAuthorizationHeaderFieldArray;
- (NSDictionary *)requestHeaderFieldValueDictionary;

- (AFConstructingBlock)constructingBodyBlock;
- (NSString *)resumableDownloadPath;
- (AFDownloadProgressBlock)resumableDownloadProgressBlock;
- (NSURLRequest *)buildCustomURLRequest;
- (NSDictionary *)reformParams:(NSDictionary *)params;

- (BOOL)shouldCache;

@end
