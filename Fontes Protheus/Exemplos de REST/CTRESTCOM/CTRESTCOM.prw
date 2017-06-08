#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#Include "TbiConn.ch"
#Include "Fileio.ch"
#Include "TopConn.ch"

#define FILIAL "06"

/*/{Protheus.doc} CTRESTCOM
@author adib.dias
@since 07/03/2017
@version 6
/*/
user function CTRESTCOM()
return("1.0")

/*/{Protheus.doc} ct_picklist - Ciatoy
@author adib.dias
@since 18/02/2016
@version 1.0
/*/
WSRESTFUL cotacao DESCRIPTION "Cotação de preços <br>Esse método, irá buscar/atualizar cotações no protheus (SC8)"

WSDATA token	  AS String

WSMETHOD GET DESCRIPTION "Metodo para retornar uma cotação" WSSYNTAX "/cotacao/{token}"
WSMETHOD POST DESCRIPTION "Metodo irá realizar alteração na cotação em questão." WSSYNTAX "/cotacao/{token}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE token WSSERVICE cotacao

	Local i, _cRest:=""

	::SetContentType("application/json")

	cONOUT("CONTENT GET: "+::aURLParms[1])

	If Len(::aURLParms) == 1

		::SetResponse('[')
		_cRest := fGeraJson("COTACAO",{cValToChar(::aURLParms[1])})
		::SetResponse(_cRest)
		::SetResponse(']')

	Else

		DEFAULT ::token := ""

		::SetResponse('[')
		_cResp := '{"status":"erro", "msg":"Parametro invalido!"}'
		::SetResponse(_cRest)
		::SetResponse(']')

	EndIf

Return .T.

WSMETHOD POST WSRECEIVE token WSSERVICE cotacao

	Local lPost := .T.
	Local cBody
	Local _cJson
	Local _aRet := {}

	Local _cErro := ""
	Local _cResp := ""

	Private _oObj

	::SetContentType("application/json")

	cONOUT("CONTENT POST: "+::GetContent())

	If Empty(::GetContent())
		::SetResponse('{"status":false, "msg":"Os parametros sao obrigatorios"}')
	Else

		cBody := ::GetContent()

		Conout(cBody)

		If FWJsonDeserialize(cValToChar(cBody),@_oObj)

			If fRetSC8(_oObj)
				_cResp := '{"status":true, "msg":"Pedido '+_oObj:Numero_Cotacao+' atualizado com sucesso em nosso sistema!"}'
			Else
				_cResp := '{"status":false, "msg":"'+NoAcento(_cErro)+'", "idCabecalho":0}'
			EndIf

		EndIf

	EndIf

::SetResponse(_cResp)

Return lPost

/*/{Protheus.doc} condpgto - Ciatoy
@author adib.dias
@since 18/02/2016
@version 1.0
/*/
WSRESTFUL condpgto DESCRIPTION "Condições de pagamento liberadas para o Compras(SE4)"

WSMETHOD GET DESCRIPTION "Metodo para retornar as condições de pagamento liberadas para o Compras" WSSYNTAX "/condpgto"

END WSRESTFUL

WSMETHOD GET WSRECEIVE NULLPARAM WSSERVICE condpgto

	Local i, _cRest:=""

	::SetContentType("application/json")

	::SetResponse('[')
	_cRest := fGeraJson("CONDPG")
	::SetResponse(_cRest)
	::SetResponse(']')

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} fGeraJson
Gerador de arquivo no formato JSON
@author adib.dias
@since 19/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function fGeraJson(_cMetodo,_aParam)

	Local _cRet := ""
	Local _aRet := {}

	Local _lPrepEnv := Empty(Select("SM0"))

	If _lPrepEnv
		RpcSetType(3)
		RpcSetEnv( "01", FILIAL)
	Endif

	//CONOUT("PARAMETRO: "+CVALTOCHAR(_aParam[01]))

	Do Case

		Case _cMetodo == "COTACAO"

		_aRet	:=	fGetSC82(_aParam[01])
		Case _cMetodo == "CONDPG"

		_aRet	:=	fGetCOND()

		Otherwise
		_cRet	:=	'{"status":"ERRO", "msg":"Metodo [ '+Capital(_cMetodo)+' ] é inválido."}'

	EndCase

	If empty(_cRet)
		If !Empty(_aRet)
			_cRet    := fToJson2( { Capital(_cMetodo) , _aRet[01], _aRet[02]} )
		Else
			_cRet	:=	'{"status":"ERRO", "msg":"Não há dados para o [ '+Capital(_cMetodo)+' ]."}'
		EndIf
	EndIf

	If _lPrepEnv
		RpcClearEnv()
	Endif

Return _cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} fToJson2
Converte o arquivo para JSON

@Param String com Nome da Tabela
@Param Array com o nome dos campos
@Param Array com os itens do Array

@Return String
@author adib.dias
@since 19/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static function fToJson(_aCab,_aLin)

	Local _cJSON  := ""
	Local _oObjJson :=	JsonObject():New()
	Local _aJson	:=	{}
	Local _aSub		:= {}
	Local _oItem	:= 	nil
	Local _i		:=	0
	Local _j		:=	0

	For _i:= 1 To Len(_aLin)

		_oItem := JsonObject():New()
		_aSub  := {}

		For _j:=1 To Len(_aCab)

			_oItem:PutVal( _aCab[_j], _aLin[_i][_j] )

		Next _j

		aAdd(_aJson,_oItem)

	Next _i

	_cJSON := _oItem:ToJson()

Return _cJSON

Static function fToJson2(_aGeraJson)

	Local _cJSON  := ""
	Local _cTable := _aGeraJson[1]
	Local _aCab   := _aGeraJson[2]
	Local _aLin   := _aGeraJson[3]

	Local _oObjJson :=	JsonObject():New()
	Local _aJson	:=	{}
	Local _oItem	:= 	nil
	Local _i		:=	0
	Local _j		:=	0

	For _i:= 1 To Len(_aLin)
		_oItem := JsonObject():New()
		For _j:=1 To Len(_aCab)
			_oItem:PutVal( _aCab[_j], _aLin[_i][_j] )
		Next _j
		aAdd(_aJson,_oItem)
	Next _i

	_oObjJson:PutVal(_cTable,_aJson)

	_cJSON := _oObjJson:ToJson()

	//Conout("Json convertido: "+_cJSON)
Return _cJSON

/*/{Protheus.doc} fGetSC8
@author adib.dias
@since 07/03/2017
@version 1.0
/*/
Static Function fGetSC82(_cToken)

	Local _cAlias	:=	GetNextAlias()
	Local _aRet		:=	{}

	Local _cExp		:=	"% %"

	Default _cToken	:=	""

	BeginSQL alias _cAlias
	%noparser%
	SELECT * FROM WF_COTACOES WHERE TOKEN=%exp:_cToken%
	ORDER BY ITEM
	EndSql

	_aRet := fMontaArray(_cAlias)

Return(_aRet)

/*/{Protheus.doc} fGetCOND
@author adib.dias
@since 07/03/2017
@version 1.0
/*/
Static Function fGetCOND()

	Local _cAlias	:=	GetNextAlias()
	Local _aRet		:=	{}

	Local _cExp		:=	"% %"

	BeginSQL alias _cAlias
	%noparser%
	SELECT * FROM WF_CONDPG
	ORDER BY VENCIMENTO
	EndSql

	_aRet := fMontaArray(_cAlias)

Return(_aRet)
/*/{Protheus.doc} fGetSC8
@author adib.dias
@since 07/03/2017
@version 6
@param _cToken, , descricao
/*/
Static Function fGetSC8(_cToken)

	Local _aRet		:=	{}
	Local _aCabec	:=	{}
	Local _aDados	:=	{}

	Local lPrepEnv		:=	Empty(Select("SM0"))
	Local _aArea		:=	{}

	Local	_cFilial  := ""
	Local	_cNum     := ""
	Local	_cFornece := ""
	Local	_cLoja    := ""

	_aArea		:=	SaveArea1( { "SX2" , "SX3" , "SB1" , "SC8"} )

	DbSelectArea("SC8")
	SC8->(DbOrderNickName("SCXTOKEN"))
	If SC8->(DbSeek(Padr(_cToken,TamSX3("C8_XTOKEN")[01]),.T.))

		_aDados := {}

		_cFilial  := SC8->C8_FILIAL
		_cNum     := SC8->C8_NUM
		_cFornece := SC8->C8_FORNECE
		_cLoja    := SC8->C8_LOJA

		While !SC8->(Eof())	.and. SC8->C8_FILIAL == _cFilial .and. SC8->C8_NUM == _cNum .and. SC8->C8_FORNECE == _cFornece .and. SC8->C8_LOJA == _cLoja

			//caso o token não seja o mesmo
			If Alltrim(SC8->C8_XTOKEN) <> Alltrim(_cToken)
				SC8->(dbSkip())
				Loop
			EndIF

			//caso ja tenha sido respondida
			If Alltrim(SC8->C8_WFCO) > "1001"
				SC8->(dbSkip())
				Loop
			EndIF

			_aItem := {}

			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1") + SC8->C8_PRODUTO )

			aAdd( _aItem , SC8->C8_ITEM    )
			aAdd( _aItem , Alltrim(SC8->C8_PRODUTO) )
			aAdd( _aItem , Alltrim(SB1->B1_DESC)    )
			aAdd( _aItem , SC8->C8_QUANT )
			aAdd( _aItem , SC8->C8_UM)
			aAdd( _aItem , 0 )
			aAdd( _aItem , 0 )
			aAdd( _aItem , " ")
			aAdd( _aItem , 0 )
			aAdd( _aItem , Transform(Dtos(SC8->C8_DATPRF),"@R 9999-99-99")+" 00:00:00.000" )

			dbSelectArea("SC8")
			//GRAVA DADOS NO SC8
			RecLock('SC8',.F.)

			SC8->C8_WFCO   := "1001"
			If Empty(SC8->C8_WFDT)
				SC8->C8_WFDT   := dDataBase
			EndIF

			If Empty(SC8->C8_WFEMAIL)
				If cUsername == "Administrador"
					SC8->C8_WFEMAIL := GetMV("MV_RELACNT")
				Else
					SC8->C8_WFEMAIL := "compras@ciatoy.com.br"
				EndIF
			EndIf
			SC8->C8_WFID := "000002"
			MsUnlock()

			SC8->(aAdd(_aDados,_aItem))
			SC8->(DbSkip())

		EndDo

	EndIf

	aAdd(_aCabec,"item")
	aAdd(_aCabec,"producao")
	aAdd(_aCabec,"descricao")
	aAdd(_aCabec,"quant")
	aAdd(_aCabec,"um")
	aAdd(_aCabec,"preco")
	aAdd(_aCabec,"valor")
	aAdd(_aCabec,"prazo")
	aAdd(_aCabec,"ipi")
	aAdd(_aCabec,"dataesperada")

	If Len(_aDados)>0
		_aRet := {_aCabec,_aDados}
	EndIf

	RestArea1(_aArea)

Return(_aRet)

/*/{Protheus.doc} fMontaArray
(long_description)
@author adib.dias
@since 19/02/2016
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
Static Function fMontaArray(_cAlias)

	Local _aCabec	:=	{}
	Local _aDados	:=	{}
	Local _i		:=	0
	Local _nCont	:=	0

	(_cAlias)->(DbGoTop())
	Count to _nCont

	//Caso não tenha nenhum registro na query, retorna array vazio
	If _nCont <= 0
		Return _aDados
	EndIf

	(_cAlias)->(DbGoTop())

	If !(_cAlias)->(Eof())

		For _i:=1 To (_cAlias)->(Fcount())
			aAdd(_aCabec,Alltrim((_cAlias)->(FieldName(_i))))
		Next _i

	EndIf

	While !(_cAlias)->(Eof())

		_aTemp := {}

		For _i:=1 To (_cAlias)->(Fcount())
			aAdd(_aTemp,If(ValType((_cAlias)->&(FieldName(_i)))=="C",Alltrim((_cAlias)->&(FieldName(_i))),(_cAlias)->&(FieldName(_i))))
		Next _i

		aAdd(_aDados,_aTemp)

		(_cAlias)->(DbSkip())
	EndDo
	(_cAlias)->(DbCloseArea())

Return({_aCabec,_aDados})
/*
Cod		Descricao
1000	AGUARDANDO INTERACAO
1001	EM ANALISE
1002	PROCESSO APROVADO
1003	PROCESSO RECUSADO
1004	PROCESSO CANCELADO MANUALMENTE
1005	PROCESSO CANCELADO AUTOMATICAMENTE
1099	PROCESSO VENCIDO
*/

Static Function fConvStr(_cString)

	Local _cStr := Alltrim(_cString)
	Local _aTemp := {},_aTempLin := {}
	Local _aRet := {{},{}}

	Local _aStr := Separa(_cString,"&")

	If Len(_aStr) > 0

		aEval(_aStr,{|x| If(!Empty(x),Aadd(_aTemp,fLinToArr(x)),) })

	EndIf

	If Len(_aTemp) > 0

		aEval(_aTemp,{|x| aAdd(_aRet[01],x[01]),aAdd(_aTempLin,x[02]) })

		aAdd(_aRet[02],_aTempLin)

	EndIf

Return(_aRet)

Static Function fLinToArr(_cLin)

	Local _aRet := Separa(_cLin,"=")

	If Len(_aRet) > 0

		_aRet[02] := fConvType(Upper(Left(_aRet[01],1)),_aRet[02])

	EndIf

Return(_aRet)

Static Function fConvType(_cTipo,_xConv)

	Local _xRet := ""

	Do Case
		Case _cTipo == "C"
		_xRet := Replace(Alltrim(_xConv),"+",Space(1))
		_xRet := Replace(Alltrim(_xConv),"%3A",":")

		Case _cTipo == "N"
		_xRet := Val(Replace(Replace(_xConv,".",""),",","."))
		Case _cTipo == "L"
		_xRet := Upper(Alltrim(_xConv))=="TRUE" .or. Upper(Alltrim(_xConv))==".T."
		Case _cTipo == "D"
		_xRet := Stod(Replace(_xConv,"-",""))
	EndCase

Return(_xRet)

Static Function fRetSC8(_oSC8)

	Local aCab   :={}
	Local aItem  := {}
	Local nUsado := 0
	Local aRelImp := {}

	Local _lRet := .F.
	
	Local cUsermail := ""

	Private lMsErroAuto := .F.

	Conout("CTRESTCOM - Preparando ambiente 01/"+Left(cValToChar(_oSC8:Numero_Cotacao),2))

	RpcSetType(3)
	RpcSetEnv("01",Left(cValToChar(_oSC8:Numero_Cotacao),2),,,"COM")

	cUsermail := GetMv("MV_RELACNT")

	aRelImp := MaFisRelImp("MT150",{"SC8"})

	_cC8_NUM     := _oSC8:Numero_Cotacao
	_cC8_FORNECE := _oSC8:Fornecedor
	_cC8_LOJA    := _oSC8:Loja
	
	_cNomeFor	:=	Posicione('SA2',1,xFilial("SA2")+Padr(_cC8_FORNECE,TamSX3("A2_COD")[01])+Padr(_cC8_LOJA,TamSX3("A2_COD")[01]),"A2_NREDUZ")
	_cEmlFor := Alltrim(Posicione('SA2',1,xFilial("SA2")+Padr(_cC8_FORNECE,TamSX3("A2_COD")[01])+Padr(_cC8_LOJA,TamSX3("A2_COD")[01]),"A2_EMAIL"))
	
	// Cotacao Recebida
	if _oSC8:Aprovado

		_cC8_ALIIPI := _oSC8:ALIIPI
		_cC8_VALFRE := _oSC8:VALFRE

		//Verifica o frete
		if Alltrim(_oSC8:Frete) == "FOB"
			_cC8_RATFRE := 0
		endif

		//Grava no SC8
		for _nind := 1 to len(_oSC8:Itens)

			dbSelectArea("SC8")
			SC8->(DbGoto(_oSC8:Itens[_nind]:Id))
			/*
			dbSetOrder(1)
			dbSeek( Padr(_cC8_NUM,8) + Padr(_cC8_FORNECE,6) + _cC8_LOJA + _cC8_ITEM )
			*/

			//BASE DO ICMS
			MaFisIni(Padr(_cC8_FORNECE,6),_cC8_LOJA,"F","N","R",aRelImp)
			MaFisIniLoad(1)
			For nY := 1 To Len(aRelImp)
				MaFisLoad(aRelImp[nY][3],SC8->(FieldGet(FieldPos(aRelImp[nY][2]))),1)
			Next nY
			MaFisEndLoad(1)

			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek( xFilial("SB1") + Padr(_oSC8:Itens[_nind]:Produto,15) )
			cIcm := SC8->C8_PICM

			_cC8_ITEM := _oSC8:Itens[_nind]:Item

			//caso o prazo tenha vencido não permite gravacao
			If Alltrim(SC8->C8_WFID) == "9999"
				Return .f.
			EndIf
			RecLock("SC8",.f.)
			SC8->C8_WFCO   := "1004"
			SC8->C8_QUANT  := _oSC8:Itens[_nind]:Quant
			SC8->C8_PRECO  := _oSC8:Itens[_nind]:Preco
			SC8->C8_TOTAL  := _oSC8:Itens[_nind]:Valor
			SC8->C8_ALIIPI := _oSC8:Itens[_nind]:Ipi

			//Caso o IPI não seja zero
			If _oSC8:Itens[_nind]:Ipi > 0
				SC8->C8_VALIPI  := (_oSC8:Itens[_nind]:Ipi * _oSC8:Itens[_nind]:Valor) / 100
				SC8->C8_BASEIPI := SC8->C8_TOTAL
			EndIf

			SC8->C8_PRAZO  := _oSC8:Itens[_nind]:Prazo

			//caso o icm nao seja zero
			MaFisAlt("IT_ALIQICM",cIcm,1)
			SC8->C8_PICM        := MaFisRet(1,"IT_ALIQICM")

			If SC8->C8_PICM >0
				SC8->C8_BASEICM     := SC8->C8_TOTAL
				MaFisAlt("IT_VALICM",cIcm,1)
				SC8->C8_VALICM      := MaFisRet(1,"IT_VALICM")
			EndIf

			SC8->C8_COND   := Substr(_oSC8:Pagamento,1,3)
			SC8->C8_TPFRETE:= Substr(_oSC8:Frete,1,1)

			If Alltrim(_oSC8:Frete) == "FOB"
				SC8->C8_VALFRE := 0
			ElseIf _oSC8:ValFre > 0
				SC8->C8_VALFRE := _oSC8:ValFre / Len(_oSC8:Itens)//(_oSC8:Itens[_nind]:Quant * _oSC8:Itens[_nind]:Preco) / (_oSC8:TotPed * _oSC8:ValFre)
			EndIf

			If (_oSC8:VlDesc == 0)
				SC8->C8_VLDESC := 0
			Else
				SC8->C8_VLDESC := _oSC8:VlDesc / Len(_oSC8:Itens)//(_oSC8:Itens[_nind]:Quant * _oSC8:Itens[_nind]:Preco) / (_oSC8:TotPed * _oSC8:VlDesc)
			EndIf
			
			//Cria array aItem para envio dos itens por email
			SC8->(aAdd(aItem,{C8_PRODUTO,C8_QUANT,C8_PRECO,C8_VLDESC,C8_TOTAL}))
			
			MsUnlock()
			MaFisEnd()

		next
		
		_cAssunto := "Ciatoy - Cotação Nº "+Alltrim(SC8->C8_FILIAL+SC8->C8_NUM)+" - APROVADA."

		_cBody	:= 'Olá,' 
		_cBody	+= '<p>' 
		_cBody	+= 'O fornecedor '+Capital(Alltrim(_cNomeFor))+' aprovou a cotação '+Alltrim(SC8->C8_FILIAL+SC8->C8_NUM)+'. <br>' 
		_cBody	+= 'Favor dar continuidade ao processo de análise e compra.' 
		_cBody	+= '</p>'
		
		If Len(aItem)>0 
			_cBody	+= '<p>'		
			_cBody	+= '<table border="0" cellpadding="10" class="tabela">'
			_cBody	+= '<tr><td colspan="5" align="center"><b>Resumo da cotação</b></td></tr>'
			_cBody	+= '<th align="left">Produto</th>'
			_cBody	+= '<th>Qtd</th>'
			_cBody	+= '<th>Valor.Unit</th>'
			_cBody	+= '<th>Desconto</th>'
			_cBody	+= '<th>Total</th>'		
			For _nIt:=1 To Len(aItem)//aItem,{C8_PRODUTO,C8_QUANT,C8_PRECO,C8_VLDESC,C8_TOTAL}
				_cBody	+= '<tr>'
					_cBody	+= '<td>'+Alltrim(Posicione("SB1", 1, xFilial("SB1") + aItem[_nIt][01], "B1_XDESCCO"))+'</td>'
					_cBody	+= '<td align="right">'+Transform(aItem[_nIt][02],"@E 9,999,999.99")+'</td>'
					_cBody	+= '<td align="right">'+Transform(aItem[_nIt][03],"@E 9,999,999.99")+'</td>'
					_cBody	+= '<td align="right">'+Transform(aItem[_nIt][04],"@E 9,999,999.99")+'</td>'
					_cBody	+= '<td align="right">'+Transform(aItem[_nIt][05],"@E 9,999,999.99")+'</td>'                                    
				_cBody	+= '</tr>'
				
			Next _nIt
			_cBody	+= '</table>'		
	        _cBody	+= '</p>'    
        EndIf
                         		
		_cBody	+= '<p>' 
		_cBody	+= '    Atenciosamente,<br/>'
		_cBody	+= '    Workflow Ciatoy.' 
		_cBody	+= '</p>' 

		//Envia o email para o departamento de compras
		If !fSendMail(cUsermail,"compras@ciatoy.com.br",_cAssunto,_cBody)
			Conout("Ocorreu erros ao tentar enviar o email para o fornecedor!")
		EndIf
		
		_cAssunto := "Ciatoy - Cotação Nº "+Alltrim(SC8->C8_FILIAL+SC8->C8_NUM)+" - ENVIADA."

		_cBody	:= 'Olá '+Capital(Alltrim(_cNomeFor))+',' 
		_cBody	+= '<p>' 
		_cBody	+= 'Nós recebemos com sucesso a cotação '+Alltrim(SC8->C8_FILIAL+SC8->C8_NUM)+'. <br>' 
		_cBody	+= 'Aguarde o nosso contato para finalizarmos o processo de compra.' 
		_cBody	+= '</p>'
		
		If Len(aItem)>0 
			_cBody	+= '<p>'		
			_cBody	+= '<table border="0" cellpadding="10" class="tabela">'
			_cBody	+= '<tr><td colspan="5" align="center"><b>Resumo da cotação</b></td></tr>'
			_cBody	+= '<th align="left">Produto</th>'
			_cBody	+= '<th>Qtd</th>'
			_cBody	+= '<th>Valor.Unit</th>'
			_cBody	+= '<th>Desconto</th>'
			_cBody	+= '<th>Total</th>'		
			For _nIt:=1 To Len(aItem)//aItem,{C8_PRODUTO,C8_QUANT,C8_PRECO,C8_VLDESC,C8_TOTAL}
				_cBody	+= '<tr>'
					_cBody	+= '<td>'+Alltrim(Posicione("SB1", 1, xFilial("SB1") + aItem[_nIt][01], "B1_XDESCCO"))+'</td>'
					_cBody	+= '<td align="right">'+Transform(aItem[_nIt][02],"@E 9,999,999.99")+'</td>'
					_cBody	+= '<td align="right">'+Transform(aItem[_nIt][03],"@E 9,999,999.99")+'</td>'
					_cBody	+= '<td align="right">'+Transform(aItem[_nIt][04],"@E 9,999,999.99")+'</td>'
					_cBody	+= '<td align="right">'+Transform(aItem[_nIt][05],"@E 9,999,999.99")+'</td>'                                    
				_cBody	+= '</tr>'
				
			Next _nIt
			_cBody	+= '</table>'		
	        _cBody	+= '</p>'    
        EndIf
                         		
		_cBody	+= '<p>' 
		_cBody	+= '    Atenciosamente,<br/>'
		_cBody	+= '    Departamento de Compras da Ciatoy.' 
		_cBody	+= '</p>' 
		
		//Envia o e-mail para o fornecedor
		If !fSendMail(cUsermail,_cEmlFor,_cAssunto,_cBody)
			Conout("Ocorreu erros ao tentar enviar o email para o fornecedor!")
		EndIf		
		
		
		_lRet := .T.

	Else //caso tenha sido rejeitado
		
		_lRet := .F.
		
		For _nind := 1 to len(_oSC8:Itens)

			_cC8_ITEM := _oSC8:Itens[_nind]:Item

			dbSelectArea("SC8")
			SC8->(dbSetOrder(1))
			If SC8->(dbSeek( Padr(_cC8_NUM,8) + Padr(_cC8_FORNECE,6) + _cC8_LOJA + _cC8_ITEM ))

				Conout("Cotacao "+Padr(_cC8_NUM,8)+" localizada...")

				aCabec := {}
				aItens := {}

				aadd(aCabec,{"C8_NUM"    ,SC8->(C8_NUM)})

				MSExecAuto({|v,x,y| MATA150(v,x,y)},aCabec,aItens,5,,,SC8->C8_ITEM)
				If lMsErroAuto
					_lRet := .F.
					fSendMail(cUsermail,"compras@ciatoy.com.br","Erro na exclusao da cotacao - "+SC8->(C8_FILIAL+C8_NUM)+"-"+SC8->C8_ITEM,Mostraerro())
				Else
					Conout("Cotacao "+Padr(_cC8_NUM,8)+"-"+SC8->C8_ITEM+" excluida com sucesso...")
					_lRet := .T.
				EndIf

			Else
				Conout("Cotacao "+Padr(_cC8_NUM,8)+" nao foi localizada...")
			EndIf

		Next _nind

		If _lRet

			_cAssunto := "Ciatoy - Cotação Nº "+Alltrim(SC8->C8_FILIAL+SC8->C8_NUM)+" - REPROVADA."

			_cBody	:= 'Olá,' 
			_cBody	+= '<p>' 
			_cBody	+= 'O fornecedor '+Capital(Alltrim(_cNomeFor))+' desistiu da cotação '+Alltrim(SC8->C8_FILIAL+SC8->C8_NUM)+'. <br>' 
			_cBody	+= 'Favor desconsiderar esta no seu processo de compra.' 
			_cBody	+= '</p>'
			_cBody	+= '<p>'
			_cBody	+= 'Motivo: '+DecodeUtf8(cValToChar(_oSC8:C8_OBS))
			_cBody	+= '</p>' 			
			_cBody	+= '<p>'
			_cBody	+= '    Atenciosamente,<br/>' 
			_cBody	+= '    Workflow Ciatoy.' 
			_cBody	+= '</p>' 

			If !fSendMail(cUsermail,"compras@ciatoy.com.br",_cAssunto,_cBody)
				Conout("Ocorreu erros ao tentar enviar o email para o fornecedor!")
			EndIf

		EndIf

		/*
		//ATUALIZA O SC8
		for _nind := 1 to len(_oSC8:Itens)

		_cC8_ITEM := _oSC8:Itens[_nind]:Item

		dbSelectArea("SC8")
		SC8->(DbGoto(_oSC8:Itens[_nind]:Id))

		aCab := {	{"C8_FILIAL"	,SC8->C8_FILIAL,NIL},{"C8_NUM"	,SC8->C8_NUM,NIL}}

		//dbSetOrder(1)
		//dbSeek( Padr(_cC8_NUM,8) + Padr(_cC8_FORNECE,6) + _cC8_LOJA + _cC8_ITEM )

		//caso o prazo tenha vencido não permite gravacao
		If Alltrim(SC8->C8_WFCO) == "9999"
		Return .T.
		EndIf

		cEmailComp := SC8->C8_WFEMAIL

		lMsErroAuto := .F.

		aadd(aItem,   {{"C8_ITEM",_cC8_ITEM ,NIL},;
		{"C8_FORNECE",_cC8_FORNECE ,NIL},;
		{"C8_LOJA",_cC8_LOJA ,NIL}})

		MSExecAuto({|x,y,z| mata150(x,y,z)},aCab,aItem,5) //EXCLUI

		If lMsErroAuto
		_lRet := .F.
		fSendMail("adib.dias@ciatoy.com.br","Erro na exclusao da cotacao - "+SC8->(C8_FILIAL+C8_NUM),Mostraerro())
		Else
		_lRet := .T.
		Endif

		Next
		If _lRet
		fSendMail("adib.dias@ciatoy.com.br","Fornecedor desistiu da cotação",_oSC8:C8_OBS)
		EndIf
		*/
	Endif

	Reset Environment

Return(_lRet)

/*/{Protheus.doc} fSendMail
@author adib.dias
@since 16/03/2017
@version 6
/*/
Static Function fSendMail(_cDe,_cPara,_cAssunto,_cBody)

	_oEmail :=	GapMail():New()
	_oEmail:cFrom		:= _cDe
	_oEmail:cTo	 		:= _cPara
	If _cPara <> "compras@ciatoy.com.br"
		//_oEmail:cCC			:= "compras@ciatoy.com.br"
	EndIf
	_oEmail:cSubject 	:= _cAssunto
	_oEmail:cBody		:= _cBody
	_oEmail:lLayout		:= .T.

Return(_oEmail:Envia())

Static Function fNomeAbr(_cNome)

	Local _aNome := Separa(Alltrim(_cNome),SPACE(1))

	If Len(_aNome)>1

		_cNome := Alltrim(lower(_aNome[01]+ " " +_aNome[Len(_aNome)]))

	EndIf

Return(lower(_cNome))

Static Function MyMata150()

	Local aCabec := {}
	Local aItens := {}

	PRIVATE lMsErroAuto := .F.

	dbSelectArea("SC8")
	dbSetOrder(1)
	dbSeek(xFilial("SC8")+"000055")
	aadd(aCabec,{"C8_FORNECE" ,"2     "})
	aadd(aCabec,{"C8_LOJA"    ,"01"})
	aadd(aCabec,{"C8_COND"    ,"001"})
	aadd(aCabec,{"C8_CONTATO" ,"AUTO"})
	aadd(aCabec,{"C8_FILENT"  ,"01"})
	aadd(aCabec,{"C8_MOEDA"   ,0})
	aadd(aCabec,{"C8_EMISSAO" ,dDataBase})
	aadd(aCabec,{"C8_TOTFRE"  ,0})
	aadd(aCabec,{"C8_VALDESC" ,0})
	aadd(aCabec,{"C8_DESPESA" ,0})
	aadd(aCabec,{"C8_SEGURO"  ,0})
	aadd(aCabec,{"C8_DESC1"   ,0})
	aadd(aCabec,{"C8_DESC2"   ,0})
	aadd(aCabec,{"C8_DESC3"   ,0})

	aadd(aItens,{{"C8_NUMPRO","01"  ,Nil},;
	{"C8_PRODUTO","ZZ-002"  ,Nil},;
	{"C8_ITEM"  ,"0001",Nil},;
	{"C8_UM"  ,"CX "   ,Nil},;
	{"C8_QUANT",1000   ,Nil},;
	{"C8_PRECO",1      ,NIL},;
	{"C8_TOTAL",1000   ,NIL}})

	MSExecAuto({|v,x,y| MATA150(v,x,y)},aCabec,aItens,2)
	If lMsErroAuto
		mostraerro()
	EndIf

	// ---- EXEMPLO ALTERACAO DE UMA COTACAO JA EXISTENTE ----
	aCabec:={}
	aItens:={}
	dbSelectArea("SC8")
	dbSetOrder(1)
	dbSeek(xFilial("SC8")+"000055")
	aadd(aCabec,{"C8_FORNECE" ,"1     "})
	aadd(aCabec,{"C8_LOJA"    ,"01"})
	aadd(aCabec,{"C8_COND"    ,"001"})
	aadd(aCabec,{"C8_CONTATO" ,"AUTO"})
	aadd(aCabec,{"C8_FILENT"  ,"01"})
	aadd(aCabec,{"C8_MOEDA"   ,0})
	aadd(aCabec,{"C8_EMISSAO" ,dDataBase})
	aadd(aCabec,{"C8_SEGURO"  ,100})

	aadd(aItens,{{"C8_NUMPRO","01"  ,Nil},;
	{"C8_PRODUTO","ZZ-002"  ,Nil},;
	{"C8_ITEM"  ,"0001",Nil},;
	{"C8_UM"  ,"CX "   ,Nil},;
	{"C8_QUANT",2000   ,Nil}})
	MSExecAuto({|v,x,y| MATA150(v,x,y)},aCabec,aItens,3)
	If lMsErroAuto
		mostraerro()
	EndIf
	// ---- EXEMPLO INCLUSAO DE UMA PROPOSTA EM UMA COTACAO JA EXISTENTE ----
	aCabec := {}
	aItens := {}

	dbSelectArea("SC8")
	dbSetOrder(1)
	dbSeek(xFilial("SC8")+"000055")

	aadd(aCabec,{"C8_FORNECE" ,"1     "})
	aadd(aCabec,{"C8_LOJA"    ,"01"})
	aadd(aCabec,{"C8_COND"    ,"001"})
	aadd(aCabec,{"C8_CONTATO" ,"AUTO"})
	aadd(aCabec,{"C8_FILENT"  ,"01"})
	aadd(aCabec,{"C8_MOEDA"   ,0})
	aadd(aCabec,{"C8_EMISSAO" ,dDataBase})
	aadd(aCabec,{"C8_TOTFRE"  ,0})
	aadd(aCabec,{"C8_VALDESC" ,0})
	aadd(aCabec,{"C8_DESPESA" ,0})
	aadd(aCabec,{"C8_SEGURO"  ,0})
	aadd(aCabec,{"C8_DESC1"   ,0})
	aadd(aCabec,{"C8_DESC2"   ,0})
	aadd(aCabec,{"C8_DESC3"   ,0})

	aadd(aItens,{;
	{"C8_NUMPRO","02"  ,Nil},;
	{"C8_PRODUTO","ZZ-002"  ,Nil},;
	{"C8_ITEM"  ,"0001",Nil},;
	{"C8_UM"  ,"CX "   ,Nil},;
	{"C8_QUANT",3000   ,Nil}})

	MSExecAuto({|v,x,y| MATA150(v,x,y)},aCabec,aItens,4)
	If lMsErroAuto
		mostraerro()
	EndIf
	// ---- EXEMPLO EXCLUSAO DE UMA COTACAO JA EXISTENTE ----
	aCabec := {}
	aItens := {}
	aadd(aCabec,{"C8_NUM"    ,"000055"})

	MSExecAuto({|v,x,y| MATA150(v,x,y)},aCabec,aItens,5)
	If lMsErroAuto
		mostraerro()
	EndIf
	// ---- EXEMPLO EXCLUSAO DE UM ITEM DA COTACAO JA EXISTENTE ----
	aCabec := {}
	aItens := {}
	aadd(aCabec,{"C8_NUM"    ,"000055"})
	MSExecAuto({|v,x,y| MATA150(v,x,y)},aCabec,aItens,5,,,"0001")
	If lMsErroAuto
		mostraerro()
	EndIf

Return(.T.)

