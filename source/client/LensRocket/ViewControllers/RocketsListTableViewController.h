//
//  LensRocketTableViewController.h
//  LensRocket
//
//  Created by Chris Risner on 1/17/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "BaseViewController.h"
#import "PageIndexProtocol.h"
#import "PagesViewController.h"

@interface RocketsListTableViewController : BaseViewController <PageIndexProtocol, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
@property NSInteger pageIndex;
@property (strong, nonatomic) PagesViewController *pagesViewController;

-(NSInteger)getPageIndex;
-(void)setPageIndexToValue:(NSInteger) value;
@end
