//
//  WMViewController.m
//  WHU Mobile
//
//  Created by 黄 嘉恒 on 3/3/13.
//  Copyright (c) 2013 黄 嘉恒. All rights reserved.
//

#import "WMViewController.h"
#import "STKeychain.h"
#import "WHUWLAN.h"

@interface WMViewController ()<NSURLConnectionDelegate,WHUWLANDelegate>
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (nonatomic,strong) WHUWLAN *whuWLAN;
@end

@implementation WMViewController

- (void)handleWLANLoginError:(NSError *)error
{
    if ([error.domain isEqual:NSURLErrorDomain]) {
        if (error.code == -1001)
            self.resultLabel.text = @"连接超时";
        else if (error.code == -1009)
            self.resultLabel.text = @"无网络";
        else
            NSLog(@"%@",error.description);
            self.resultLabel.text = @"未知错误";
    }
}

- (void)handleWLANLoginResponse:(NSString *)response
{
    if (![response isEqualToString:@" 正在检测是否已登录"])
    {
        if ([response isEqualToString:@"连接成功"] || [response isEqualToString:@"已连接"])
        {
            self.loginButton.selected = YES;
            self.loginButton.highlighted = NO;
        }
        else if ([response isEqualToString:@"正在登出"] || [response isEqualToString:@"正在登录"])
            self.loginButton.highlighted = YES;
        else
        {
            self.loginButton.selected = NO;
            self.loginButton.highlighted = NO;
        }
        self.resultLabel.text = response;
    }
}

- (WHUWLAN *)whuWLAN{
    if (!_whuWLAN) {
        _whuWLAN = [[WHUWLAN alloc] initWithDelegate:self];
    }
    return _whuWLAN;
}
- (IBAction)login:(UIButton *)sender
{
    if (sender.isSelected)
    {
        [self.whuWLAN logOff];
    }
    else
    {
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        NSString *username = [userDefaultes stringForKey:@"myWLANUsername"];
        NSString *password = [STKeychain getPasswordForUsername:username
                                                 andServiceName:@"WHUWLAN"
                                                          error:nil];
        if ([username isEqualToString:@""] || [password isEqualToString:@""] || username == nil)
            [self performSegueWithIdentifier:@"settings" sender:self];
        else
            [self.whuWLAN loginUsingUsername:username
                                 andPassword:password];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.whuWLAN checkWhetherLogged];
}

- (void)viewDidUnload {
    [self setLoginButton:nil];
    [super viewDidUnload];
}
@end
