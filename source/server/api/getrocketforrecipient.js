var azure = require('azure');
var qs = require('querystring');

exports.post = function(request, response) {
    var rocket = request.body;
    
    var messagesTable = request.service.tables.getTable('Messages');
    messagesTable.where(function(rocket) {
        return this.id == rocket.id && this.toUserId == rocket.toUserId;
    },rocket).read({ 
		success: function(results) {
            if (results.length === 0) {
				response.send(200, { Status : "FAIL", Error : "Sorry!  Couldn't find friend request"});
                return;
			} else {
                var actualRocket = results[0];
                if (actualRocket.rocketFileId != rocket.rocketFileId) {
                    response.send(200, { Status : "FAIL", Error : "Sorry!  Invalid rocket information requested."});
                    return;
                } else {
                    //Get RocketFile out
                    var rocketFileTable = request.service.tables.getTable('RocketFile');
                    rocketFileTable.where({ id : actualRocket.rocketFileId }).read({
                        success: function(rocketFiles) {
                            if (rocketFiles.length === 0) {
                                response.send(200, { Status : "FAIL", Error : "Sorry!  Unable to find rocket file."});
                                return;     
                            } else {
                                //Get SAS
                                var rocketFile = rocketFiles[0];
                                var accountName = process.env.STORAGE_ACCOUNT_NAME;
                                var accountKey = process.env.STORAGE_ACCOUNT_KEY;
                                var host = accountName + '.blob.core.windows.net';
                                var blobService = azure.createBlobService(accountName, accountKey, host);
                                var containerName = rocketFile.creator.replace(":", "").toLowerCase();
                                
                                var sharedAccessPolicy = { 
                                    AccessPolicy: {
                                        Permissions: 'r', //write permissions
                                        Expiry: minutesFromNow(5) 
                                    }
                                };
                                
                                var sasUrl = blobService.generateSharedAccessSignature(containerName,
                                        rocketFile.fileName, sharedAccessPolicy);                    
                                var sasQueryString = { 'sasUrl' : sasUrl.baseUrl + sasUrl.path + '?' + qs.stringify(sasUrl.queryString) };                    
                                console.log(sasQueryString);                                
                                var blobPath = sasQueryString.sasUrl;
                                
                                //Update Rocket as seen! add new SeenOn date stamp to rocket
                                actualRocket.userHasSeen = true;
                                actualRocket.seenOn = new Date();
                                actualRocket.updateDate = new Date();
                                messagesTable.update(actualRocket, {
                                    success: function() {
                                        console.log('success');
                                        response.send(200, { Status : "Success", RocketUrl: blobPath });
                                        
                                        //Check to see if all viewers have viewed rocket, if so, update original sent to be viewed
                                        //and mark rocket file for deletion
                                        //actualRocket.rocketFileId;
                                        var sql = "SELECT id FROM Messages WHERE rocketFileId = ? AND type = 'Rocket' AND userHasSeen = 0";
                                        var mssql = request.service.mssql;
                                        mssql.queryRaw(sql, [actualRocket.rocketFileId], {
                                        	success: function(results) {
                                                if (results.rows.length == 0) {                                                    
                                                    //all rockets have been seen, update original
                                                    sql = "UPDATE Messages SET allUsersHaveSeen = 1 WHERE rocketFileId = ? AND type = 'SENT';UPDATE RocketFile SET readyForDeletion = 1 WHERE id = ?";
                                                    mssql.queryRaw(sql, [actualRocket.rocketFileId, actualRocket.rocketFileId], {
                                                        success: function(results) { /* do nothin */ },
                                                        error: function(error) {
                                                            console.error("Couldn't update sent Rocket to indicate all seen: ", error);            
                                                        }
                                                    });
                                                } else {
                                                    //All rockets have not been seen, do nothing 
                                                }
                                            }, error: function(error) {
                                                console.error("Couldn't check for messages not having seen rocket: ", error);            
                                            }
                                        });                                                                            
                                        return;
                                    }, error: function(error) {
                                        response.send(200, { Status : "FAIL", Error : "Sorry!  There was an issue updating the rocket as seen:"+ error});
                                        return; 
                                    }
                                });                                                                
                            }
                        }, error: function(error) {
                            response.send(200, { Status : "FAIL", Error : "Sorry!  There was an issue getting the error: "+ error});
                            return; 
                        }
                    });
                }
            }
        }
    });
};

function minutesFromNow(minutes) {
    var date = new Date()
  date.setMinutes(date.getMinutes() + minutes);
  return date;
}
