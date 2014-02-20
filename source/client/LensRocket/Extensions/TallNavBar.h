//
//  TallNavBar.h
//  LensRocket
//
//  Created by Chris Risner on 1/20/14.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TallNavBar : UINavigationBar

- (CGSize)sizeThatFits:(CGSize)size;
-(void)setBounds:(CGRect)bounds;
@end
