//
//  SelectFriendsTableViewController.h
//  LensRocket
//
//  Created by Chris Risner on 2/4/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "BaseViewController.h"

@interface SelectFriendsTableViewController : BaseViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSString *replyToUserId;
@property (strong, nonatomic) NSString *replyToUsername;
@end
