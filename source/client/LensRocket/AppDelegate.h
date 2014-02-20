//
//  AppDelegate.h
//  LensRocket
//
//  Created by Chris Risner on 1/8/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) LensRocketService *lensRocketService;

@end
