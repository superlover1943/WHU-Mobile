//
//  WMViewController.m
//  WHU Mobile
//
//  Created by 黄 嘉恒 on 3/3/13.
//  Copyright (c) 2013 黄 嘉恒. All rights reserved.
//

#import "WMViewController.h"
#import "WHUWLAN.h"

@interface WMViewController ()<NSURLConnectionDelegate,WHUWLANDelegate>
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
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
            self.resultLabel.text = @"未知错误";
    }
}

- (void)handleWLANLoginResponse:(NSString *)response
{
    self.resultLabel.text = response;
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
        NSString *password = [userDefaultes stringForKey:@"myWLANPassword"];
        if ([username isEqualToString:@""] || [password isEqualToString:@""] || username == nil)
            [self performSegueWithIdentifier:@"settings" sender:self];
        else
            [self.whuWLAN loginUsingUsername:username
                                 andPassword:password];
    }
}

- (void)viewDidLoad
{
    [self.whuWLAN checkWhetherLogged];
    [super viewDidLoad];
    
}@end
