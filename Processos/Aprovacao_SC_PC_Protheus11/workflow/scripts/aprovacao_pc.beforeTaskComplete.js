function beforeTaskComplete(colleagueId,nextSequenceId,userList){
	
		
		var NumPedido = hAPI.getCardValue('PEDIDO');
		var dtEmissao = hAPI.getCardValue('EMISSAO');
		var NomAprov = hAPI.getCardValue('APROVADOR');
		var Empresa = hAPI.getCardValue('EMPRESA');
		var Filial = hAPI.getCardValue('FILIAL');
		log.info("PC NUMERO " + NumPedido + " // " + "EMAIL DO APROVADOR " +  NomAprov + " EMISSAO: " + dtEmissao);
		
		
		if(Empresa == "01") {
			var nomeServico = "ws_Protheus_PC_Farmax";
			var serviceLocator = "_13._0._168._192._55555.UWSAPRVPC";
		} else {
			var nomeServico = "ws_Protheus_PC_Icot";
			var serviceLocator = "_13._0._168._192._55556.UWSAPRVPC";
		}
		
		var AprovSCService = ServiceManager.getService(nomeServico);
		var serviceHelper = AprovSCService.getBean();
		var serviceLocator = serviceHelper.instantiate(serviceLocator);
		var service = serviceLocator.getUWSAPRVPCSOAP();
		
		if(nextSequenceId == 7){
			log.info("WS PROTHEUS APROVAR PC, ATIVIDADE DESTINO:" + nextSequenceId);
			log.info("ANTES DA EXECUÇÃO DO WS: PC NUMERO " + NumPedido + " // " + "NOME DO APROVADOR" +  NomAprov);
			var result = service.aprovar(NumPedido,NomAprov);
			log.info(result);
		}
		
		if(nextSequenceId == 13 || nextSequenceId == 15){
			log.info("WS PROTHEUS REPROVAR PC, ATIVIDADE DESTINO:" + nextSequenceId);
			log.info("ANTES DA EXECUÇÃO DO WS: PC NUMERO " + NumPedido + " // " + "NOME DO APROVADOR" +  NomAprov);			
			var result = service.reprovar(NumPedido,NomAprov);
			log.info(result);
		}
			
	
}