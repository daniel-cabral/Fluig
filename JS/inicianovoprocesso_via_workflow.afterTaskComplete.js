function afterTaskComplete(colleagueId,nextSequenceId,userList){
	// Igor Rodrigues - Junho-2017
	//var especialista = hAPI.getCardValue("especialista");
	var id_especialista = hAPI.getCardValue("id_especialista");
	var tem_especialista = hAPI.getCardValue("tem_especialista");
	
	var id_sel_aprovador_nvl1 = hAPI.getCardValue("id_sel_aprovador_nvl1");
	var sel_aprovador_nvl1 = hAPI.getCardValue("sel_aprovador_nvl1");
	
	var dt_solicitacao = hAPI.getCardValue("dt_solicitacao");
	var hr_solicitacao = hAPI.getCardValue("hr_solicitacao");
	var id_solicitante = hAPI.getCardValue("id_solicitante");
	var nm_solicitante = hAPI.getCardValue("nm_solicitante");
	
	var periodo_conta = hAPI.getCardValue("periodo_conta");
	var cod_filial = hAPI.getCardValue("cod_filial");
	var cod_filial_oculto = hAPI.getCardValue("cod_filial_oculto");
	var nm_filial = hAPI.getCardValue("nm_filial");
	var nm_filial_oculto = hAPI.getCardValue("nm_filial_oculto");
	
	var nm_conta = hAPI.getCardValue("nm_conta");
	var nm_conta_oculto = hAPI.getCardValue("nm_conta_oculto");
	var saldo_conta = hAPI.getCardValue("saldo_conta");
	var orcado_conta = hAPI.getCardValue("orcado_conta");
	var descricao_despesa = hAPI.getCardValue("descricao_despesa");
	
	
	if (tem_especialista == "sim"){
	   
    var processId       = "WFDESPESASESPECIALISTA";
    var ativDest        = 7;
    var listaColab      = new java.util.ArrayList();
    listaColab.add(id_sel_aprovador_nvl1);
    var obs             = "";
    var completarTarefa = true;
    var valoresForm     = new java.util.HashMap();  
    var modoGestor      = false;
     
    valoresForm.put("nm_solicitante", nm_solicitante);
    valoresForm.put("dt_solicitacao", dt_solicitacao);
    valoresForm.put("hr_solicitacao", hr_solicitacao);
    valoresForm.put("id_solicitante", id_solicitante);
   
    valoresForm.put("periodo_conta", periodo_conta);
    valoresForm.put("cod_filial", cod_filial);
    valoresForm.put("cod_filial_oculto", cod_filial_oculto);
    valoresForm.put("nm_filial", nm_filial);
    valoresForm.put("nm_conta", nm_conta);
    valoresForm.put("saldo_conta", saldo_conta);
    valoresForm.put("orcado_conta", orcado_conta);
    valoresForm.put("descricao_despesa", descricao_despesa);
    valoresForm.put("sel_aprovador_nvl1", sel_aprovador_nvl1);
    valoresForm.put("periodo_conta", periodo_conta);
    valoresForm.put("cod_filial", cod_filial);
    valoresForm.put("cod_filial_oculto", cod_filial_oculto);
    valoresForm.put("nm_filial", nm_filial);
    valoresForm.put("nm_filial_oculto", nm_filial_oculto);
    valoresForm.put("nm_conta", nm_conta);
    valoresForm.put("nm_conta_oculto", nm_conta_oculto);
    valoresForm.put("saldo_conta", saldo_conta);
    valoresForm.put("orcado_conta", orcado_conta);
    valoresForm.put("descricao_despesa", descricao_despesa);
    valoresForm.put("sel_aprovador_nvl1", sel_aprovador_nvl1);
    valoresForm.put("id_sel_aprovador_nvl1", id_sel_aprovador_nvl1);
   
    
    //valoresForm.put("especialista", especialista);
    valoresForm.put("id_especialista", id_especialista);
     
    var retorno = hAPI.startProcess(processId, parseInt(ativDest), listaColab, obs, completarTarefa, valoresForm, modoGestor);
     
    log.info(retorno);
     
    log.info(retorno.get("iProcess"));
	
	}
	
	if (tem_especialista == "nao"){
		   
	    var processId       = "WFAPRVSEMESP";
	    var ativDest        = 6;
	    var listaColab      = new java.util.ArrayList();
	    listaColab.add(id_sel_aprovador_nvl1);
	    var obs             = "";
	    var completarTarefa = true;
	    var valoresForm     = new java.util.HashMap();  
	    var modoGestor      = false;
	     
	    valoresForm.put("nm_solicitante", nm_solicitante);
	    valoresForm.put("dt_solicitacao", dt_solicitacao);
	    valoresForm.put("hr_solicitacao", hr_solicitacao);
	    valoresForm.put("id_solicitante", id_solicitante);
	   
	    valoresForm.put("periodo_conta", periodo_conta);
	    valoresForm.put("cod_filial", cod_filial);
	    valoresForm.put("cod_filial_oculto", cod_filial_oculto);
	    valoresForm.put("nm_filial", nm_filial);
	    valoresForm.put("nm_conta", nm_conta);
	    valoresForm.put("saldo_conta", saldo_conta);
	    valoresForm.put("orcado_conta", orcado_conta);
	    valoresForm.put("descricao_despesa", descricao_despesa);
	    valoresForm.put("sel_aprovador_nvl1", sel_aprovador_nvl1);
	    valoresForm.put("periodo_conta", periodo_conta);
	    valoresForm.put("cod_filial", cod_filial);
	    valoresForm.put("cod_filial_oculto", cod_filial_oculto);
	    valoresForm.put("nm_filial", nm_filial);
	    valoresForm.put("nm_filial_oculto", nm_filial_oculto);
	    valoresForm.put("nm_conta", nm_conta);
	    valoresForm.put("nm_conta_oculto", nm_conta_oculto);
	    valoresForm.put("saldo_conta", saldo_conta);
	    valoresForm.put("orcado_conta", orcado_conta);
	    valoresForm.put("descricao_despesa", descricao_despesa);
	    valoresForm.put("sel_aprovador_nvl1", sel_aprovador_nvl1);
	    valoresForm.put("id_sel_aprovador_nvl1", id_sel_aprovador_nvl1);
	    
	    //valoresForm.put("especialista", especialista);
	     
	    var retorno = hAPI.startProcess(processId, parseInt(ativDest), listaColab, obs, completarTarefa, valoresForm, modoGestor);
	     
	    log.info(retorno);
	     
	    log.info(retorno.get("iProcess"));
	     
	    hAPI.setCardValue("nrSolicCriada",retorno.get("iProcess"));

		
		
		}
		
	
	
	
	
	
	
}