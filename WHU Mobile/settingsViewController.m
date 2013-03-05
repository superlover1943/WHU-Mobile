//
//  settingsViewController.m
//  testProject
//
//  Created by 黄 嘉恒 on 3/3/13.
//  Copyright (c) 2013 黄 嘉恒. All rights reserved.
//

#import "settingsViewController.h"

@interface settingsViewController ()<UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic,strong)NSString *username;
@property (nonatomic,strong)NSString *password;

@end

@implementation settingsViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {return 1;}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {return 2;}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.row == 0)
    {
        cell = [self.myTableView dequeueReusableCellWithIdentifier:@"username"];
    }
    else if (indexPath.row == 1)
    {
        cell = [self.myTableView dequeueReusableCellWithIdentifier:@"password"];
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView
titleForFooterInSection:(NSInteger)section {return @"用户名和密码会自动保存，若想清除数据，清空用户名一栏即可";}

- (IBAction)closeSettingView:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.username forKey:@"myWLANUsername"];
    [userDefaults setObject:(self.username? self.password:@"") forKey:@"myWLANPassword"];
    [userDefaults synchronize];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)closeDoneEdit:(id)sender
{
    [self closeSettingView:sender];
}

/*
- (IBAction)dismissKeyboard:(id)sender;
{
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}
*/


- (void)setup
{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *myUsername = [userDefaultes stringForKey:@"myWLANUsername"];
    self.username = myUsername;
    NSString *myPassword = [userDefaultes stringForKey:@"myWLANPassword"];
    self.password = myPassword;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setup];
    }
    return self;
}

@end
