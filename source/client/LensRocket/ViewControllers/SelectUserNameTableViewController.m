//
//  SelectUserNameTableViewController.m
//  LensRocket
//
//  Created by Chris Risner on 1/8/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "SelectUserNameTableViewController.h"
#import "UIView+Extensions.h"

@interface SelectUserNameTableViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UIButton *btnEnter;
@property (nonatomic) BOOL showingEnterButton;
@end

@implementation SelectUserNameTableViewController

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
    
    [self.tableView setBackgroundColor:[LensRocketConstants darkGreyColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.btnEnter setBackgroundColor:[LensRocketConstants enterButtonColorNormal]];
    self.navigationItem.hidesBackButton = YES;
    self.tableView.scrollEnabled = NO;
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

- (IBAction)tappedEnter:(id)sender {
    [self.view forceResignFirstResponder];
    
    //Show the activity indicator
    [self.btnEnter setHidden:YES];
    [self.activityIndicator startAnimating];
    [self.lensRocketService saveUsername:self.txtUsername.text withCompletion:^(ResponseType type, id response) {
        if (type == kResponseTypeFail) {
            [self.btnEnter setHidden:NO];
            [self.activityIndicator stopAnimating];
            [Util displayOkDialogWithTitle:@"Error" andMessage:[response objectForKey:@"Error"]];
            [self hideEnterButton];
        } else if (type == kresponseTypeSuccess) {
            [self performSegueWithIdentifier:@"pushAccessFriendsSegue" sender:self];
        }
    }];
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (range.location == newString.length && range.length == newString.length)
        newString = @"";
    if (textField == self.txtUsername)
        [self checkForCompletionWithUsername:newString];
    return YES;
}

-(void)checkForCompletionWithUsername:(NSString *)username{
    if (username.length > 3) {
        [self hideEnterButton];
    } else {
        if (self.showingEnterButton) {
            [self animateButtonOut];
            [self.btnEnter setEnabled:NO];
            self.showingEnterButton = NO;
        }
    }
}

-(void)hideEnterButton {
    if (!self.showingEnterButton) {
        [self animateButtonIn];
        [self.btnEnter setEnabled:YES];
        self.showingEnterButton = YES;
    }
}


@end
