//
//  ReviewRocketViewController.m
//  LensRocket
//
//  Created by Chris Risner on 1/13/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "ReviewRocketViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SelectFriendsTableViewController.h"

@interface ReviewRocketViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) MPMoviePlayerController *player;
@property (weak, nonatomic) IBOutlet UIButton *btnTime;
@property (nonatomic) int seconds;
@end

@implementation ReviewRocketViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)tappedClose:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)tappedSend:(id)sender {
    NSLog(@"Tapped send");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.seconds = 3;
    self.lensRocketService.secondsForShare = 3;
}
- (IBAction)tappedTime:(id)sender {
    NSLog(@"Tapped time");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
         delegate:self
        cancelButtonTitle:@"Cancel"
       destructiveButtonTitle:nil
        otherButtonTitles:@"1 second", @"2 seconds", @"3 seconds", @"4 seconds", @"5 seconds", @"6 seconds", @"7 seconds", @"8 seconds", @"9 seconds", @"10 seconds", nil];
    [actionSheet showInView:self.view];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    //NSLog(@"CLicked button %i", buttonIndex);
    self.seconds = buttonIndex + 1;
    self.lensRocketService.secondsForShare = self.seconds;
    //self.btnTime.titleLabel.text = [NSString stringWithFormat:@"%i", self.seconds];
    [self.btnTime setTitle:[NSString stringWithFormat:@"%i", self.seconds] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setImage:(UIImage *)image {
    [self.imgView setImage:image];
    NSLog(@"Setting image");
    self.lensRocketService.isSharingPicture = YES;
    self.lensRocketService.sharingImage = image;
    self.lensRocketService.isSharingVideo = NO;
    self.lensRocketService.sharingMovieUrl = nil;
    
    //UIImageView *imgView = [[UIImageView alloc] initWithImage:image];
    //imgView.frame = self.view.frame;
    //[self.view addSubview:imgView];
}

-(void)setVideo:(NSURL *)videoUrl {

    //NSURL *movieUrl = [NSURL fileURLWithPath:videoUrl];
    //MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:movieUrl];
    self.player = [[MPMoviePlayerController alloc] init];
    [self.player setContentURL:videoUrl];
    //self.player.repeatMode = MPMovieRepeatModeOne;

    [self.player.view setFrame:CGRectMake (0, 0, 320, 480)];
//    [self.view addSubview:self.player.view];
    
    [self.view insertSubview:self.player.view atIndex:0];
//    [self presentMoviePlayerViewControllerAnimated:player];
//    [self.player setFullscreen:YES animated:NO];
    [self.player setControlStyle:MPMovieControlStyleNone];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateChange:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:self.player];
    
    
    [self.player setScalingMode:MPMovieScalingModeAspectFill];
    [self.player prepareToPlay];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.player];
//    [self.player setRepeatMode:MPMovieRepeatModeOne];
    [self.player play];
    self.imgView.hidden = YES;
    
    self.lensRocketService.isSharingPicture = NO;
    self.lensRocketService.sharingImage = nil;
    self.lensRocketService.isSharingVideo = YES;
    self.lensRocketService.sharingMovieUrl = videoUrl;
    
}

-(void)moviePlayBackDidFinish:(NSNotification *)notification {
    //NSLog(@"Movie did finish");
    [self.player stop];
//    [self.player prepareToPlay];
//    [self.player setCurrentPlaybackTime:0];
//    [self.player setInitialPlaybackTime:0];
    [self.player play];
}

-(void) stateChange {
    NSLog(@"State chagne 1");
}

-(void) stateChange:(NSDictionary *)info {
    NSLog(@"State chagne");
}


- (void) hidecontrol {
    NSLog(@"Hide control");
    //[[NSNotificationCenter defaultCenter] removeObserver:self     name:MPMoviePlayerNowPlayingMovieDidChangeNotification object:self.player];
    //[self.player setControlStyle:MPMovieControlStyleNone];
    [self.player setRepeatMode:MPMovieRepeatModeOne];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Review prepareforsegue");
    SelectFriendsTableViewController *vc = [segue destinationViewController];
    vc.replyToUserId = self.replyToUserId;
    vc.replyToUsername = self.replyToUsername;
}

@end
