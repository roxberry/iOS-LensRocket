//
//  RecordViewController.h
//  LensRocket
//
//  Created by Chris Risner on 1/10/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "BaseViewController.h"
#import "CameraViewController.h"
#import "PageIndexProtocol.h"
#import "PagesViewController.h"

@interface RecordViewController : //BaseViewController
UIImagePickerController <CameraOverlayDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PageIndexProtocol>
@property NSInteger pageIndex;
@property (strong, nonatomic) PagesViewController *pagesViewController;
@property (strong, nonatomic) NSString *replyToUserId;
@property (strong, nonatomic) NSString *replyToUsername;
@property (nonatomic) bool isReplying;

-(NSInteger)getPageIndex;
-(void)setPageIndexToValue:(NSInteger) value;

@end
