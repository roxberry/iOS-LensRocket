//
//  PrivacyPolicyViewController.m
//  LensRocket
//
//  Created by Chris Risner on 2/14/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "PrivacyPolicyViewController.h"

@interface PrivacyPolicyViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation PrivacyPolicyViewController

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
    
    [self.view setBackgroundColor:[LensRocketConstants dullGreenColor]];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    NSURL *websiteUrl = [NSURL URLWithString:PRIVACY_POLICY_URL];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:websiteUrl];
    [self.webView loadRequest:urlRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

@end
