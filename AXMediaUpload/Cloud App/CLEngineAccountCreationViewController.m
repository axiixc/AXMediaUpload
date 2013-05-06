//
//  CLEngineAccountCreationViewController.m
//  Firefly
//
//  Created by James Savage on 1/2/13.
//  Copyright (c) 2013 axiixc.com. All rights reserved.
//

#import "CLEngineAccountCreationViewController.h"
#import "CLEngine.h"

@interface CLEngineAccountCreationViewController ()
<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    UITextField * _usernameField;
    UITextField * _passwordField;

    UIButton * _accountCreationButton;
}

@property (nonatomic, strong) CLEngine * engine;
@property (nonatomic, strong) UITableView * tableView;

@end

@implementation CLEngineAccountCreationViewController

- (id)initWithEngine:(CLEngine *)engine;
{
    if ((self = [super init]))
    {
        self.engine = engine;
        self.navigationItem.title = [[CLEngine serviceDescription] serviceName];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    return self;
}

- (void)loadView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.view = self.tableView;
}

- (void)viewDidLoad
{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"std"];
    self.tableView.alwaysBounceVertical = NO;
    
    _usernameField = [[UITextField alloc] init];
    _usernameField.placeholder = @"email@example.com";
    _usernameField.borderStyle = UITextBorderStyleNone;
    _usernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _usernameField.keyboardType = UIKeyboardTypeEmailAddress;
    _usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    [_usernameField addTarget:self action:@selector(_updateDoneButton:) forControlEvents:UIControlEventEditingChanged];
    
    _passwordField = [[UITextField alloc] init];
    _passwordField.placeholder = @"password";
    _passwordField.borderStyle = UITextBorderStyleNone;
    _passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _passwordField.secureTextEntry = YES;
    [_passwordField addTarget:self action:@selector(_updateDoneButton:) forControlEvents:UIControlEventEditingChanged];
    
    _accountCreationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_accountCreationButton setTitle:@"Need an account?" forState:UIControlStateNormal];
    [_accountCreationButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_accountCreationButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_accountCreationButton addTarget:self action:@selector(_doAccountCreate:) forControlEvents:UIControlEventTouchUpInside];
    _accountCreationButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_usernameField becomeFirstResponder];
}

#pragma mark - User Interface Actions

- (void)commitServiceCreation:(id)sender
{
//    [self.engine
//     testUsername:_usernameField.text
//     password:_passwordField.text
//     onVerificationComplete:^(BOOL success) {
//         if (success)
//             return [super commitServiceCreation:sender];
//         
//         [[[UIAlertView alloc]
//           initWithTitle:NSLocalizedString(@"Invalid Login", nil)
//           message:nil
//           delegate:nil
//           cancelButtonTitle:NSLocalizedString(@"Try Again", nil)
//           otherButtonTitles:nil] show];
//     }];
}

- (void)_doAccountCreate:(id)sender;
{
//    NSString * urlString = [NSString stringWithFormat:@"http://%@/register", self.engine.readonlyHostName];
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)_updateDoneButton:(id)sender;
{
    self.navigationItem.rightBarButtonItem.enabled = (!AXIsEmptyString(_usernameField.text) && !AXIsEmptyString(_passwordField.text));
}

#pragma mark - UITableView Delegate/DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"std"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.contentView.subviews enumerateObjectsUsingBlock:^(UIView * view, NSUInteger idx, BOOL *stop) {
        [view removeFromSuperview];
    }];
    
    CGRect rect = CGRectMake(10, 0, 280, 44);
    
    if (indexPath.row == 0)
    {
        [cell.contentView addSubview:_usernameField];
        _usernameField.frame = rect;
    }
    else if (indexPath.row == 1)
    {
        [cell.contentView addSubview:_passwordField];
        _passwordField.frame = rect;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        [_usernameField becomeFirstResponder];
    }
    else if (indexPath.row == 1)
    {
        [_passwordField becomeFirstResponder];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return _accountCreationButton;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 44;
}

@end
