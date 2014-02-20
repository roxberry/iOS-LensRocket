//
//  Util.m
//  LensRocket
//
//  Created by Chris Risner on 9/25/13.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "Util.h"
#import <QuartzCore/QuartzCore.h>
#import "UIAlertView+Block.h"
#import "BaseViewController.h"

@implementation Util

NSString * const UUID_STRING = @"UUID_STRING";
NSString * const USER_NAME = @"USER_NAME";

/*
 Checks to see if this device needs to generate a unique ID.  Stores it
 to NSUserDefaults if generated.
 */
+ (NSString *) generateUUID {
    NSString *UUID = [[NSUserDefaults standardUserDefaults] objectForKey:UUID_STRING];
    if (!UUID)
    {
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef string = CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);
        UUID = [(__bridge NSString*)string stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [[NSUserDefaults standardUserDefaults] setValue:UUID forKey:UUID_STRING];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return UUID;
}

+(void)rememberUsername:(NSString *)username {
    [[NSUserDefaults standardUserDefaults] setValue:username forKey:USER_NAME];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getUsername{
    return [[NSUserDefaults standardUserDefaults] valueForKey:USER_NAME];
}

+(void)displayOkDialogWithTitle:(NSString *)title andMessage:(NSString *)message{
    [Util displayOkDialogWithTitle:title andMessage:message andCompletion:nil];
}

+(void)displayOkDialogWithTitle:(NSString *)title andMessage:(NSString *)message  andCompletion:(CompletionBlock) completion{
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(title, nil)
    //                message:NSLocalizedString(message, nil)
    //               delegate:nil
    //              cancelButtonTitle:NSLocalizedString(@"OK", nil)
    //              otherButtonTitles:nil];
    //    [alert show];
    
    UIAlertView *alert = [UIAlertView alertViewWithTitle:title message:message cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil onDismiss:nil onCancel:^() {
        if (completion)
            completion();
    }];
    [alert show];
    
}

+ (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)validateUsername:(NSString*)username {
    if ([username isEqualToString:@""])
        return NO;
    return YES;
}

+ (UIAlertView *)showYesNoAlertViewWithTitle:(NSString *)title withMessage:(NSString *)message withDelegate:(UIViewController *)delegate {
    UIAlertView *alert = [[UIAlertView alloc] init];
	[alert setTitle:title];
	[alert setMessage:message];

	[alert setDelegate:delegate];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	[alert show];
    return alert;
}

+(NSString *)urlEncoded:(NSString *) input
{
    CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(
                                                                    NULL,
                                                                    (CFStringRef)input,
                                                                    NULL,
                                                                    (CFStringRef)@"!*'\"();:@&=+$,/?%#[]%. ",
                                                                    kCFStringEncodingUTF8 );
    return (__bridge NSString *)urlString;
}


//From SO: http://stackoverflow.com/questions/3139619/check-that-an-email-address-is-valid-on-ios
+(BOOL) IsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end
