exports.post = function(request, response) {

    var postValues = request.body;
    if (postValues.members != null) 
      postValues = postValues.members;

    var accounts = request.service.tables.getTable('AccountData');
    var requestUserId = request.user.userId;
    var item = { username : postValues.username };
    accounts.where(function(item) {
            return this.username == item.username;
    },item).read({ 
		success: function(results) {
			handleFindFriendResults(results, response, item, request, accounts, requestUserId);
        }, error: function(error) {
            console.error('Error saving friend request: ', error);
            response.send(200, { Status : "FAIL", Error: "Couldn't request friend."});
        }
    });                
};

function handleFindFriendResults(results, response, item, request, accounts, requestUserId) {
    if (results.length === 0) {
		response.send(200, { Status : "FAIL", Error : "Sorry!  Couldn't find " + item.username});
	}
	else {
        var receivingFriend = results[0];
        var newFriend = { fromUserId : request.user.userId,
                          toUserId:    receivingFriend.userId,
                          status:      'requested',
                          createDate:  new Date(),
                          updateDate:  new Date(),
                          requestedBy: request.user.userId,
                          toUsername: receivingFriend.username
                          };
         var friends = request.service.tables.getTable('Friends');
         friends.insert(newFriend, {
             success: function() {
                 accounts.where({ userId: requestUserId}).read({ 
            		success: function(requestingUser) {
                        handleInsertFriendResult(requestingUser, response, request, receivingFriend, item);
                    }, error: function(error) {
                        console.error('Error looking up requesting friend: ', error);
                        response.send(200, { Status: "FAIL", Error: "Couldn't request friend."});
                    }
                });                                               
             }
         });
    }
}

function handleInsertFriendResult(requestingUser, response, request, receivingFriend, item) {
    if (requestingUser.length === 0) {
        response.send(200, { Status : "FAIL", Error : "Sorry!  Couldn't find your user record."});
    } else {
             var newMessage = { fromUserId : request.user.userId,
                              toUserId:    receivingFriend.userId,
                              type:        'FriendRequest',
                              createDate:  new Date(),
                              updateDate:  new Date(),
                              fromUsername: requestingUser[0].username,
                              userHasSeen: false,
                              delivered:   true
                              };
             var messages = request.service.tables.getTable('Messages');
             messages.insert(newMessage, {
                 success: function() {
                    response.send(200, { Status : item.username + ' is private.  Friend request sent' });
                    //Push down to user receiving request     
                    var azure = require('azure');
                    var notificationHubService = azure.createNotificationHubService(process.env.NOTIFICATION_HUB_NAME, process.env.NOTIFICATION_HUB_FULL_ACCESS_SIGNATURE);
                    
                    var payload = '{ "message" : "Friend request received", "collapse_key" : "FRIENDREQUEST" }';
                     notificationHubService.send(newMessage.toUserId, payload, 
                         function(error, outcome) {
                             console.log('issue sending push');
                             console.log('error: ', error);
                             console.log('outcome: ',outcome);
                         });     
                 }, error: function(error) {
                     throw error;
                 }
             });
    }
}
