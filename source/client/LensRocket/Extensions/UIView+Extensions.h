//
//  UIView+Extensions.h
//  LensRocket
//
//  Created by Chris Risner on 9/25/13.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extensions)

-(UIView *)findFirstResponder;
-(void)forceResignFirstResponder;

@end
