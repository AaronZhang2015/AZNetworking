//
//  AZURLResponse.h
//  AZNetworking
//
//  Created by ZhangMing on 11/24/15.
//  Copyright © 2015 Aaron Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AZURLResponseStatus)
{
    AZURLResponseStatusSuccess, //作为底层，请求是否成功只考虑是否成功收到服务器反馈。至于签名是否正确，返回的数据是否完整，由上层的RTApiBaseManager来决定。
    AZURLResponseStatusErrorTimeout,
    AZURLResponseStatusErrorNoNetwork // 默认除了超时以外的错误都是无网络错误。
};

@interface AZURLResponse : NSObject

@property (nonatomic, assign, readonly) AZURLResponseStatus status;
@property (nonatomic, copy, readonly) NSString *responseString;

@property (nonatomic, copy, readonly) id responseJSONObject;

@property (nonatomic, copy, readonly) NSURLRequest *request;

@property (nonatomic, copy) NSDictionary *requestParams;
@property (nonatomic, readonly) NSInteger responseStatusCode;

@property (nonatomic, assign, readonly) BOOL isCache;

- (instancetype)initWithResponseString:(NSString *)responseString request:(NSURLRequest *)request responseData:(NSData *)responseData status:(AZURLResponseStatus)status;
- (instancetype)initWithResponseString:(NSString *)responseString request:(NSURLRequest *)request responseData:(NSData *)responseData error:(NSError *)error;

@end
