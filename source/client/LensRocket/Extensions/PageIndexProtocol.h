//
//  PageIndexProtocol.h
//  LensRocket
//
//  Created by Chris Risner on 1/17/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PagesViewController.h"

@protocol PageIndexProtocol <NSObject>
//@property NSInteger pageIndex;
-(NSInteger)getPageIndex;
-(void)setPageIndexToValue:(NSInteger) value;
-(void)setPagesViewController:(PagesViewController *) pagesViewController;
@end
