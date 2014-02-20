//
//  ReviewRocketViewController.h
//  LensRocket
//
//  Created by Chris Risner on 1/13/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "BaseViewController.h"

@interface ReviewRocketViewController : BaseViewController <UIActionSheetDelegate>
@property (strong, nonatomic) NSString *replyToUserId;
@property (strong, nonatomic) NSString *replyToUsername;

-(void)setImage:(UIImage *)image;
-(void)setVideo:(NSURL *)videoUrl;
-(void)moviePlayBackDidFinish:(NSNotification *)notification;

@end
