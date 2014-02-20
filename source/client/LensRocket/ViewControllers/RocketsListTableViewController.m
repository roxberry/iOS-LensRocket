//
//  LensRocketTableViewController.m
//  LensRocket
//
//  Created by Chris Risner on 1/17/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "RocketsListTableViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "RecordViewController.h"

@interface RocketsListTableViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl* refreshControl;
@property (strong, nonatomic) UIView *viewImageOverlay;
@property (strong, nonatomic) MPMoviePlayerController *player;
@property (strong, nonatomic) NSMutableDictionary *timerTracker;

@end

@implementation RocketsListTableViewController

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
    
    self.navBar.barTintColor = [LensRocketConstants darkGreyColor];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [LensRocketConstants darkGreyColor];
    [self addRefreshControl];
    
    //If we've already started pulling our rockets list from
    //the server but don't have a callback, set one
    if (self.lensRocketService.isFetchingRockets) {// &&
//        !self.lensRocketService.getRocketsCallback) {
        //Start refreshing
        [self triggerRefreshUI];
        //Set callback
//        __weak typeof(self) weakSelf = self;
//        self.lensRocketService.getRocketsCallback = ^(BOOL successful, NSString *info) {
//            [weakSelf handleGetRocketsCallbackWithSuccessful:successful andInfo:info];
//        };
    }
    
    //Set up Gestures
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:doubleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 2.0;
    longPress.delegate = self;
    [self.tableView addGestureRecognizer:longPress];
    
    self.timerTracker = [[NSMutableDictionary alloc] init];
    
    //Subscribe to refresh notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerRefreshUI) name:@"triggerRefreshUIRockets" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRocketPull) name:@"handleRocketPull" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)getPageIndex {
    return self.pageIndex;
}

-(void)setPageIndexToValue:(NSInteger) value {
    self.pageIndex = value;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    if (self.lensRocketService.isSendingRocket) {
        //Start refreshing
        [self triggerRefreshUI];
        //Set callback
        __weak typeof(self) weakSelf = self;
        self.lensRocketService.sendingRocketCallback = ^(BOOL successful, NSString *info) {
            [weakSelf handleSendRocketCallbackWithSuccessful:successful andInfo:info];
        };
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)addRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)onRefresh:(id) sender
{
    [self refresh];
}

- (void) refresh {
    [self.lensRocketService getRocketsFromServer];
}

-(void)handleRocketPull {
    NSLog(@"HandleRocketPull");
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

-(void)handleSendRocketCallbackWithSuccessful:(BOOL) successful andInfo:(NSString *) info{
    NSLog(@"Send Rocket callback");
//    [self.refreshControl endRefreshing];

    
    if (successful) {
        [self triggerRefreshUI];
        [self refresh];
    } else {
        [Util displayOkDialogWithTitle:@"Error" andMessage:info];
    }
}

- (IBAction)tappedCamera:(id)sender {
    UIViewController *viewController = [self.pagesViewController viewControllerAtIndex:1];
    NSArray *viewControllers = @[viewController];
    [self.pagesViewController.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward  animated:YES completion:nil];
    self.pagesViewController.currentIndex = 1;
}

- (IBAction)tappedSettings:(id)sender {
    NSLog(@"Tapped settings");
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.lensRocketService.rockets count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSDictionary *rocket = [self.lensRocketService.rockets objectAtIndex:indexPath.item];
    
    UILabel *lblFromName = (UILabel *)[cell viewWithTag:1];
    lblFromName.text = [rocket objectForKey:@"fromUsername"];
    
    UILabel *lblDate = (UILabel *)[cell viewWithTag:2];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterMediumStyle;
    //NSDateFormatterMediumStyle;    
    lblDate.text = [NSString stringWithFormat:@"%@",
                    [df stringFromDate:[rocket objectForKey:@"createDate"]]];
    
    NSString *imageName = @"";

    UILabel *lblInstructions = (UILabel *)[cell viewWithTag:4];
    NSString *rocketType = [rocket objectForKey:@"type"];
    if ([rocketType isEqualToString:@"FriendRequest"]) {
        if ([[rocket objectForKey:@"userHasSeen"] boolValue]) {
            lblInstructions.text = @" - Friend request accepted";
            imageName = @"rocket_accepted_friend_request";
        } else {
            lblInstructions.text = @" - Press and hold to accept";
            imageName = @"rocket_friend_request";
        }
    } else if ([rocketType isEqualToString:@"Rocket"]) {
        if ([[rocket objectForKey:@"userHasSeen"] boolValue]) {
            lblInstructions.text = @" - Double tap to reply";
            imageName = @"rocket_seen";
        } else {
            lblInstructions.text = @" - Press and hold to view";
            imageName = @"rocket_not_seen";
        }
    } else if ([rocketType isEqualToString:@"SENT"]) {
        if ([[rocket objectForKey:@"allUsersHaveSeen"] boolValue]) {
            lblInstructions.text = @"- Opened";
            imageName = @"rocket_sent_and_seen_message";
        } else {
            imageName = @"rocket_sent_message";
            if ([[rocket objectForKey:@"delivered"] boolValue]) {
                lblInstructions.text = @" - Delivered";
            } else {
                lblInstructions.text = @" - Sending";
            }
        }
    }
    UIImageView *icon = (UIImageView *)[cell viewWithTag:3];
    UIImage *image = [UIImage imageNamed:imageName];
    [icon setImage:image];
    
    return cell;
}

-(IBAction)goToRocketsList:(UIStoryboardSegue *)segue {
    NSLog(@"gotorocketslist!");
}

//Ensures the row is deselected / unhighlighted
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)dismissPictureOrMovie {
    if (self.viewImageOverlay) {
        [self.viewImageOverlay removeFromSuperview];
        self.viewImageOverlay = nil;
    } else if (self.player) {
        [self.player.view removeFromSuperview];
        [self.player stop];
        self.player = nil;
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        NSLog(@"state: %i", gestureRecognizer.state);
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            [self dismissPictureOrMovie];
        }
        return;
    }
    
    NSLog(@"Long Press");
    
    CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"Long Press index: %i", indexPath.item);
 //   NSLog(@"Long Press cell: %@", cell);
    NSDictionary *rocket = [self.lensRocketService.rockets objectAtIndex:indexPath.item];
    NSString *rocketType = [rocket objectForKey:@"type"];
    if ([rocketType isEqualToString:@"FriendRequest"]) {
        if ([[rocket objectForKey:@"userHasSeen"] boolValue]) {
            //Do nothing, they've already seen it
        } else {
            //Accept friend request
            [self.lensRocketService acceptFriendRequestWithRocket:rocket andCompletion:^(BOOL successful, NSString *info) {
                if (!successful) {
                    [Util displayOkDialogWithTitle:@"Error" andMessage:info];
                } else {
                    //Trigger refresh
                    [self triggerRefreshUI];
                    [self refresh];
                    UILabel *lblInstructions = (UILabel *)[cell viewWithTag:4];
                    UIImageView *icon = (UIImageView *)[cell viewWithTag:3];
                    lblInstructions.text = @" - Friend request accepted";
                    NSString *imageName = @"rocket_accepted_friend_request";
                    UIImage *image = [UIImage imageNamed:imageName];
                    [icon setImage:image];
                }
            }];
        }
    } else if ([rocketType isEqualToString:@"Rocket"]) {
        if ([[rocket objectForKey:@"userHasSeen"] boolValue]) {
            //Do nothing, they've already seen it
        } else {
            //get rocket, display and start countdown
            [self.lensRocketService getRocketFileForRecipientFromRocket:rocket andCompletion:^(ResponseType type, id response) {
                if (type == kResponseTypeFail) {
                    [Util displayOkDialogWithTitle:@"Error" andMessage:response];
                } else {
                    //RocketFile received successfully
                    //Get Time To Live
                    NSString *timeToLive = [[rocket objectForKey:@"timeToLive"] stringValue];

                    NSMutableDictionary *cellValues = [[NSMutableDictionary alloc] initWithDictionary:@{
                             @"index" : indexPath,
                             @"timeToLive" : [rocket objectForKey:@"timeToLive"]
                     }];
                    UILabel *lblTimer = (UILabel *)[cell viewWithTag:5];
                    bool isTimerAlreadyStartedForCell = NO;

                    NSString *indexPathString = [NSString stringWithFormat:@"%i", [indexPath item]];
                    if ([self.timerTracker objectForKey:indexPathString])
                        isTimerAlreadyStartedForCell = YES;
                    //Load data
                    if ([[rocket objectForKey:@"isPicture"] boolValue]) {
                        NSString *pictureUrl = [response objectForKey:@"RocketUrl"];
                        UIImage *rocketImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:pictureUrl]]];
                        self.viewImageOverlay = [[UIView alloc] initWithFrame:self.view.frame];
                        self.viewImageOverlay.backgroundColor = [UIColor blackColor];
                        UIImageView *imgView = [[UIImageView alloc] initWithImage:rocketImage];
                        //Match frame so image is full screen
                        imgView.frame = self.view.frame;
                        [self.viewImageOverlay addSubview:imgView];
                        [self.view.window addSubview:self.viewImageOverlay];
                        if (!isTimerAlreadyStartedForCell) {
                            [self.timerTracker setValue:@YES forKey:indexPathString];
                            lblTimer.text = timeToLive;
                            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:cellValues repeats:YES];
                        }

                    } else if ([[rocket objectForKey:@"isVideo"] boolValue]) {
                        NSURL *videoUrl = [NSURL URLWithString:[response objectForKey:@"RocketUrl"]];
                        self.player = [[MPMoviePlayerController alloc] initWithContentURL:videoUrl];
                        [self.player.view setFrame:self.view.frame];
                        [self.view.window addSubview:self.player.view];
                        [self.player setControlStyle:MPMovieControlStyleNone];
                        [self.player setScalingMode:MPMovieScalingModeAspectFill];
                        [self.player prepareToPlay];
                        [[NSNotificationCenter defaultCenter] addObserver:self
                             selector:@selector(moviePlayBackDidFinish:)
                             name:MPMoviePlayerPlaybackDidFinishNotification
                           object:self.player];
                        [self.player play];
                        if (!isTimerAlreadyStartedForCell) {
                            [self.timerTracker setValue:@YES forKey:indexPathString];
                            lblTimer.text = timeToLive;
                            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:cellValues repeats:YES];
                        }
                    }
                }
            }];
        }
    }
}

-(void)handleTimer:(NSTimer *)timer {
    NSLog(@"Timer");
    NSMutableDictionary *cellValues = (NSMutableDictionary *) [timer userInfo];
    int time = [[cellValues objectForKey:@"timeToLive"] intValue];
    time--;
    NSNumber *currentTime = [NSNumber numberWithInteger:time];
    NSIndexPath *indexPath = [cellValues objectForKey:@"index"];
    
    //Get cell and timer label
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UILabel *lblTimer = (UILabel *)[cell viewWithTag:5];
    
    if ([currentTime intValue] == 0) {
        [timer invalidate];
        if (self.viewImageOverlay) {
            [self.viewImageOverlay removeFromSuperview];
            self.viewImageOverlay = nil;
        } else if (self.player) {
            [self.player.view removeFromSuperview];
            [self.player stop];
            self.player = nil;
        }
        //Clear timer
        NSString *indexPathString = [NSString stringWithFormat:@"%i", [(NSIndexPath *)indexPath item]];
        [self.timerTracker removeObjectForKey:indexPathString];
        
        //Clear the timer label
        lblTimer.text = @"";
        
        //Set the image indicator
        UILabel *lblInstructions = (UILabel *)[cell viewWithTag:4];
        lblInstructions.text = @" - Double tap to reply";
        UIImageView *icon = (UIImageView *)[cell viewWithTag:3];
        UIImage *image = [UIImage imageNamed:@"rocket_seen"];
        [icon setImage:image];
        
        //Update Rocket locally
        NSDictionary *rocket = [self.lensRocketService.rockets objectAtIndex:indexPath.item];
        NSMutableDictionary *mutableRocket = [rocket mutableCopy];
        [mutableRocket setValue:@YES forKey:@"userHasSeen"];
        NSMutableArray *mutableRockets = (NSMutableArray *)self.lensRocketService.rockets;
        [mutableRockets replaceObjectAtIndex:[indexPath item] withObject:mutableRocket];
        
        return;
    }
    
    NSString *timeToLive = [currentTime stringValue];
    lblTimer.text = timeToLive;
    
    [cellValues setValue:currentTime forKey:@"timeToLive"];

    
}

-(void)moviePlayBackDidFinish:(NSNotification *)notification {
    //NSLog(@"Movie did finish");
    [self.player stop];
    //    [self.player prepareToPlay];
    //    [self.player setCurrentPlaybackTime:0];
    //    [self.player setInitialPlaybackTime:0];
    [self.player play];
}

-(void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer {
    NSLog(@"Double Tap");
    CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"Tapped index: %i", indexPath.item);
//    NSLog(@"Tapped cell: %@", cell);
    NSDictionary *rocket = [self.lensRocketService.rockets objectAtIndex:indexPath.item];
    if ([[rocket objectForKey:@"type"] isEqualToString:@"Rocket"]) {
        if ([[rocket objectForKey:@"userHasSeen"] boolValue]) {
            NSLog(@"Start the reply!");
            UIViewController *viewController = [self.pagesViewController viewControllerAtIndex:1];
            NSArray *viewControllers = @[viewController];
            [self.pagesViewController.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward  animated:YES completion:nil];
            self.pagesViewController.currentIndex = 1;
            
            RecordViewController *recordVC = (RecordViewController *) viewController;
            recordVC.isReplying = YES;
            recordVC.replyToUserId = [rocket objectForKey:@"fromUserId"];
            recordVC.replyToUsername = [rocket objectForKey:@"fromUsername"];
        }
    }
}

-(void)triggerRefreshUI {
    if (![self.refreshControl isRefreshing]) {
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [self.refreshControl beginRefreshing];
        NSLog(@"Begin refresh");
    }
}

-(void)triggerRefresh {
    [self refresh];
    [self triggerRefreshUI];
}

@end
