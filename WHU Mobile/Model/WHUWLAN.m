//
//  WHUWLAN.m
//  WHU Mobile
//
//  Created by 黄 嘉恒 on 2/26/13.
//  Copyright (c) 2013 黄 嘉恒. All rights reserved.
//

#import "WHUWLAN.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <netinet/in.h>
#import <ifaddrs.h>
#import <sys/socket.h>

@interface WHUWLAN ()
@property (nonatomic,strong)NSURLConnection *loginConnection;
@property (nonatomic,strong)NSURLConnection *logoffConnection;
@property (nonatomic,strong)NSURLConnection *getCookieConnection;
@property (nonatomic,strong)NSURLConnection *checkWhetherLoggedConnection;
@property (nonatomic)BOOL checkThenLogin;
@property (nonatomic,strong)NSString *username;
@property (nonatomic,strong)NSString *password;
@end

@implementation WHUWLAN

- (void)loginUsingUsername:(NSString *)username
               andPassword:(NSString *)password
{
    if ([username length] && [password length]) {
        self.username = username;
        self.password = password;
        self.checkThenLogin = YES;
        [self cancelAllConnectionWithoutConnection:nil];
        [self checkWhetherLogged];
    }
    else
        [[NSNotificationCenter defaultCenter] postNotificationName:@"wlanLoginResponce"
                                                            object:@"用户名或密码为空"];
}

- (void)login
{
    NSURL *myURL = [NSURL URLWithString:@"https://wlan.whu.edu.cn/portal/login"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60];
    request.HTTPMethod = @"POST";
    NSString *POSTBody = [NSString stringWithFormat:@"username=%@&password=%@",self.username,self.password];
    self.username = nil;
    self.password = nil;
    request.HTTPBody = [POSTBody dataUsingEncoding:NSUTF8StringEncoding];
    self.loginConnection = [[NSURLConnection alloc] initWithRequest:request
                                                           delegate:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"wlanLoginResponce"
                                                        object:@"正在登录"];
}

- (void)checkWhetherLogged
{
    if ([[self fetchSSIDInfo] isEqualToString:@"WHU-WLAN"]) {
        NSURL *myURL = [NSURL URLWithString:@"http://wlan.whu.edu.cn/portal/info"];
        NSURLRequest *request = [NSURLRequest requestWithURL:myURL
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60];
        self.checkWhetherLoggedConnection = [[NSURLConnection alloc] initWithRequest:request
                                                                        delegate:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"wlanLoginResponce"
                                                            object:@"正在检测是否已登录"];

    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"wlanLoginResponce"
                                                            object:@"未连接至WHU-WLAN"];
    }
}

- (void)loadCookie
{
    [self clearCookies];
    NSString *URLString = [NSString stringWithFormat:@"https://wlan.whu.edu.cn/portal?cmd=login&switchip=&mac=&ip=%@&essid=WHU-WLAN&url=",[self getLoaclIP]];
    NSURL *myURL = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:myURL
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60];
    self.getCookieConnection = [[NSURLConnection alloc] initWithRequest:request
                                                               delegate:self];
}

- (void)logOff
{
    [self cancelAllConnectionWithoutConnection:self.logoffConnection];
    NSURL *myURL = [NSURL URLWithString:@"http://wlan.whu.edu.cn/portal/logOff"];
    NSURLRequest *request = [NSURLRequest requestWithURL:myURL
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60];
    self.logoffConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //?
    [[NSNotificationCenter defaultCenter] postNotificationName:@"wlanLoginResponce"
                                                        object:@"正在登出"];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    NSString *htmlContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (connection == self.loginConnection)
    {
        self.loginConnection = nil;
        NSRange successRange = [htmlContent rangeOfString:@"欢迎你"];
        NSRange wrongPasswordRange = [htmlContent rangeOfString:@"密码不正确"];
        NSRange invalidUsernameRange = [htmlContent rangeOfString:@"不存在"];
        NSRange busyRange = [htmlContent rangeOfString:@"系统繁忙"];
        NSRange wifiConflictRange = [htmlContent rangeOfString:@"同名无线用户已在线"];
        NSRange conflictRange = [htmlContent rangeOfString:@"帐号已在线"];
        NSRange outOfService = [htmlContent rangeOfString:@"包天暂停"];
        if (successRange.location != NSNotFound)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"wlanLoginResponce"
                                                                object:@"连接成功"];
        else if (wrongPasswordRange.location != NSNotFound)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"wlanLoginResponce"
                                                                object:@"密码错误"];
        else if (invalidUsernameRange.location != NSNotFound)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"wlanLoginResponce"
                                                                object:@"用户名不存在"];
        else if (busyRange.location != NSNotFound)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"wlanLoginResponce"
                                                                object:@"系统繁忙"];
        else if (wifiConflictRange.location != NSNotFound)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"wlanLoginResponce"
                                                                object:@"同名用户已连接WLAN"];
        else if (conflictRange.location != NSNotFound)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"wlanLoginResponce"
                                                                object:@"同名用户已连接校园网"];
        else if (outOfService.location != NSNotFound)
            [[NSNotificationCenter defaultCenter] postNotificationName:@"wlanLoginResponce"
                                                                object:@"用户已停止校园网包天"];
        else
            [[NSNotificationCenter defaultCenter] postNotificationName:@"wlanLoginResponce"
                                                                object:@"连接失败"];
    }
    else if (connection == self.logoffConnection)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"wlanLoginResponce"
                                                            object:@"已登出"];
        self.logoffConnection = nil;
    }
    else if (connection == self.getCookieConnection)
    {
        self.getCookieConnection = nil;
        [self login];
    }
    else if (connection == self.checkWhetherLoggedConnection)
    {
        self.checkWhetherLoggedConnection = nil;
        NSRange successRange = [htmlContent rangeOfString:@"欢迎你"];
        if (successRange.location == NSNotFound)
            if (self.checkThenLogin)
            {
                self.checkThenLogin = NO;
                [self loadCookie];
            }
            else
                [[NSNotificationCenter defaultCenter] postNotificationName:@"wlanLoginResponce"
                                                                    object:@"未连接"];
            else
                [[NSNotificationCenter defaultCenter] postNotificationName:@"wlanLoginResponce"
                                                                    object:@"已连接"];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"wlanLoginError"
                                                        object:error];
}
/*
 登陆时可能的返回值：
 系统繁忙，请稍后再试。。
 神码用户[＃用户名＃]密码不正确！
 用户[＃用户名＃]不存在!
 同名无线用户已在线！
 神码用户[＃用户名＃]帐号已在线!
 神码用户[＃用户名＃]包天暂停!
 ＃用户名＃,欢迎你!
 
 登出时可能的返回值：
 下线操作失败:下线操作必须在认证通过的终端上！
 用户下线操作成功！
 
 检测是否成功登陆时可能的返回值：
 ＃用户名＃,欢迎你!
 也可能跳转至www.whu.edu.cn
*/


- (void)clearCookies{
    NSURL *myURL = [NSURL URLWithString:@"https://wlan.whu.edu.cn/"];
    NSHTTPCookieStorage *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *WLANCookies = [cookies cookiesForURL:myURL];
    for (NSHTTPCookie *cookie in WLANCookies) {
        [cookies deleteCookie:cookie];
    }
}

//ignore Certification Error
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSArray *trustedHosts = @[@"wlan.whu.edu.cn"];
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        if ([trustedHosts containsObject:challenge.protectionSpace.host])
            [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (NSString *)getLoaclIP
{
    NSString *localIP = [NSString new];
    struct ifaddrs*	addrs;
    BOOL success = (getifaddrs(&addrs) == 0);
    if (success)
    {
        const struct ifaddrs* cursor = addrs;
        while (cursor != NULL)
        {
            NSMutableString* ip;
            if (cursor->ifa_addr->sa_family == AF_INET)
            {
                const struct sockaddr_in* dlAddr = (const struct sockaddr_in*) cursor->ifa_addr;
                const uint8_t* base = (const uint8_t*)&dlAddr->sin_addr;
                ip = [NSMutableString new];
                for (int i = 0; i < 4; i++)
                {
                    if (i != 0)
                        [ip appendFormat:@"."];
                    [ip appendFormat:@"%d", base[i]];
                }
                if ([[NSString stringWithFormat:@"%s", cursor->ifa_name] isEqual:@"en0"]) {
                    localIP = (NSString*)ip;
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    return localIP;
}

- (NSString *)fetchSSIDInfo
{
    CFArrayRef myArray = CNCopySupportedInterfaces();
    const void* currentSSID = nil;
    if(myArray != nil){
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if(myDict != nil)
            currentSSID = CFDictionaryGetValue(myDict, @"SSID");
    }
    else
        currentSSID=@"";
    return CFBridgingRelease(currentSSID);
}

- (void)cancelAllConnectionWithoutConnection:(NSURLConnection *)connection
{
    NSMutableArray *connectionArray = [[NSMutableArray alloc] init];
    if (self.loginConnection) {
        [connectionArray addObject:self.loginConnection];
    }
    if (self.logoffConnection) {
        [connectionArray addObject:self.loginConnection];
    }
    if (self.checkWhetherLoggedConnection) {
        [connectionArray addObject:self.loginConnection];
    }
    if (self.getCookieConnection) {
        [connectionArray addObject:self.loginConnection];
    }
    for (NSURLConnection *aConnection in connectionArray)
    {
        if (aConnection != connection) {
            [aConnection cancel];
        }
    }
}

@end
