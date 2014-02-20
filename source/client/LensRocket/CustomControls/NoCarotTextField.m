//
//  NoCarotTextField.m
//  LensRocket
//
//  Created by Chris Risner on 9/25/13.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "NoCarotTextField.h"

@implementation NoCarotTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//Hides the cursor by making it clear
-(CGRect)caretRectForPosition:(UITextPosition *)position {
    return CGRectZero;
}


@end
