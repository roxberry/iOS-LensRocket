var azure = require('azure');
var qs = require('querystring');

function insert(item, user, request) {
    
    var accountName = process.env.STORAGE_ACCOUNT_NAME;
    var accountKey = process.env.STORAGE_ACCOUNT_KEY;
    var host = accountName + '.blob.core.windows.net';
    var blobService = azure.createBlobService(accountName, accountKey, host);
    var containerName = user.userId.replace(":", "").toLowerCase();
    
    blobService.createContainerIfNotExists(containerName, function (error) {
        if (error) {
            console.log(error);
            request.respond(500, { Status : "FAIL", Error : "Sorry!  Couldn't find your user record."});            
        } else {
            item.creator = user.userId;            
            var sharedAccessPolicy = { 
                AccessPolicy: {
                    Permissions: 'w', //write permissions
                    Expiry: minutesFromNow(5) 
                }
            };
            
            var sasUrl = blobService.generateSharedAccessSignature(containerName,
                    item.fileName, sharedAccessPolicy);
            var sasQueryString = { 'sasUrl' : sasUrl.baseUrl + sasUrl.path + '?' + qs.stringify(sasUrl.queryString) };                                
            item.blobPath = sasQueryString.sasUrl;
            item.readyForDeletion = false;            
            request.execute();
        }
    }); 
}

function minutesFromNow(minutes) {
    var date = new Date()
  date.setMinutes(date.getMinutes() + minutes);
  return date;
}