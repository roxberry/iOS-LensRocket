//
//  SplashScreenViewController.h
//  LensRocket
//
//  Created by Chris Risner on 8/28/13.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "BaseViewController.h"

@interface SplashScreenViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIButton *btnSignup;
- (IBAction)tappedLogin:(id)sender;
- (IBAction)tappedSignup:(id)sender;

@end
