//
//  WMViewController.m
//  WHU Mobile
//
//  Created by 黄 嘉恒 on 3/3/13.
//  Copyright (c) 2013 黄 嘉恒. All rights reserved.
//

#import "WMViewController.h"
#import "WMAppDelegate.h"
#import "WHUWLAN.h"
#import "STKeychain.h"

@interface WMViewController ()<NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation WMViewController

- (void)handleWLANLoginError:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:[NSError class]]) {
        NSError *error = [notification object];
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
}

- (void)handleWLANLoginResponse:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:[NSString class]]) {
        NSString *response = [notification object];
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
}

- (IBAction)login:(UIButton *)sender
{
    WHUWLAN *whuWlan = ((WMAppDelegate *)[[UIApplication sharedApplication] delegate]).whuWlan;
    if (sender.isSelected)
    {
        [whuWlan logOff];
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
            [whuWlan loginUsingUsername:username
                            andPassword:password];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    WHUWLAN *whuWlan = ((WMAppDelegate *)[[UIApplication sharedApplication] delegate]).whuWlan;
    [whuWlan checkWhetherLogged];
}

- (void)setup
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWLANLoginResponse:)
                                                 name:@"wlanLoginResponce"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWLANLoginError:)
                                                 name:@"wlanLoginError"
                                               object:nil];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [self setup];
    return self;
}

@end
