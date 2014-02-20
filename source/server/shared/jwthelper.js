var crypto = require('crypto');
var iterations = 1000;
var bytes = 32;

exports.createSalt = function() {
	return new Buffer(crypto.randomBytes(bytes)).toString('base64');
}

exports.hash = function hash(text, salt, callback) {
	crypto.pbkdf2(text, salt, iterations, bytes, function(err, derivedKey){
		if (err) { callback(err); }
		else {
			var h = new Buffer(derivedKey).toString('base64');
			callback(null, h);
		}
	});
}

exports.zumoJwt = function zumoJwt(aud, userId, masterKey) {
 
 	function base64(input) {
		return new Buffer(input, 'utf8').toString('base64');
	}
 
	function urlFriendly(b64) {
		return b64.replace(/\+/g, '-').replace(/\//g, '_').replace(new RegExp("=", "g"), '');
	}
 
	function signature(input) {
		var key = crypto.createHash('sha256').update(masterKey + "JWTSig").digest('binary');
		var str = crypto.createHmac('sha256', key).update(input).digest('base64');
		return urlFriendly(str);
	}
	
 
	var s1 = '{"alg":"HS256","typ":"JWT","kid":0}';
	var j2 = {
		//"exp":expiryDate.valueOf() / 1000,
		"exp": new Date().setUTCDate(new Date().getUTCDate() + 4000),
		"iss":"urn:microsoft:windows-azure:zumo",
		"ver":1,
		"aud":aud,
		"uid":userId 
	};
	var s2 = JSON.stringify(j2);
	var b1 = urlFriendly(base64(s1));
	var b2 = urlFriendly(base64(s2));
	var b3 = signature(b1 + "." + b2);
    console.log('jwt: ', [b1,b2,b3].join("."));
	return [b1,b2,b3].join(".");
}

exports.slowEquals = function(a, b) {
	var diff = a.length ^ b.length;
    for (var i = 0; i < a.length && i < b.length; i++) {
        diff |= (a[i] ^ b[i]);
	}
    return diff === 0;
}