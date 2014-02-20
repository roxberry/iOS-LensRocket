var jwthelper = require('../shared/jwthelper.js');
var aud = "Custom";


exports.post = function(request, response) {    
	var postValues = request.body;
	if (postValues.members != null)
		postValues = postValues.members;

    var accounts = request.service.tables.getTable('AccountData');	
    var item = { emailOrUserName : postValues.emailOrUsername,
                 password : postValues.password
                };
    accounts.where(function(item) {
                return this.email == item.emailOrUserName || this.username == item.emailOrUserName;
            },item).read({ 
			success: function(results) {
				if (results.length === 0) {
					response.send(200, { Status : "FAIL", Error : "Incorrect username or password"});
				}
				else {
					var account = results[0];
                    console.log(account);
					jwthelper.hash(item.password, account.salt, function(err, h) {
						var incoming = h;
						if (jwthelper.slowEquals(incoming, account.password)) {							
							var userId = aud + ":" + account.id;
							response.send(200, {
								userId: userId,
								token: jwthelper.zumoJwt(aud, userId, request.service.config.masterKey),
                                status: "SUCCESS",
                                username: account.username,
                                email: account.email
							});
						}
						else {
                            console.error('incorrect username or password');
							response.send(200, { Status : "FAIL", Error: "Incorrect username or password."});
						}
					});
				}
			}
		});	
};
