//
//  UIView+Extensions.m
//  LensRocket
//
//  Created by Chris Risner on 9/25/13.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "UIView+Extensions.h"

@implementation UIView (Extensions)

-(UIView *)findFirstResponder {
    if (self.isFirstResponder) {
        return self;
    }
    for (UIView *subView in self.subviews) {
        UIView *view = [subView findFirstResponder];
        if (view)
            return view;
    }
    return nil;
}
-(void)forceResignFirstResponder {
    UIView *view = [self findFirstResponder];
    if (view)
        [view resignFirstResponder];
}

@end
