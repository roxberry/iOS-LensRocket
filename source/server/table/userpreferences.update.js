function update(item, user, request) {

    var userPreferencesTable = tables.getTable('UserPreferences');    
    
    userPreferencesTable.where({ userId : user.userId}).read({
		success: function(results) {
			if (results.length === 0) {
                request.respond(500, 'Unable to find your account');
				return;
			}
			else {
                item.updateDate = new Date();
                var originalPreferences = results[0];
                if (originalPreferences.email !== item.email) {
                    var sql = "SELECT id FROM UserPreferences WHERE email = ?";
                        mssql.queryRaw(sql, [item.email], {
                        	success: function(results) {
                                if (results.rows.length === 0) {                                                    
                                    //Email address not in use, ok to update
                                    var callbackCount = 0;
                                    sql = "UPDATE UserPreferences SET email = ? WHERE userId = ?;UPDATE AccountData SET email = ? WHERE userId = ?;";
                                    mssql.queryRaw(sql, [item.email, user.userId, item.email, user.userId], {
                                        success: function(results) {
                                            if (callbackCount++ == 1) {
                                                request.respond(200, { Status: 'success', Details: 'Email updated'});                                             
                                                return;
                                            }
                                        },
                                        error: function(error) {
                                            console.error("Couldn't update preferences for email: ", error);
                                            request.respond(500, 'Error updating email address');                                            
                                            return;            
                                        }
                                    });
                                } else {
                                    //Email address in use, don't change
                                    request.respond(500, 'Email address is unavailable');                                    
                                    return; 
                                }
                            }, error: function(error) {
                                console.error("Couldn't check for existing emai address: ", error);
                                request.respond(500, 'There was an issue updating your email address.  Please try again later');                                
                                return;            
                            }
                        });
                } else {
                    //Not email, update away
                    var updateSql = "UPDATE UserPreferences SET receiveFrom = ?, shareTo = ?, updateDate = getdate() WHERE userId = ?";
                    mssql.queryRaw(updateSql, [item.receiveFrom, item.shareTo, user.userId], {
                        success: function(results) {
                           request.respond(200, { Status: 'success', Details: 'Settings updated'});
                           return;
                        },
                        error: function(error) {
                            console.error("Couldn't update prefs: ", error);
                            request.respond(500, 'There was an issue updating your preferences.  Please try again later');                                
                            return;      
                        }
                    });
                }
            }
        }, error: function(error) {
            console.error('Error fetching User Preferences: ', error);
            request.respond(500, 'Unable to update user preferences');
        }
    });
}