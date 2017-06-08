#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
 
WSRESTFUL cliente DESCRIPTION "Exemplo de serviço REST Cliente"
 
WSDATA codigo	AS String
 
WSMETHOD GET DESCRIPTION "Exemplo de retorno de entidade(s)" WSSYNTAX "/cliente || /cliente/NomeCliente"
 
END WSRESTFUL
 
WSMETHOD GET WSRECEIVE codigo WSSERVICE cliente

	Local cQuery  := ""
	Local cAlias1 := GetNextAlias()
	Local nX      := 0
	 
	::SetContentType("application/json")	// define o tipo de retorno do método
 
	If Len(::aURLParms) > 0
	
		ConOut("PARAMETRO1 "+::aURLParms[1])	
		
	  	// exemplo de retorno de uma lista de objetos JSON
	  	cQuery := " SELECT A1_COD,"
	  	cQuery += "        A1_LOJA,"
	  	cQuery += "        A1_NOME,"
	  	cQuery += "        A1_NREDUZ,"
	  	cQuery += "        A1_BAIRRO,"
	  	cQuery += "        A1_MUN"
	  	cQuery += " FROM "+RetSQLName("SA1")
	  	cQuery += " WHERE A1_FILIAL = '"+ xFilial("SA1") +"'"
	  	cQuery += "   AND A1_NOME LIKE '"+ Upper( ::aURLParms[1] )+"%'"
	  	cQuery += "   AND D_E_L_E_T_<>'*'"
  		cQuery := ChangeQuery( cQuery )
  		dbUseArea( .T.,"TOPCONN",TcGenQry( ,,cQuery ),cAlias1,.F.,.T. )

  		::SetResponse('[')
  		  		
  		While ( cAlias1 )->( !EOF() )

			If nX >= 1
      		::SetResponse(',')
    		EndIf
    	
    	//::SetResponse('{"id":' + ::aURLParms[1] + ', "name":"Igor"}')
    		
	    	::SetResponse('{"id":'		+ CHR(34) + cValToChar(nX) + CHR(34) +;
	    					  ',"cod":'  	+ CHR(34) + AllTrim( ( cAlias1 )->A1_COD )	+ CHR(34) +;
	    					  ',"loja":'	+ CHR(34) + AllTrim( ( cAlias1 )->A1_LOJA )	+ CHR(34) +;
	    					  ',"nome":'	+ CHR(34) + AllTrim( ( cAlias1 )->A1_NOME )	+ CHR(34) +;
	    					  ',"nomred":'	+ CHR(34) + AllTrim( ( cAlias1 )->A1_NREDUZ )+ CHR(34) +;
							  ',"bairro":'	+ CHR(34) + AllTrim( ( cAlias1 )->A1_BAIRRO )+ CHR(34) +;	    					  
	    	              ',"Munic":'	+ CHR(34) + AllTrim( ( cAlias1 )->A1_MUN )	+ CHR(34) + '}')
	    	
	    	nX++
	    	
  			( cAlias1 )->( dbSkip() )
  			
  		EndDo
  	
  		::SetResponse(']')
  			
  		( cAlias1 )->( dbCloseArea() )	
 
	Else
	
	// as propriedades da classe receberão os valores enviados por querystring
	  	// exemplo: http://localhost:8080/sample?nome=1&codigo=10
	  	//DEFAULT ::nome := "1", ::codigo := "5"
 
	  	// exemplo de retorno de uma lista de objetos JSON
	  	cQuery := " SELECT A1_COD,"
	  	cQuery += "        A1_LOJA,"
	  	cQuery += "        A1_NOME,"
	  	cQuery += "        A1_NREDUZ,"
	  	cQuery += "        A1_BAIRRO,"
	  	cQuery += "        A1_MUN"	  	
	  	cQuery += " FROM "+RetSQLName("SA1")
	  	cQuery += " WHERE A1_FILIAL ='"+xFilial("SA1")+"'"
	  	cQuery += "   AND D_E_L_E_T_<>'*'"
  		cQuery := ChangeQuery( cQuery )
  		dbUseArea( .T.,"TOPCONN",TcGenQry( ,,cQuery ),cAlias1,.F.,.T. )

  		::SetResponse('[')
  		  		
  		While ( cAlias1 )->( !EOF() )
  		
			If nX >= 1
      		::SetResponse(',')
    		EndIf
    		
	    	::SetResponse('{"id":'		+ CHR(34) + cValToChar(nX) + CHR(34) +;
	    					  ',"cod":'  	+ CHR(34) + AllTrim( ( cAlias1 )->A1_COD )	+ CHR(34) +;
	    					  ',"loja":'	+ CHR(34) + AllTrim( ( cAlias1 )->A1_LOJA )	+ CHR(34) +;
	    					  ',"nome":'	+ CHR(34) + AllTrim( ( cAlias1 )->A1_NOME )	+ CHR(34) +;
	    					  ',"nomred":'	+ CHR(34) + AllTrim( ( cAlias1 )->A1_NREDUZ )+ CHR(34) +;
							  ',"bairro":'	+ CHR(34) + AllTrim( ( cAlias1 )->A1_BAIRRO )+ CHR(34) +;	    					  
	    	              ',"Munic":'	+ CHR(34) + AllTrim( ( cAlias1 )->A1_MUN )	+ CHR(34) + '}')
	    	
	    	nX++
	    	
  			( cAlias1 )->( dbSkip() )
  			
  		EndDo
  	
  		::SetResponse(']')
  		  			
  		( cAlias1 )->( dbCloseArea() )
  		 
	EndIf
	
Return(.T.)