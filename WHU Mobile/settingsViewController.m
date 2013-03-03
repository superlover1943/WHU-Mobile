//
//  settingsViewController.m
//  testProject
//
//  Created by 黄 嘉恒 on 3/3/13.
//  Copyright (c) 2013 黄 嘉恒. All rights reserved.
//

#import "settingsViewController.h"

@interface settingsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation settingsViewController
- (IBAction)closeSettingView:(id)sender
{
    NSString *username = self.usernameField.text;
    if (username.length == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误"
                                                            message:@"用户名不能为空！"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    
    NSString *password = self.passwordField.text;
    if (password.length == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"错误"
                                                            message:@"密码不能为空！"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alertView show];
        return;
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:(1 ? username:@"") forKey:@"myWLANUsername"];
    [userDefaults setObject:(1 ? password:@"") forKey:@"myWLANPassword"];
    [userDefaults synchronize];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)closeDoneEdit:(id)sender
{
    [sender resignFirstResponder];
}

- (IBAction)dismissKeyboard:(id)sender;
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *myUsername = [userDefaultes stringForKey:@"myWLANUsername"];
    self.usernameField.text = myUsername;
    NSString *myPassword = [userDefaultes stringForKey:@"myWLANPassword"];
    self.passwordField.text = myPassword;
}

@end
