#Include "Ap5Mail.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#Include "TBICONN.CH"
#Include "dbTree.ch"


#Define  newLine Chr(13)+Chr(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} MT110TOK
Ponto de Entrada

@protected
@author    
@since     
@obs       

Alteracoes Realizadas desde a Estruturacao Inicial
Data       Programador     Motivo
/*/
//-------------------------------------------------------------------
User Function MT110TOK()
Local oWS
Local oWsdl
Local aArea := GetArea()
Local nPosItem 		:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_ITEM"})
Local nPosEmail 		:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_EMAIL"})
Local nPosCC 			:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_CC"})
Local nPosNomeApro		:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_NOMAPRO"})
Local nPosUm			:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_UM"})   
Local nPosSolicit		:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_SOLICIT"}) 
Local cNomeAp

//Variáveis públicas para obter o retorno do código da solicitação Fluig
//Public aRetorno := {}  
//Public cSolicitante := AllTrim(SC1->C1_SOLICIT) // Variável Pública para armazenar o solicitante fora deste fonte
//Cria variável Pública para gravar o e-mail do aprovador	
Public cEmailApr := ''

If Empty(cCentroCusto)
	Aviso( "Atencao !", "O Centro de Custo é obrigatório", { "Ok" }, 2 )
	lRetVld := .F.
Else

	lRetVld := U_MCCOMV01(cCentroCusto,"C")

	If lRetVld 
               
        ZB2->(DBClearFilter())
		ZB2->(dbSetOrder(2))
		ZB2->(dbSeek(xFilial("ZB2")+cCentroCusto))

		If ZB2->(! Eof())
			cNomeAp := ZB2->ZB2_USUARI
		EndIf

		//monta um array com os e-mails a serem enviados.                                  
		For i := 1 To Len(aCols)

			aCols[i][nPosEmail]	:= AllTrim(cEmailSoli)  //Esta declarada como publica no ponto de entrada MT110TEL
			aCols[i][nPosCC]		:= AllTrim(cCentroCusto)//Esta declarada como publica no ponto de entrada MT110TEL

			if (nPosNomeApro) <> 0
				aCols[i][nPosNomeApro] := AllTrim(cNomeAp)
			endif

		Next i

		FEnvemail(cNomeAp)

	EndIf
EndIf

If AllTrim(cNomeAp) <> ''

	// Defino a ordem
	PswOrder(2) // Ordem de nome
	     
	// Efetuo a pesquisa, definindo se pesquiso usuário ou grupo
	If PswSeek(cNomeAp,.T.)
		// Obtenho o resultado conforme vetor
		aRetUsrAp	:= PswRet(1)
		cEmailApr		:= Upper(Alltrim(aRetUsrAp[1,14]))
	EndIf
EndIf


RestArea(aArea)
	
return lRetVld



static function FEnvemail(cNomeAp)

Local cEmaiAp := ""
Local nPosOBS 			:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_OBS"})    	
Local nPosCC 			:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_CC"})    
Local nPosQuant 		:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_QUANT"})    
Local nPosDescri 		:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_DESCRI"})    
Local nPosProduto		:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_PRODUTO"})
Local nPosNomeApro		:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_NOMAPRO"})
Local nPosUm			:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_UM"})   
Local nPosSolicit		:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_SOLICIT"})    
Local nPosDatPrf		:= Ascan(aHeader,{|x| allTrim(x[2]) == "C1_DATPRF"})  

// Defino a ordem
PswOrder(2) // Ordem de nome
     
// Efetuo a pesquisa, definindo se pesquiso usuário ou grupo
If PswSeek(cNomeAp,.T.)
	// Obtenho o resultado conforme vetor
	aRetUsrAp	:= PswRet(1)
	cemaiAp		:= Upper(Alltrim(aRetUsrAp[1,14]))
EndIf

If (Len(AllTrim(cEmailSoli)) <> 0)  
	msg := 	"<html>"
	msg +=	"<head>"
	msg +=	"<title>Solicitação de Compras</title>"
	msg +=	"<style> * {font-size: 11pt; font-family: Arial}"
	msg +=	" th, td {border-style: solid; border-width: 1px; border-color: #a0a0a0}"
	msg +=	"</style>"
	msg +=	"</head>"
	msg +=	"<body>"
	msg +=	"<p>Caro Usuário,</p>"
	if INCLUI
		msg += 	"<p>Acaba de ser <b>incluída</b> no sistema uma solicitação de compras conforme os dados abaixo:</p>"
	else
		msg += 	"<p>Acaba de ser <b>alterada</b> no sistema uma solicitação de compras conforme os dados abaixo:</p>"	    	
	endif
	msg +=	"<table>"    	
	msg +=	"<tr>"
	msg +=	"<td style='border-style: none'>Número da Solicitação:</td>"
	msg +=  "<th style='font-size:16pt; border-style: none;letter-spacing:2px'><font color=red><b>" + cA110Num + "</b></font></th>"
	msg +=	"</tr>"
	msg +=	"</table>"
	msg +=	"<br>"
	msg +=	"<table cellspacing=0 cellpadding=8>"
	msg +=	"<tr>"
	msg +=	"<th>Produto</th>"
    	msg +=	"<th>Descrição</th>"
    	msg +=	"<th>Quant.</th>"
    	msg +=	"<th>Centro Custo</th>"
    	msg +=	"<th>Obs</th>"
		msg +=	"</tr>"
		
		//percorre os itens do usuario...
		for j := 1 to len(aCols)
			msg +=	"<tr>"
	    	msg +=	"<td style='text-align:center;background-color: white'>" + aCols[j][nPosProduto] + "</td>"
	    	msg +=	"<td style='text-align:left;background-color: white'>" + aCols[j][nPosDescri] + "</td>"
	    	msg +=	"<td style='text-align:right;background-color: white'>" + TransForm(aCols[j][nPosQuant],PesqPict("SC1","C1_QUANT")) + "</td>"
	    	msg +=	"<td style='text-align:center;background-color: white'>" + aCols[j][nPosCC] + "</td>"
	    	msg +=	"<td style='text-align:left;background-color: white'>" + aCols[j][nPosOBS] + "</td>"
			msg +=	"</tr>"			
		next j
		msg +=	"</table>"
		msg +=	"<p>É de sua responsabilidade a conferência destes dados e caso esteja em desacordo entrar em contato imediatamente com o usuário <font color=red>" + cUserName + "</font>.</p>"
		msg +=	"<p>Por favor não responda este e-mail, esta conta não é monitorada, qualquer assunto comunique-se diretamente com o usuário que lançou a solicitação</p>"
		                    
		assunto := "SOLICITAÇÃO DE COMPRAS - " + cA110Num  
		cpara := trim(cEmailSoli)
		
		bBloco := { |lEnd| envMail(cpara, assunto, msg)}
		MsAguarde(bBloco,"Aguarde","Notificando: " +  cpara,.F.)
	endif		 
	
	
	if (len(trim(cemaiAp)) <> 0)  
    	msg := 	"<html>"
    	msg +=	"<head>"
    	msg +=	"<title>Solicitação de Compras</title>"
    	msg +=	"<style> * {font-size: 11pt; font-family: Arial}"
    	msg +=	" th, td {border-style: solid; border-width: 1px; border-color: #a0a0a0}"
   		msg +=	"</style>"
    	msg +=	"</head>"
    	msg +=	"<body>"
    	msg +=	"<p>Caro Usuário,</p>"
    	if INCLUI
    		msg += 	"<p>Acaba de ser <b>incluída</b> no sistema uma solicitação de compras <b>para o seu centro de custo</b> conforme os dados abaixo:</p>"
    	else
			msg += 	"<p>Acaba de ser <b>alterada</b> no sistema uma solicitação de compras <b>do seu centro de custo</b> conforme os dados abaixo:</p>"	    	
    	endif
   		msg += 	"<p>Caso um dos produtos listados não possuir aprovação automática (Insumos por exemplo), o Sr. deverá acessar a rotina de solicitação de compras para aprová-las ou rejeitá-las.</p>"	    	
    	msg +=	"<table>"    	
    	msg +=	"<tr>"
    	msg +=	"<td style='border-style: none'>Número da Solicitação:</td>"
    	msg +=  "<th style='font-size:16pt; border-style: none;letter-spacing:2px'><font color=red><b>" + cA110Num + "</b></font></th>"
    	msg +=	"</tr>"
    	msg +=	"</table>"
    	msg +=	"<br>"
    	msg +=	"<table cellspacing=0 cellpadding=8>"
    	msg +=	"<tr>"
    	msg +=	"<th>Produto</th>"
    	msg +=	"<th>Descrição</th>"
    	msg +=	"<th>Quant.</th>"
    	msg +=	"<th>Centro Custo</th>"
    	msg +=	"<th>Obs</th>"
		msg +=	"</tr>"
		
		//percorre os itens do usuario...
		for j := 1 to len(aCols)
			msg +=	"<tr>"
	    	msg +=	"<td style='text-align:center;background-color: white'>" + aCols[j][nPosProduto] + "</td>"
	    	msg +=	"<td style='text-align:left;background-color: white'>" + aCols[j][nPosDescri] + "</td>"
	    	msg +=	"<td style='text-align:right;background-color: white'>" + TransForm(aCols[j][nPosQuant],PesqPict("SC1","C1_QUANT")) + "</td>"
	    	msg +=	"<td style='text-align:center;background-color: white'>" + aCols[j][nPosCC] + "</td>"
	    	msg +=	"<td style='text-align:left;background-color: white'>" + aCols[j][nPosOBS] + "</td>"
			msg +=	"</tr>"			
		next j
		msg +=	"</table>"
		msg +=	"<p>É de sua responsabilidade a conferência destes dados e caso esteja em desacordo entrar em contato imediatamente com o usuário <font color=red>" + cUserName + "</font>.</p>"
		msg +=	"<p>Por favor não responda este e-mail, esta conta não é monitorada, qualquer assunto comunique-se diretamente com o usuário que lançou a solicitação</p>"
		                    
		assunto := "SOLICITAÇÃO DE COMPRAS - " + cA110Num  
		cpara := trim(cemaiAp)
		
		bBloco := { |lEnd| envMail(cpara, assunto, msg)}
		MsAguarde(bBloco,"Aguarde","Notificando: " +  cpara,.F.)
	endif		 	

Return



static function envMail(cpara,cassunto,cmsg)

	local oServer  := Nil
	local oMessage := Nil
	local nErr     := 0
	local cPopAddr  := ''
	local cSMTPAddr := GETMV('MV_RELSERV')
	local cPOPPort  := 110
   	local cSMTPPort := 465
	local cUser     := GETMV('MV_RELACNT')
	local cPass     := GETMV('MV_RELPSW')
	local nSMTPTime := 60
	Local lAutentica := GetMV("MV_RELAUTH")             
     
	if (":" $ cSMTPAddr)
		aEndereco := STRTOKARR(cSMTPAddr , ":")	             	
		
		cSMTPAddr := aEndereco[1]
	   	cSMTPPort := val(aEndereco[2])
	
	endif     

	             	             
	// Instancia um novo TMailManager
	oServer := tMailManager():New()    
	                                                     
	// Usa SSL na conexao
	oServer:setUseSSL(.F.)
	
	// Inicializa
	oServer:init(cPopAddr, cSMTPAddr, cUser, cPass, 0, cSMTPPort)
	
	// Define o Timeout SMTP
	if oServer:SetSMTPTimeout(nSMTPTime) != 0
  		conout("[ERROR]Falha ao definir timeout")
  		return .F.
	endif

	// Conecta ao servidor
	nErr := oServer:smtpConnect()
	if nErr <> 0
  		conOut("[ERROR]Falha ao conectar: " + oServer:getErrorString(nErr))
  		oServer:smtpDisconnect()
  		return .F.
	endif
            
    If lAutentica                  
	// Realiza autenticacao no servidor
		nErr := oServer:smtpAuth(cUser, cPass)
		if nErr <> 0
	  		conOut("[ERROR]Falha ao autenticar: " + oServer:getErrorString(nErr))
	  		oServer:smtpDisconnect()
	  		return .F.
		endif
	endif
	
	// Cria uma nova mensagem (TMailMessage)
	oMessage := tMailMessage():new()
	oMessage:clear()
	oMessage:cFrom    := "Farmax"
	oMessage:cTo      := cpara
	oMessage:cSubject := cassunto
	oMessage:cBody    := cmsg
                                        
	// Envia a mensagem
	nErr := oMessage:send(oServer)
	if nErr <> 0
  		conout("[ERROR]Falha ao enviar: " + oServer:getErrorString(nErr))
  		oServer:smtpDisconnect()
  		return .F.
	endif

	// Disconecta do Servidor
	oServer:smtpDisconnect()


Return