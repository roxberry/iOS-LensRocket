//
//  SettingsTableViewController.h
//  LensRocket
//
//  Created by Chris Risner on 1/23/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "BaseTableViewController.h"

@interface SettingsTableViewController : BaseTableViewController <UIAlertViewDelegate>

-(void)updateEmailTo:(NSString *)newEmail;

@end
