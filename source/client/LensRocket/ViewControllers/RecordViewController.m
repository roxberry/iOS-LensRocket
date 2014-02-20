//
//  RecordViewController.m
//  LensRocket
//
//  Created by Chris Risner on 1/10/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "RecordViewController.h"
#import "CameraViewController.h"
#import "ReviewRocketViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface RecordViewController ()

@property (nonatomic) BOOL frontCameraSelected;
@property (nonatomic) BOOL rearCameraSelected;
@property (nonatomic) BOOL flashOn;
@property (nonatomic) BOOL isPictureTaken;
@property (strong, nonatomic) CameraViewController *overlayViewController;

@end

@implementation RecordViewController

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
    
    //UIImagePickerController *camera = [[UIImagePickerController alloc] init];
    //camera.sourceType = UIImagePickerControllerSourceTypeCamera;
    //[self addChildViewController:camera];
    //[self presentViewController:camera animated:NO completion:nil];
    self.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.toolbarHidden = YES;
    self.navigationBarHidden = YES;
    self.showsCameraControls = NO;
    self.isPictureTaken = NO;
    self.cameraViewTransform = CGAffineTransformScale(self.cameraViewTransform, 1, 1.12412);
    
    [self loadOverlay];
    self.frontCameraSelected = NO;
    self.rearCameraSelected = YES;
    self.flashOn = NO;
    self.delegate = self;
    [self setFlashOn:NO];
    self.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    
    self.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, kUTTypeImage, nil];
    self.videoQuality =

    UIImagePickerControllerQualityType640x480;
    //UIImagePickerControllerQualityTypeHigh;
    self.videoMaximumDuration = 10;
    
    //Register for push notifications
    [[LensRocketService getInstance] registerForPushNotifications];
}

-(void)loadOverlay {
//    UIView *overlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
//    
//    //Flash
//    UIImage *flash = [UIImage imageNamed:@"flashoff.png"];
//    UIImageView *flashView = [[UIImageView alloc] initWithImage:flash];
//    flashView.frame = CGRectMake(10, 10, 50, 25);
//    [overlayView addSubview:flashView];
//    
//    //Flip Camera
//    UIImage *flipImage = [UIImage imageNamed:@"flipcamera.png"];
//    UIImageView *flipView = [[UIImageView alloc] initWithImage:flipImage];
//    flipView.frame = CGRectMake(270, 10, 44, 30);
////    [overlayView addSubview:flipView];
//    UIButton *btnFlip = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btnFlip setBackgroundImage:flipImage forState:UIControlStateNormal];
//    btnFlip.frame = CGRectMake(270, 10, 44, 30);
//    [overlayView addSubview:btnFlip];
    
   // [btnFlip addTarget:self action:@selector(tappedReverseCamera:) forControlEvents:UIControlEventTouchUpInside];
    
    

    //self.cameraOverlayView = overlayView;
    
    self.overlayViewController = [[CameraViewController alloc] initWithNibName:@"CameraViewController" bundle:nil];
    self.overlayViewController.delegate = self;
//    [overlay.btnSwitchCamera addTarget:self action:@selector(changeFlash) forControlEvents:UIControlEventTouchUpInside];
    self.cameraOverlayView = self.overlayViewController.view;
}

-(IBAction)changeCamera:(id)sender {
    NSLog(@"Change camera");
    if (self.frontCameraSelected) {
        self.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        self.rearCameraSelected = YES;
        self.frontCameraSelected = NO;
    } else if (self.rearCameraSelected) {
        self.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        self.rearCameraSelected = NO;
        self.frontCameraSelected = YES;
    }

}

-(IBAction)changeFlash:(id)sender {
    NSLog(@"Change flash");
    if (self.flashOn) {
        self.flashOn = NO;
        [self setFlashOn:NO];
        self.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        [self.overlayViewController.btnFlash setImage:[UIImage imageNamed:@"flashoff.png"] forState:UIControlStateNormal];
    } else {
        self.flashOn = YES;
        [self setFlashOn:YES];
        self.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        [self.overlayViewController.btnFlash setImage:[UIImage imageNamed:@"flashon.png"] forState:UIControlStateNormal];
    }
}

-(IBAction)takePicture:(id)sender {
    self.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    self.isPictureTaken = YES;
    [self takePicture];
}

-(IBAction)holdTakePicture:(id)sender {
    UIGestureRecognizer *recog = (UIGestureRecognizer *)sender;
    if (recog.state == 1) {
        self.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        NSLog(@"Video capture start");
        if (![self startVideoCapture]) {
            NSLog(@"Issue starting video capture");
            [Util displayOkDialogWithTitle:@"Error" andMessage:@"There was an issue starting recording.  Please try again."];
        }
        self.isPictureTaken = YES;
    } else if (recog.state == 3) {
        NSLog(@"Video capture end");
        [self stopVideoCapture];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"Finished picking");
    
    NSString *pickedMediaType = info[UIImagePickerControllerMediaType];
    if ([pickedMediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *movieUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        ReviewRocketViewController *reviewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"reviewRocketViewController"];
        reviewVC.replyToUserId = self.replyToUserId;
        reviewVC.replyToUsername = self.replyToUsername;
        NSLog(@"MovieUrl: %@", movieUrl);
        //[reviewVC setImage:inImage];
        [self presentViewController:reviewVC animated:NO completion:^{
            [reviewVC setVideo:movieUrl];
        }];

    } else if ([pickedMediaType isEqualToString:(NSString *)kUTTypeImage]) {
        NSLog(@"image taken: %@", info);
        NSLog(@"image URL: %@", [info valueForKey:UIImagePickerControllerMediaURL]);
        UIImage *pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        ReviewRocketViewController *reviewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"reviewRocketViewController"];
        reviewVC.replyToUserId = self.replyToUserId;
        reviewVC.replyToUsername = self.replyToUsername;
        //[reviewVC setImage:inImage];
        [self presentViewController:reviewVC animated:NO completion:^{
            [reviewVC setImage:pickedImage];
        }];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)inImage
                  editingInfo:(NSDictionary *)editingInfo {
//    myImage = inImage;
//    myImageView.image = myImage;
//    
//    // Get rid of the picker interface
//    [[picker parentViewController]
//     dismissModalViewControllerAnimated:YES];
//    [picker release];
    
//    UIImageView *imgView = [[UIImageView alloc] initWithImage:inImage];
//    imgView.frame = self.view.frame;
//    [self.view addSubview:imgView];
    
    ReviewRocketViewController *reviewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"reviewRocketViewController"];
    //[reviewVC setImage:inImage];
    [self presentViewController:reviewVC animated:NO completion:^{
        [reviewVC setImage:inImage];
    }];
    
    
}

-(NSInteger)getPageIndex {
    return self.pageIndex;
}

-(void)setPageIndexToValue:(NSInteger) value {
    self.pageIndex = value;
}

-(IBAction)goToFriendsList:(id)sender {
    //NSLog(@"go to friends list");
    //self.pagesViewController.pageViewController setViewControllers:<#(NSArray *)#> direction:<#(UIPageViewControllerNavigationDirection)#> animated:<#(BOOL)#> completion:<#^(BOOL finished)completion#>
    
//    UIViewController *startingViewController = [self viewControllerAtIndex:1];
//    NSArray *viewControllers = @[startingViewController];
//    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward | UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    
    UIViewController *viewController = [self.pagesViewController viewControllerAtIndex:2];
    NSArray *viewControllers = @[viewController];
    [self.pagesViewController.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward  animated:YES completion:nil];
    self.pagesViewController.currentIndex = 2;
}

-(IBAction)goToRocketsList:(id)sender {
    UIViewController *viewController = [self.pagesViewController viewControllerAtIndex:0];
    NSArray *viewControllers = @[viewController];
    [self.pagesViewController.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse  animated:YES completion:nil];
    self.pagesViewController.currentIndex = 0;
}

-(IBAction)backFromReply:(id)sender {
    [self goToRocketsList:sender];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isPictureTaken = NO;
    if (self.isReplying) {
        NSLog(@"IsReplying");
        self.overlayViewController.btnFriendsList.hidden = YES;
        self.overlayViewController.btnRocketsList.hidden = YES;
        self.overlayViewController.btnBackReply.hidden = NO;
    } else {
        NSLog(@"IsNotReplying");
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"View dis");
    
    //Backing out of replying, change back to normal capture mode
    if (self.isReplying && !self.isPictureTaken) {
        self.replyToUserId = nil;
        self.replyToUsername = nil;
        self.overlayViewController.btnFriendsList.hidden = NO;
        self.overlayViewController.btnRocketsList.hidden = NO;
        self.overlayViewController.btnBackReply.hidden = YES;
        self.isReplying = NO;
    }
}

@end
