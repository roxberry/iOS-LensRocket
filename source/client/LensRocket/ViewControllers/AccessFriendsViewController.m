//
//  AccessFriendsViewController.m
//  LensRocket
//
//  Created by Chris Risner on 1/10/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "AccessFriendsViewController.h"

@interface AccessFriendsViewController ()

@end

@implementation AccessFriendsViewController

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
    
    [self setWhiteForwardButton];
        self.navigationItem.hidesBackButton = YES;
    
//    self.navigationItem.rightBarButtonItem.target = 
//    UIButton *forwardButton = [self.navigationItem.rightBarButtonItem];
    //[self.navigationItem.rightBarButtonItem ]
     //   [backButton addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
    
    /*
     UIButton *backButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 44.0f, 30.0f)];
     [backButton setImage:[UIImage imageNamed:@"back.png"]  forState:UIControlStateNormal];
     [backButton addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
     self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
     */
}

-(void) tappedForwardButton {
    [self performSegueWithIdentifier:@"modalRecordSegue" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (IBAction)tappedAllowAccess:(id)sender {
    [Util displayOkDialogWithTitle:@"Oops" andMessage:@"This feature is not yet enabled."];
}

@end
