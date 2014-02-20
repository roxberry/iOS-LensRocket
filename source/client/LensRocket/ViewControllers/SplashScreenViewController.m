//
//  SplashScreenViewController.m
//  LensRocket
//
//  Created by Chris Risner on 8/28/13.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "SplashScreenViewController.h"

@interface SplashScreenViewController ()

@end

@implementation SplashScreenViewController

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
    [self.btnLogin addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [self.btnLogin addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchUpInside];
    [self.btnSignup addTarget:self action:@selector(buttonHighlight:) forControlEvents:UIControlEventTouchDown];
    [self.btnSignup addTarget:self action:@selector(buttonNormal:) forControlEvents:UIControlEventTouchUpOutside | UIControlEventTouchUpInside];
    
//    [self.btnLogin setBackgroundColor:[LensRocketConstants loginButtonColorNormal]];
//    [self.btnSignup setBackgroundColor:[LensRocketConstants signupButtonColorNormal]];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    if ([self.lensRocketService isUserAuthenticated]) {
        [self.lensRocketService getFriendsFromServer];
        [self.lensRocketService getRocketsFromServer];
        [self.lensRocketService getUserPreferences];
        [self performSegueWithIdentifier:@"modalRecordSegue" sender:self];
    }
}

-(void) buttonHighlight:(UIButton *)sender {
//    [sender setBackgroundColor:[LensRocketConstants darkerColorForColor:[sender backgroundColor]]];
}

-(void) buttonNormal:(UIButton *)sender {
//    [sender setBackgroundColor:[LensRocketConstants lighterColorForColor:[sender backgroundColor]]];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tappedLogin:(id)sender {
    NSLog(@"Login");
}

- (IBAction)tappedSignup:(id)sender {
    NSLog(@"Signup");
}

-(IBAction)reset:(UIStoryboardSegue *)segue {
    //do stuff
    NSLog(@"RESET!");
    [self.lensRocketService killAuthInfo];
}

-(BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender {
    return YES;
}

-(void)viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

@end
