//
//  LoggingHandler.m
//  LensRocket
//
//  Created by Chris Risner on 10/1/13.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "LoggingHandler.h"

@implementation LoggingHandler

+(void)logError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

@end
