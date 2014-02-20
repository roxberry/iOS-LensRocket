//
//  LoggingHandler.h
//  LensRocket
//
//  Created by Chris Risner on 10/1/13.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoggingHandler : NSObject

+(void)logError:(NSError *)error;

@end
