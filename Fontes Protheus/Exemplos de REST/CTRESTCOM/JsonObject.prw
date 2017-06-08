#include "Protheus.ch"

CLASS JsonObject
	
	DATA oMap
	
	METHOD New() CONSTRUCTOR
	
	METHOD PutVal()
	
	METHOD GetCharac()
	METHOD GetNumber()
	METHOD GetBool()
	METHOD GetObjJson()
	METHOD GetArray()

	METHOD GetUndef()	
	METHOD ToJson()	
	METHOD Parse()
ENDCLASS

METHOD New() CLASS JsonObject
	::oMAP := Map():New()
RETURN SELF

METHOD PutVal(cKEY,uVAL) CLASS JsonObject
	Local oEntry
	
	oEntry := Entry():New(cKEY,uVAL)
	::oMAP:PutEntry(oEntry)
	
RETURN

METHOD GetUndef(cKEy) CLASS JsonObject
	Local oEntry 
	Local uRet := nil
	oEntry := ::oMAP:GetEntry(cKEy)
	
	if ValType(oEntry) == "O"
		uRet := oEntry:GetValue()
	EndIf
	
RETURN uRet

METHOD GetCharac(cKEy) CLASS JsonObject
	local cRet :=""
	local uVal
	If ::oMap:HasKey(cKEy)
		uVal := ::GetUndef(cKEy)
		if(ValType(uVal)=="C")
			cRet := uVal
		ElseIf (ValType(uVal)=="N")
			cRet := AllTrim(str(uVal))
		ElseIf (ValType(uVal)=="D")
			cRet := dtos(uVal)
		EndIf				
	EndIf
RETURN cRet

METHOD GetNumber(cKEy) CLASS JsonObject
	Local nRet := 0 
	local uVal
	Local var := 0
	If ::oMap:HasKey(cKEy)
		uVal := ::GetUndef(cKEy)
		if(ValType(uVal)=="C")
			nRet := Val(uVal)
		ElseIf (ValType(uVal)=="N")
			cRet := uVal
		EndIf
	EndIf
RETURN nRet

METHOD GetBool(cKEy) CLASS JsonObject
	Local lRet := .F. 
	local uVal
	If ::oMap:HasKey(cKEy)
		uVal := ::GetUndef(cKEy)
		if(ValType(uVal)=="C")
			if(upper(uVal)== 'FALSE' .OR. upper(uVal)== '.F.' )
				lRet := .F.
			ElseIf (upper(uVal)== 'TRUE' .OR. upper(uVal)== '.T.' )
				lRet := .F.
			EndIf
		ElseIf (ValType(uVal)=="L")
			lRet := uVal
		EndIF
	EndIf
RETURN lRet  

METHOD GetObjJson(cKEy) CLASS JsonObject
	Local oRet := JsonObject():New()
	local uVal
	If ::oMap:HasKey(cKEy)
		uVal := ::GetUndef(cKEy)
		if(ValType(uVal)=="O")
			oRet:oMap := uVal:oMap 
		EndIf
	EndIf
RETURN oRet	

METHOD GetArray(cKEy) CLASS JsonObject
	Local aRet := {}
	local uVal
	If ::oMap:HasKey(cKEy)
		uVal := ::GetUndef(cKEy)
		if(ValType(uVal)=="A")
			aRet := uVal   
		EndIf
	EndIf
RETURN aRet

METHOD ToJson() CLASS JsonObject
	Local cJson := ""
	cJson += ::oMap:ToJson()	
RETURN cJson

METHOD Parse(cJson) CLASS JsonObject
	Local teste :=""
	Local oParse := JsonParse():New(cJson)
	Local tmpObjson := oParse:ParseToObj()
	
	::oMap := tmpObjson:oMap
RETURN
