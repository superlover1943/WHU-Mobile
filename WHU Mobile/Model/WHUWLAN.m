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
@property (nonatomic,strong)NSMutableData *responseData;
@property (nonatomic,strong)NSURLConnection *loginConnection;
@property (nonatomic,strong)NSURLConnection *logoffConnection;
@property (nonatomic,strong)NSURLConnection *getCookieConnection;
@property (nonatomic,strong)NSURLConnection *checkWhetherLoggedConnection;
@property (nonatomic)BOOL checkThenLogin;
@property (nonatomic,strong)NSHTTPURLResponse *response;
@property (nonatomic,strong)NSOperationQueue *connectionQueue;
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
        [self.connectionQueue cancelAllOperations];
        [self checkWhetherLogged];
    }
    else
        [self.delegate handleWLANLoginResponse:@"用户名或密码为空"];
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
                                                           delegate:self
                                                   startImmediately:NO];
    [self.loginConnection setDelegateQueue:self.connectionQueue];
    [self.loginConnection start];
    [self.delegate handleWLANLoginResponse:@"正在登录"];
}

- (void)checkWhetherLogged
{
    if ([[self fetchSSIDInfo] isEqualToString:@"WHU-WLAN"]) {
        NSURL *myURL = [NSURL URLWithString:@"http://wlan.whu.edu.cn/portal/info"];
        NSURLRequest *request = [NSURLRequest requestWithURL:myURL
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:60];
        self.checkWhetherLoggedConnection = [[NSURLConnection alloc] initWithRequest:request
                                                                        delegate:self
                                                                startImmediately:NO];
        [self.checkWhetherLoggedConnection setDelegateQueue:self.connectionQueue];
        [self.checkWhetherLoggedConnection start];
        [self.delegate handleWLANLoginResponse:@"正在检测是否已登录"];
    }else{
        [self.delegate handleWLANLoginResponse:@"未连接至WHU-WLAN"];
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
    self.getCookieConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.getCookieConnection setDelegateQueue:self.connectionQueue];
    [self.getCookieConnection start];
    [self.delegate handleWLANLoginResponse:@"正在加载Cookies"];
}

- (void)logOff
{
    [self.connectionQueue cancelAllOperations];
    NSURL *myURL = [NSURL URLWithString:@"http://wlan.whu.edu.cn/portal/logOff"];
    NSURLRequest *request = [NSURLRequest requestWithURL:myURL
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:60];
    self.logoffConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self.delegate handleWLANLoginResponse:@"正在登出"];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.response = (NSHTTPURLResponse *)response;
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.delegate handleWLANLoginError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *htmlContent = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    if (connection == self.loginConnection)
    {
        self.loginConnection = nil;
        NSRange successRange = [htmlContent rangeOfString:@"欢迎你"];
        NSRange wrongPasswordRange = [htmlContent rangeOfString:@"密码不正确"];
        NSRange invalidUsernameRange = [htmlContent rangeOfString:@"不存在"];
        NSRange busyRange = [htmlContent rangeOfString:@"系统繁忙"];
        NSRange wificonflictRange = [htmlContent rangeOfString:@"同名无线用户已在线"];
        NSRange conflictRange = [htmlContent rangeOfString:@"帐号已在线"];
        NSRange outOfService = [htmlContent rangeOfString:@"包天暂停"];
        if (successRange.location != NSNotFound)
            [self.delegate handleWLANLoginResponse:@"连接成功"];
        else if (wrongPasswordRange.location != NSNotFound)
            [self.delegate handleWLANLoginResponse:@"密码错误"];
        else if (invalidUsernameRange.location != NSNotFound)
            [self.delegate handleWLANLoginResponse:@"用户名不存在"];
        else if (busyRange.location != NSNotFound)
            [self.delegate handleWLANLoginResponse:@"系统繁忙"];
        else if (wificonflictRange.location != NSNotFound)
            [self.delegate handleWLANLoginResponse:@"同名用户已连接WLAN"];
        else if (conflictRange.location != NSNotFound)
            [self.delegate handleWLANLoginResponse:@"同名用户已连接校园网"];
        else if (outOfService.location != NSNotFound)
            [self.delegate handleWLANLoginResponse:@"用户已停止校园网包天"];
        else
            [self.delegate handleWLANLoginResponse:@"连接失败"];
    }
    else if (connection == self.logoffConnection)
    {
        [self.delegate handleWLANLoginResponse:@"已登出"];
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
                [self.delegate handleWLANLoginResponse:@"未连接"];
        else
        {
            [self.delegate handleWLANLoginResponse:@"已连接"];
        }
    }
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
    /*
    CFArrayRef arrayRef = CNCopySupportedInterfaces();
    NSArray *interfaces = (__bridge NSArray *)arrayRef;
    NSLog(@"interfaces -> %@", interfaces);
    for (NSString *interfaceName in interfaces)
    {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName);
        if (dictRef != NULL) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            CFRelease(dictRef);
        }
    }
    CFRelease(arrayRef);
    
    CFArrayRef myArray = CNCopySupportedInterfaces();
    const void* currentSSID;
    if(myArray!=nil){
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if(myDict!=nil)currentSSID=CFDictionaryGetValue(myDict, @"SSID");
    } else currentSSID=@"";
    return CFBridgingRelease(currentSSID);
     */
    return @"WHU-WLAN";
}

- (id)initWithDelegate:(id)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (NSOperationQueue *)connectionQueue
{
    if (!_connectionQueue) {
        _connectionQueue = [[NSOperationQueue alloc] init];
        _connectionQueue.maxConcurrentOperationCount = 1;
    }
    return _connectionQueue;
}

@end
