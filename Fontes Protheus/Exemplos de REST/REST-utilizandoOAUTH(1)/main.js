$(document).ready(function() {
	var keysGET = {
		consumerPublic : "appGET",
		consumerSecret : "ConsumerSecretKeyAppGet",
		tokenPublic : "498f1ea5-7ec1-4a80-a8e3-3834959f937d",
		tokenSecret : "93a1f01e-93cd-48df-acc4-0d495622b8f7f750b46d-4ec4-4260-80eb-d737e515d64a"
	}

	var keysPOST = {
		consumerPublic : "appPOST",
		consumerSecret : "ConsumerSecretKeyAppPost",
		tokenPublic : "cd6207db-5b4a-4889-ad04-50b9fbf14324",
		tokenSecret : "4e49fd43-96be-48b0-86d2-717f377433666b47225e-b0cc-49ca-b977-81aca79f0fb3"
	}

	FluigAPI.setKeys(keysGET, keysPOST);
});

function searchColleague(){
	var colleagueName = $("#colleagueName").val();
	var params = {
		"name" : "colleague",
		"fields" : ["colleagueId", "mail"],
		"constraints" : [{
		"_field" : "colleagueName",
		"_initialValue": "%" + colleagueName + "%",
		"_finalValue" : "%" + colleagueName + "%",
		"_type": 0,
		"_likeSearch": true
		}],
		"order" : ["mail"]
	};

	FluigAPI.consume('POST',
					 'http://fluighml.totvsrs.com.br:8080/api/public/ecm/dataset/datasets',
					  params,
					  showDataColleague);
}

function showDataColleague(response){
	console.log(response);
	var colleague = response.content.values[0];
	$("#colleagueId").val(colleague.colleagueId);
	$("#mail").val(colleague.mail);
}
