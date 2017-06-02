function beforeTaskComplete(colleagueId,nextSequenceId,userList){
	
	if(nextSequenceId == 13 || nextSequenceId == 9 || nextSequenceId == 19){
		var NumSolicit = hAPI.getCardValue('C1_NUM');
		var dtEmissao = hAPI.getCardValue('C1_EMISSAO');
		var NomAprov = hAPI.getCardValue('C1_NOMAPRO');
		var Empresa = hAPI.getCardValue('EMPRESA');
		var Filial = hAPI.getCardValue('FILIAL');
		
		log.info("(ANTES DO IF) SC NUMERO " + NumSolicit + " // " + "NOME DO APROVADOR " +  NomAprov + " EMISSAO: " + dtEmissao);
		
		if(Empresa == "01") {
			var nomeServico = "ws_Protheus_SC_Farmax";
			var serviceLocator = "_13._0._168._192._55555.UWSAPRVSC";
		} else {
			var nomeServico = "ws_Protheus_SC_Icot";
			var serviceLocator = "_13._0._168._192._55556.UWSAPRVSC";
		}
		
		var AprovSCService = ServiceManager.getService(nomeServico);
		var serviceHelper = AprovSCService.getBean();
		var serviceLocator = serviceHelper.instantiate(serviceLocator);
		var service = serviceLocator.getUWSAPRVSCSOAP();
		
		if(nextSequenceId == 9){
			log.info("WS PROTHEUS APROVAR SC, ATIVIDADE DESTINO:" + nextSequenceId);
			log.info("ANTES DA EXECUÇÃO DO WS: SC NUMERO " + NumSolicit + " // " + "NOME DO APROVADOR" +  NomAprov);
			
			var result = service.aprovar(NumSolicit,NomAprov);
			log.info(result);
			
		}
		
		if(nextSequenceId == 13 || nextSequenceId == 19){
			log.info("WS PROTHEUS REPROVAR SC, ATIVIDADE DESTINO:" + nextSequenceId);
			log.info("ANTES DA EXECUÇÃO DO WS: SC NUMERO " + NumSolicit + " // " + "NOME DO APROVADOR" +  NomAprov);
			
			var result = service.reprovar(NumSolicit,NomAprov);
			log.info(result);
		}
	}
}