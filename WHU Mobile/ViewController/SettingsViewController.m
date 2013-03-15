//
//  settingsViewController.m
//  testProject
//
//  Created by 黄 嘉恒 on 3/3/13.
//  Copyright (c) 2013 黄 嘉恒. All rights reserved.
//

#import "SettingsViewController.h"
#import "StringInputTableViewCell.h"
#import "STKeychain.h"

#define kUsernameCellTag 100
#define kPasswordCellTag 200
#define kWHUWLANKeychain @"WHUWLANKeychain"

@interface SettingsViewController ()<UITableViewDataSource,StringInputTableViewCellDelegate,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic,strong)NSString *username;
@property (nonatomic,strong)NSString *password;

@end

@implementation SettingsViewController

- (void)tableViewCell:(StringInputTableViewCell *)cell didEndEditingWithString:(NSString *)value
{
    if (cell.tag == kUsernameCellTag)
    {
        if ([value isEqualToString:@""]) {
            self.password = @"";
            NSIndexPath *indexPathOfPasswordCell = [NSIndexPath indexPathForRow:1
                                                                      inSection:0];
            ((StringInputTableViewCell *)[self.myTableView cellForRowAtIndexPath:indexPathOfPasswordCell]).stringValue = @"";
            [STKeychain deleteItemForUsername:self.username
                               andServiceName:@"WHUWLAN"
                                        error:nil];
        }
        self.username = value;
    }
    else if (cell.tag == kPasswordCellTag)
        self.password = value;
}

- (void)tableViewCellDidClear:(StringInputTableViewCell *)cell
{
    if (cell.tag == kUsernameCellTag) {
        NSIndexPath *indexPathOfPasswordCell = [NSIndexPath indexPathForRow:1
                                                                  inSection:0];
        ((StringInputTableViewCell *)[self.myTableView cellForRowAtIndexPath:indexPathOfPasswordCell]).stringValue = @"";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {return 2;}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        StringInputTableViewCell *SICell = (StringInputTableViewCell *)cell;
        if (indexPath.row == 0)
        {
            SICell = [[StringInputTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            SICell.textLabel.text = @"账号：";
            SICell.tag = kUsernameCellTag;
            SICell.delegate = self;
            SICell.stringValue = self.username;
            SICell.textField.placeholder = @"Student Number";
            SICell.textField.keyboardType = UIKeyboardTypeNumberPad;
            SICell.textField.returnKeyType = UIReturnKeyDefault;
            SICell.textField.clearButtonMode = UITextFieldViewModeAlways;
        }
        else if (indexPath.row == 1)
        {
            SICell = [[StringInputTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            SICell.textLabel.text = @"密码：";
            SICell.tag = kPasswordCellTag;
            SICell.delegate = self;
            SICell.stringValue = self.password;
            SICell.textField.placeholder = @"Password";
            SICell.textField.secureTextEntry = YES;
            SICell.textField.returnKeyType = UIReturnKeyDone;
            SICell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            SICell.textField.clearsOnBeginEditing = YES;
        }
        cell = SICell;
    }
    else
    {
        if (indexPath.row == 0)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.text = @"Powered By 自强学堂网";
        }
        else
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.text = @"ziqiang.net";
        }
        
    }
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView
titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return @"用户名和密码会自动保存，若想清除数据，清空用户名一栏即可";
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"校园网用户信息";
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView
shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return YES;
    }
    return NO;
}

- (IBAction)closeSettingView:(id)sender
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIView *firstResponder = [keyWindow performSelector:@selector(firstResponder)];
    [firstResponder resignFirstResponder];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.username forKey:@"myWLANUsername"];
    [userDefaults synchronize];
    if (![self.username isEqualToString:@""]) {
        [STKeychain storeUsername:self.username
                      andPassword:self.password
                   forServiceName:@"WHUWLAN"
                   updateExisting:YES
                            error:nil];
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)finishEditing:(UITapGestureRecognizer *)sender
{
    CGPoint tapLocation = [sender locationInView:self.myTableView];
    NSIndexPath *indexPath = [self.myTableView indexPathForRowAtPoint:tapLocation];
    if (!indexPath) {
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        UIView *firstResponder = [keyWindow performSelector:@selector(firstResponder)];
        [firstResponder resignFirstResponder];
    }
}

#pragma mark initialize
- (void)setup
{
    NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
    NSString *myUsername = [userDefaultes stringForKey:@"myWLANUsername"];
    self.username = myUsername;
    self.password = [STKeychain getPasswordForUsername:myUsername andServiceName:@"WHUWLAN" error:nil];
    
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
