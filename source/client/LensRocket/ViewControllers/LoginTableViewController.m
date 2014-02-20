//
//  LoginTableViewController.m
//  LensRocket
//
//  Created by Chris Risner on 1/10/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "LoginTableViewController.h"
#import "UIView+Extensions.h"

@interface LoginTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnEnter;
@property (nonatomic) BOOL showingEnterButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LoginTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBar.barTintColor = [LensRocketConstants darkGreyColor];
    [self.tableView setBackgroundColor:[LensRocketConstants darkGreyColor]];
    
    //This removes the empty cells from the bottom of the view
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self setWhiteBackButton];
    
    self.tableView.scrollEnabled = NO;
    
    [self.btnEnter setBackgroundColor:[LensRocketConstants enterButtonColorNormal]];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView
                       cellForRowAtIndexPath:indexPath];
    return cell;
}

-(void)hideEnterButton {
    if (self.showingEnterButton) {
        [self animateButtonOut];
        [self.btnEnter setEnabled:NO];
        self.showingEnterButton = NO;
    }
}

-(void)animateButtonIn {
    CGPoint newButtonCenter = CGPointMake( self.btnEnter.frame.size.width / 2.0f, self.btnEnter.center.y);
    
    [UIView animateWithDuration:1.0
                          delay:0.2 options:0 animations:^{
                              self.btnEnter.center = newButtonCenter;
                          } completion:^(BOOL finished) {
                          }];
}

-(void)animateButtonOut {
    CGPoint newButtonCenter = CGPointMake(  self.btnEnter.frame.size.width / 2.0f- 350 , self.btnEnter.center.y);
    
    [UIView animateWithDuration:1.0
                          delay:0 options:0 animations:^{
                              self.btnEnter.center = newButtonCenter;
                          } completion:^(BOOL finished) {
                          }];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.txtUsername) {
        [self.txtPassword becomeFirstResponder];
        
    }
    if (textField == self.txtPassword) {
        [textField resignFirstResponder];
    }
    return NO;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
   
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (range.location == newString.length && range.length == newString.length)
        newString = @"";
    if (textField == self.txtUsername)
        [self checkForCompletionWithUsernameEmail:newString andPassword:self.txtPassword.text];
    else if (textField == self.txtPassword)
        [self checkForCompletionWithUsernameEmail:self.txtUsername.text andPassword:newString];
    
    return YES;
}



-(void)checkForCompletionWithUsernameEmail:(NSString *)usernameEmail andPassword:(NSString *)password{
    if ([usernameEmail isEqualToString:@""] ||
        [password isEqualToString:@""]) {
        [self hideEnterButton];
    } else if (!self.showingEnterButton) {
        [self animateButtonIn];
        self.showingEnterButton = YES;
        [self.btnEnter setEnabled:YES];
    }
}

- (IBAction)tappedEnter:(id)sender {
    //Make sure our keyboard / date picker is gone
    [self.view forceResignFirstResponder];
    
    //Show the activity indicator
    [self.btnEnter setHidden:YES];
    [self.activityIndicator startAnimating];
    
    [self.lensRocketService loginWithUsernameEmail:self.txtUsername.text andPassword:self.txtPassword.text andCompletion:^(ResponseType type, id response) {
        if (type == kResponseTypeFail) {
            [self.btnEnter setHidden:NO];
            [self.activityIndicator stopAnimating];
            
            [Util displayOkDialogWithTitle:@"Error" andMessage:[response objectForKey:@"Error"]];
            [self hideEnterButton];
            
        } else if (type == kresponseTypeSuccess) {
            [self.lensRocketService getFriendsFromServer];
            [self.lensRocketService getRocketsFromServer];
            [self.lensRocketService getUserPreferences];
            [self performSegueWithIdentifier:@"modalRecordSegue" sender:self];
        }
    }];
}

@end
