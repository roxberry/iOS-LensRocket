//
//  BaseViewController.h
//  LensRocket
//
//  Created by Chris Risner on 8/28/13.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LensRocketService.h"

@interface BaseViewController : UIViewController

@property (nonatomic, strong) LensRocketService* lensRocketService;

-(void)setWhiteBackButton;
-(void)setWhiteForwardButton;

@end
