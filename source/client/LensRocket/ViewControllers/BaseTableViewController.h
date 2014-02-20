//
//  BaseTableViewController.h
//  LensRocket
//
//  Created by Chris Risner on 9/24/13.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableViewController : UITableViewController

@property (nonatomic, strong) LensRocketService* lensRocketService;

-(void)setWhiteBackButton;
-(void)setWhiteForwardButton;

@end
