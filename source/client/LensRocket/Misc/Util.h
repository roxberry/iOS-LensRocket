//
//  Util.h
//  LensRocket
//
//  Created by Chris Risner on 9/25/13.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewController.h"

@interface Util : NSObject

extern NSString * const UUID_STRING;

+ (NSString *) generateUUID;

+(void)displayOkDialogWithTitle:(NSString *)title andMessage:(NSString *)message;
+(void)displayOkDialogWithTitle:(NSString *)title andMessage:(NSString *)message andCompletion:(CompletionBlock) completion;

+ (BOOL)validateEmailWithString:(NSString*)email;
+ (BOOL)validateUsername:(NSString*)username;

+ (UIAlertView *)showYesNoAlertViewWithTitle:(NSString *)title withMessage:(NSString *)message withDelegate:(UIViewController *)delegate;

+(NSString *)urlEncoded:(NSString *) input;

+(BOOL) IsValidEmail:(NSString *)checkString;

@end
