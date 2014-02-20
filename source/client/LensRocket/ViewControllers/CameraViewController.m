//
//  CameraViewController.m
//  LensRocket
//
//  Created by Chris Risner on 1/13/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController ()


@end

@implementation CameraViewController

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
    // Do any additional setup after loading the view from its nib.
    
    [self.btnSwitchCamera addTarget:self.delegate action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnFlash addTarget:self.delegate action:@selector(changeFlash:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnCamera addTarget:self.delegate action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnBackReply addTarget:self.delegate action:@selector(backFromReply:) forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer *tapAndHold = [[UILongPressGestureRecognizer alloc] initWithTarget:self.delegate action:@selector(holdTakePicture:)];
    [tapAndHold setMinimumPressDuration:0.4];
    [self.btnCamera addGestureRecognizer:tapAndHold];
    
    [self.btnFriendsList addTarget:self.delegate action:@selector(goToFriendsList:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnRocketsList addTarget:self.delegate action:@selector(goToRocketsList:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
