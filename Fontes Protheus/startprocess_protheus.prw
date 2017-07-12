#include "Totvs.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � AFEWS04 � Autor � Igor Rodrigues     � Data � 20/03/2017  ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao para consumo do Metodo startProcess do Fluig        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Cliente                                         ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function AFEWS04()

	Local cTexto	:= ""
	Local nX		:= 0
	Local oWSDL
	Local oWSitem
	Local oNome
	Local oEmail
	
	oWSDL := WSECMWorkflowEngineServiceService():New()
		
	oWSDL:cusername 		:= "integra"
	oWSDL:cpassword 		:= "integra" 
	oWSDL:ncompanyId 		:= 2
	oWSDL:cprocessId 		:= "001-LiberacaoPedidoVenda"
	oWSDL:nchoosedState	:= 4
	
	oWSDL:ccomments 		:= "Solicita��o de Pedido de Venda do Protheus"
	oWSDL:cuserId 		:= "denis.rodrigues" 
	oWSDL:lcompleteTask	:= .T.
	
	oWSDL:oWSstartProcessattachments := WsClassNew("ECMWorkflowEngineServiceService_processAttachmentDtoArray")
	oWSDL:oWSstartProcessattachments:oWSitem := {}
	
	//oWSDL:oWSstartProcessArray := WsClassNew("WSECMWorkflowEngineServiceService_stringArray")
	oWSDL:oWSstartProcessArray:oWSitem := {}
	
	/*cardData*/		
	oWSDL:oWSstartProcessItem1:cItem  := {"emailUsuarioAbertura"	,"denis.rodrigues@totvs.com.br"	}
	aAdd( oWSDL:oWSstartProcessArray:oWSitem, oWSDL:oWSstartProcessItem1:cItem  )
	
	oWSDL:oWSstartProcessItem2:cItem  := {"nomeUsuarioAbertura"		,"D�nis Rodrigues"				}
	aAdd( oWSDL:oWSstartProcessArray:oWSitem, oWSDL:oWSstartProcessItem2:cItem  )
	
	oWSDL:oWSstartProcessItem3:cItem  := {"c5_num"				,"123456"						}
	aAdd( oWSDL:oWSstartProcessArray:oWSitem, oWSDL:oWSstartProcessItem3:cItem  )
	
	oWSDL:oWSstartProcessItem4:cItem  := {"c5_emissao"				,"20/03/2107"					}
	aAdd( oWSDL:oWSstartProcessArray:oWSitem, oWSDL:oWSstartProcessItem4:cItem  )
	
	oWSDL:oWSstartProcessItem5:cItem  := {"c5_filial"				, xFilial("SC5")				}
	aAdd( oWSDL:oWSstartProcessArray:oWSitem, oWSDL:oWSstartProcessItem5:cItem  )
		
	oWSDL:oWSstartProcessItem6:cItem  := {"c5_cliente"				, "854796"					}
	oWSDL:oWSstartProcessItem7:cItem  := {"c5_lojacli"				, "01"						}		
	oWSDL:oWSstartProcessItem8:cItem  := {"c5_nomcli"				,"Samuel Etoo Protheus"		}

	
	oWSDL:oWSstartProcessItem9:cItem  := {"c5_muncli"				,"Porto Alegre"				}
	oWSDL:oWSstartProcessItem10:cItem := {"c5_est"				,"RS"						}
	oWSDL:oWSstartProcessItem11:cItem := {"c5_tipocli"				,"Cons.Final"					}
	oWSDL:oWSstartProcessItem12:cItem := {"c5_nomven"				,"Lewis Hamilton"				}
	
	
	oWSDL:oWSstartProcessItem13:cItem := {"indice___1"				,"1"							}
	oWSDL:oWSstartProcessItem14:cItem := {"c6_item___1"			,"001"						}
	oWSDL:oWSstartProcessItem15:cItem := {"c6_produto___1"			,"100.0101.123"				}
	oWSDL:oWSstartProcessItem16:cItem := {"c6_descri___1"			,"Pilhas Rayovac"				}
	oWSDL:oWSstartProcessItem17:cItem := {"c6_qtdven___1"			,"80,00"						}
	oWSDL:oWSstartProcessItem18:cItem := {"c6_prc_cli___1"			,"560,42"						}
	oWSDL:oWSstartProcessItem19:cItem := {"c6_vl_total___1"		,"44.832,00"					}
	
	
	
	oWSDL:lmanagerMode := .F.
	
	varinfo( "", oWSDL )

	oWSDL:startProcess(	oWSDL:cusername,;
						oWSDL:cpassword,;
						oWSDL:ncompanyId,;
						oWSDL:cprocessId,;
						oWSDL:nchoosedState,;
						oWSDL:ccomments,;
						oWSDL:cuserId,;
						oWSDL:lcompleteTask,;
						oWSDL:oWSstartProcessItem1,;
						oWSDL:oWSstartProcessItem2,;
						oWSDL:oWSstartProcessItem3,;
						oWSDL:oWSstartProcessItem4,;
						oWSDL:oWSstartProcessItem5,;
						oWSDL:oWSstartProcessItem6,;
						oWSDL:oWSstartProcessItem7,;
						oWSDL:oWSstartProcessItem8,;
						oWSDL:oWSstartProcessItem9,;
						oWSDL:oWSstartProcessItem10,;
						oWSDL:oWSstartProcessItem11,;
						oWSDL:oWSstartProcessItem12,;						
						oWSDL:oWSstartProcessItem13,;
						oWSDL:oWSstartProcessItem14,;
						oWSDL:oWSstartProcessItem15,;
						oWSDL:oWSstartProcessItem16,;
						oWSDL:oWSstartProcessItem17,;
						oWSDL:oWSstartProcessItem18,;
						oWSDL:oWSstartProcessItem19,;
						oWSDL:oWSstartProcesscolleagueIds,;
						oWSDL:lmanagerMode,;
						oWSDL:oWSstartProcessArray )						
												 						
	ConOut(WSDLDbgLevel(1))
	Conout(GETWSCERROR(1))

	ConOut(WSDLDbgLevel(2))
	Conout(GETWSCERROR(2))
		
	ConOut(WSDLDbgLevel(3))
	Conout(GETWSCERROR(3))		
			
	MsgInfo("OK")
	
	If Len( OWSDL:OWSSTARTPROCESSRESULT:OWSITEM ) = 1//Erro
		MsgInfo( OWSDL:OWSSTARTPROCESSRESULT:OWSITEM[1]:cItem[1] + " - " + OWSDL:OWSSTARTPROCESSRESULT:OWSITEM[1]:cItem[2] )
	Else
	
		For nX := 1 To Len( OWSDL:OWSSTARTPROCESSRESULT:OWSITEM )
			
			cTexto += " - " + OWSDL:OWSSTARTPROCESSRESULT:OWSITEM[nX]:cItem[1] + ": " + OWSDL:OWSSTARTPROCESSRESULT:OWSITEM[nX]:cItem[2] + CRLF
		
		Next nX
		
		MsgInfo( cTexto )
		 
	EndIf

Return