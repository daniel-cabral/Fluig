#INCLUDE "PROTHEUS.CH"

#DEFINE CTRL CHR(13)+CHR(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} M110STTS
PONTO DE ENTRADA EXECUTADO APÓS GRAVAR A SOLICITAÇÃO DE COMPRAS

@protected
@author    
@since     
@obs       
		L = ABERTO (liberada)
		R = REJEITADA
		B = BLOQUEADA

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
user function M110STTS

	Local aArea := GetArea()
	Local oWS
	
	Local cAprovar := "B"    
	Local nQtdLibe := 0
	Local nQtdSoli := 0
	Local lRet		:= .T.
	Local cSolicitante := SC1->C1_SOLICIT
	Local cXNumFluig := SC1->C1_XNFLUIG
	Local cNumFluig	:= ''
	                      
	                      
	//PERCORRE TODOS OS PRODUTOS DA SOLICITACAO
	//E VERIFICA SE TODOS TEM LIBERACAO AUTOMATICA
	SC1->(dbSetOrder(1))
	SC1->(dbSeek(xFilial("SC1")+PARAMIXB[1]))
		
	While SC1->(! Eof()) .And. SC1->C1_FILIAL == xFilial("SC1") .AND. SC1->C1_NUM == PARAMIXB[1]
			
		nQtdSoli++;
	
		lRet := U_MCCOMV01(SC1->C1_CC,"C")
	
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+SC1->C1_PRODUTO))
	
		If SB1->(! Eof())
	
			SBM->(dbSetOrder(1))
			SBM->(dbSeek(xFilial("SBM")+SB1->B1_GRUPO))
	
			If SBM->(! Eof()) .And. SBM->BM_AUTOAPR .And. lRet
				nQtdLibe++
			EndIf
	
		EndIf
	
		lRet	:= .T.
			
		SC1->(dbskip())
	
	EndDo

	//Verifica se já existe solicitação Fluig desta SC em andamento. Se sim, envia o cancelamento para
	//evitar duplicidade após alterações na SC.
	//cusername,cpassword,ncompanyId,nprocessInstanceId,cuserId,ccancelText


	SC1->(dbSetOrder(1))
	SC1->(dbSeek(xFilial("SC1")+cA110Num))
	//Invoca o WS para cancelar a solicitação anterior à alteração
	IF !INCLUI .AND. AllTrim(cXNumFluig) <> ''
		oWS := WSECMWorkflowEngineServiceService():New()
		oWS:cusername := Lower(AllTrim(GetMv("MV_XFLGUSU")))
		oWS:cpassword := AllTrim(GetMv("MV_XFLGSEN"))
		oWS:ncompanyId := 1
		oWS:nProcessInstanceId := Val((Alltrim(cXNumFluig)))
		oWS:cuserId := AllTrim(GetMv('MV_XFLGUID'))
		oWS:ccancelText := ("A solicitação de compra " + cA110Num + " foi alterada. Este fluxo de aprovação será cancelado para novo envio com as atualizações.")
		
		oWS:cancelInstance()
	EndIf
	
	If (nQtdSoli == nQtdLibe)
		cAprovar := "L"
	Else
		Aviso("A T E N C A O",	"Sua solicitação de compras possui " + AllTrim(Str(nQtdSoli)) + " iten(s), "+CTRL+;
										"dos quais " + trim(str(nQtdSoli - nQtdLibe)) + " não possuem liberação automática. "+CTRL+;
										"Por este motivo sua solicitação de compras não será aprovada automaticamente.",{"OK"})
	
	//Dispara SC Fluig se a solicitação tiver pelo menos um item bloqueado.
	
		// Cria a instância do serviço POST
		oObj := FluigStartProcess():new() 
		
		 nPosOBS 			:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_OBS"})    	
		 nPosCC 			:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_CC"})    
		 nPosQuant 			:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_QUANT"})    
		 nPosDescri 		:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_DESCRI"})    
		 nPosProduto		:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_PRODUTO"}) 
		 nPosUm				:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_UM"})   
		 nPosItem 			:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_ITEM"})   
		 nPosDatPrf			:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_DATPRF"})  
		
		oObj:setProcessId("aprovacao_sc") 
		oObj:setComments("Solicitacao " + cA110Num + " integrada Protheus -> Fluig " + DtoS(date()))
		oObj:setCompleteTask(.T.) 
		aTmp := {}
		aadd(aTmp, {"C1_NUM", AllTrim(cA110Num) })
		aadd(aTmp, {"C1_EMISSAO", DtoC(dDataBase) })
		aadd(aTmp, {"C1_CC", AllTrim(cCentroCusto) })
		aadd(aTmp, {"C1_SOLICIT",  cSolicitante })
		aadd(aTmp, {"C1_NOMAPRO",  Lower(AllTrim(cEmailApr)) })  
		
		For nI := 1 To Len(aCols)
			
			aadd(aTmp, {"C1_ITEM___" + cValToChar(nI), aCols[nI][nPosItem]})
			aadd(aTmp, {"C1_PRODUTO___" + cValToChar(nI), aCols[nI][nPosProduto]})
			aadd(aTmp, {"C1_DESCRI___" + cValToChar(nI), aCols[nI][nPosDescri]})
			aadd(aTmp, {"C1_UM___" + cValToChar(nI), aCols[nI][nPosUm]})
			aadd(aTmp, {"C1_QUANT___" + cValToChar(nI), TransForm(aCols[nI][nPosQuant],PesqPict("SC1","C1_QUANT"))})
			aadd(aTmp, {"C1_DATPRF___" + cValToChar(nI), DtoC(aCols[nI][nPosDatPrf])})
			aadd(aTmp, {"C1_OBS___" + cValToChar(nI), FwNoAccent(aCols[nI][nPosOBS])})
			
		Next
		
		aadd(aTmp, {"EMPRESA", SM0->M0_CODIGO })
		aadd(aTmp, {"FILIAL", SM0->M0_CODFIL })
		
		oObj:setCardData(aTmp)
		
		lRet := oObj:Send() 
		
		If lRet == .T.
			aRetorno := oObj:getResponse()
			cNumFluig := oObj:getResponse():Result:Iprocess
		Else
			Alert("Falha ao enviar a solicitação de aprovação via Fluig.")
		EndIf
		
		//Fim do disparo do WS Fluig
	
	
	EndIf
	
	SC1->(dbSetOrder(1))
	SC1->(dbSeek(xFilial("SC1")+PARAMIXB[1]))
		
	While SC1->(! Eof()) .And. SC1->C1_FILIAL == xFilial("SC1") .AND. SC1->C1_NUM == PARAMIXB[1]
	
		RecLock("SC1",.F.)
		SC1->C1_APROV := cAprovar 
		MsUnLock()
			
		dbSkip()
	
	EndDo
		
	RestArea(aArea)	
	
	//Grava número da solicitação Fluig na SC
	If AllTrim(cNumFluig) <> ''
		dbSelectArea("SC1")
		SC1->( dbSetOrder( 1 ) )
		dbGoTop()
		If dbSeek(xFilial("SC1") + cA110Num, .F.)
			While ! EOF() .AND. SC1->C1_NUM = cA110Num
				RecLock("SC1", .F.)
				SC1->C1_XNFLUIG := cNumFluig
	 			MsUnlock()	
				dbSkip()
			EndDo
		EndIf
		
		dbCloseArea()
	EndIf

Return