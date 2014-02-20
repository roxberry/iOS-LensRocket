//
//  CameraViewController.h
//  LensRocket
//
//  Created by Chris Risner on 1/13/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "BaseViewController.h"

@class CameraViewController;

@protocol CameraOverlayDelegate <NSObject>

-(IBAction)changeCamera:(id)sender;
-(IBAction)changeFlash:(id)sender;
-(IBAction)takePicture:(id)sender;
-(IBAction)goToFriendsList:(id)sender;
-(IBAction)goToRocketsList:(id)sender;
-(IBAction)holdTakePicture:(id)sender;
-(IBAction)backFromReply:(id)sender;

@end

@interface CameraViewController : BaseViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnFlash;
@property (weak, nonatomic) IBOutlet UIButton *btnSwitchCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnFriendsList;
@property (weak, nonatomic) IBOutlet UIButton *btnRocketsList;
@property (weak, nonatomic) IBOutlet UIButton *btnBackReply;
@property (weak, nonatomic) id <CameraOverlayDelegate> delegate;

@end
