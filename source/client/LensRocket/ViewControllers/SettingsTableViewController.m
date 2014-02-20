//
//  SettingsTableViewController.m
//  LensRocket
//
//  Created by Chris Risner on 1/23/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "Util.h"
#import "EditEmailViewController.h"

#define EMAIL_ROW_NUMBER 3

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

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
    
    [self setWhiteBackButton];
    self.navigationController.navigationBar.barTintColor = [LensRocketConstants darkGreyColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [self.tableView setBackgroundColor:[LensRocketConstants darkGreyColor]];
}

- (void) popViewController{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return 5;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 16;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [super tableView:tableView
                       cellForRowAtIndexPath:indexPath];
    
    if (indexPath.item == 0 || indexPath.item == 5
        || indexPath.item == 7 || indexPath.item == 9
        || indexPath.item == 13) {
        UILabel *lblHeader = (UILabel*)[cell viewWithTag:1];
        lblHeader.textColor = [LensRocketConstants darkGreyColor];
        [cell setBackgroundColor:[LensRocketConstants greyColor]];
    }
    if (indexPath.item == 1) {
        UILabel *lblUsername = (UILabel*)[cell viewWithTag:2];
        lblUsername.text = self.lensRocketService.username;
    }
    else if (indexPath.item == EMAIL_ROW_NUMBER) {
        UILabel *lblEmail = (UILabel*)[cell viewWithTag:2];
        lblEmail.text = self.lensRocketService.email;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.item) {
        case 15:
            //Logoout
            [Util showYesNoAlertViewWithTitle:@"Are you sure you want to logout?" withMessage:@"Are you sure you want to logout?" withDelegate:self];
            break;
            
        default:
            break;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //Log the user out
//        [self dismissViewControllerAnimated:NO completion:nil];
//        [self.navigationController popToRootViewControllerAnimated:NO];
        [self performSegueWithIdentifier:@"resetSegue" sender:self];
    } else if (buttonIndex == 1) {
        //They picked no, do nothing
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editEmailSegue"]) {
        EditEmailViewController *vc = segue.destinationViewController;
        vc.parent = self;
    }
}

-(void)updateEmailTo:(NSString *)newEmail {
//    [Util displayOkDialogWithTitle:@"Change" andMessage:@"email"];
    if ([Util IsValidEmail:newEmail]) {
        UITableViewCell *emailCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:EMAIL_ROW_NUMBER inSection:0]];
        UILabel *lblEmail = (UILabel*)[emailCell viewWithTag:2];
        lblEmail.text = @"Updating...";
        NSMutableDictionary *newPreferences = [self.lensRocketService.userPreferences mutableCopy];
        [newPreferences setValue:newEmail forKey:@"email"];
        [self.lensRocketService updatePreferences:newPreferences withCompletion:^(BOOL successful, NSString *info) {
            if (!successful) {
                [Util displayOkDialogWithTitle:@"Error" andMessage:info];
                lblEmail.text = self.lensRocketService.email;
            } else {
                lblEmail.text = newEmail;
            }
        }];
    } else {
        [Util displayOkDialogWithTitle:@"Error" andMessage:@"The email address you have entered is not valid."];

    }
}

@end
