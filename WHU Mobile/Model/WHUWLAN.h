//
//  WHUWLAN.h
//  WHU Mobile
//
//  Created by 黄 嘉恒 on 2/26/13.
//  Copyright (c) 2013 黄 嘉恒. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 注册到NSNotificationCenter
 处理登陆返回值: @"wlanLoginResponce" 传入NSString
 处理登陆错误: @“@"wlanLoginError" 传入NSError (参考 NSURLErrorDomain 文档)
 */
/*
 @"wlanLoginResponce"可能的返回值：
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

@interface WHUWLAN : NSObject <NSURLConnectionDelegate,NSURLConnectionDataDelegate>

- (void)loginUsingUsername:(NSString *)username
               andPassword:(NSString *)password;
- (void)logOff;
- (void)checkWhetherLogged;

@end

