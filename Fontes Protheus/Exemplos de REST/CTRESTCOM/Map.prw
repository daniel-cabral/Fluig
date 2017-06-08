#include "Protheus.ch"
CLASS Map

	DATA aENTRY

	METHOD New() CONSTRUCTOR
	METHOD Size()
	METHOD HasKey()
	METHOD HasValue()
	METHOD GetIndex()
	METHOD GetEntry()
	METHOD SetEntry()
	METHOD PutEntry() 
	//METHOD DelEntry()
	METHOD ToJson()
ENDCLASS

METHOD New(_Map) CLASS Map
	::aENTRY := {}	
RETURN SELF

METHOD Size() CLASS Map
RETURN LEN(aEntry)


/*/{Protheus.doc} HasKey
Busca no array de entrys deste objeto
se o mesmo possue alguma Entry com a KEY informada
@author desenvolvimento
@since 17/09/2014
@version 1.0
@param cKEY, character, (Key que deve ser procurada)
@example
(examples)
@see (links_or_references)
/*/METHOD HasKey(cKEY) CLASS Map
	Local var := 0
	
	for var:= 1 to Len(::aENTRY)
		if ::aENTRY[var]:GetKey() == cKEY
			RETURN .T.		
		endif
	next
RETURN .F.
/*/{Protheus.doc} HasValue
Busca no array de entrys deste objeto
se o mesmo possue alguma Entry com o VALUE informado
@author desenvolvimento
@since 17/09/2014
@version 1.0
@param uVALUE, ${Undefined}, (VALUE que deve ser procurado)
@example
(examples)
@see (links_or_references)
/*/METHOD HasValue(uVALUE) CLASS Map
	Local var := 0
	
	for var:= 1 to Len(::aENTRY)
		if type(::aENTRY[var]:GetValue()) == type(var)
			if ::aENTRY[var]:GetValue() == type(var)
				RETURN .T.		
			endif
		endif
	next
RETURN .F.
/*/{Protheus.doc} GetIndex
Retorna a posicao de uma ENTRY pela sua KEY
@author desenvolvimento
@since 17/09/2014
@version 1.0
@param cKEY, character, (Key que deve ser procurada)
@example
(examples)
@see (links_or_references)
/*/METHOD GetIndex(cKEY) CLASS Map
	Local var := 0
	
	for var:= 1 to Len(::aENTRY)
		if ::aENTRY[var]:GetKey() == cKEY
			RETURN var		
		endif
	next	
RETURN 0
/*/{Protheus.doc} GetEntry
Retorna o Objeto Entry que possui esta KEY
@author desenvolvimento
@since 17/09/2014
@version 1.0
@param cKEY, character, (Key que deve ser procurada)
@example
(examples)
@see (links_or_references)
/*/METHOD GetEntry(cKEY) CLASS Map
	Local var := 0
	local oEntry:= nil
	
	var := ::GetIndex(cKEY)
	
	if(var > 0)
		oEntry := ::aENTRY[var]
	endIf
RETURN oEntry
METHOD SetEntry(oEntry) CLASS Map
	if ::HasKey(oEntry:GetKEY())
		::aENTRY[::GetIndex(oEntry:GetKEY())] := oEntry
	Endif
RETURN 
METHOD PutEntry(oEntry) CLASS Map
	If ::HasKey(oEntry:GetKey())
		::SetEntry(oEntry)
	Else
		aadd(::aENTRY,oEntry)
	Endif
RETURN
/*/{Protheus.doc} ToJson
Retorna o valor de Todas as Entrys deste 
objeto, de acordo com a formatação Json
@author desenvolvimento
@since 17/09/2014
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
METHOD ToJson() CLASS Map
	Local cJson := "{"
	Local var := 0
	Local oEntry
	
	for var:= 1 to Len(::aEntry)
		oEntry := ::aEntry[var]
		cJson += oEntry:ToJson()
		
		if(var < Len(::aEntry))
			cJson += ', ' 
		endIf
	next
	
	cJson += "}"
	
	if Len(::aEntry) == 0
		cJson := "null"	
	endIF
	
	
RETURN cJson 