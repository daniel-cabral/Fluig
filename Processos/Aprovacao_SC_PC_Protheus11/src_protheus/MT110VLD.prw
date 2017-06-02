#Include "Ap5Mail.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#Include "TBICONN.CH"
#Include "dbTree.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MT110VLD
Ponto de Entrada

@protected
@author    
@since     
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------

User Function MT110VLD()

Local oWS

//Verifica se já existe solicitação Fluig desta SC em andamento. Se sim, envia o cancelamento para
//evitar duplicidade após alterações na SC.
//cusername,cpassword,ncompanyId,nprocessInstanceId,cuserId,ccancelText

//	SC1->(dbSetOrder(1))
//	SC1->(dbSeek(xFilial("SC1")+cA110Num))
	
	//Invoca o WS para cancelar a solicitação anterior à alteração
	IF PARAMIXB[1] == 6 .AND. lower(alltrim(substr(cusuario,7,15))) $ lower(Alltrim(GetMv("MV_XSCFL")))
		oWS := WSECMWorkflowEngineServiceService():New()
		oWS:cusername := Lower(AllTrim(GetMv("MV_XFLGUSU")))
		oWS:cpassword := AllTrim(GetMv("MV_XFLGSEN"))
		oWS:ncompanyId := 1
		oWS:nProcessInstanceId := Val((Alltrim(SC1->C1_XNFLUIG)))
		oWS:cuserId := AllTrim(GetMv('MV_XFLGUID'))
		oWS:ccancelText := ("A solicitação de compra " + cA110Num + " foi excluída. Este fluxo de aprovação será cancelado para novo envio com as atualizações.")
		
		oWS:cancelInstance()
		
	EndIf
	
Return