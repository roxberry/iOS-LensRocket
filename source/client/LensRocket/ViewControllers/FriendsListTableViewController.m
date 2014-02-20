//
//  FriendsListTableViewController.m
//  LensRocket
//
//  Created by Chris Risner on 1/17/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "FriendsListTableViewController.h"
#import "TallNavBar.h"

@interface FriendsListTableViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl* refreshControl;
@property (strong, nonatomic) UIButton* btnAddFriend;
@property (strong, nonatomic) NSString* searchText;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong)   NSArray *selectedFriends;
@property (nonatomic) bool searchNameInList;

@end

@implementation FriendsListTableViewController

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

    [self addRefreshControl];
    //[self.navBar setBounds:CGRectMake(0, 0, 320, 120)];
    //[self.navBar setFrame:CGRectMake(0, 0, 320, 120)];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [LensRocketConstants darkGreyColor];
    
    self.searchBar.barTintColor = [LensRocketConstants darkGreyColor];
    
    //If we've already started pulling our friends list from
    //the server but don't have a callback, set one
    if (self.lensRocketService.isFetchingFriends) { //&&
        [self triggerRefreshUI];
//        !self.lensRocketService.getFriendsCallback) {
//        __weak typeof(self) weakSelf = self;
//        self.lensRocketService.getFriendsCallback = ^(BOOL successful, NSString *info) {
//            [weakSelf handleGetFriendsCallbackWithSuccessful:successful andInfo:info];
//        };
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

-(NSInteger)getPageIndex {
    return self.pageIndex;
}

-(void)setPageIndexToValue:(NSInteger) value {
    self.pageIndex = value;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
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
    [self.lensRocketService getFriendsFromServer];
}

//-(void)handleGetFriendsCallbackWithSuccessful:(BOOL) successful andInfo:(NSString *) info{
//    [self.refreshControl endRefreshing];
//    [self.tableView reloadData];
//    if (!successful) {
//        [Util displayOkDialogWithTitle:@"Error" andMessage:info];
//    }
//}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.searchText length] == 0) {
        self.selectedFriends = self.lensRocketService.friends;
        return [self.lensRocketService.friends count];
    }
    
    NSArray *friends = self.lensRocketService.friends;
    //Presetting this to 1 to account for our search/add friend row
    int count = 1;
    self.selectedFriends = [[NSMutableArray alloc] init];
    
    for (NSDictionary *friend in friends) {
        NSString *name = [friend objectForKey:@"toUsername"];
        name = [name lowercaseString];
        if ([name hasPrefix:self.searchText]) {
            count++;
            [((NSMutableArray *)self.selectedFriends) addObject:friend];
            if ([name isEqualToString:self.searchText]) {
                self.searchNameInList = YES;
                count--; //Remove the row for adding friend
            }
        }
    }
    return count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.item < [self.selectedFriends count]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
        NSDictionary *friend = [self.selectedFriends objectAtIndex:indexPath.item];
        
        UILabel *lblName = (UILabel *)[cell viewWithTag:1];
        lblName.text = [friend objectForKey:@"toUsername"];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"AddFriend"];
        UILabel *lblAddName = (UILabel *)[cell viewWithTag:1];
        lblAddName.text = [@"Add " stringByAppendingString:self.searchBar.text];
        self.btnAddFriend = (UIButton *)[cell viewWithTag:2];
        [self.btnAddFriend addTarget:self action:@selector(tappedAddFriend) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

-(void)tappedAddFriend {
    self.btnAddFriend.enabled = NO;
    [self.searchBar setUserInteractionEnabled:NO];
    
    __weak typeof(self) weakSelf = self;
    [self.lensRocketService addFriendWithName:self.searchText andCompletion:^(BOOL successful, NSString *info) {
        if (successful) {
            [Util displayOkDialogWithTitle:@"Success" andMessage:info];
            weakSelf.searchBar.text = @"";
            [weakSelf searchBar:weakSelf.searchBar textDidChange:@""];

            //-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
        } else {
            [Util displayOkDialogWithTitle:@"Error" andMessage:info];
            weakSelf.btnAddFriend.enabled = YES;
            [weakSelf.searchBar setUserInteractionEnabled:YES];
        }
    }];
}

- (IBAction)tappedCamera:(id)sender {
    
    UIViewController *viewController = [self.pagesViewController viewControllerAtIndex:1];
    NSArray *viewControllers = @[viewController];
    [self.pagesViewController.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse  animated:YES completion:nil];
    self.pagesViewController.currentIndex = 1;
}

- (IBAction)tappedPerson:(id)sender {
    NSLog(@"Tapped person");    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.searchNameInList = NO;
    self.searchText = [searchText lowercaseString];
    [self.tableView reloadData];
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
