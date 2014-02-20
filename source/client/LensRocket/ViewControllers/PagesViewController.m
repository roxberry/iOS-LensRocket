//
//  PagesViewController.m
//  LensRocket
//
//  Created by Chris Risner on 1/17/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "PagesViewController.h"
#import "PageIndexProtocol.h"
#import "FriendsListTableViewController.h"

@interface PagesViewController ()
    

@end

@implementation PagesViewController

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
    
    _pageTitles = @[@"RocketsList", @"Record", @"FriendsList"];
    _pageImages = @[@"RocketsList", @"Record", @"FriendsList"];
    
    self.currentIndex = 1;
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    UIViewController *startingViewController = [self viewControllerAtIndex:1];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward | UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
//    NSInteger index = ((PageContentViewController*) viewController).pageIndex;
    NSInteger index = [((id) viewController) getPageIndex];
    index -= 1;
//    int index = self.currentIndex - 1;
    if (index < 0)
        return nil;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    
    //int index = self.currentIndex + 1;
    NSInteger index = [((id) viewController) getPageIndex];
    index +=1;
    if (index > 2)
        return nil;

    return [self viewControllerAtIndex:index];
}

- (UIViewController *)viewControllerAtIndex:(int)index
{
//    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
//        return nil;
//    }
//    if (index < 0) {
//        index += 3;
//    } else if (index > 2) {
//        index -= 3;
//    }
    self.currentIndex = index;
    
    UIViewController *viewController;
    if (index == 1) {
        viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pageRecordViewController"];
        [((id)viewController) setPageIndexToValue:1];
        [((id)viewController) setPagesViewController:self];
    }
    else if (index == 0) {
        viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pageRocketsListViewController"];
        [((id)viewController) setPageIndexToValue:0];
        [((id)viewController) setPagesViewController:self];
    }
    else if (index == 2) {
        viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"pageFriendsListViewController"];
        [((id)viewController) setPageIndexToValue:2];
        [((id)viewController) setPagesViewController:self];        
    }
    
    
    return viewController;
}

@end
