//
//  WHUWLAN.h
//  WHU Mobile
//
//  Created by 黄 嘉恒 on 2/26/13.
//  Copyright (c) 2013 黄 嘉恒. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WHUWLANDelegate <NSObject>

- (void)handleWLANLoginResponse:(NSString *)response;
/*
 可能的返回值：
 正在登录
 正在检测是否已登录
 未连接至WHU-WLAN
 正在登出
 连接成功
 密码错误
 用户名不存在
 系统繁忙
 同名用户已连接WLAN
 同名用户已连接校园网
 用户已停止校园网包天
 连接失败
 已登出
 未连接
 已连接
 */

- (void)handleWLANLoginError:(NSError *)error;
//参考 NSURLErrorDomain 文档

@end

@interface WHUWLAN : NSObject <NSURLConnectionDelegate,NSURLConnectionDataDelegate>
@property (nonatomic)id<WHUWLANDelegate> delegate;

- (void)loginUsingUsername:(NSString *)username
               andPassword:(NSString *)password;
- (void)logOff;
- (void)checkWhetherLogged;

//Designed initializer.
- (id)initWithDelegate:(id)delegate;


@end

