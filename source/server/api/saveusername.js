exports.post = function(request, response) {    

    var postValues = request.body;
    if (postValues.members != null)
        postValues = postValues.members;
    
    var accounts = request.service.tables.getTable('AccountData');
	var mssql = request.service.mssql;
   
    var item = { username : postValues.username,
                email : postValues.email 
               };    
    if (item.username.length < 4) {
        response.send(200, { Status: 'fail', Error: 'Invalid username (at least 4 chars required)'});
        return;
    }
	accounts.where({ username : item.username}).read({
		success: function(results) {
			if (results.length > 0) {
                response.send(200, { Status: 'fail', Error: 'Username already exists'});
				return;
			}
			else {
                console.log("Saving username    ");
                var sql = "UPDATE AccountData set username = ?, updateDate = ? WHERE userId = ?";                
                mssql.queryRaw(sql, [item.username, new Date(), request.user.userId], {
                	success: function(results) {  	
                        if (results.rowcount == 1) {
                            //Save UserPreferences
                            var userPrefs = { username: item.username,
                                              receiveFrom: 'Just Friends',
                                              shareTo: 'Just Friends',
                                              email: item.email,
                                              userId: request.user.userId,
                                              createDate: new Date(),
                                              updateDate: new Date()
                                            };
                            var userPreferencesTable = request.service.tables.getTable('UserPreferences');
                            userPreferencesTable.insert(userPrefs, {
                                success: function(results) {
                                    request.respond(200, { Status: 'User updated' });
                                }, error: function(error) {
                                    console.error('Unable to update accountData (1):', error);
                                    request.respond(200, { Status: 'fail', Error: 'Unable to update accountData'});        
                                }
                            });                            
                        } else {
                        	console.error('Unable to update accountData (2)');
                            request.respond(200, { Status: 'fail', Error: 'Unable to update accountData'});
                        }
                    }, error: function(error) {
                        console.error('Error updating accountData (3): ', error);
                        request.respond(200, { Status: 'fail', Error: 'Unable to update accountData'});
                    }
                }
        );
                
                
			}
		}
	});
};