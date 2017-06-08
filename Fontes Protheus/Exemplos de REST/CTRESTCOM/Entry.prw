#include "Protheus.ch"

/*/{Protheus.doc} Entry
Conceito de ‘entrada’ para mapeamento de chave/Valor.
@author desenvolvimento
@since 17/09/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
CLASS Entry
	DATA KEY
	DATA VALUE
	
	METHOD New() CONSTRUCTOR
	METHOD GetKey()
	METHOD GetVALUE()
	METHOD SetVALUE()
	METHOD SetKEY_()
	METHOD ToJson()
ENDCLASS
/*/{Protheus.doc} New
Cria uma nova instância de Entry
@author desenvolvimento
@since 17/09/2014
@version 1.0
@param _KEY, ${Caracter}, (Chave)
@param _VALUE, ${Undefined}, (valor)
@example
oEntry := Entry():New('1','casa')
@see (links_or_references)
/*/METHOD New(_KEY,_VALUE) CLASS Entry
::KEY = _KEY
::VALUE= _VALUE
RETURN self
METHOD GetKey() CLASS Entry
RETURN ::KEY
METHOD GetVALUE() CLASS Entry
RETURN ::VALUE
METHOD SetVALUE(_VALUE) CLASS Entry
::VALUE = _VALUE
RETURN 
METHOD SetKEY_(_KEY) CLASS Entry
::KEY := _KEY
RETURN
/*/{Protheus.doc} ToJson
Retorna o valor do conteudo do 
objeto de acordo com a formatação Json
@author desenvolvimento
@since 17/09/2014
@version 1.0
@example
oEntry := Entry():New('nome','Cladimir')
oEntry:ToJson() --> "Nome" : "Cladimir" 
oEntry := Entry():New('valores',{1,5,8,7})
oEntry:ToJson() --> "valores": [1,5,8,7]
@see (links_or_references)
/*/
METHOD ToJson() CLASS Entry
	LOCAL cRet
	LOCAL oObj
	Local var := 0
	
	IF ValType(::VALUE) == "C"
		cRet := '"'+::KEY+'"'+': '+'"'+::VALUE+'"'
	ELSEIF ValType(::VALUE) == "N" .OR. ValType(::VALUE) == "F"
		cRet := '"'+::KEY+'"'+': '+Alltrim(str(::VALUE))
	ELSEIF ValType(::VALUE) == "L"
		If(::VALUE)
			cRet := '"'+::KEY+'"'+': '+'true'
		Else
			cRet := '"'+::KEY+'"'+': '+'false'
		EndIf
	ELSEIF ValType(::VALUE) == "D"
		cRet := '"'+::KEY+'"'+': '+'"'+dtoc(::VALUE)+'"'
	ELSEIF ValType(::VALUE) == "O"
		oObj := ::VALUE
		cRet :=  '"'+::KEY+'"' +': '+oObj:ToJson()
	ELSEIF ValType(::VALUE) == "A"
		if Len(::VALUE) > 0
			cRet :=  '"'+::KEY+'"' +': ['
			
			if  ValType(::VALUE[1]) == "O"
				for var:= 1 to Len(::VALUE)
					oObj :=  ::VALUE[var]
					cRet += oObj:ToJson()
					If var < Len(::VALUE)
						cRet += ', '
					EndIF
				next
			else
				for var:= 1 to Len(::VALUE)
					If ValType(::VALUE[var]) == "C"
						cRet += '"'+alltrim(::VALUE[var])+'"'
					ELSEIF ValType(::VALUE[var]) == "N" .OR. ValType(::VALUE[1]) == "F"
						cRet += alltrim(str(::VALUE[var]))
					ELSEIF ValType(::VALUE[var]) == "L"
						if(::VALUE[var])
							cRet += "true"
						Else
							cRet += "false"
						EndIf
					ELSEIF ValType(::VALUE[var]) == "D"
						cRet += dtoc(::VALUE[var])
					ENDIF
					
					If var < Len(::VALUE)
						cRet += ', '
					EndIF
				next
			EndIF
			
			cRet += ']'
		
		// Alterado por Jackson em 10/11/2014 
		// -> Tratamento para TAG com array vazio pois estava gerando excecao na concatenacao do metodo toJson da classe Map.
		Else
			cRet :=  '"'+::KEY+'"' +': ['
			cRet += ']'
		EndIf
	ENDIF
	
	
		
RETURN cRet
