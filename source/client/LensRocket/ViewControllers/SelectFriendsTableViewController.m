//
//  SelectFriendsTableViewController.m
//  LensRocket
//
//  Created by Chris Risner on 2/4/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "SelectFriendsTableViewController.h"
#import "TallNavBar.h"

@interface SelectFriendsTableViewController ()
@property (weak, nonatomic) IBOutlet TallNavBar *navBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl* refreshControl;
@property (weak, nonatomic) IBOutlet UIView *sendView;
@property (nonatomic) int friendsSelected;
@property (weak, nonatomic) IBOutlet UILabel *lblSendToNames;
@property (strong, nonatomic) NSMutableString *namesString;
@property (strong, nonatomic) NSMutableArray *selectedIds;
@property (strong, nonatomic) NSMutableArray *selectedNames;
@end

@implementation SelectFriendsTableViewController

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
    self.navBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [LensRocketConstants darkGreyColor];
    self.sendView.backgroundColor = [LensRocketConstants darkGreyColor];
//    self.sendView.frame = CGRectMake(0, 480, 320, 44);
    
    self.selectedIds = [[NSMutableArray alloc] init];
    self.selectedNames = [[NSMutableArray alloc] init];
    
    [self addRefreshControl];
    self.friendsSelected = 0;
    if (self.replyToUserId) {
        self.friendsSelected++;
//        self.selectedIds = [[NSMutableArray alloc] init];
//        self.selectedNames = [[NSMutableArray alloc] init];
        [self.selectedIds addObject:self.replyToUserId];
        [self.selectedNames addObject:self.replyToUsername];
        self.namesString = [[NSMutableString alloc] initWithString:self.replyToUsername];
        self.lblSendToNames.text = self.namesString;
    }
    
    //If we've already started pulling our friends list from
    //the server but don't have a callback, set one
    if (self.lensRocketService.isFetchingFriends) {// &&
//        !self.lensRocketService.getFriendsCallback) {
//        __weak typeof(self) weakSelf = self;
//        self.lensRocketService.getFriendsCallback = ^(BOOL successful, NSString *info) {
//            [weakSelf handleGetFriendsCallbackWithSuccessful:successful andInfo:info];
//        };
        [self triggerRefreshUI];
        
        
    }
    
    //Subscribe to refresh notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(triggerRefresh) name:@"triggerRefreshUIFriends" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFriendPull) name:@"handleFriendPull" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
//    [self.sendView setFrame:CGRectMake(0, 480, 320, 44)];
    
//    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
    
//    if (self.friendsSelected > 0) {
//        [self.sendView setFrame:CGRectMake(0, 480, 320, 44)];
//    }
    
    if (self.friendsSelected > 0) {
        [self performSelector:@selector(animateSendViewIn) withObject:self afterDelay:0.1];
//        [self buildSendToFriendsNames];
    }
    
    CGFloat heightOfYourTabBar = 44;
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, heightOfYourTabBar, 0);
    
    [self.tableView setContentInset:insets];
    [self.tableView setScrollIndicatorInsets:insets];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void) popViewController{
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (IBAction)tappedBack:(id)sender {
    [self popViewController];
}

- (BOOL) prefersStatusBarHidden {
    return NO;
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
    [self.lensRocketService getFriendsFromServer];
}

-(void)handleGetFriendsCallbackWithSuccessful:(BOOL) successful andInfo:(NSString *) info{
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
    if (!successful) {
        [Util displayOkDialogWithTitle:@"Error" andMessage:info];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return ([self.lensRocketService.friends count]);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSDictionary *friend = [self.lensRocketService.friends objectAtIndex:indexPath.item];
    
    UILabel *lblName = (UILabel *)[cell viewWithTag:1];
    lblName.text = [friend objectForKey:@"toUsername"];

    UISwitch *switchSend = (UISwitch *)[cell viewWithTag:2];
    [switchSend addTarget:self action:@selector(switchSendFriendWithSwitch:) forControlEvents:UIControlEventValueChanged];
    [switchSend setOn:NO];
    if (self.selectedIds) {
        if ([self.selectedIds containsObject:[friend objectForKey:@"toUserId"]]) {
            [switchSend setOn:YES];
        }
    }
    
    UILabel *lblID = (UILabel *) [cell viewWithTag:3];
    lblID.text = [friend objectForKey:@"toUserId"];
    
    return cell;
}

-(void)switchSendFriendWithSwitch:(UISwitch *)switchSend {
//    UITableViewCell *cell = (UITableViewCell *)switchSend.superview;
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    NSIndexPath *indexPathTwo = [self.tableView indexPathForCell:(UITableViewCell *)switchSend.superview.superview];
    
    CGPoint cellPosition = [switchSend convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:cellPosition];

    NSDictionary *friend = [self.lensRocketService.friends objectAtIndex:indexPath.item];
    
    if (switchSend.on) {
        //Check to make sure this wasn't a false tap / click
        if ([self.selectedIds containsObject:[friend objectForKey:@"toUserId"]]) {
            return;
        }
        
        self.friendsSelected++;
        NSLog(@"Add friend");
        if (self.friendsSelected == 1)
            [self animateSendViewIn];
//        [self buildSendToFriendsNames];
    } else {
        //Check to make sure this wasn't a false tap / click
        if (![self.selectedIds containsObject:[friend objectForKey:@"toUserId"]]) {
            return;
        }
        self.friendsSelected--;
        if (self.friendsSelected == 0)
            [self animateSendViewOut];
        NSLog(@"Subtract friend");
    }
    [self buildSendToFriendsNamesWithIndexPath:indexPath andStatus:switchSend.on forFriend:friend];
}

-(void)buildSendToFriendsNamesWithIndexPath:(NSIndexPath *)indexPath andStatus:(BOOL)status forFriend:(NSDictionary *)friend {
    self.namesString = [[NSMutableString alloc] init];
    //self.selectedIds = [[NSMutableArray alloc] init];

    if (!status) {
        //Remove name and ID
        [self.selectedIds removeObject:[friend objectForKey:@"toUserId"]];
        [self.selectedNames removeObject:[friend objectForKey:@"toUsername"]];
    } else {
        //add the ID
        [self.selectedIds addObject:[friend objectForKey:@"toUserId"]];
        [self.selectedNames addObject:[friend objectForKey:@"toUsername"]];
    }
    
    //Rebuild the send to string
    for (NSInteger i = 0; i < self.friendsSelected; i++) {
        if (![self.namesString isEqualToString:@""]) {
            [self.namesString appendString:@", "];
        }
        [self.namesString appendString:[self.selectedNames objectAtIndex:i]];
        
    }
    self.lblSendToNames.text = self.namesString;
    
//    for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:0]; i++) {
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
//        if (cell) {
//            UISwitch *switchSend = (UISwitch *)[cell viewWithTag:2];
//            if (switchSend.on) {
//                if (![self.namesString isEqualToString:@""]) {
//                    [self.namesString appendString:@", "];
//                }
//                UILabel *lblFriend = (UILabel *)[cell viewWithTag:1];
//                [self.namesString appendString:lblFriend.text];
//                UILabel *lblID = (UILabel *)[cell viewWithTag:3];
//                [self.selectedIds addObject:lblID.text];
//            }
//        }
//    }
//    self.lblSendToNames.text = self.namesString;
}

-(void)animateSendViewIn {
    
    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
        self.sendView.center = CGPointMake(self.view.frame.size.width / 2.0f, self.view.frame.size.height - 22.0f);
    } completion:^(BOOL finished) {
        
    }];
}

-(void)animateSendViewOut {
    
    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
        self.sendView.center = CGPointMake(self.view.frame.size.width / 2.0f, self.view.frame.size.height + 22.0f);
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)tappedSend:(id)sender {
    if (self.friendsSelected > 0) {
        NSLog(@"Sending!");
        [self.lensRocketService sendRocketToFriends:self.selectedIds withCompletion:^(BOOL successful, NSString *info) {
            NSLog(@"Completion handler");
        }];
        [self performSegueWithIdentifier:@"goToRocketsListSegue" sender:self];
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

-(void)handleFriendPull {
    NSLog(@"handleFriendPull");
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

@end
