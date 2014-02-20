//
//  LensRocketService.m
//  PieTalk
//
//  Created by Chris Risner on 10/1/13.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import "LensRocketService.h"
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "KeychainWrapper.h"
#import <AFNetworking/AFNetworking.h>
#import "UIImage+Resize.h"
#import <AVFoundation/AVFoundation.h>
#import <WindowsAzureMessaging/WindowsAzureMessaging.h>

@interface LensRocketService()

@property (nonatomic)           NSInteger busyCount;
@property (nonatomic, strong)   NSString *version;
@property (nonatomic, strong)   NSString *build;
@property (nonatomic, assign)   BOOL isLogoutInProcess;

@property (nonatomic, assign)   BOOL isAuthenticated;

@property (nonatomic, strong)   MSTable *tableFriends;
@property (nonatomic, strong)   MSTable *tableRockets;
@property (nonatomic, strong)   MSTable *tableUserPreferences;
@property (nonatomic, strong)   MSTable *tableRocketFiles;

@end

@implementation LensRocketService

static LensRocketService *singletonInstance;

+ (LensRocketService*)getInstance{
    if (singletonInstance == nil) {
        singletonInstance = [[super alloc] init];
    }
    return singletonInstance;
}

-(LensRocketService *) init {
    // Initialize the Mobile Service client with your URL and key
    MSClient *newClient = [MSClient clientWithApplicationURLString:MOBILE_SERVICE_URL applicationKey:MOBILE_SERVICE_APPLICATION_KEY];
    
    // Add a Mobile Service filter to enable the busy indicator
    self.client = [newClient clientWithFilter:self];
    
    self.version = [Util urlEncoded:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    self.build = [Util urlEncoded:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    [self loadAuthInfo];
    self.busyCount = 0;
    
    self.tableFriends = [self.client tableWithName:@"Friends"];
    self.tableRockets = [self.client tableWithName:@"Messages"];
    self.tableUserPreferences = [self.client tableWithName:@"UserPreferences"];
    self.tableRocketFiles = [_client tableWithName:@"RocketFile"];
    self.friends = [[NSMutableArray alloc] init];
    self.rockets = [[NSMutableArray alloc] init];
    self.hasSentPushTokenToNotificationHubs = NO;
    
    return self;
}

-(void)killAuthInfo {
    NSLog(@"We should be deleting all of the user info here");
    [KeychainWrapper deleteItemFromKeychainWithIdentifier:@"userid"];
    [KeychainWrapper deleteItemFromKeychainWithIdentifier:@"token"];
    [KeychainWrapper deleteItemFromKeychainWithIdentifier:@"email"];
    [KeychainWrapper deleteItemFromKeychainWithIdentifier:@"username"];
    
    [self.client logout];
    for (NSHTTPCookie *value in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:value];
    }
    
    //Kill data
}

- (BOOL)isUserAuthenticated {
    return self.isAuthenticated;
}

- (void)saveAuthInfo{

    [KeychainWrapper createKeychainValue:self.client.currentUser.userId forIdentifier:@"userid"];
    [KeychainWrapper createKeychainValue:self.client.currentUser.mobileServiceAuthenticationToken forIdentifier:@"token"];
    [KeychainWrapper createKeychainValue:self.email forIdentifier:@"email"];
    [KeychainWrapper createKeychainValue:self.username forIdentifier:@"username"];
    self.isAuthenticated = YES;
}

- (void)loadAuthInfo {
    NSString *userid = [KeychainWrapper keychainStringFromMatchingIdentifier:@"userid"];
    if (userid) {
        NSLog(@"userid: %@", userid);
        self.client.currentUser = [[MSUser alloc] initWithUserId:userid];
        self.client.currentUser.mobileServiceAuthenticationToken = [KeychainWrapper keychainStringFromMatchingIdentifier:@"token"];
        self.email = [KeychainWrapper keychainStringFromMatchingIdentifier:@"email"];
        self.username = [KeychainWrapper keychainStringFromMatchingIdentifier:@"username"];
        self.isAuthenticated = YES;
    }
}

- (void) registerAccountWithEmail:(NSString *) email
                      andPassword:(NSString *) password
                           andDob:(NSString *) dob
                    andCompletion:(CompletionWithResponseTypeAndResponse) completion {

    NSDictionary *postValues = @{ @"email": email,
                            @"password": password,
                            @"dob" : dob };
//    NSDictionary *user = @{ @"members" : members};
    
    [self.client invokeAPI:@"Register" body:postValues HTTPMethod:@"POST" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Error %@", error);
        NSLog(@"result %@", result);
        NSLog(@"response %@", response);
        
        if (error || [result objectForKey:@"Error"]) {
            [LoggingHandler logError:error];
            //[Util displayOkDialogWithTitle:@"Error" andMessage:[result objectForKey:@"Error"]];
            completion(kResponseTypeFail, result);
        } else {
            //store login details
            MSUser *user = [[MSUser alloc] initWithUserId:[result valueForKey:@"userId"]];
            user.mobileServiceAuthenticationToken = [result valueForKey:@"token"];
            self.client.currentUser = user;
            self.email = [result valueForKey:@"email"];
            self.username = [result valueForKey:@"username"];
            [self saveAuthInfo];
            
            completion(kresponseTypeSuccess, result);
        }
    }];
}

- (void) loginWithUsernameEmail:(NSString *) usernameEmail
                    andPassword:(NSString *) password
                  andCompletion:(CompletionWithResponseTypeAndResponse) completion {
    NSDictionary *postValues = @{ @"emailOrUsername": usernameEmail,
                                  @"password": password};
    
    [self.client invokeAPI:@"Login" body:postValues HTTPMethod:@"POST" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Error %@", error);
        NSLog(@"result %@", result);
        NSLog(@"response %@", response);
        
        if (error || [result objectForKey:@"Error"]) {
            [LoggingHandler logError:error];
            completion(kResponseTypeFail, result);
        } else {
            //store login details
            MSUser *user = [[MSUser alloc] initWithUserId:[result valueForKey:@"userId"]];
            user.mobileServiceAuthenticationToken = [result valueForKey:@"token"];
            self.client.currentUser = user;
            self.email = [result valueForKey:@"email"];
            self.username = [result valueForKey:@"username"];
            [self saveAuthInfo];
            
            completion(kresponseTypeSuccess, result);
        }
    }];
}

- (void) saveUsername:(NSString *) username
                    withCompletion:(CompletionWithResponseTypeAndResponse) completion {
    
    NSDictionary *postValues = @{ @"email": self.email,
                               @"username" : username };
//    NSDictionary *postValues = @{ @"members" : members};
    
    [self.client invokeAPI:@"SaveUsername" body:postValues HTTPMethod:@"POST" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Error %@", error);
        NSLog(@"result %@", result);
        NSLog(@"response %@", response);
        
        if (error || [result objectForKey:@"Error"]) {
            [LoggingHandler logError:error];
            completion(kResponseTypeFail, result);
        } else {
            //store login details
            self.username = username;
            [self saveAuthInfo];
            completion(kresponseTypeSuccess, result);
        }
    }];
    
}


-(void)triggerLogout {
    if (!self.isLogoutInProcess) {
        self.isLogoutInProcess = YES;
        [self killAuthInfo];
//        SplashScreenViewController *rootVC = (SplashScreenViewController *) [[[[UIApplication sharedApplication] delegate] window] rootViewController];
//        //Return to the root view
//        [rootVC dismissModalViewControllerAnimated:NO];
//        //Trigger a dialog to let the user we cause a logout due to token
//        [rootVC performSelector:@selector(tellUserLogOutDueToToken) withObject:self afterDelay:0.5];
    }
}







- (void) getFriendsFromServer{
    self.isFetchingFriends = YES;
//    self.getFriendsCallback = completion;
    [self.tableFriends readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        self.isFetchingFriends = NO;
        if (error) {
            NSLog(@"ERROR %@", error);
//            if (self.getFriendsCallback)
//                self.getFriendsCallback(NO, error.localizedDescription);
            [Util displayOkDialogWithTitle:@"Error" andMessage:error.localizedDescription];
        } else {
            NSLog(@"Friends received");
            self.friends = [items mutableCopy];
            //Add self to friens list
            NSDictionary *selfFriends = @{ @"toUsername" : [self.username stringByAppendingString:@" (me)"],
                                      @"toUserId" : self.client.currentUser.userId,
                                      @"fromUserId" : self.client.currentUser.userId,
                                      @"status" : @"self",
                                      @"id" : @"self"};
            [(NSMutableArray *)self.friends insertObject:selfFriends atIndex:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"handleFriendPull" object:nil];
//            if (self.getFriendsCallback)
//                self.getFriendsCallback(YES, nil);
        }
//        self.getFriendsCallback = nil;
    }];
}

- (void) addFriendWithName:(NSString *)username andCompletion:(CompletionWithBoolAndStringBlock) completion {
    NSDictionary *friendRequest = @{@"username": username };
    [self.client invokeAPI:@"RequestFriend" body:friendRequest HTTPMethod:@"POST" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"ERROR %@", error);
            if (completion)
                completion(NO, error.localizedDescription);
        } else {
            if ([[result objectForKey:@"Status"] isEqualToString:@"FAIL"]) {
                completion(NO, [result objectForKey:@"Error"]);
            } else {                
                completion(YES, [result objectForKey:@"Status"]);
            }
        }
    }];
}

- (void) acceptFriendRequestWithRocket:(NSDictionary *)rocket andCompletion:(CompletionWithBoolAndStringBlock) completion {
    
     [self.client invokeAPI:@"AcceptFriendRequest" body:rocket HTTPMethod:@"POST" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
         if (error) {
             NSLog(@"ERROR %@", error);
             if (completion)
                 completion(NO, error.localizedDescription);
         } else {
             if ([[result objectForKey:@"Status"] isEqualToString:@"FAIL"]) {
                 if (completion) {
                     completion(NO, [result objectForKey:@"Error"]);
                 }
             } else {
                 completion(YES, [result objectForKey:@"Status"]);
             }
         }
     }];
}







- (void) getRocketsFromServer{
    self.isFetchingRockets = YES;
    //self.getRocketsCallback = completion;
    [self.tableRockets readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        self.isFetchingRockets = NO;
        if (error) {
            NSLog(@"ERROR %@", error);
//            if (self.getRocketsCallback)
//                self.getRocketsCallback(NO, error.localizedDescription);
            [Util displayOkDialogWithTitle:@"Error" andMessage:error.localizedDescription];
        } else {
            NSLog(@"Rockets received");

            self.rockets = [items mutableCopy];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"handleRocketPull" object:nil];
            
            
//            if (self.getRocketsCallback)
//                self.getRocketsCallback(YES, nil);
        }
//        self.getRocketsCallback = nil;
    }];
}

-(NSDictionary *)getNewRocket {
    NSDictionary *rocketDictionary = @{
        @"fromUserId" : self.client.currentUser.userId,
         @"toUserId" : self.client.currentUser.userId,
         @"fromUsername" : self.username,
         @"type" : @"SENT",
         @"timeToLive" : [NSNumber numberWithInt:self.secondsForShare],
         @"delivered" : @NO,
         @"isPicture" : self.isSharingPicture ? @YES : @NO,
         @"isVideo" : self.isSharingVideo ? @YES : @NO,
         @"allUsersHaveSeen" : @NO,
         @"createDate" : [NSDate date],
         @"updateDate" : [NSDate date]
     };
    return rocketDictionary;
}

-(void) sendRocketToFriends:(NSArray *)friendsIDs withCompletion:(CompletionWithBoolAndStringBlock) completion {
    self.isSendingRocket = YES;

    NSDictionary *rocketDictionary = [self getNewRocket];
    NSMutableArray *mutableRockets = (NSMutableArray *) self.rockets;
    [mutableRockets insertObject:rocketDictionary atIndex:0];
    
    [self.tableRockets insert:rocketDictionary completion:^(NSDictionary *item, NSError *error) {
        if (error) {
            NSLog(@"Error inserting rocket: %@", error);
            if (self.sendingRocketCallback)
                self.sendingRocketCallback(NO, error.localizedDescription);
        } else if ([[item objectForKey:@"Status"] isEqualToString:@"FAIL"]) {
            NSLog(@"Error inserting rocket2: %@", [item objectForKey:@"Error"]);
            if (self.sendingRocketCallback)
                self.sendingRocketCallback(NO, [item objectForKey:@"Error"]);
        } else {
            NSLog(@"Response from insert rocket");
            NSLog(@"rocket ID: %@", [item objectForKey:@"id"]);
            [mutableRockets replaceObjectAtIndex:0 withObject:item];
            
            NSString *fileName;
            double time = [[NSDate date] timeIntervalSince1970];
            int seconds = time / 1;
            if (self.isSharingPicture) {
                fileName = [NSString stringWithFormat:@"%i.jpg", seconds];
            } else if (self.isSharingVideo) {
                fileName = [NSString stringWithFormat:@"%i.mp4", seconds];
            }
            NSDictionary *rocketFile = @{
              @"isVideo" : self.isSharingVideo ? @YES : @NO,
               @"isPicture" : self.isSharingPicture ? @YES : @NO,
               @"ownerUsername" : self.username,
               @"sentMessageId" : [item objectForKey:@"id"],
               @"fileName" : fileName
           };
            [self.tableRocketFiles insert:rocketFile completion:^(NSDictionary *rocketFileItem, NSError *error) {
                if (error) {
                    NSLog(@"Error inserting rocketfile: %@", error);
                    if (self.sendingRocketCallback)
                        self.sendingRocketCallback(NO, error.localizedDescription);
                } else if ([[rocketFileItem objectForKey:@"Status"] isEqualToString:@"FAIL"]) {
                    NSLog(@"Error inserting rocketfile2: %@", [rocketFileItem objectForKey:@"Error"]);
                    if (self.sendingRocketCallback)
                        self.sendingRocketCallback(NO, [rocketFileItem objectForKey:@"Error"]);
                } else {
                    NSLog(@"RocketFile inserted %@", rocketFileItem);
                    [self handleBlobUploadForRocket:item andRocketFile:rocketFileItem andRecipients:friendsIDs];
                }
            }];
        }
    }];
}

-(void)handleBlobUploadForRocket:(NSDictionary *)rocket andRocketFile:(NSDictionary *)rocketFile andRecipients:(NSArray *)friendIds {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];

    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *blobURL = [NSURL URLWithString:[rocketFile objectForKey:@"blobPath"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:blobURL];
    [request setHTTPMethod:@"PUT"];
    NSURLSessionUploadTask *uploadTask;
    if (self.isSharingPicture) {
        [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
        UIImage *scaledImage = [self.sharingImage resizedImage:CGSizeMake(480, 640) interpolationQuality:kCGInterpolationDefault];
        
        NSData *imageData = UIImageJPEGRepresentation(scaledImage, 1.0);

        uploadTask = [manager uploadTaskWithRequest:request fromData:imageData progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                NSLog(@"upVidError: %@", error);
                if (self.sendingRocketCallback)
                    self.sendingRocketCallback(NO, error.localizedDescription);
            } else {
                [self sendRocketsToRecipientsWithRocket:rocket andRocketFile:rocketFile andRecipients:friendIds];
            }
        }];
        [uploadTask resume];
    } else if (self.isSharingVideo) {
        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:self.sharingMovieUrl options:nil];
        NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
        
        if ([compatiblePresets containsObject:AVAssetExportPresetLowQuality]) {
             AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetPassthrough];
            
            NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp3.mp4"];
            
            exportSession.outputURL = [NSURL fileURLWithPath:filePath];
            //exportSession.outputURL = self.sharingMovieUrl;
            //[NSURL fileURLWithPath:videoPath];
            
            exportSession.outputFileType = AVFileTypeMPEG4;
            
//            CMTime start = CMTimeMakeWithSeconds(0.0, 600);
//            
//            CMTime duration = CMTimeMakeWithSeconds(10.0, 600);
//            
//            CMTimeRange range = CMTimeRangeMake(start, duration);
//            
//            exportSession.timeRange = range;
            
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                
                switch ([exportSession status]) {
                        
                    case AVAssetExportSessionStatusFailed:
                        //If this fails, it might be because the temorary
                        //files weren't cleaned and this isn't overwriting
                        //the temporary filename
                        NSLog(@"Export failed: %@", [[exportSession error] localizedDescription]);
                        if (self.sendingRocketCallback)
                            self.sendingRocketCallback(NO, [exportSession error].localizedDescription);
                        
                        break;
                        
                    case AVAssetExportSessionStatusCancelled:
                        
                        NSLog(@"Export canceled");
                        if (self.sendingRocketCallback)
                            self.sendingRocketCallback(NO, [exportSession error].localizedDescription);
                        
                        break;
                        
                    default:
                        //This should have been a success
                        
                        [request setValue:@"video/mp4" forHTTPHeaderField:@"Content-Type"];
                         NSURLSessionUploadTask *videoUploadTask;
                         //videoUploadTask = [manager uploadTaskWithRequest:request fromFile:self.sharingMovieUrl progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                        videoUploadTask = [manager uploadTaskWithRequest:request fromFile:[NSURL URLWithString:filePath] progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                         if (error) {
                         NSLog(@"upVidError: %@", error);
                         if (self.sendingRocketCallback)
                         self.sendingRocketCallback(NO, error.localizedDescription);
                         } else {
                         [self sendRocketsToRecipientsWithRocket:rocket andRocketFile:rocketFile andRecipients:friendIds];
                         }
                         
                         
                         }];
                         [videoUploadTask resume];
                        
                        
                        
                        break;
                        
                }
                
            }];
        }
        
    }
}

-(void)sendRocketsToRecipientsWithRocket:(NSDictionary *)rocket andRocketFile:(NSDictionary *)rocketFile andRecipients:(NSArray *)friendIds {
    //Remove the video file if necessary
    if (self.isSharingVideo) {
        NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
        for (NSString *file in tmpDirectory) {
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
        }
    }
    //Get JSON String of recipients
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:friendIds options:NSJSONWritingPrettyPrinted error:&jsonError];
    NSString *recipients = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    //Send rockets to recipients
    NSDictionary *sendRocketsDictionary = @{
     @"recipients" : recipients,
     @"timeToLive" : [NSNumber numberWithInt:self.secondsForShare],
     @"fromUserId" : self.client.currentUser.userId,
     @"fromUsername" : self.username,
     @"isPicture": self.isSharingPicture? @YES : @NO,
     @"isVideo" : self.isSharingVideo ? @YES : @NO,
     @"originalSentRocketId" : [rocket objectForKey:@"id"],
     @"rocketFileId" : [rocketFile objectForKey:@"id"]
     };
    
    [self.client invokeAPI:@"SendRocketToFriends" body:sendRocketsDictionary HTTPMethod:@"POST" parameters:nil headers:nil completion:^(id sendRocketsResult, NSHTTPURLResponse *response, NSError *error) {
        //Clean up regardless of what happened
        self.isSendingRocket = NO;
        self.isSharingPicture = NO;
        self.isSharingVideo = NO;
        self.sharingMovieUrl = nil;
        self.sharingImage = nil;
        
        if (error) {
            NSLog(@"Error sending rocket to recips: %@", error);
            if (self.sendingRocketCallback)
                self.sendingRocketCallback(NO, error.localizedDescription);
        } else if ([[sendRocketsResult objectForKey:@"Status"] isEqualToString:@"FAIL"]) {
            NSLog(@"Error sending rocket to recips2: %@", [sendRocketsResult objectForKey:@"Error"]);
            if (self.sendingRocketCallback)
                self.sendingRocketCallback(NO, [sendRocketsResult objectForKey:@"Error"]);
        } else {
            if (self.sendingRocketCallback)
                self.sendingRocketCallback(YES, @"SUCCESS");
        }
    }];
    
    
    
    
}

- (void) getRocketFileForRecipientFromRocket:(NSDictionary *)rocket andCompletion:(CompletionWithResponseTypeAndResponse) completion {
    [self.client invokeAPI:@"getRocketForRecipient" body:rocket HTTPMethod:@"POST" parameters:nil headers:nil completion:^(id result, NSHTTPURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"ERROR %@", error);
            if (completion)
                completion(kResponseTypeFail, error.localizedDescription);
        } else {
            if ([[result objectForKey:@"Status"] isEqualToString:@"FAIL"]) {
                if (completion) {
                    completion(kResponseTypeFail, [result objectForKey:@"Error"]);
                }
            } else {
                completion(kresponseTypeSuccess, result);
            }
        }
    }];
}



-(void)registerForPushNotifications {
    if (!self.hasSentPushTokenToNotificationHubs && self.pushToken) {
        self.hasSentPushTokenToNotificationHubs = YES;
        SBNotificationHub* hub = [[SBNotificationHub alloc] initWithConnectionString:
              NOTIFICATION_HUB_CONNECTION_STRING notificationHubPath:NOTIFICATION_HUB_NAME];
        NSArray *tagArray = @[
                              self.client.currentUser.userId,
                              @"AllUsers",
                              @"iOSUser"
                              ];
        NSSet *tagSet = [[NSSet alloc] initWithArray:tagArray];
        NSString *template = @"{\"aps\": {\"alert\": \"$(message)\"}}";
        
        NSLog(@"registering with device token: %@", self.pushToken);

        [hub registerTemplateWithDeviceToken:self.pushToken name:@"messageTemplate" jsonBodyTemplate:template expiryTemplate:nil tags:tagSet completion:^(NSError *error) {
            if (error != nil) {
                NSLog(@"Error registering for push notifications: %@", error);
            } else {
                NSLog(@"Success registering for push");
            }
        }];
        
        
    }
}

-(void)getUserPreferences {
    [self.tableUserPreferences readWithCompletion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        if (error) {
            NSLog(@"ERROR %@", error);
        } else {
            if ([items count] > 0) {
                NSDictionary *prefs = [items objectAtIndex:0];
                self.userPreferences = prefs;
                //Set our local email to make sure it's right
                self.email = [prefs objectForKey:@"email"];
                [KeychainWrapper createKeychainValue:self.email forIdentifier:@"email"];
            }

        }
    }];
}

-(void)updatePreferences:(NSDictionary *)preferences withCompletion:(CompletionWithBoolAndStringBlock) completion {
    [self.tableUserPreferences update:preferences completion:^(NSDictionary *item, NSError *error) {
        if (error) {
            NSLog(@"Error %@", error);
            if (completion) {
                completion(NO, error.localizedDescription);
            }
        }
        else {
            //Success, updatep preferences locally
            self.email = [preferences objectForKey:@"email"];
            [KeychainWrapper createKeychainValue:self.email forIdentifier:@"email"];
            if (completion)
                completion(YES, nil);
        }
    }];
}





- (void) busy:(BOOL) busy
{
    // assumes always executes on UI thread
    if (busy) {
        if (self.busyCount == 0 && self.busyUpdate != nil) {
            self.busyUpdate(YES);
        }
        self.busyCount ++;
    }
    else
    {
        if (self.busyCount == 1 && self.busyUpdate != nil) {
            self.busyUpdate(FALSE);
        }
        self.busyCount--;
    }
}

#pragma mark * MSFilter methods

- (void) handleRequest:(NSURLRequest *)request
                  next:(MSFilterNextBlock)onNext
              response:(MSFilterResponseBlock)onResponse
{
    
    // A wrapped response block that decrements the busy counter
    //    MSFilterResponseBlock wrappedResponse = ^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
    //        [self busy:NO];
    //        onResponse(response, data, error);
    //    };
    // Increment the busy counter before sending the request
    [self busy:YES];
    //    onNext(request, wrappedResponse);
    
    // add additional versioning information to the querystring for versioning purposes
    NSString *append = [NSString stringWithFormat:@"build=%@&version=%@", self.build, self.version];
    NSURL *url = nil;
    NSRange range = [request.URL.absoluteString rangeOfString:@"?"];
    if (range.length > 0) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&%@&p=iOS", request.URL.absoluteString, append]];
    }
    else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@&p=iOS", request.URL.absoluteString, append]];
    }
    
    NSMutableURLRequest *newRequest = [request mutableCopy];
    newRequest.URL = url;
    
    
    onNext(newRequest, ^(NSHTTPURLResponse *response, NSData *data, NSError *error){
        [self filterResponse:response
                     forData:data
                   withError:error
                  forRequest:request
                      onNext:onNext
                  onResponse:onResponse];
    });
}

- (void) filterResponse: (NSHTTPURLResponse *) response
                forData: (NSData *) data
              withError: (NSError *) error
             forRequest:(NSURLRequest *) request
                 onNext:(MSFilterNextBlock) onNext
             onResponse: (MSFilterResponseBlock) onResponse
{
    if (response.statusCode == 401) {
        //Log the user out
        [self triggerLogout];
    }
    else {
        [self busy:NO];
        onResponse(response, data, error);
        
        
    }
}

@end
