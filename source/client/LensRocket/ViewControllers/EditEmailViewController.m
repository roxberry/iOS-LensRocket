//
//  EditEmailViewController.m
//  LensRocket
//
//  Created by Chris Risner on 1/27/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "EditEmailViewController.h"

@interface EditEmailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtEmailAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblInfo1;
@property (weak, nonatomic) IBOutlet UILabel *lblInfo2;

@end

@implementation EditEmailViewController

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
    [self setWhiteBackButton];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.view setBackgroundColor:[LensRocketConstants darkGreyColor]];
    
    self.txtEmailAddress.text = self.lensRocketService.email;
    
//    self.lblInfo1.textColor = [LensRocketConstants toolbarGreenColor];
//    self.lblInfo2.textColor = [LensRocketConstants toolbarGreenColor];
//    self.txtEmailAddress    .textColor = [LensRocketConstants toolbarGreenColor];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) popViewController{
    if (![self.lensRocketService.email isEqualToString:self.txtEmailAddress.text]) {
        //Email address change has been attempted
        [self.parent updateEmailTo:self.txtEmailAddress.text];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
