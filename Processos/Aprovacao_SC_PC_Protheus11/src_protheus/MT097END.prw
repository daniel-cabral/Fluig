#include 'protheus.ch'
#include 'parmtype.ch'
#include "TbiConn.ch"
#include "topconn.ch" 

/**
* Ponto de entrada responsavel por verificar se houve aprovação e disparar worflow 
* de aguardando aprovação pedido compras para proximos aprovadores
*
* @Author Leonardo Soares 
*/
user function MT097END()
	Local cAreaOld := getArea()
	Local _cQuery	:= ''


	//Caso esteja cancelando a operação, não efetuo nenhuma validação
	If PARAMIXB[3] == 1
		return
	EndIf


	If PARAMIXB[3] == 2
		cMsgObs	:= 'O pedido de compra ' + AllTrim(SC7->C7_NUM) + ' foi aprovado no ERP.'
	Else
		cMsgObs	:= 'O pedido de compra ' + AllTrim(SC7->C7_NUM) + ' foi bloqueado no ERP.'
	EndIf

	//Verifico se o registro na SC7 possui número de processo de aprovação, caso exista efetuo o encerramento da solicitação para que possa criar uma nova caso essa seja necessário
	If AllTrim(SC7->C7_XNFLUIG) <> ''
		oWS := WSECMWorkflowEngineServiceService():New()
		oWS:cusername := Lower(AllTrim(GetMv("MV_XFLGUSU")))
		oWS:cpassword := AllTrim(GetMv("MV_XFLGSEN"))
		oWS:ncompanyId := 1
		oWS:nProcessInstanceId := Val((Alltrim(SC7->C7_XNFLUIG)))
		oWS:cuserId := AllTrim(GetMv('MV_XFLGUID'))
		oWS:ccancelText := cMsgObs
		oWS:cancelInstance()
	EndIf

	//Procura nome do aprovador 
	_cQuery := " SELECT A.*"
	_cQuery += " FROM "+ RetSqlName('SCR') +" A "
	_cQuery += " WHERE A.D_E_L_E_T_ <> '*' AND A.CR_TIPO='PC' AND "
	_cQuery += " A.CR_NUM = '"+SC7->C7_NUM+"' AND A.CR_USER = '"+ __cUserId +"'"
	
	TCQUERY _cQuery NEW ALIAS "SCRTMP"
	SCRTMP->(DBGotop())
	
	DO While !SCRTMP->(Eof())
		If SCRTMP->CR_STATUS == '03'
			U_WFW120P( 0, nil )
			SCRTMP->(dBskip())			
		EndIf
		EXIT
	EndDo
	
	SCRTMP->(dbclosearea())
	RestArea(cAreaOld)
return