//
//  SignUpTableViewController.m
//  LensRocket
//
//  Created by Chris Risner on 9/24/13.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "SignUpTableViewController.h"
#import "UIView+Extensions.h"
#import "SelectUserNameTableViewController.h"

@interface SignUpTableViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webViewDisclaimer;
@property (weak, nonatomic) IBOutlet UITextField *txtEmailAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtBirthday;
@property (weak, nonatomic) IBOutlet UIButton *btnEnter;
@property (strong, nonatomic) NSString *dob;
- (IBAction)tappedEnter:(id)sender;

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIPopoverController *popOverForDatePicker;
@property (strong, nonatomic) UIActionSheet *aac;

@property (nonatomic) BOOL showingEnterButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SignUpTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [LensRocketConstants darkGreyColor];

    [self setWhiteBackButton];
    self.showingEnterButton = NO;
    
    [self.tableView setBackgroundColor:[LensRocketConstants darkGreyColor]];

//    NSString *test = @"<center><span style='font:family: Helvetica-Neue; font-size: 12;'>By creating an account, you agree to the Terms of Use and you acknowledge that you have read the <a href='http://chrisrisner.com'>Privacy Policy</a>.</span></center>";
    
    NSString *disclaimerText = [NSString stringWithFormat:@"<center><span style='font:family: Helvetica-Neue; font-size: 12;color:white;'>By creating an account, you agree to the <a href='%@'>Terms of Use</a> and you acknowledge that you have read the <a href='%@'>Privacy Policy</a>.</span></center>", TERMS_AND_CONDITIONS_URL, PRIVACY_POLICY_URL];
    [self.webViewDisclaimer loadHTMLString:disclaimerText baseURL:nil];
    self.webViewDisclaimer.scrollView.scrollEnabled = NO;
    self.webViewDisclaimer.delegate = self;


    
    //This removes the empty cells from the bottom of the view
//    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 140)];
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [self setDatePickerAsEditorForBirthday];
    
    [self.btnEnter setBackgroundColor:[LensRocketConstants enterButtonColorNormal]];
    
//    self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width, self.tableView.contentSize.height + 300);
}

//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleBlackOpaque;
//}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request  navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString * requestString=[[request URL] absoluteString];
    //NSLog(@"%@ is requestString from clicking",requestString );
    
    //if ([[[request URL] absoluteString] hasPrefix:@"http://www.google"]) {
    NSRange privacyRange = [requestString rangeOfString:@"privacy"];
    NSRange termsRange = [requestString rangeOfString:@"terms"];
    if (privacyRange.location != NSNotFound) {
        [self performSegueWithIdentifier:@"pushPrivacyPolicySegue" sender:self];
        return NO;
    } else if (termsRange.location != NSNotFound) {
        [self performSegueWithIdentifier:@"pushTermsSegue" sender:self];
        return NO;
    }
    return YES;
//        [[UIApplication sharedApplication] openURL:[request URL]];
        
        
    //}
//    return TRUE;
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView
                       cellForRowAtIndexPath:indexPath];
    return cell;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.txtEmailAddress) {
        [self.txtPassword becomeFirstResponder];
        
    }
    if (textField == self.txtPassword) {
        //[textField resignFirstResponder];
        [self.txtBirthday becomeFirstResponder];
    }
    return NO;
}

-(void)animateButtonIn {
    CGPoint newLeftCenter = CGPointMake( 350.0f + self.webViewDisclaimer.frame.size.width / 2.0f, self.webViewDisclaimer.center.y);
    CGPoint newButtonCenter = CGPointMake( self.btnEnter.frame.size.width / 2.0f, self.btnEnter.center.y);
    
    [UIView animateWithDuration:1.0
                          delay:0.0 options:0 animations:^{
                              self.webViewDisclaimer.center = newLeftCenter;
                          } completion:^(BOOL finished) {
                          }];
    
    [UIView animateWithDuration:1.0
                          delay:0.2 options:0 animations:^{
                              self.btnEnter.center = newButtonCenter;
                          } completion:^(BOOL finished) {
                          }];
}

-(void)animateButtonOut {
    CGPoint newLeftCenter = CGPointMake(  self.webViewDisclaimer.frame.size.width / 2.0f, self.webViewDisclaimer.center.y);
    CGPoint newButtonCenter = CGPointMake(  self.btnEnter.frame.size.width / 2.0f- 350 , self.btnEnter.center.y);
    
    [UIView animateWithDuration:1.0
                          delay:0.2 options:0 animations:^{
                              self.webViewDisclaimer.center = newLeftCenter;
                          } completion:^(BOOL finished) {
                          }];
    
    [UIView animateWithDuration:1.0
                          delay:0 options:0 animations:^{
                              self.btnEnter.center = newButtonCenter;
                          } completion:^(BOOL finished) {
                          }];
}


-(void)setDatePickerAsEditorForBirthday {
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, 44.0, 0.0, 0.0)];
    self.datePicker.datePickerMode=UIDatePickerModeDate;
    self.datePicker.backgroundColor = [UIColor whiteColor];
    
    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate]; // Get necessary date components

    [components setMonth:12];
    [components setDay:31];
    
    [self.datePicker setMaximumDate:[calendar dateFromComponents:components]];
    [self.datePicker setDate:[calendar dateFromComponents:components]];
    
    [components setMonth:1];
    [components setDay:1];
    [components setYear:1920];
    [self.datePicker setMinimumDate:[calendar dateFromComponents:components]];
    [self.txtBirthday setInputView:self.datePicker];
    

    [self.datePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
    
    //Set recognzier for tap on date picker
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pickerViewTapped:)];
    [recognizer setNumberOfTapsRequired:1];
    [recognizer setCancelsTouchesInView:NO];
    [recognizer setDelaysTouchesBegan:NO];
    [recognizer setDelaysTouchesEnded:NO];
    [self.datePicker addGestureRecognizer:recognizer];
}

//Hide date picker
-(IBAction)pickerViewTapped:(UITapGestureRecognizer *)sender {
    [self.txtBirthday resignFirstResponder];
}

-(void)dateChanged{//:(id)sender {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterMediumStyle;
    //NSDateFormatterMediumStyle;
    self.txtBirthday.text = [NSString stringWithFormat:@"%@",
                      [df stringFromDate:self.datePicker.date]];
    
    [self checkForCompletionWithEmail:self.txtEmailAddress.text andPassword:self.txtPassword.text];
    
    //Get DOB in proper format
    [df setDateFormat:@"MM/dd/yyyy"];
    self.dob = [NSString stringWithFormat:@"%@",
                     [df stringFromDate:self.datePicker.date]];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.txtBirthday)
        return NO;
    else {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (range.location == newString.length && range.length == newString.length)
            newString = @"";
        if (textField == self.txtEmailAddress)
            [self checkForCompletionWithEmail:newString andPassword:self.txtPassword.text];
        else if (textField == self.txtPassword)
            [self checkForCompletionWithEmail:self.txtEmailAddress.text andPassword:newString];
    }
    return YES;
}



-(void)checkForCompletionWithEmail:(NSString *)email andPassword:(NSString *)password{
    if ([email isEqualToString:@""] ||
        [password isEqualToString:@""] ||
        [self.txtBirthday.text isEqualToString:@""]) {
        [self hideEnterButton];
    } else if (!self.showingEnterButton) {
        [self animateButtonIn];
        self.showingEnterButton = YES;
        [self.btnEnter setEnabled:YES];
    }
}

-(void)hideEnterButton {
    if (self.showingEnterButton){
        [self animateButtonOut];
        self.showingEnterButton = NO;
        [self.btnEnter setEnabled:NO];
    }
}

- (IBAction)tappedEnter:(id)sender {
    //Make sure our keyboard / date picker is gone
    [self.view forceResignFirstResponder];
    
    //Check if date is in past
    NSDate *today = [NSDate date];
    NSComparisonResult result = [today compare:self.datePicker.date];
    if (result == NSOrderedAscending) {
        [Util displayOkDialogWithTitle:@"Oops" andMessage:@"Your birthday cannot be in the future!"];
        return;
    }
    
    
    //Show the activity indicator
    [self.btnEnter setHidden:YES];
    [self.activityIndicator startAnimating];
    
    [self.lensRocketService registerAccountWithEmail:self.txtEmailAddress.text andPassword:self.txtPassword.text andDob:self.dob andCompletion:^(ResponseType type, id response) {
        if (type == kResponseTypeFail) {
            [self.btnEnter setHidden:NO];
            [self.activityIndicator stopAnimating];
            
            //[Util displayOkDialogWithTitle:@"Error" andMessage:[response objectForKey:@"Error"]];
//            [self performSelector:@selector(showMessage) withObject:self afterDelay:0.5];
            //[self performSelector:@selector(showMessage) withObject:response afterDelay:0.2];
            [Util displayOkDialogWithTitle:@"Error" andMessage:[response objectForKey:@"Error"]];
            [self hideEnterButton];
            
        } else if (type == kresponseTypeSuccess) {

//            [self.navigationController performSegueWithIdentifier:@"pushSelectUsernameSegue" sender:self];
            [self performSegueWithIdentifier:@"pushSelectUsernameSegue" sender:self];
//            [self.navigationController popViewControllerAnimated:NO];
            //SelectUserNameTableViewController *viewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectUsernameViewController"];
            //[self.navigationController pushViewController:viewController animated:NO];
            //[self presentViewController:viewController animated:NO completion:nil];
        }
    }];
}
@end
