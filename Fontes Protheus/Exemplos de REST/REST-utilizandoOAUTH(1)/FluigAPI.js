var FluigAPI = FluigAPI || {};

FluigAPI.setKeys = function(keysGET, keysPOST){
	FluigAPI.GET = {};
	FluigAPI.POST = {};

	FluigAPI.GET.consumerPublic = keysGET.consumerPublic;
	FluigAPI.GET.consumerSecret = keysGET.consumerSecret;
	FluigAPI.GET.tokenPublic = keysGET.tokenPublic;
	FluigAPI.GET.tokenSecret = keysGET.tokenSecret;

	FluigAPI.POST.consumerPublic = keysPOST.consumerPublic;
	FluigAPI.POST.consumerSecret = keysPOST.consumerSecret;
	FluigAPI.POST.tokenPublic = keysPOST.tokenPublic;
	FluigAPI.POST.tokenSecret = keysPOST.tokenSecret;
}

FluigAPI.getHeaderOAuth = function(request_data){
	var method = request_data.method

	var oauth = OAuth({
		consumer: {
			'public':this[method].consumerPublic,
			'secret':this[method].consumerSecret
		},
		signature_method:'HMAC-SHA1'
	});

	var token = {
		'public':this[method].tokenPublic,
		'secret':this[method].tokenSecret
	};

	return oauth.toHeader(oauth.authorize(request_data, token));
}

FluigAPI.consume = function(type, urlApi, params, callbackSuccess, callbackError){
	var request_data = { url: urlApi, method: type };
	var headerOAuth = this.getHeaderOAuth(request_data);
	var callbackDefault = function(response){ console.log(response) };
	$.ajax({
		async : false,
		type : request_data.method,
		contentType: "application/json",
		dataType : "json",
		url : request_data.url,
		data : JSON.stringify(params),
		headers: headerOAuth,
		success: callbackSuccess || callbackDefault,
		error: callbackError || callbackDefault
	});
}