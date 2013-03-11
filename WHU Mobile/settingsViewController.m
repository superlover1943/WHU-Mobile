//
//  settingsViewController.m
//  testProject
//
//  Created by 黄 嘉恒 on 3/3/13.
//  Copyright (c) 2013 黄 嘉恒. All rights reserved.
//

#import "settingsViewController.h"
#import "StringInputTableViewCell.h"

@interface settingsViewController ()<UITableViewDataSource,StringInputTableViewCellDelegate,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (nonatomic,strong)NSString *username;
@property (nonatomic,strong)NSString *password;

@end

@implementation settingsViewController

- (void)tableViewCell:(StringInputTableViewCell *)cell didEndEditingWithString:(NSString *)value
{
    if (cell.tag == 100)
    {
        self.username = value;
        if ([value isEqualToString:@""]) {
            self.password = @"";
            ((StringInputTableViewCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1
                                                                                                    inSection:0]]).stringValue = @"";
        }
    }
        else if (cell.tag == 200)
        self.password = value;
}

- (void)tableViewCellDidClear:(StringInputTableViewCell *)cell
{
    if (cell.tag == 100) {
        ((StringInputTableViewCell *)[self.myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1
                                                                                                inSection:0]]).stringValue = @"";
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
            SICell.tag = 100;
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
            SICell.tag = 200;
            SICell.delegate = self;
            SICell.stringValue = self.password;
            SICell.textField.placeholder = @"Password";
            SICell.textField.secureTextEntry = YES;
            SICell.textField.returnKeyType = UIReturnKeyDone;
            SICell.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
            {
                SICell.textField.clearsOnInsertion = YES;
            }
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
            cell.textLabel.text = @"Ziqiang.net";
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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.username forKey:@"myWLANUsername"];
    [userDefaults setObject:(self.username? self.password:@"") forKey:@"myWLANPassword"];
    [userDefaults synchronize];
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
