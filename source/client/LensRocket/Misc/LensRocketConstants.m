//
//  LensRocketConstants.m
//  LensRocket
//
//  Created by Chris Risner on 8/28/13.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "LensRocketConstants.h"

@implementation LensRocketConstants

+(UIColor *) loginButtonColorNormal { return [UIColor colorWithRed:1.0 green:0.4 blue:0.0 alpha:1.0]; }
+(UIColor *) signupButtonColorNormal { return [UIColor colorWithRed:0.0 green:0.96 blue:1.0 alpha:1.0]; }
//+(UIColor *) enterButtonColorNormal { return [UIColor colorWithRed:0.36 green:0.62 blue:0.41 alpha:1.0]; }
+(UIColor *) enterButtonColorNormal { return [UIColor colorWithRed:0.2 green:0.72 blue:0.55 alpha:1.0]; }
//+(UIColor *) toolbarGreenColor { return [UIColor colorWithRed:0.2 green:0.72 blue:0.55 alpha:1.0]; }
+(UIColor *) toolbarGreenColor { return [UIColor colorWithRed:0.31 green:0.659 blue:0.522 alpha:1]; }
+(UIColor *) toolbarPurpleColor { return [UIColor colorWithRed:0.53 green:0.42 blue:0.59 alpha:1.0]; } //
+(UIColor *) dullYellowColor { return [UIColor colorWithRed:1.0 green:0.74 blue:0.26 alpha:1.0]; }
+(UIColor *) dullGreenColor { return [UIColor colorWithRed:0.753 green:0.851 blue:0.78 alpha:1]; }
+(UIColor *) darkGreyColor { return [UIColor colorWithRed:0.255 green:0.263 blue:0.267 alpha:1]; /*#414344*/  }
+(UIColor *) greyColor { return [UIColor colorWithRed:0.392 green:0.404 blue:0.408 alpha:1]; /*#646768*/ }


+ (UIColor *)darkerColorForColor:(UIColor *)c
{
    float r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.2, 0.0)
                               green:MAX(g - 0.2, 0.0)
                                blue:MAX(b - 0.2, 0.0)
                               alpha:a];
    return nil;
}

+ (UIColor *)lighterColorForColor:(UIColor *)c
{
    float r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + 0.2, 1.0)
                               green:MIN(g + 0.2, 1.0)
                                blue:MIN(b + 0.2, 1.0)
                               alpha:a];
    return nil;
}



@end
