User Function MT110END()

Local nNumSC := PARAMIXB[1]       // Numero da Solicitação de compras 
Local nOpca  := PARAMIXB[2]       // 1 = Aprovar; 2 = Rejeitar; 3 = Bloquear
Local cDscOpc:= '' 

	If Alltrim(SC1->C1_XNFLUIG) <> ''

		If nOpca == 1
			cDscOpc := "aprovada"
		ElseIf nOpca == 2
			cDscOpc := "rejeitada"
		Else
			//Caso seja acao de bloqueio da solicitacao de compra, não executo o bloco para finalizar o processo no fluig.
			cDscOpc := "bloqueada"
			Return
		EndIf
	
	
		// Validações do Usuario
	
		oWS := WSECMWorkflowEngineServiceService():New()
		oWS:cusername := Lower(AllTrim(GetMv("MV_XFLGUSU")))
		oWS:cpassword := AllTrim(GetMv("MV_XFLGSEN"))
		oWS:ncompanyId := 1
		oWS:nProcessInstanceId := Val((Alltrim(SC1->C1_XNFLUIG)))
		oWS:cuserId := AllTrim(GetMv('MV_XFLGUID'))
		oWS:ccancelText := ("A solicitação de compra " + nNumSC + " foi "+ cDscOpc +" via Protheus.")
		
		oWS:cancelInstance()
	EndIf

Return