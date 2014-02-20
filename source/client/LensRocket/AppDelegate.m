//
//  AppDelegate.m
//  LensRocket
//
//  Created by Chris Risner on 1/8/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "AppDelegate.h"
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
//                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName, nil]];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    
    self.lensRocketService = [LensRocketService getInstance];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    NSLog(@"appWillResign");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"appDidEnterBack");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"appWilLEnterFore");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        NSLog(@"ApppDidBecomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"appWillTerminate");
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *) deviceToken {
    
    self.lensRocketService.pushToken = deviceToken;
    if ([self.lensRocketService isUserAuthenticated]) {
        [self.lensRocketService registerForPushNotifications];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification: (NSDictionary *)userInfo {
    NSLog(@"%@", userInfo);
    NSRange inRange = [[[userInfo objectForKey:@"aps"] valueForKey:@"alert"] rangeOfString:@"rocket"];
    if (inRange.location != NSNotFound) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"triggerRefreshUIRockets" object:nil];
        [self.lensRocketService getRocketsFromServer];
    } else {
        inRange = [[[userInfo objectForKey:@"aps"] valueForKey:@"alert"] rangeOfString:@"Friend"];
        if (inRange.location != NSNotFound) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"triggerRefreshUIRockets" object:nil];
            [self.lensRocketService getRocketsFromServer];
        } else {
            //Just show an alert if this was a different type of push
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notification" message:
                                  [[userInfo objectForKey:@"aps"] valueForKey:@"alert"] delegate:nil cancelButtonTitle:
                                  @"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    
}

@end
