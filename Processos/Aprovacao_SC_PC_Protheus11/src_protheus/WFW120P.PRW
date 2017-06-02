#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 20/03/00
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "topconn.ch"



USER function WFW120P( nOpcao, oProcess )


Local aTmp := {}
Local lRet		:= .T.
Local aRetorno := {}
Local cNumPcFluig := ""
    
    If ValType(nOpcao) = "A"
      	nOpcao := nOpcao[1]
    Endif  

	If nOpcao == NIL
		nOpcao := 0          
	End                                                      
    
    //nOpcao := 1
    cstatus := 0
    
	If oProcess == NIL
		oProcess := TWFProcess():New( "PEDCOM", "Pedido de Compras" )
	End

	//#==================================?
	//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
	//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
	//?identificando as variaveis publicas do sistema utilizadas no codigo ?
	//?Incluido pelo assistente de conversao do AP5 IDE                    ?
	//#==================================?

	SetPrvt("CPAR,NBARRA,N_ITEM,C_MAT,C_DEST,CGRAP")
	SetPrvt("C_NUM,C_MOTIVO,N_TOTPC,CGRAPANT,N_TERMINA,N_DOHTML")
	SetPrvt("CRAIZ,NRET,NHLDHTM,NHLDSCP,CIND,C_PCANT")
	SetPrvt("N_QTDPC,N_FRTPC,A_ITENS,LCABEC,_AREGISTROS,NLIMITE")
	SetPrvt("CAB_NUM,CAB_EMIS,CAB_FORN,CAB_COND,CAB_NOME,_NI")
	SetPrvt("ARRAYCAB,ARRAYITENS,C_ITPED,NPRESUP,CAPROV,AINFO")
	SetPrvt("CMAILAP,CNOMEAP,CORIGEM,CABEC,NHDLVLR,NCOUNT")
	SetPrvt("NRESULT,CHTML,NHDLCONNECT")
    
	lPrimeira := .F.
	Do Case
		Case nOpcao == 0
			SPCIniciar( oProcess,lPrimeira )
			
//			Aviso(oProcess:oHtml:RetByName('Pedido'))
		Case nOpcao == 1
			SPCRetorno( oProcess,lPrimeira )
		Case nOpcao == 2
			SPCTimeOut( oProcess )
	End

	oProcess:Free()	
RETURN		
            



STATIC FUNCTION SPCRetorno( oProcess )
	Local lLast   := .T.
	Local _oProc  
	Local nTotal 
	
    ConOut('Pedido:'+oProcess:oHtml:RetByName('Pedido')) 
  	_Aprov :=  oProcess:oHtml:RetByName("Aprovacao")
  	
  	if oProcess:oHtml:RetByName("Aprovacao") = "S"
	    cstatus := 01

      	ConOut("Aprovando o pedido")
	  	DBSelectarea("SCR")                   // Posiciona a Liberacao
	  	DBSetorder(2)

		ConOut((xFilial("SCR")+"PC"+alltrim(oProcess:oHtml:RetByName('Pedido'))+Alltrim(oProcess:oHtml:RetByName('CR_USER'))))

		If lLast 
  			DBSelectarea("SCR")                   // Posiciona a Liberacao
		  	DBSetorder(2)
		  
	  		IF DBSeek(xFilial("SCR")+"PC"+alltrim(oProcess:oHtml:RetByName('Pedido'))+SPACE(44)+Alltrim(oProcess:oHtml:RetByName('CR_USER')))    
	    		RecLock("SCR",.f.)
	    		SCR->CR_DataLib := dDataBase
	    		SCR->CR_Obs     := ""
	    		SCR->CR_UserLib := Subs(cUsuario,7,15)
	    		SCR->CR_STATUS  := "03"
	    		MsUnLock()
	  		ENDIF  
	  
	  		dbselectarea("SC7")
	  		DBSETORDER(1)
	  		DBSeek(xFilial("SC7")+oProcess:oHtml:RetByName('Pedido'))      // Posiciona o Pedido
	  
	  		WHILE !EOF() .and. SC7->C7_Num == oProcess:oHtml:RetByName('Pedido')
	     		RecLock("SC7",.f.)
	     		SC7->C7_ConaPro := "L"
	     		MsUnLock()
	     		DBSkip()
	  		ENDDO 
	  	ELSE
	    	RecLock("SCR")
	    	SCR->CR_NIVEL := "02"
	    	MsUnlock()
        	oProcess:NewTask( "Solicitação", "\WORKFLOW\WFW120P1.HTM",.T. )	    
			oProcess:bReturn := "U_WFW120P( 1 )"        
			oProcess:cTo := "daniel.cabral@farmax.com.br"	
	    	oProcess:Start()
        	RastreiaWF("00001"+'.'+oProcess:fTaskID,"000001",'1006')   		       	    
	  	Endif	 
	ENDIF	  
      
 	/**** Aviso ao Comprador ****/		
	dbSelectArea('SC7')
	dbSetOrder(1)
	dbSeek(xFilial('SC7')+oProcess:oHtml:RetByName('Pedido'))		
 	_oProc := TWFProcess():New( "PEDCP", "Pedido para o Comprador" )		  
	
	if _Aprov == "S"
		_oProc:NewTask( "PC Aprovado", "\WORKFLOW\WFW120P2.HTM" )
		_oProc:cSubject := "PC Aprovado " + SC7->C7_NUM
	 	oHTML := _oProc:oHTML
   		oHtml:ValByName( "lbAprov" ,"SIM" )
	else		  
		_oProc:NewTask( "PC Reprovado", "\WORKFLOW\WFW120P2.HTM" )
		_oProc:cSubject := "PC Reprovado " + SC7->C7_NUM
	 	oHTML := _oProc:oHTML
   		oHtml:ValByName( "lbAprov" ,"NAO" )
	endif
	

		 
	// _oProc:bReturn := "U_WFW120P( 1 )"	
	// Preenche os dados do cabecalho
 	oHtml:ValByName( "EMISSAO", SC7->C7_EMISSAO )
	oHtml:ValByName( "FORNECEDOR", SC7->C7_FORNECE )

	
	dbSelectArea('SA2')
	dbSetOrder(1)
	dbSeek(xFilial('SA2')+SC7->C7_FORNECE)    
	oHtml:ValByName( "lb_nome", SA2->A2_NREDUZ ) 
	   

	//Pego as condiicoes de Pagamento
 	dbSelectArea('SE4')
  	DBSETORDER(1)
   	dbSeek(xFilial('SE4') + SC7->C7_COND)
    ccond := SE4->E4_DESCRI
    oHtml:ValByName( "lb_cond", CCOND ) 
   
    
    dbSelectArea('SC1')
	dbSetOrder(1)
	dbSeek(xFilial('SC1')+SC7->C7_NUMSC)
	oHtml:ValByName( "solicitante", SC1->C1_SOLICIT)
	oHtml:ValByName( "datasc", dtoc(SC1->C1_DATPRF))
	
    
		   	
	//Conta numero de cotações efetuadas
	ncot := 0
	_bQuery := " SELECT C8_NUM"
	_bQuery += " FROM " + RetSqlName('SC8') + " A "
	_bQuery += " WHERE A.D_E_L_E_T_ <> '*' AND A.C8_FILIAL='"+xfilial("SC1")+"' AND "
	_bQuery += " A.C8_NUMSC = '"+SC1->C1_NUM+"' AND A.C8_PRECO <> '0' "
	_bQuery += " GROUP BY C8_NUM,C8_FORNECE "
	TCQUERY _bQuery NEW ALIAS "BBB" 		
	BBB->(DBGotop())
			
	DO While !BBB->(Eof()) 	
		ncot := ncot + 1
		BBB->(dBskip())
    ENDDO 
    BBB->(dbclosearea()) 

   	oHtml:ValByName( "nrcot", ncot )
   
   		     
    dbSelectArea('SC7')  
   	ccompra := ""
	PswOrder(1)
	IF PswSeek(SC7->C7_USER,.t.)
		aInfo   := PswRet(1)
		ccompra := alltrim(aInfo[1,2]) 
		oHtml:ValByName( "COMPRADOR", ccompra )	
	     
	ENDIF
 	      
 	oHtml:ValByName( "PEDIDO", SC7->C7_NUM )
 	
 	
  	cNum := SC7->C7_NUM
   	
   	dbSetOrder(1)
    dbSeek(xFilial('SC7')+cNum)
    nTotal := 0
    nFrete := 0
    
    While !Eof() .and. C7_NUM = cNum
    	nTotal := nTotal + C7_TOTAL
        nFrete := nFrete + C7_VALFRE
        
        AAdd( (oHtml:ValByName( "it.item" )),C7_ITEM )
   
        		
        AAdd( (oHtml:ValByName( "it.codigo" )),C7_PRODUTO )
  
        
        dbSelectArea('SB1')
        dbSetOrder(1)
        dbSeek(xFilial('SB1')+SC7->C7_PRODUTO)

        dbSelectArea('SC7')
        IF C7_DESCRI == '0'
        	AAdd( (oHtml:ValByName( "it.descricao" )),C7_DESCRI )
        			              
		ELSE
  			AAdd( (oHtml:ValByName( "it.descricao" )), SB1->B1_DESC )
  			    
     	ENDIF
      	AAdd( (oHtml:ValByName( "it.quant" )),TRANSFORM( C7_QUANT,'@E 999,999.99' ) )
      		       
       	AAdd( (oHtml:ValByName( "it.preco" )),TRANSFORM( C7_PRECO,'@E 999,999.99' ) )	
       		                     
        AAdd( (oHtml:ValByName( "it.total" )),TRANSFORM( C7_TOTAL,'@E 999,999.99' ) )
        	                     
        AAdd( (oHtml:ValByName( "it.unid" )),C7_UM )
        	
        AAdd( (oHtml:ValByName( "it.entrega" )),dtoc(C7_DATPRF))
        	        
	    AAdd( (oHtml:ValByName( "it.obs" )),C7_OBS )
	    	
	    AAdd( (oHtml:ValByName( "it.onde" )),posicione("SC1",2,xFilial("SC1")+SC7->C7_PRODUTO+SC7->C7_NUMSC,"C1_ONDEUSA") )       		                         
		
		dbSkip()
	Enddo
    
    
    
    oHtml:ValByName( "lbValor" ,TRANSFORM( nTotal,'@E 999,999.99' ) )	
    	          	
    oHtml:ValByName( "lbFrete" ,TRANSFORM( nFrete,'@E 999,999.99' ) )
    	     	    
    oHtml:ValByName( "lbTotal" ,TRANSFORM( (nTotal+nFrete),'@E 999,999.99' ) )	
    	             	    		              	    
    oHtml:ValByName( "lbMotivo" ,oProcess:oHtml:RetByName('lbMotivo') )
    
    

    
		 //imprime as cotacoes efetuadas
	if ncot <> 0
		_bQuery := " SELECT C8_PRODUTO,B1_DESC,C8_UM,C8_QUANT,C8_PRECO,C8_TOTAL,C8_COND,C8_FORNECE,A2_NREDUZ,C8_EMISSAO,E4_DESCRI,A2_MUN,A2_EST"
		_bQuery += " FROM " + RetSqlName('SC8') + " A "
   		_bQuery += " LEFT JOIN "+RetSqlName('SA2')+" B ON B.A2_COD=A.C8_FORNECE AND B.A2_LOJA=A.C8_LOJA "
   	 	_bQuery += " LEFT JOIN "+RetSqlName('SB1')+" C ON C.B1_COD=A.C8_PRODUTO AND C.B1_FILIAL=A.C8_FILIAL "
   	 	_bQuery += " LEFT JOIN "+RetSqlName('SE4')+" D ON D.E4_CODIGO=A.C8_COND "
		_bQuery += " WHERE A.D_E_L_E_T_ <> '*' AND B.D_E_L_E_T_ <> '*' AND C.D_E_L_E_T_ <> '*' AND D.D_E_L_E_T_ <> '*' AND "
		_bQuery += " A.C8_NUMSC = '"+SC1->C1_NUM+"' AND A.C8_PRECO <> '0' AND A.C8_FILIAL='"+xfilial("SC1")+"'"
	 	_bQuery += " ORDER BY C8_PRODUTO,C8_FORNECE "
		TCQUERY _bQuery NEW ALIAS "BBB" 		
		BBB->(DBGotop())
		
		DO While !BBB->(Eof())
  			AAdd( (oHtml:ValByName( "ct.fornecedor" )),BBB->C8_FORNECE+" - "+BBB->A2_NREDUZ )
   			AAdd( (oHtml:ValByName( "ct.produto" )),BBB->C8_PRODUTO+" - "+BBB->B1_DESC )		                        
    		AAdd( (oHtml:ValByName( "ct.unid" )),BBB->C8_UM )		              
  		  	AAdd( (oHtml:ValByName( "ct.quant" )),TRANSFORM( C8_QUANT,'@E 999,999.99' ) )		              
            AAdd( (oHtml:ValByName( "ct.preco" )),TRANSFORM( C8_PRECO,'@E 999,999.99' ) )		                     
            AAdd( (oHtml:ValByName( "ct.total" )),TRANSFORM( C8_TOTAL,'@E 999,999.99' ) )		                     
            AAdd( (oHtml:ValByName( "ct.cond" )),BBB->E4_DESCRI )	 
	      	AAdd( (oHtml:ValByName( "ct.cidade" )),BBB->A2_MUN+"/"+A2_EST )		                            	              
		    BBB->(dBskip())
      	ENDDO 
       	
       	BBB->(dbclosearea())
	ENDIF         		              	    
   	      
 	dbSelectArea('SC7')
  	dbSetOrder(1)
   	dbSeek(xFilial('SC7')+cNum) 		  
	PswOrder(1)
  	
  	IF PswSeek(SC7->C7_USER,.t.)
   		aInfo   := PswRet(1)
	    cMailAp := alltrim(aInfo[1,14])	       
    ENDIF
  	
  	_oProc:cTo := cMailAp
  	_oProc:Start() 

    //avisa ao solicitante o sobre aprovação do pedido de compra
    dbSelectArea('SC7')
	dbSetOrder(1)
	dbSeek(xFilial('SC7')+oProcess:oHtml:RetByName('Pedido'))		
 	_oProc := TWFProcess():New( "PEDSC", "Pedido para o Solicitante" )		  
  	
  	IF _Aprov == "S"
		_oProc:NewTask( "PC Aprovado", "\WORKFLOW\WFW120P2.HTM" )
		_oProc:cSubject := "PC Aprovado " + SC7->C7_NUM
	 	oHTML := _oProc:oHTML
   		oHtml:ValByName( "lbAprov" ,"SIM" )
	ELSE		  
		_oProc:NewTask( "PC Reprovado", "\WORKFLOW\WFW120P2.HTM" )
		_oProc:cSubject := "PC Reprovado " + SC7->C7_NUM
	 	oHTML := _oProc:oHTML
   		oHtml:ValByName( "lbAprov" ,"NAO" )
	ENDIF
		
	ccompra := ""
	PswOrder(1)
	IF PswSeek(SC7->C7_USER,.t.)
		aInfo   := PswRet(1)
		ccompra := alltrim(aInfo[1,2])	       
	ENDIF

	oHTML := _oProc:oHTML

	// Preenche os dados do cabecalho
  	oHtml:ValByName( "EMISSAO", SC7->C7_EMISSAO )
	oHtml:ValByName( "FORNECEDOR", SC7->C7_FORNECE )    
	dbSelectArea('SA2')
	dbSetOrder(1)
	dbSeek(xFilial('SA2')+SC7->C7_FORNECE)    
	oHtml:ValByName( "lb_nome", SA2->A2_NREDUZ )    
    
    //Pego as condicoes de Pagamento
    dbSelectArea('SE4')
    DBSETORDER(1)
    dbSeek(xFilial('SE4') + SC7->C7_COND)
    ccond := SE4->E4_DESCRI
    oHtml:ValByName( "lb_cond", CCOND ) 
    
    dbSelectArea('SC1')
	dbSetOrder(1)
	dbSeek(xFilial('SC1')+SC7->C7_NUMSC)
	oHtml:ValByName( "solicitante", SC1->C1_SOLICIT)
	oHtml:ValByName( "datasc", dtoc(SC1->C1_DATPRF))
	PswOrder(1)
  	
  	IF PswSeek(SC1->C1_USER,.t.)
    	aInfo   := PswRet(1)
	    cMailAp := alltrim(aInfo[1,14])	       
    ENDIF
	 
	//Conta numero de cotações efetuadas
	ncot := 0
	_bQuery := " SELECT C8_NUM"
	_bQuery += " FROM "+RetSqlName('SC8')+" A "
	_bQuery += " WHERE A.D_E_L_E_T_ <> '*' AND A.C8_FILIAL='"+xfilial("SC1")+"' AND "
	_bQuery += " A.C8_NUMSC = '"+SC1->C1_NUM+"' AND A.C8_PRECO <> '0' "
	_bQuery += " GROUP BY C8_NUM,C8_FORNECE "
	TCQUERY _bQuery NEW ALIAS "BBB" 		
	BBB->(DBGotop())
	
	DO While !BBB->(Eof()) 	
		ncot := ncot + 1
		BBB->(dBskip())
	ENDDO 
	
	BBB->(dbclosearea()) 
	
	oHtml:ValByName( "nrcot", ncot )	     
	dbSelectArea('SC7')
 	ccompra := ""
	
	PswOrder(1)
	IF PswSeek(SC7->C7_USER,.t.)
		aInfo   := PswRet(1)
		ccompra := alltrim(aInfo[1,2]) 
		oHtml:ValByName( "COMPRADOR", ccompra )	       
	ENDIF
 	oHtml:ValByName( "PEDIDO", SC7->C7_NUM ) 
  	oHtml:ValByName( "COMPRADOR", ccompra )
	cNum := SC7->C7_NUM
	
	dbSetOrder(1)
 	dbSeek(xFilial('SC7')+cNum)
  	nTotal := 0
   	nFrete := 0
    
    While !Eof() .and. C7_NUM = cNum
    	nTotal := nTotal + C7_TOTAL
     	nFrete := nFrete + C7_VALFRE
      	AAdd( (oHtml:ValByName( "it.item" )),C7_ITEM )		
       	AAdd( (oHtml:ValByName( "it.codigo" )),C7_PRODUTO )		       
        
        dbSelectArea('SB1')
        dbSetOrder(1)
        dbSeek(xFilial('SB1')+SC7->C7_PRODUTO)
             
        dbSelectArea('SC7')		       
        
        IF C7_DESCRI == '0'
        	AAdd( (oHtml:ValByName( "it.descricao" )),C7_DESCRI )		              
        ELSE
        	AAdd( (oHtml:ValByName( "it.descricao" )), SB1->B1_DESC )		              
        ENDIF		              
        
        AAdd( (oHtml:ValByName( "it.quant" )),TRANSFORM( C7_QUANT,'@E 999,999.99' ) )		              
        AAdd( (oHtml:ValByName( "it.preco" )),TRANSFORM( C7_PRECO,'@E 999,999.99' ) )		                     
        AAdd( (oHtml:ValByName( "it.total" )),TRANSFORM( C7_TOTAL,'@E 999,999.99' ) )		                     
        AAdd( (oHtml:ValByName( "it.unid" )),C7_UM )
	    AAdd( (oHtml:ValByName( "it.entrega" )),dtoc(C7_DATPRF))		          
     	AAdd( (oHtml:ValByName( "it.obs" )),C7_OBS )
	    AAdd( (oHtml:ValByName( "it.onde" )),posicione("SC1",2,xFilial("SC1")+SC7->C7_PRODUTO+SC7->C7_NUMSC,"C1_ONDEUSA") )       		                         		                                      		              
     	
     	dbSkip()
	Enddo
    
    oHtml:ValByName( "lbValor" ,TRANSFORM( nTotal,'@E 999,999.99' ) )		              	
    oHtml:ValByName( "lbFrete" ,TRANSFORM( 0,'@E 999,999.99' ) )		              	    
    oHtml:ValByName( "lbTotal" ,TRANSFORM( (nTotal + nFrete),'@E 999,999.99' ) )		              	    		              	    
    //oHtml:ValByName( "lbMotivo" ,oProcess:oHtml:RetByName('lbMotivo') )
	//imprime as cotacoes efetuadas
	
	IF ncot <> 0
		_bQuery := " SELECT C8_PRODUTO,B1_DESC,C8_UM,C8_QUANT,C8_PRECO,C8_TOTAL,C8_COND,C8_FORNECE,A2_NREDUZ,C8_EMISSAO,E4_DESCRI,A2_MUN,A2_EST"
		_bQuery += " FROM "+RetSqlName('SC8')+" A "
  		_bQuery += " LEFT JOIN "+RetSqlName('SA2')+" B ON B.A2_COD=A.C8_FORNECE AND B.A2_LOJA=A.C8_LOJA "
   		_bQuery += " LEFT JOIN "+RetSqlName('SB1')+" C ON C.B1_COD=A.C8_PRODUTO AND C.B1_FILIAL=A.C8_FILIAL "
   	 	_bQuery += " LEFT JOIN "+RetSqlName('SE4')+" D ON D.E4_CODIGO=A.C8_COND "
		_bQuery += " WHERE A.D_E_L_E_T_ <> '*' AND B.D_E_L_E_T_ <> '*' AND C.D_E_L_E_T_ <> '*' AND D.D_E_L_E_T_ <> '*' AND "
		_bQuery += " A.C8_NUMSC = '"+SC1->C1_NUM+"' AND A.C8_PRECO <> '0' AND A.C8_FILIAL='"+xfilial("SC1")+"'"
	 	_bQuery += " ORDER BY C8_PRODUTO,C8_FORNECE "
		TCQUERY _bQuery NEW ALIAS "BBB" 		
		BBB->(DBGotop())
		
		DO While !BBB->(Eof())
   			AAdd( (oHtml:ValByName( "ct.fornecedor" )),BBB->C8_FORNECE+" - "+BBB->A2_NREDUZ )
   		 	AAdd( (oHtml:ValByName( "ct.produto" )),BBB->C8_PRODUTO+" - "+BBB->B1_DESC )		                        
    		AAdd( (oHtml:ValByName( "ct.unid" )),BBB->C8_UM )		              
  		  	AAdd( (oHtml:ValByName( "ct.quant" )),TRANSFORM( C8_QUANT,'@E 999,999.99' ) )		              
       		AAdd( (oHtml:ValByName( "ct.preco" )),TRANSFORM( C8_PRECO,'@E 999,999.99' ) )		                     
            AAdd( (oHtml:ValByName( "ct.total" )),TRANSFORM( C8_TOTAL,'@E 999,999.99' ) )		                     
            AAdd( (oHtml:ValByName( "ct.cond" )),BBB->E4_DESCRI )	  
	        AAdd( (oHtml:ValByName( "ct.cidade" )),BBB->A2_MUN+"/"+A2_EST )		                            	              
		    BBB->(dBskip())
      	ENDDO 
       	
       	BBB->(dbclosearea())
	ENDIF         		              	    
 
 	_oProc:cTo := cMailAp
  	_oProc:Start()
	wfSendMail()
 	_oProc:Finish()
Return 





STATIC FUNCTION SPCIniciar( oProcess,lPrimeira )

Local aCond		:= {}
Local nTotal 	:= 0
Local nFrete 	:= 0
Local lPrimeira := .T.
Local cMailAp   := ""
Local cNum 		:= SC7->C7_NUM

//Procura nome do aprovador 
_cQuery := " SELECT A.CR_USER"
_cQuery += " FROM "+RetSqlName('SCR')+" A "
_cQuery += " WHERE A.D_E_L_E_T_ <> '*' AND A.CR_TIPO='PC' AND "
_cQuery += " A.CR_NUM = '"+cNum+"' AND A.CR_STATUS = '02'"
TCQUERY _cQuery NEW ALIAS "AAA" 		
AAA->(DBGotop())

DO While !AAA->(Eof()) 	
	cAprov := AAA->CR_USER
	AAA->(dBskip())
	
	dbSelectArea('SC7')
    dbSetOrder(1)
	dbSeek(xFilial('SC7')+cNum) 		
	
	oProcess:NewTask( "Solicitação", "\WORKFLOW\WFW120P2.HTM" )
	oProcess:cSubject := "Liberação PC "+cNum
	oProcess:bReturn := "U_WFW120P( 1 )"
	oHTML := oProcess:oHTML
	
		//Inicia WF de aprovação via Fluig - Daniel C Santos 22/02/2017
	
	oObj := FluigStartProcess():new()
		oObj:setProcessId("aprovacao_pc") 
		oObj:setComments("Pedido " + SC7->C7_NUM + " integrado Protheus -> Fluig " + DtoS(date()))
		oObj:setCompleteTask(.T.)
		//Array Temporário para montar o CardData p/ Fluig
		aTmp := {} 
	
	/*** Preenche os dados do cabecalho ***/
	oHtml:ValByName( "EMISSAO"	 , SC7->C7_EMISSAO )
	oHtml:ValByName( "FORNECEDOR", SC7->C7_FORNECE )  
		// WS Fluig
	aadd(aTmp, {"EMISSAO", dtoc(SC7->C7_EMISSAO) })
	aadd(aTmp, {"FORNECEDOR", SC7->C7_FORNECE })
	aadd(aTmp, {"APROVADOR", cAprov})
	      

	dbSelectArea('SA2')
	dbSetOrder(1)
	dbSeek(xFilial('SA2')+SC7->C7_FORNECE)    
	oHtml:ValByName( "lb_nome", SA2->A2_NREDUZ )
	// WS Fluig
	aadd(aTmp, {"lb_nome", SA2->A2_NREDUZ })    

    //Pego as condiicoes de Pagamento
    dbSelectArea('SE4')
    DBSETORDER(1)
    dbSeek(xFilial('SE4') + SC7->C7_COND)
    ccond := SE4->E4_DESCRI
	oHtml:ValByName( "lb_cond", CCOND )
	// WS Fluig
    aadd(aTmp, {"lb_cond", CCOND }) 

	nTotal := 0 
	nFrete := 0   
	dbSelectArea('SC1')
    dbSetOrder(1)
    dbSeek(xFilial('SC1')+SC7->C7_NUMSC)
	oHtml:ValByName( "solicitante", SC1->C1_SOLICIT)
	oHtml:ValByName( "datasc", dtoc(SC1->C1_DATPRF))
	// WS Fluig
    aadd(aTmp, {"solicitante", SC1->C1_SOLICIT })
   	//Conta numero de cotações efetuadas

   	ncot := 0
	_bQuery := " SELECT C8_NUM"
	_bQuery += " FROM "+RetSqlName('SC8')+" A "
	_bQuery += " WHERE A.D_E_L_E_T_ <> '*' AND A.C8_FILIAL='"+xfilial("SC1")+"' AND "
	_bQuery += " A.C8_NUMSC = '"+SC1->C1_NUM+"' AND A.C8_PRECO <> '0' "
    _bQuery += " GROUP BY C8_NUM,C8_FORNECE "
	TCQUERY _bQuery NEW ALIAS "BBB"
	BBB->(DBGotop())
	DO While !BBB->(Eof()) 	
        ncot := ncot + 1
		BBB->(dBskip())
    ENDDO 
    BBB->(dbclosearea())

	dbSelectArea('SC7')
    PswOrder(1)
  	IF PswSeek(SC7->C7_USER,.t.)
       aInfo   := PswRet(1)
	   ccompra := alltrim(aInfo[1,2])	       
    ENDIF
	oHtml:ValByName( "nrcot"	, ncot )
	// WS Fluig
    aadd(aTmp, {"nrcot", ncot })
	oHtml:ValByName( "COMPRADOR", ccompra )
	// WS Fluig
	aadd(aTmp, {"COMPRADOR", ccompra })
	oHtml:ValByName( "PEDIDO"	, SC7->C7_NUM )
	// WS Fluig
	aadd(aTmp, {"PEDIDO", SC7->C7_NUM }) 
	aadd(aTmp, {"CCUSTO", SC7->C7_CC }) 
	oProcess:fDesc := "Pedido de Compras No "+ cNum                                                                        
    dbSetOrder(1)
    dbSeek(xFilial('SC7')+cNum)
    While !Eof() .and. C7_NUM = cNum
       	nTotal := nTotal + C7_TOTAL
       	nFrete := nFrete + C7_VALFRE
       	AAdd( (oHtml:ValByName( "it.item"   )),C7_ITEM )
       	// WS Fluig
		aadd(aTmp, {"it_item___" + StrTran(C7_ITEM,"0"), SC7->C7_ITEM }) 		
      	AAdd( (oHtml:ValByName( "it.codigo" )),C7_PRODUTO )	
      	// WS Fluig
		aadd(aTmp, {"it_codigo___" + StrTran(C7_ITEM,"0"), C7_PRODUTO })	       

       	dbSelectArea('SB1')
       	dbSetOrder(1)
       	dbSeek(xFilial('SB1')+SC7->C7_PRODUTO)
       	dbSelectArea('SC7')
       		
       	IF C7_DESCRI <> '0'
       	
       		AAdd( (oHtml:ValByName( "it.descricao" )),C7_DESCRI )
       		// WS Fluig
        	aadd(aTmp, {"it_descricao___" + StrTran(C7_ITEM,"0"), C7_DESCRI }) 			              
       	ELSE
             AAdd( (oHtml:ValByName( "it.descricao" )), SB1->B1_DESC )
             // WS Fluig
        	aadd(aTmp, {"it_descricao___" + StrTran(C7_ITEM,"0"), SB1->B1_DESC }) 	
       	ENDIF
       
       	AAdd( (oHtml:ValByName( "it.quant" )),TRANSFORM( C7_QUANT,'@E 999,999.99' ) )
       	// WS Fluig
  			aadd(aTmp, { "it_quant___" + StrTran(C7_ITEM,"0"), TRANSFORM( C7_QUANT,'@E 999,999.99' ) }) 		              
       	AAdd( (oHtml:ValByName( "it.preco" )),TRANSFORM( C7_PRECO,'@E 999,999.99' ) )
       	// WS Fluig
  			aadd(aTmp, { "it_preco___" + StrTran(C7_ITEM,"0"), TRANSFORM( C7_PRECO,'@E 999,999.99' ) })		                     
       	AAdd( (oHtml:ValByName( "it.total" )),TRANSFORM( C7_TOTAL,'@E 999,999.99' ) )
       	// WS Fluig
  			aadd(aTmp, { "it_total___" + StrTran(C7_ITEM,"0"), TRANSFORM( C7_TOTAL,'@E 999,999.99' )  })		                     
       	AAdd( (oHtml:ValByName( "it.unid" )),C7_UM )
       	// WS Fluig
  			aadd(aTmp, { "it_unid___" + StrTran(C7_ITEM,"0"), C7_UM })              
       	AAdd( (oHtml:ValByName( "it.entrega" )),dtoc(C7_DATPRF))
       	// WS Fluig
  			aadd(aTmp, { "it_entrega___" + StrTran(C7_ITEM,"0"), DtoC(C7_DATPRF) })		          
       	AAdd( (oHtml:ValByName( "it.obs" )),C7_OBS )
       	// WS Fluig
  			aadd(aTmp, { "it_obs___" + StrTran(C7_ITEM,"0"), C7_OBS })
       	//AAdd( (oHtml:ValByName( "it.onde" )),posicione("SC1",2,xFilial("SC1")+SC7->C7_PRODUTO+SC7->C7_NUMSC,"C1_ONDEUSA") )       		                         
       //AAdd( (oHtml:ValByName( "it.entrega" )),'0' )		                                                                                        
       //AAdd( (oHtml:ValByName( "it.condPag" )),CCond )		                     
       
       RecLock('SC7')
	   C7_FILENT := C7_FILIAL	
       MsUnlock()

       DBSkip()
	Enddo

    oHtml:ValByName( "lbValor" ,TRANSFORM( nTotal,'@E 999,999.99' ) )
    // WS Fluig
    	aadd(aTmp, { "lbValor" , TRANSFORM( nTotal,'@E 999,999.99' ) })    	    
    			              	
    oHtml:ValByName( "lbFrete" ,TRANSFORM( nFrete,'@E 999,999.99' ) )
    // WS Fluig
    	aadd(aTmp, { "lbFrete" , TRANSFORM( nFrete,'@E 999,999.99' ) })
    			              	    
    oHtml:ValByName( "lbTotal" ,TRANSFORM( (nTotal + nFrete),'@E 999,999.99' ) )
    // WS Fluig
    	aadd(aTmp, { "lbTotal" , TRANSFORM( nTotal + nFrete,'@E 999,999.99' ) })		              	    
	//oHtml:valByName('botoes', '<input type=submit name=B1 value=Enviar> <input type=reset name=B2 value=Limpar>')
	
    //imprime as cotacoes efetuadas
    /*
    if ncot <> 0
	   	_bQuery := " SELECT C8_PRODUTO,B1_DESC,C8_UM,C8_QUANT,C8_PRECO,C8_TOTAL,C8_COND,C8_FORNECE,A2_NREDUZ,C8_EMISSAO,E4_DESCRI,A2_MUN,A2_EST"
	   	_bQuery += " FROM SC8010 A "
   	   	_bQuery += " LEFT JOIN SA2010 B ON B.A2_COD=A.C8_FORNECE AND B.A2_LOJA=A.C8_LOJA "
   	   	_bQuery += " LEFT JOIN SB1010 C ON C.B1_COD=A.C8_PRODUTO AND C.B1_FILIAL=A.C8_FILIAL "
   	   	_bQuery += " LEFT JOIN SE4010 D ON D.E4_CODIGO=A.C8_COND "
	   	_bQuery += " WHERE A.D_E_L_E_T_ <> '*' AND B.D_E_L_E_T_ <> '*' AND C.D_E_L_E_T_ <> '*' AND D.D_E_L_E_T_ <> '*' AND "
	   	_bQuery += " A.C8_NUMSC = '"+SC1->C1_NUM+"' AND A.C8_PRECO <> '0' AND A.C8_FILIAL='"+xfilial("SC1")+"'"
       	_bQuery += " ORDER BY C8_PRODUTO,C8_FORNECE "
	   	TCQUERY _bQuery NEW ALIAS "BBB" 		
	   	BBB->(DBGotop())
	   	
	   	DO While !BBB->(Eof())
          	AAdd( (oHtml:ValByName( "ct.fornecedor" )),BBB->C8_FORNECE+" - "+BBB->A2_NREDUZ )
          	AAdd( (oHtml:ValByName( "ct.produto" )),BBB->C8_PRODUTO+" - "+BBB->B1_DESC )		                        
          	AAdd( (oHtml:ValByName( "ct.unid" )),BBB->C8_UM )		              
          	AAdd( (oHtml:ValByName( "ct.quant" )),TRANSFORM( C8_QUANT,'@E 999,999.99' ) )		              
          	AAdd( (oHtml:ValByName( "ct.preco" )),TRANSFORM( C8_PRECO,'@E 999,999.99' ) )		                     
          	AAdd( (oHtml:ValByName( "ct.total" )),TRANSFORM( C8_TOTAL,'@E 999,999.99' ) )		                     
          	AAdd( (oHtml:ValByName( "ct.cond" )),BBB->E4_DESCRI )		              
          	AAdd( (oHtml:ValByName( "ct.cidade" )),BBB->A2_MUN+"/"+A2_EST )		              
		  	BBB->(dBskip())
       	ENDDO 
       	
       	BBB->(dbclosearea())
    ENDIF
    */
    
	PswOrder(1)
	
	IF PswSeek(cAprov,.t.)
 		aInfo   := PswRet(1)
        cMailAp += alltrim(aInfo[1,14])+";"
        
        // WS Fluig
        	aadd(aTmp, {"APROVADOR", alltrim(aInfo[1,14]) })
        	aadd(aTmp, {"EMPRESA", SM0->M0_CODIGO })
        	aadd(aTmp, {"FILIAL", SM0->M0_CODFIL })  	

        IF AAA->(Eof())            						//!empty(aInfo[1,14])
        	//oHtml:ValByName( "cr_user", cAprov )
	        //cMailAp := alltrim(aInfo[1,14])+";"
			oProcess:ClientName( Subs(cUsuario,7,15) )
			oProcess:cTo := cMailAp
		   	//oProcess:Start()
		   	//oProcess:Finish()
		 
		 //Monta o array do CardData para Fluig  	
		   	oObj:setCardData(aTmp)
    
    
		 // Envia os dados para Fluig
			
			lRet := oObj:Send()
			aRetorno := oObj:getResponse()
			cNumPcFluig := oObj:getResponse():Result:Iprocess
			
			
			SC7->(dbSelectArea('SC7'))
			SC7->(dbSetOrder(1))
			If SC7->(dbSeek(xFilial('SC7')+cNum))
				While ! SC7->(Eof()) .and. SC7->C7_NUM = cNum
					RecLock('SC7', .F.)
					SC7->C7_XNFLUIG := cNumPcFluig
					MsUnlock()
					SC7->(dbSkip())
				EndDo
			EndIf
	  	ENDIF
    ENDIF

ENDDO

AAA->(dbclosearea())    

Return(.T.)
           


STATIC FUNCTION Aviso(cNumeroPed)


//Avisa ao solicitante o sobre a inserção do pedido de compra 
dbSelectArea('SC7')
dbSetOrder(1)
dbSeek(xFilial('SC7')+cNumeroPed)		
_oProc := TWFProcess():New( "PEDSC", "Pedido para o Solicitante" )		  
_oProc:NewTask( "SC -> PC", "\WORKFLOW\HTM\WFW120P3.HTM" )
_oProc:cSubject := "SC -> PC " + SC7->C7_NUM + " aguardando aprovação"
oHTML := _oProc:oHTML
oHtml:ValByName( "EMISSAO"   , SC7->C7_EMISSAO )
oHtml:ValByName( "FORNECEDOR", SC7->C7_FORNECE )    
		  
dbSelectArea('SA2')
dbSetOrder(1)
dbSeek(xFilial('SA2')+SC7->C7_FORNECE)    
oHtml:ValByName( "lb_nome", SA2->A2_NREDUZ )    
    	  
//Pego as condicoes de Pagamento
dbSelectArea('SE4')
DBSETORDER(1)
dbSeek(xFilial('SE4') + SC7->C7_COND)
ccond := SE4->E4_DESCRI
oHtml:ValByName( "lb_cond", CCOND ) 
          	
dbSelectArea('SC1')
dbSetOrder(1)
dbSeek(xFilial('SC1')+SC7->C7_NUMSC)
oHtml:ValByName( "solicitante", SC1->C1_SOLICIT)
oHtml:ValByName( "datasc", dtoc(SC1->C1_DATPRF))
PswOrder(1)
IF PswSeek(SC1->C1_USER,.t.)
	aInfo   := PswRet(1)
	cMailAp := alltrim(aInfo[1,14])	       
ENDIF

//Conta numero de cotações efetuadas
ncot := 0
_bQuery := " SELECT C8_NUM"
_bQuery += " FROM "+RetSqlName('SC8')+" A "
_bQuery += " WHERE A.D_E_L_E_T_ <> '*' AND A.C8_FILIAL='"+xfilial("SC1")+"' AND "
_bQuery += " A.C8_NUMSC = '"+SC1->C1_NUM+"' AND A.C8_PRECO <> '0' "
_bQuery += " GROUP BY C8_NUM,C8_FORNECE "
TCQUERY _bQuery NEW ALIAS "BBB" 		
BBB->(DBGotop())

DO While !BBB->(Eof()) 	
	ncot := ncot + 1
	BBB->(dBskip())
ENDDO 
BBB->(dbclosearea()) 

oHtml:ValByName( "nrcot", ncot )	     

dbSelectArea('SC7')
oHtml:ValByName( "PEDIDO", SC7->C7_NUM ) 
//oHtml:ValByName( "COMPRADOR", ccompra )
cNum := SC7->C7_NUM
dbSetOrder(1)
dbSeek(xFilial('SC7')+cNum)
nTotal := 0
nFrete := 0
While !Eof() .and. C7_NUM = cNum
	nTotal := nTotal + C7_TOTAL
 	nFrete := nFrete + C7_VALFRE             
  	AAdd( (oHtml:ValByName( "it.item" )),C7_ITEM )		
   	AAdd( (oHtml:ValByName( "it.codigo" )),C7_PRODUTO )		       
		     
	dbSelectArea('SB1')
	dbSetOrder(1)
	dbSeek(xFilial('SB1')+SC7->C7_PRODUTO)
	dbSelectArea('SC7')
	IF C7_DESCRI <> '0'
 		AAdd( (oHtml:ValByName( "it.descricao" )),C7_DESCRI )		              
   	ELSE
    	AAdd( (oHtml:ValByName( "it.descricao" )), SB1->B1_DESC )		              
	ENDIF
    AAdd( (oHtml:ValByName( "it.quant" )),TRANSFORM( C7_QUANT,'@E 999,999.99' ) )		              
    AAdd( (oHtml:ValByName( "it.preco" )),TRANSFORM( C7_PRECO,'@E 999,999.99' ) )		                     
    AAdd( (oHtml:ValByName( "it.total" )),TRANSFORM( C7_TOTAL,'@E 999,999.99' ) )		                     
    AAdd( (oHtml:ValByName( "it.unid" )),C7_UM )
    AAdd( (oHtml:ValByName( "it.entrega" )),dtoc(C7_DATPRF))		          
    AAdd( (oHtml:ValByName( "it.obs" )),C7_OBS )
    AAdd( (oHtml:ValByName( "it.onde" )),posicione("SC1",2,xFilial("SC1")+SC7->C7_PRODUTO+SC7->C7_NUMSC,"C1_ONDEUSA") )       		                         
    
    DBSkip()
Enddo

oHtml:ValByName( "lbValor" ,TRANSFORM( nTotal,'@E 999,999.99' ) )		              	
oHtml:ValByName( "lbFrete" ,TRANSFORM( nFrete,'@E 999,999.99' ) )		              	    
oHtml:ValByName( "lbTotal" ,TRANSFORM( (nTotal + nFrete),'@E 999,999.99' ) )		              	    		              	    
//oHtml:ValByName( "lbMotivo" ,oProcess:oHtml:RetByName('lbMotivo') )

//imprime as cotacoes efetuadas
if ncot <> 0
	_bQuery := " SELECT C8_PRODUTO,B1_DESC,C8_UM,C8_QUANT,C8_PRECO,C8_TOTAL,C8_COND,C8_FORNECE,A2_NREDUZ,C8_EMISSAO,E4_DESCRI,A2_MUN,A2_EST"
	_bQuery += " FROM "+RetSqlName('SC8')+" A "
   	_bQuery += " LEFT JOIN "+RetSqlName('SA2')+" B ON B.A2_COD=A.C8_FORNECE AND B.A2_LOJA=A.C8_LOJA "
   	_bQuery += " LEFT JOIN "+RetSqlName('SB1')+" C ON C.B1_COD=A.C8_PRODUTO AND C.B1_FILIAL=A.C8_FILIAL "
   	_bQuery += " LEFT JOIN "+RetSqlName('SE4')+" D ON D.E4_CODIGO=A.C8_COND "
	_bQuery += " WHERE A.D_E_L_E_T_ <> '*' AND B.D_E_L_E_T_ <> '*' AND C.D_E_L_E_T_ <> '*' AND D.D_E_L_E_T_ <> '*' AND "
	_bQuery += " A.C8_NUMSC = '"+SC1->C1_NUM+"' AND A.C8_PRECO <> '0' AND A.C8_FILIAL='"+xfilial("SC1")+"'"
	_bQuery += " ORDER BY C8_PRODUTO,C8_FORNECE "
	TCQUERY _bQuery NEW ALIAS "BBB" 		
	BBB->(DBGotop())
	
	DO While !BBB->(Eof())
		AAdd( (oHtml:ValByName( "ct.fornecedor" )),BBB->C8_FORNECE+" - "+BBB->A2_NREDUZ )
   		AAdd( (oHtml:ValByName( "ct.produto" )),BBB->C8_PRODUTO+" - "+BBB->B1_DESC )		                        
    	AAdd( (oHtml:ValByName( "ct.unid" )),BBB->C8_UM )		              
  		AAdd( (oHtml:ValByName( "ct.quant" )),TRANSFORM( C8_QUANT,'@E 999,999.99' ) )		              
        AAdd( (oHtml:ValByName( "ct.preco" )),TRANSFORM( C8_PRECO,'@E 999,999.99' ) )		                     
        AAdd( (oHtml:ValByName( "ct.total" )),TRANSFORM( C8_TOTAL,'@E 999,999.99' ) )		                     
        AAdd( (oHtml:ValByName( "ct.cond" )),BBB->E4_DESCRI )
        AAdd( (oHtml:ValByName( "ct.cidade" )),BBB->A2_MUN+"/"+A2_EST )		                            		              
		
		BBB->(dBskip())
	ENDDO 
    BBB->(dbclosearea())
ENDIF         		              	    

_oProc:cTo := cMailAp
_oProc:Start()
wfSendMail()
//RastreiaWF("00001"+'.'+_oProc:fTaskID,"000001",'1007',"Pedido de Compras "+cNum+" Aprovado. Enviado para o Fornecedor")	     
_oProc:Finish()    

Return(.T.) 
     





STATIC FUNCTION SPCTimeOut( oProcess )
  ConOut("Funcao de TIMEOUT executada")  
  oProcess:NewTask('Time Out',"\workflow\EVENTO\timeout.htm")
  oHtml:=oProcess:oHtml
  oHtml:RetByName("Titulo","Usuario não respondeu e-mail")
  oHtml:RetByName("numPed",_cPedido)
  oHtml:RetByName("cliente",_ccliente)
  _cUser = Subs(cUsuario,7,15)
  oHtml:RetByName("usuario",_cUser)
  subj := "Pedido"+ _cPedido + " por " + _ccliente
  oProcess:Start() 
  WFSendMail()
Return 




STATIC FUNCTION TestProcess(oProc)
  	oHTML := oProc:oHTML
  	ConOut("abe")
	oProc:cTo := "daniel.cabral@farmax.com.br"	
    oProc:Start()
    WFSendMail()
RETURN .T.




STATIC FUNCTION SeekEml(cAprovador)  
  	PswOrder(1)

	IF PswSeek(cAprovador,.t.)
       aInfo   := PswRet(1)
	   cMailAp := alltrim(aInfo[1,14])
	   conout ("Email do Aprovador" + cMailAp)	   
    ENDIF
RETURN  