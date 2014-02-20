//
//  LensRocketService.h
//  LensRocket
//
//  Created by Chris Risner on 10/1/13.
//  Copyright (c) 2014 Microsoft Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>

@interface LensRocketService : NSObject <MSFilter>

@property (nonatomic, strong)   MSClient *client;
@property (nonatomic, copy)     BusyUpdateBlock busyUpdate;
@property (nonatomic, strong)   NSString *username;
@property (nonatomic, strong)   NSString *email;
@property (nonatomic, strong)   NSData *pushToken;
@property (nonatomic) bool      hasSentPushTokenToNotificationHubs;

@property (nonatomic, strong)   NSArray *friends;
@property (nonatomic, strong)   NSArray *rockets;
@property (nonatomic, strong)   NSDictionary *userPreferences;

//@property (nonatomic, strong) CompletionWithBoolAndStringBlock getFriendsCallback;
//@property (nonatomic, strong) CompletionWithBoolAndStringBlock getRocketsCallback;
@property (nonatomic, strong) CompletionWithBoolAndStringBlock sendingRocketCallback;
@property (nonatomic) bool isFetchingFriends;
@property (nonatomic) bool isFetchingRockets;
@property (nonatomic) bool isSharingPicture;
@property (nonatomic) bool isSharingVideo;
@property (nonatomic) bool isSendingRocket;
@property (nonatomic) int secondsForShare;
@property (nonatomic, strong) UIImage *sharingImage;
@property (nonatomic, strong) NSURL *sharingMovieUrl;

+(LensRocketService*) getInstance;


/***************************************************************/
/** Authentication **/
/***************************************************************/

- (void)saveAuthInfo;
- (void)killAuthInfo;
- (BOOL)isUserAuthenticated;
- (void) registerAccountWithEmail:(NSString *) email
                      andPassword:(NSString *) password
                           andDob:(NSString *) dob
              andCompletion:(CompletionWithResponseTypeAndResponse) completion;
- (void) loginWithUsernameEmail:(NSString *) usernameEmail
                    andPassword:(NSString *) password
                  andCompletion:(CompletionWithResponseTypeAndResponse) completion;

- (void) saveUsername:(NSString *) username
       withCompletion:(CompletionWithResponseTypeAndResponse) completion;

/***************************************************************/
/** Friends **/
/***************************************************************/

- (void) getFriendsFromServer;
- (void) addFriendWithName:(NSString *)username andCompletion:(CompletionWithBoolAndStringBlock) completion;
- (void) acceptFriendRequestWithRocket:(NSDictionary *)rocket andCompletion:(CompletionWithBoolAndStringBlock) completion;

/***************************************************************/
/** Rockets **/
/***************************************************************/

- (void) getRocketsFromServer;
-(void) sendRocketToFriends:(NSArray *)friendsIDs withCompletion:(CompletionWithBoolAndStringBlock) completion;
- (void) getRocketFileForRecipientFromRocket:(NSDictionary *)rocket andCompletion:(CompletionWithResponseTypeAndResponse) completion;

-(void)registerForPushNotifications;

/***************************************************************/
/** User Preferences **/
/***************************************************************/

-(void)getUserPreferences;
-(void)updatePreferences:(NSDictionary *)preferences withCompletion:(CompletionWithBoolAndStringBlock) completion;

/***************************************************************/
/** Service Filter **/
/***************************************************************/

- (void) handleRequest:(NSURLRequest *)request
                  next:(MSFilterNextBlock)onNext
              response:(MSFilterResponseBlock)onResponse;

@end
