* JSON.PRG
* 100% VFP Json Parser
*
* Version: 1.32
* Author: V. Espina / A. Ferreira
*
*
* BASIC USAGE
*
* DO json
* string = json.Stringify(object)
* string = json.Stringify(@array)
* object = json.Parse(string)
* string = json.Beautify(string | object)
*
*
* JSON CONSTRUCTION
*
* LOCAL cFName, cLName
* cFName = "Victor"
* cLName = "Espina"
* TEXT TO cJSON NOSHOW
* {
*   firstName: cFName,
*   lastName: cLName,
*   fullName: (this.firstName + SPACE(1) + this.lastName),
*   age: 44,
*   nacionality: "VENEZUELAN",
*   dob: "1970-11-18",
*   hobbies: ["Programming", "Music", "SciFi"],
*   languages: [
*               { id: "ES", caption: "Spanish", level: "Mother" },
*               { id: "EN", caption: "English", level: "Good" }
*              ]
* }
* ENDTEXT
*
* oVES = json.Parse(cJSON)
* ?oVES.firstName ---> "Victor"
* ?oVES.fullName ---> "Victor Espina"
* ?oVES.hobbies.Count --> 2
* ?oVES.hobbies.Item[1] --> "Programming"
* ?oVES.Languages.Item[1].id --> "ES"
*
*
*
* ERROR HANDLING
* The library uses a singleton class to handle errors in 
* all classes, so any error ocurred anywhere in the library
* can be checked using json.lastError object:
*
* IF json.lastError.hasError   && Something went wrong
*  ?"Error #", json.lastError.errorNo
*  ?"Message", json.lastError.Message
*  ?"Procedure", json.lastError.Procedure
*  ?"Line #", json.lastError.lineNo
*  ?"Details", json.lastError.Details
* ENDIF
*
* 
*
* CURSOR HANDLING
* JSON library can convert a data cursor into a JSON string representation, optionally
* including the cursor schema.  If a cursor is converted to JSON string including the schema
* the cursor can be recreated later exactly as it was (using parseCursor).  If no schema was 
* added, then cursor can still be recreated, but the library will deduce the schema from 
* the cursor data (using toCursor).
*
* string = json.Stringify("alias" [,withSchema] [,datasession]) [8]
* json.parseCursor(string [, "alias"] [,datasession]) [1]
* json.toCursor(string | object, "alias" [,datasession]) [2]
*
*
* SCHEMAS
* Schemas allows to declare public reusable cursor structures (schemas) and 
* create empty cursors based on those pre-declared schemas. Schemas are 
* based on jsonSchema class, wich can be used directly also for on-the-fly
* dinamically cursor creation.
* 
* oSchema = json.Schemas.New(name) [3]
* oSchema = json.Schemas.newFromCursor(name, "alias" [,datasession])
* oSchema = json.Schemas.newFromString(name, string) [4]
* bool = json.Schemas.Create(cursorName, schemaName [,datasession])
* oSchema = json.Schemas.Get(name)
* bool = json.Schemas.Exist(name)
* bool = json.Schemas.Delete(name)
*
* bool = oSchema.initWithAlias("alias" [,datasession])
* bool = oSchema.initWithJSON(string) [1]
* bool = oSchema.addColumn(name, type [,lon] [,dec])
* bool = oSchema.addColumn(object) [5]
* bool = oSchema.addColumnFromString(string) [6]
* bool = oSchema.existColumn(name)
* bool = oSchema.delColumn(name)
* string = oSchema.toString([bool]) [7]
* bool = oSchema.toCursor("alias" [,datasession])
* 
* 
*
* NOTES
* [1] The JSON string must be generated using Stringify method and INCLUDE the cursor schema. To convert 
*     other JSON strings to cursor, use toCursor().
*
* [2] The JSON string must be an array of objects, ex:
*     cJSON = '[{fname: "Victor", lname: "Espina", age: 44}, {fname: "Angel", lname: "Ferreira", age: 40}]'
*     json.toCursor(cJSON, "qteam")
*     SELECT qteam
*     SCAN
*      ?fname, lname, age
*     ENDSCAN
*    
*     If a single object is passed, it would be transformed into an array before processing.
*
*
* [3] All schemas has to be identified with an unique name. This name would be used later to access a
*     particular schema, ex:
*
*     json.Schemas.newFromString("userInfo","login C (25), fullname C (50), pwd C (50), role C (50)")
*     ...
*     json.Schemas.create("quser", "userInfo")
*     insert into quser values ('vespina','Victor Espina','1234','Admin')
*
* [4] Example: 
*     oSchema = json.Schemas.newFromString("fname C(50), lname C(50), age N (3), dob D")
*
* [5] Object must be an instance of jsonColumn class
* [6] Example: 
*     oSchema.addColumnFromString("lname C (50)")
*
* [7] The optional bool parameters allows to indicate that a JSON string representation of the schema is required
* [8] If optional bool parameter withSchema is passed as True, the resulting JSON string will include the cursor's schema. Use
*     this if you plan to recreate the cursor later from the JSON string.
*
*


#DEFINE VFP_JSON_LANG		        "EN"    && Cambiar a ES para mensajes en espanol
#DEFINE VFP_NOENCODABLE_PROPS		"-controls-controlcount-objects-parent-class-baseclass-classlibrary-parentclass-helpcontextid-whatsthishelpid-top-left-width-height-picture-_customproplist-activecontrol-activeform-forms-"
#DEFINE VFP_JSON_BEAUTIFY_MARGIN	2
#DEFINE CRLF 						CHR(13)+CHR(10)
#DEFINE VFP_MAX_INT					2147483647

#IF VFP_JSON_LANG=="EN"
	#DEFINE VFP_JSON_MSG_001			"The schema name is missing."
	#DEFINE	VFP_JSON_MSG_002		 	"The specified schema does not exist."
	#DEFINE	VFP_JSON_MSG_003		 	"The specified scheme already exists."
	#DEFINE	VFP_JSON_MSG_004			"The name of the column is not specified."
	#DEFINE	VFP_JSON_MSG_005			"The type of the column is not specified."
	#DEFINE	VFP_JSON_MSG_006			"The long of the column is not specified."
	#DEFINE	VFP_JSON_MSG_007			"The specified column name already exists."
	#DEFINE	VFP_JSON_MSG_008			"Invalid column type."
	#DEFINE	VFP_JSON_MSG_009			"Column structure is not specified."
	#DEFINE	VFP_JSON_MSG_010			"The cursor name is not specified."
	#DEFINE	VFP_JSON_MSG_011			"The cursor name is not in use."
	#DEFINE	VFP_JSON_MSG_012			"The string scheme is not specified."
	#DEFINE	VFP_JSON_MSG_013			"The provided JSON string is not well formatted (invalid attribute name)"
	#DEFINE VFP_JSON_MSG_014			"Unbalanced JSON string"
	#DEFINE	VFP_JSON_MSG_015			"The provided JSON string is not well formatted (invalid variable name)"
	#DEFINE VFP_JSON_MSG_016			"The provided JSON string does not represents a valid cursor object"
	#DEFINE VFP_JSON_MSG_017			"Missing parameter"
	#DEFINE VFP_JSON_MSG_018			"Invalid parameter"
	#DEFINE VFP_JSON_MSG_019			"The provided JSON string is not well formatted"
	#DEFINE VFP_JSON_MSG_020			"The schema is empty"
	#DEFINE VFP_JSON_MSG_021			"The provided JSON is not an array of objects"
	#DEFINE VFP_JSON_MSG_022			"Alias already exists"
#ENDIF

#IF VFP_JSON_LANG == "ES"
	#DEFINE VFP_JSON_MSG_001			"Falta el nombre del esquema"
	#DEFINE	VFP_JSON_MSG_002		 	"El esquema especificado no existe."
	#DEFINE	VFP_JSON_MSG_003		 	"El esquema especificado ya existe."
	#DEFINE	VFP_JSON_MSG_004			"No se especifica el nombre de la columna."
	#DEFINE	VFP_JSON_MSG_005			"No se especifica el tipo de columna."
	#DEFINE	VFP_JSON_MSG_006			"No se especifica la longitud de la columna."
	#DEFINE	VFP_JSON_MSG_007			"El nombre de columna especificado ya existe."
	#DEFINE	VFP_JSON_MSG_008			"Tipo de columna no válida."
	#DEFINE	VFP_JSON_MSG_009			"No se especifica la estructura de columnas."
	#DEFINE	VFP_JSON_MSG_010			"El nombre del cursor no se especifica."
	#DEFINE	VFP_JSON_MSG_011			"El nombre del cursor no está en uso."
	#DEFINE	VFP_JSON_MSG_012			"El esquema de cadenas no está especificado."
	#DEFINE	VFP_JSON_MSG_013			"La cadena JSON proporcionada no está bien formateada (nombre de atributo no válido)"
	#DEFINE VFP_JSON_MSG_014			"Cadena JSON desequilibrada"
	#DEFINE	VFP_JSON_MSG_015			"La cadena JSON proporcionada no está bien formateada (nombre de variable no válido)"
	#DEFINE VFP_JSON_MSG_016			"La cadena JSON proporcionada no representa un objeto de cursor válido"
	#DEFINE VFP_JSON_MSG_017			"Parámetro que falta"
	#DEFINE VFP_JSON_MSG_018			"Parámetro no válido"
	#DEFINE VFP_JSON_MSG_019			"La cadena JSON suministrada no está bien formateada"
	#DEFINE VFP_JSON_MSG_020			"El esquema está vacío"
	#DEFINE VFP_JSON_MSG_021			"El JSON proporcionado no es un array de objetos"
	#DEFINE VFP_JSON_MSG_022			"El alias ya existe"
#ENDIF


#IF VERSION(5) < 800
	#DEFINE _TRY		ex=TRY()
	#DEFINE _CATCH	    IF CATCH(@ex)
	#DEFINE _ENDTRY		ENDIF
	#DEFINE _EMPTY		"EMPTYOBJECT"
#ELSE
	#DEFINE _TRY		TRY
	#DEFINE _CATCH	    CATCH TO ex
	#DEFINE _ENDTRY		ENDTRY
	#DEFINE _EMPTY		"EMPTY"
#ENDIF

		
* Load the library into mnemory
SET PROCEDURE TO json ADDITIVE

PUBLIC json
json = CREATEOBJECT("json")

RETURN



* json (Class)
* JSON parser engine
*
DEFINE CLASS json AS Custom

	version = 0							&& Current version
	useStrictNotation = .T.				&& Use JSON strict notation ("token" : value)
	lastOpTime = 0 					    && Time (in seg) consumed by the last operation 
	Schemas = NULL                      && Published schemas
	lastError = NULL                    && Last error info
	stringSeparator = ["]				&& String separator
	useFastParser = .F.                 && Use a faster parser (Non-VFP code)	
	normalizeResults = .T.              && (fastParsing only). Converts JS object to Fox object
	ignoreInvalidChars = .T.            && Ignore invalid chars in property names
	httpClient = 0                      && HTTP client to be used (0:serverXMLHTTP6, 1:XMLHTTP6, 2:XMLHTTP)
	
	HIDDEN oFastParser                  && Rerence to the fast parser
	HIDDEN oFPBuff                      && Buffer for data interchange with faster parser
	
	PROCEDURE version_access
	 RETURN 1.32
	ENDPROC
	
    
    * Init	(Method)
    * Constructor of Class
    *
    PROCEDURE Init()
      * Add Property for handle of Cursors Schemas
      THIS.Schemas = CREATEOBJECT("jsonSchemas")
      
      * Add Property for handle of jSon Errors
      THIS.lastError = CREATEOBJECT("jsonError")
      
      * FastParser will be created first time is required
      THIS.oFastParser = NULL
    ENDPROC 
    
    
    * Parse (Method)
    * Takes a JSON string and returns an object representation
    *
    * nMode variable can have following values:
    * 0: Initial mode
    * 1: Property mode
    * 2: Value mode
    * 3: Token complete mode
    *
    #IF VERSION(5) < 700
	    PROCEDURE Parse(pcJson, pnPos)
	     LOCAL nStarted, oJSON, oEX
	     THIS.lastError.Clear()
	     nStarted = SECONDS()

		 ex = TRY()
	 		IF THIS.useFastParser
	 			oJSON = THIS._fastParse(pcJSON)
	 		ELSE
	     		oJSON = THIS._Parse(pcJson, pnPos)
	     	ENDIF
	     	
	     IF CATCH(@ex)	
	        THIS.lastError.initWithEx(ex)
	        oJSON = NULL
	     ENDIF
	     
		 THIS.lastOpTime = SECONDS() - nStarted + IIF(SECONDS() < nStarted, 86400, 0)
		 
		 RETURN oJSON
	    ENDPROC    
    #ENDIF
    
    #IF VERSION(5) > 600
	    PROCEDURE Parse(pcJson, pnPos)
	     LOCAL nStarted, oJSON
	     THIS.lastError.Clear()
	     nStarted = SECONDS()
	     TRY
	 		IF THIS.useFastParser
	 			oJSON = THIS._fastParse(pcJSON)
	 		ELSE
	     		oJSON = THIS._Parse(pcJson, pnPos)
	     	ENDIF
	     	
	     CATCH TO ex
	     	THIS.lastError.initWithEx(ex)
	     	oJSON = NULL
	     ENDTRY
		 THIS.lastOpTime = SECONDS() - nStarted + IIF(SECONDS() < nStarted, 86400, 0)
		 RETURN oJSON
	    ENDPROC        
    #ENDIF
    

    HIDDEN PROCEDURE _fastParse(pcJSON)
	    LOCAL oJS,oJSON,oData
	    pcJSON = ALLTRIM(CHRT(pcJSON, CHR(13) + CHR(10), ""))
		oJS = THIS._getFastParser()
		oJS.run("set","json",pcJSON)
		foo = oJS.run("get","json")
		oJS.run("set","normalize",THIS.normalizeResults)	    
	    oJSON = oJS.run("parseJSON")
	    IF !ISNULL(oJSON)
		    IF THIS.normalizeResults
		     	oJSON = THIS._js2fox(oJSON)
		    ENDIF
		ELSE
			THIS.lastError.initWithString(oJS.run("get","lasterror"))
	    ENDIF
	    RETURN oJSON

    
	HIDDEN PROCEDURE _Parse(pcJSON, pnPos)
	 *	 	 
	 IF VARTYPE(pnPos) <> "N"
	  pcJSON = ALLTRIM(CHRT(pcJSON, CHR(13) + CHR(10), ""))
	  pnPos = 1
	 ENDIF
	 	 
	 LOCAL i, nLen, cChar, cLastChar, nMode, cStringSep, lIsString, cProp, nNestLevel, oValue, ;
	       lExitLoop, oTarget, uBuff, lIsArray, oArray, lVarMode, lExprMode, nExprNestLevel, ;
	       nNestLevel
	 nLen = LEN(pcJSON)
	 cLastChar = CHR(0)
	 oTarget = NULL
	 cStringSep = THIS.stringSeparator
	 lIsString = .F.
	 nNestLevel = 0
	 lExitLoop = .F.
	 lIsArray = .F.
	 lVarMode = .F.
	 lExprMode = .F.
	 nExprNestLevel = 0
	 oArray = NULL
	 cChar = SUBSTR(pcJSON, pnPos, 1)
	 lIsArray = (cChar = "[")
	 oTarget = IIF(lIsArray, CREATEOBJECT("Collection"), CREATEOBJECT(_EMPTY))
	 nMode = IIF(lIsArray, 2, 0)
	 uBuff = ""       
	 i = 1

     #IF VERSION(5) > 600	 
	 TRY
	 #ENDIF
	 
	 IF NOT cChar $ "[{"		&& A valid JSON string must start with { or [.
	  THROW(VFP_JSON_MSG_019)
	 ENDIF
	 nNestLevel = 1

	 
	 FOR i = pnPos + 1 TO nLen
	  *
	  cChar = SUBSTR(pcJSON, i, 1)
	  
	  DO CASE
	     CASE cChar $ CHR(9)     && Ignorable chars
	          LOOP
	          
	     CASE cChar = "{" AND !lIsString  && Start new object
	          uBuff = THIS._Parse(pcJSON, @i)
	          nMode = 3
	          
	     CASE cChar $ "}]" AND !lIsString  && Close last object or array
	          lExitLoop = .T.
	          nMode = IIF(INLIST(cLastChar,cStringSep,"{","[") OR (EMPTY(cProp) AND (!lIsArray OR EMPTY(uBuff))), nMode, 3)
	          nNestLevel = nNestLevel - 1

	     CASE cChar = "[" AND !lIsString   && Start new array
	          uBuff = THIS._Parse(pcJSON, @i)
	          nMode = 3
	                                             
	     CASE cChar = cStringSep AND nMode = 0   && Property name start
	          nMode = 1
	          uBuff = ""
	          
	     CASE nMode = 0 AND THIS.isAlpha(cChar)   && Property name start (non-quoted property)
	          nMode = 1
	          uBuff = cChar
	          
	     CASE nMode = 1 AND !THIS.isAlpha(cChar) AND !ISDIGIT(cChar) AND !INLIST(cChar,":",SPACE(1),cStringSep,"-")  && Invalid char in property mode
	          IF THIS.IgnoreInvalidChars
	          	LOOP
	          ELSE
	          	THROW(VFP_JSON_MSG_013 + " (" + SUBSTR(pcJSON, i - 10, 10) + " -->" + cChar + "<-- " + SUBSTR(pcJSON,i+1,20) + ") " + TRANSFORM(lIsString,"") + " " + TRANSFORM(uBuff,""))
	          ENDIF
	          
	     CASE  !INLIST(cChar, cStringSep, ":", SPACE(1)) AND nMode = 1  && Property name
	          uBuff = uBuff + CHRTRAN(cChar,"-","_")
	          
	     CASE cChar = ":" AND nMode = 1   && Close property name
	          cProp = ALLTRIM(uBuff)
	          uBuff = ""
	          nMode = 2
	          lIsString = .F.
	          lExprMode = .F.
	          lVarMode = .F.	          
	          	          
	     CASE cChar = SPACE(1) AND nMode = 2 AND !lIsString && Discard spaces between property name and property value
	     
	     CASE nMode = 2 AND !lIsString AND EMPTY(uBuff) AND THIS.isAlpha(cChar)   && Variable value start
	          uBuff = uBuff + cChar
	          lVarMode = .T.
	          lIsString = .T.
	          
	     CASE nMode = 2 AND lVarMode AND !EMPTY(uBuff) AND INLIST(cChar,[ ],[,],"]","}")   && Variable value end	     
	          lVarMode = .F.
	          DO CASE
	             CASE INLIST(LOWER(uBuff),"true","false")
	                  uBuff = (LOWER(uBuff) == "true")
	                  
	             CASE LOWER(uBuff) == "null"
	                  uBuff = null
	             
	             OTHERWISE
			          _TRY
			           uBuff = EVALUATE(uBuff)
			          _CATCH
			            uBuff = ex.Message
			          _ENDTRY
			  ENDCASE        
	          nMode = 3
	          lIsString = (VARTYPE(uBuff) = "C")
	          IF cChar $ "]}"
	           nNestLevel = nNestLevel - 1
	           lExitLoop = .T.
	          ENDIF

	     CASE nMode = 2 AND lVarMode AND !EMPTY(uBuff) AND !THIS.isAlpha(cChar) AND !INLIST(cChar,[ ],[,],"]","}")  && Invalid variable char
	          THROW(VFP_JSON_MSG_015 + " (" + SUBSTR(pcJSON, i - 10, 10) + " -->" + cChar + "<-- " + SUBSTR(pcJSON,i+1,20) + ")")
	          
	     CASE nMode = 2 AND !lExprMode AND EMPTY(uBuff) AND cChar = "("  AND !lIsString && Expresion value start
	          lExprMode = .T.
	          uBuff = ""
	          lIsString = .T.
	          nExprNestLevel = 1
	          
	     CASE nMode = 2 AND lExprMode AND cChar = "(" 
	          nExprNestLevel = nExprNestLevel + 1
	          uBuff = uBuff + cChar
	          
	     CASE nMode = 2 AND lExprMode AND cChar = ")" AND nExprNestLevel > 1
	          nExprNestLevel = nExprNestLevel - 1     
	          uBuff = uBuff + cChar
	          	          
	     CASE nMode = 2 AND lExprMode AND cChar = ")"  AND nExprNestLevel = 1  && Expresion value end
	          lExprMode = .F.
	          nExprNestLevel = 0 
	          _TRY
	           uBuff = STRT(uBuff, "this.", "oTarget.")
	           uBuff = STRT(uBuff, "THIS.", "oTarget.")
	           uBuff = STRT(uBuff, "This.", "oTarget.")
	           uBuff = EVALUATE(uBuff)
	           IF NOEX()
	            lIsString = (VARTYPE(uBuff) $ "CM")
	           ENDIF
	           
	          _CATCH
	           uBuff = ex.Message
	           
	          _ENDTRY
	          nMode = 3
	          
	     CASE nMode = 2 AND lExprMode
	          uBuff = uBuff + cChar     
	          
	     CASE cChar = cStringSep AND !lIsString AND nMode = 2  && String value start
	          lIsString = .T.

	     CASE cChar = cStringSep AND lIsString AND nMode = 2 AND cLastChar<>"\"  && End string value
	          nMode = 3
	          
	     CASE cChar = "," AND !lIsString AND nMode = 2  && End non-string value
	          nMode = IIF(INLIST(cLastChar,cStringSep,"{","["), nMode, 3)
*!*		          
*!*		     CASE nMode = 2 
*!*		          uBuff = uBuff + cChar
	
	     CASE nMode = 2 
	 		  uBuff = uBuff + cChar
	          IF cChar = "\" AND cChar = cLastChar   && Avoid an parsing error when last char in string is "\\"
	            cChar = CHR(0)
	          ENDIF

	  ENDCASE
	  
	  IF nMode = 3 
	   DO CASE
	      CASE !VARTYPE(uBuff) $ "COX"	           
	   
	      CASE lIsString
	           lIsString = .F.
	           DO CASE
	              CASE LIKE("????-??-??T??:??:??",uBuff)
  	                   uBuff = CTOT("^" + uBuff)

	              CASE LIKE("????-??-??",uBuff)
  	                   uBuff = CTOD("^" + uBuff)
  	                   
  	              OTHERWISE
  	                   uBuff = THIS.unescapeHTML(uBuff)     
	           ENDCASE
	         
	      CASE VARTYPE(uBuff) = "O"
	           
	      CASE VARTYPE(uBuff) = "X" OR LOWER(uBuff) == "null"
	           uBuff = NULL
	          
	      CASE LOWER(uBuff) == "false"      
	           uBuff = .F.
	           
	      CASE LOWER(uBuff) == "true"
	           uBuff = .T.
	      
	      OTHERWISE
	          IF VAL(uBuff) <= VFP_MAX_INT
	          	uBuff = IIF(AT(".",uBuff) = 0, INT(VAL(uBuff)), VAL(uBuff))
	          ELSE 
	            lIsString = .T.
	          ENDIF
	   ENDCASE
	   IF lIsArray
	    oTarget.Add(uBuff)
	    uBuff = ""
	    nMode = 2	    
	   ELSE
	    IF !EMPTY(cProp)	     
	     #IF VERSION(5) >= 900
	        TRY
	     #ENDIF
	     ADDPROPERTY(oTarget, cProp, uBuff)
	     #IF VERSION(5) >= 900
	        CATCH TO ex
	            THROW "Invalid property name: " + cProp
	        ENDTRY
	     #ENDIF
	    ENDIF
	    nMode = 0 
	    cProp = ""
	    uBuff = ""
	   ENDIF
	  ENDIF
	  
	  IF lExitLoop
	   EXIT
	  ENDIF
	  
	  cLastChar = cChar
	  *
	 ENDFOR
	 pnPos = i
	 
	 
	 IF nNestLevel <> 0
	  THROW(VFP_JSON_MSG_014)
	 ENDIF
	 
	 
	 #IF VERSION(5) > 600
	 CATCH TO ex
	  ex.Details = STUFF(pcJSON,i,6,cChar + "<--  ") &&+ " [Mode: " + ALLTRIM(STR(nMode)) + ", uBuff: " + TRANSFORM(uBuff,"") + ", cProp: " + cProp + "]"
	  THIS.lastError.initWithEx(ex)
	  oTarget = NULL
	  
	 ENDTRY
	 #ENDIF
	 
	 
	 RETURN oTarget
	 *
	ENDPROC



    * parseCursor (Method)
    * Takes a JSON string and recreate the original cursor
    *
	PROCEDURE parseCursor(pcJSON, pcAlias, pnDSID)
	 *
	 LOCAL oCursor,nStarted
	 nStarted = SECONDS()
	 oCursor = THIS.Parse(pcJSON)	 
	 IF THIS.lastError.hasError
	  RETURN .F.
	 ENDIF
	 IF !PEMSTATUS(oCursor, "schema", 5)
	  THIS.lastError.initWithString(VFP_JSON_MSG_016)
	  RETURN .F.
	 ENDIF
	 
	 IF PEMSTATUS(oCursor, "name", 5)
 	  pcAlias = EVL(pcAlias, oCursor.name)
 	 ENDIF
 	 
 	 IF !EMPTY(pnDSID)
 	  SET DATASESSION TO (pnDSID)
 	 ENDIF
 	 IF EMPTY(pcAlias)
 	  DO WHILE .T.
 	   pcAlias = "Q" + SYS(2015)
 	   IF !USED(pcAlias)
 	    EXIT
 	   ENDIF
 	  ENDDO
 	 ENDIF
 	 

	 LOCAL oSchema
 	 oSchema = CREATEOBJECT("jsonSchema")
 	 IF NOT oSchema.initWithJSON(oCursor)
  	  THIS.lastOpTime = SECONDS() - nStarted + IIF(SECONDS() < nStarted, 86400, 0)
 	  RETURN .F.
 	 ENDIF
 	 
 	 SELECT 0
 	 IF NOT oSchema.toCursor(pcAlias)
 	  THIS.lastOpTime = SECONDS() - nStarted + IIF(SECONDS() < nStarted, 86400, 0)
	  RETURN .F.
	 ENDIF
	 
	 IF PEMSTATUS(oCursor, "rows", 5)
	  LOCAL oRow, i, nCount
	  nCount = oCursor.Rows.Count
	  SELECT (pcAlias)
	  FOR i = 1 TO nCount
	   oRow = oCursor.Rows.Item[i]
	   APPEND BLANK
	   GATHER NAME oRow MEMO
	  ENDFOR
	  GO TOP
	 ENDIF
	 
	 THIS.lastOpTime = SECONDS() - nStarted + IIF(SECONDS() < nStarted, 86400, 0)
	 *
	ENDPROC
	
	
	
	* parseXML (Method)
	* Takes an XML string and returns an object representation
	*
	FUNCTION parseXML(poXmlNode, pcArrayNodes)
	 *
	 THIS.lastError.Clear()
	 IF VARTYPE(poXmlNode) = "C"
	  LOCAL oXml
      oXml = CREATEOBJECT('msxml.domdocument')
      oXml.loadXML(poXmlNode)	 
      poXmlNode = oXml
	 ENDIF
	 
	 LOCAL oTarget,i
	 oTarget = CREATEOBJECT(_EMPTY)
	 
	 IF VARTYPE(pcArrayNodes)<>"C"
	  pcArrayNodes = ""
	 ENDIF
	 
	 * Add any attribute the node has
	 IF TYPE("poXmlNode.Attributes.Length")="N"
	  LOCAL cAttr, oAttr
	  FOR i = 1 TO poXmlNode.Attributes.Length
	   oAttr = poXmlNode.Attributes.Item[i-1]
	   cAttr = CHRTRAN(oAttr.Name,":-","_")
	   ADDPROPERTY(oTarget, cAttr, oAttr.Value)
	  ENDFOR
	 ENDIF


     * Get a child list
	 LOCAL oNode,cChildName,lIsArray,oChilds,nChilds,nGrandChilds
	 oChilds = CREATEOBJECT("Collection")
	 
	 DO CASE
	    CASE TYPE("poXmlNode.childNodes.Length") = "N"
	         FOR i = 1 TO poXmlNode.childNodes.Length
	          oChilds.Add(poXmlNode.childNodes.Item[i - 1])
	         ENDFOR

	    CASE TYPE("poXmlNode.Length") = "N"
	         FOR i = 1 TO poXmlNode.Length
	          oChilds.Add(poXmlNode.Item[i - 1])
	         ENDFOR	         
	 ENDCASE
     

	 * If the node has no childs, we don't need to do anything else
	 nChilds = oChilds.Count
	 IF nChilds = 0
	  RETURN oTarget
	 ENDIF
	 
	 * If all children has the same name, handle this node as a collection
	 IF nChilds > 1
		 cChildName = oChilds.Item[1].nodeName
		 lIsArray = .T.
		 FOR i = 1 TO nChilds
		  IF !(oChilds.Item[i].nodeName == cChildName)
		   lIsArray = .F.
		   EXIT
		  ENDIF
		 ENDFOR
	 ENDIF 
	 IF lIsArray
	  oTarget = CREATEOBJECT("Collection")
	 ENDIF
	 
	 
	 * Handle node's children
	 LOCAL cNodeName,cData,cLastNode,oLastNode,oArray,uData
	 oLastNode = NULL
	 cLastNode = ""
	 FOR i = 1 TO nChilds
	  oNode = oChilds.Item[i]
	  nGrandChilds = oNode.childNodes.Length
	  cNodeName = CHRTRAN(oNode.nodeName, ":-", "_")
	  
	  DO CASE
	     CASE nGrandChilds = 0 AND oNode.Attributes.Length = 0 
	          ADDPROPERTY(oTarget, cNodeName, "")
	          
	     CASE nGrandChilds = 1 AND INLIST(oNode.childNodes.Item[0].nodeName,"#text","#cdata-section")
	          cData = oNode.childNodes.Item[0].Data
	          uData = cData
	          DO CASE
	             CASE LIKE("????-??-??T??:??:??",cData)    && Date, Date/Time
			          uData = CTOT(cData)
			          IF !EMPTY(uData)
			           IF HOUR(uData) = 0 AND MINUTE(uData) = 0 AND SEC(uData) = 0 
			             uData = TTOD(uData)
			           ENDIF
			          ELSE
			           uData = cData 
			          ENDIF
			          
			     CASE INLIST(LOWER(cData),"true","false")   && Boolean
			          uData = (LOWER(cData) == "true")
			          
			     CASE INLIST(LOWER(cData),"null","nil")     && Null value
			          uData = NULL
			               
			     CASE AT(".",cData) > 0 AND VAL(cData) > 0   && Numeric value (not INT)
			          uData = VAL(cData)          
			  ENDCASE        
	          ADDPROPERTY(oTarget, cNodeName, uData)


         CASE lIsArray
              oTarget.Add(THIS.parseXml(oNode, pcArrayNodes))
              
         CASE cNodeName == cLastNode
              IF TYPE("oLastNode.Class")<>"C" OR LOWER(oLastNode.class) <> "collection"
               oArray = CREATEOBJECT("Collection")
               oArray.Add(oLastNode)
               STORE oArray TO ("oTarget." + cNodeName)
               oLastNode = GETPEM(oTarget, cNodeName)
              ENDIF
              oLastNode.Add(THIS.parseXml(oNode, pcArrayNodes))
         	          
	     OTHERWISE
	          ADDPROPERTY(oTarget, cNodeName, THIS.parseXml(oNode, pcArrayNodes))
	          oLastNode = GETPEM(oTarget, cNodeName)
	          cLastNode = cNodeName
	  ENDCASE
	 ENDFOR
	 
	 RETURN oTarget
	ENDPROC


    * parseArray
    * Toma un array y devuelve un objeto tipo JSON
    *
    PROCEDURE parseArray(paList)
     THIS.lastError.Clear()
     EXTERNAL ARRAY paList
     LOCAL oTarget,i,nRows,nCols,j,oItem
     nRows = ALEN(paList,1)
     nCols = ALEN(paList,2)
     oTarget = CREATE("Collection")
     FOR i = 1 TO nRows
      IF nCols <= 1
       oTarget.Add(paList[i])
      ELSE
       oItem = CREATEOBJECT("Collection")
       FOR j = 1 TO nCols
        oITem.Add(paList[i,j])
       ENDFOR
       oTarget.Add(oItem)
      ENDIF
     ENDFOR
     RETURN oTarget
    ENDPROC



    * Stringify (Method)
    * Takes an object or alias and returns a JSON string representation
    *
    * Usage: jsonString = oJSON.Stringify(object)
    *        jsonString = oJSON.Stringify("alias" [,plWithSchema] [,pnDataSessionID] [,pcAdditionalFields])
    *        jsonString = oJSON.Stringify(@array)
    *
	PROCEDURE Stringify(puObjectOrAlias, plWithSchema, pnDSID, pcAdditionalFields, plValueMode)
	 *
	 LOCAL cJSON,cType,oRow,nWkArea,nRow,nCount,i,j,cProp,uValue,cValue,cValueType,nColumns,cTokenSep,nStarted
	 LOCAL ARRAY aProps[1]
	 cJSON = ""
	 nWkArea = SELECT()
	 cType = VARTYPE(puObjectOrAlias)
	 nStarted = SECONDS()
	 THIS.lastError.Clear()
 	 IF !EMPTY(pnDSID)
 	  SET DATASESSION TO (pnDSID)
 	 ENDIF	 
	 
	 * Check if value passed is an array. An array is:
	 * a) An object with a baseClass equal to "Collection" and a Count property [1]
	 * b) An array
	 *
	 * [1] The Count property verification is required to avoid an error when stringifing SCX files as cursors, because SCX
	 *     doesn contains a BASECLASS column and could contains Collection objets, wich would be wrongly tested as "array".
     LOCAL lIsArray
	 lIsArray = ((cType = "O" AND PEMSTATUS(puObjectOrAlias,"baseClass",5) AND ;
	                              PEMSTATUS(puObjectOrAlias, "Count", 5) AND ;
	                              PEMSTATUS(puObjectOrAlias, "Item", 5) AND ;
	                              LOWER(puObjectOrAlias.baseClass) == "collection") OR ;
	             (TYPE("ALEN(puObjectOrAlias)") = "N"))
	 
	 
	 * Checkl if value passed is a JS object
	 LOCAL lIsJSObject
	 lIsJSObject = .F.
	 IF cType = "O"
	 	lIsJSObject = (AMEMBERS(aProps, puObjectOrAlias, 1) = 0)
	 ENDIF
	 
	 
	 DO CASE
	    CASE cType = "O" AND lIsJSObject   && JSObject
	         LOCAL oJS
	         oJS = THIS._getFastParser(.T.)
	         oJS.addObject("obj",puObjectOrAlias)
	         RETURN oJS.Eval([(JSON.stringify(obj))])
	    
	    
	    CASE cType = "O" AND !lIsArray  && Object
	     	 nCount = AMEMBERS(aProps,puObjectOrAlias,1)
	     	 #IF VERSION(5) < 800
	     	  LOCAL lEmptyObject,oLine
	     	  lEmptyObject = (TYPE("puObjectOrAlias.Class")="C" AND LOWER(puObjectOrAlias.Class) == "emptyobject")
	     	  IF lEmptyObject
 	     	   oLine = CREATE("Line")
 	     	  ENDIF
	     	 #ENDIF
	     	 FOR i = 1 TO nCount
	          IF aProps[i,2] <> "Property"
	           LOOP
	          ENDIF
		      cProp = LOWER(aProps[i,1])
		      IF "-"+LOWER(cProp)+"-" $ VFP_NOENCODABLE_PROPS
		       LOOP
		      ENDIF

		      #IF VERSION(5) < 800
		       IF lEmptyObject AND PEMSTATUS(oLine, cProp, 5)
		        LOOP
		       ENDIF
		      #ENDIF
		      uValue = GETPEM(puObjectOrAlias, cProp)
		      cValue = THIS.Stringify(uValue,,,,.T.)
		      IF !ISNULL(cValue)
		       IF THIS.useStrictNotation
		        cProp = ["] + cProp + ["]
		       ENDIF
	 	       cJSON = cJSON + IIF(EMPTY(cJSON),"",", ") + cProp + [ : ] + cValue
	 	      ENDIF
	         ENDFOR
	         cJSON = "{" + cJSON + "}"
	    

	    CASE cType = "O" AND lIsArray     && Array (Collection)
	         cJSON = "["
	         FOR i = 1 TO puObjectOrAlias.Count
	          cJSON = cJSON + IIF(i > 1,",","") + THIS.Stringify(puObjectOrAlias.Item[i],,,,.T.)
	         ENDFOR
	         cJSON = cJSON + "]"
	    
	    
	    CASE cType<>"O" AND lIsArray     && Array 
	         EXTERNAL ARRAY puObjectOrAlias
	         nColumns = MAX(ALEN(puObjectOrAlias, 2), 1)   && Because a one dimension array returns 0 for ALEN(2)
	         cJSON = "["
	         FOR i = 1 TO ALEN(puObjectOrAlias,1)
              cJSON = cJSON + IIF(i > 1,",","")	         
	          IF nColumns = 1
 	           cJSON = cJSON + THIS.Stringify(puObjectOrAlias[i],,,,.T.)
 	          ELSE
 	           cJSON = cJSON + "["
 	           FOR j = 1 TO nColumns
  	            cJSON = cJSON + IIF(j > 1,",","") + THIS.Stringify(puObjectOrAlias[i,j], .T.)
 	           ENDFOR
 	           cJSON = cJSON + "]"
 	          ENDIF
	         ENDFOR
	         cJSON = cJSON + "]"
	    
	    
	    CASE cType = "C" AND USED(puObjectOrAlias) AND !plValueMode  && Cursor	        
	         cJSON = [{"name" : "] + puObjectOrAlias + [", "rows" : ] + "["         
	         *cJSON = [{"name" = "] + puObjectOrAlias + [", "rows" = ] + "["
	         IF !EMPTY(pnDSID) 
	          SET DATASESSION TO (pnDSID)
	         ENDIF
	        
	         SELECT (puObjectOrAlias)
	         GO TOP
	         nRow = 0
	         SCAN
	          nRow = nRow + 1
	          SCATTER NAME oRow MEMO
	          cJSON = cJSON + IIF(nRow > 1,",","") + THIS.Stringify(oRow)
	         ENDSCAN
	         cJSON = cJSON + "]"
	         
	         IF plWithSchema
	          LOCAL oSchema
	          oSchema = CREATEOBJECT("jsonSchema")
	          oSchema.initWithAlias(puObjectOrAlias)
	          cProp = "schema"
	          IF THIS.useStrictNotation
		        cProp = ["] + cProp + ["]
		      ENDIF
 	          cJSON = cJSON + [, ] + cProp + [ : ] + oSchema.toString(.T.)	          
	         ENDIF
	         
	         IF !EMPTY(pcAdditionalFields)
	          cJSON = cJSON + [, ] + pcAdditionalFields
	         ENDIF
	         
	         cJSON = cJSON + [}]

	         
	         
	    OTHERWISE      && Scalar value
 	          uValue = puObjectOrAlias
		      cValueType = VARTYPE(uValue)
		      DO CASE
		         CASE cValueType $ "CM"
		              cValue = ["] + THIS.escapeHTML(RTRIM(uValue)) + ["]
		              
		         CASE cValueType $ "NIYF"
		              IF INT(uValue) = uValue
		               cValue = ALLTRIM(STR(uValue))
		              ELSE
		               cValue = ALLTRIM(STR(uValue,30,10))
		               DO WHILE RAT("0", cValue) = LEN(cValue)
		                cValue = SUBSTR(cValue, 1, LEN(cValue) - 1)
		               ENDDO
		              ENDIF
		              cValue = CHRTRAN(cValue, SET("POINT"), ".")
		              
		              
		         CASE cValueType = "D"
		              cValue = ["] + PADL(YEAR(uValue),4,"0") + "-" + PADL(MONTH(uValue),2,"0") + "-" + PADL(DAY(uValue),2,"0") + ["]
		         
		         CASE cValueType = "T"
		              cValue = ["] + PADL(YEAR(uValue),4,"0") + "-" + PADL(MONTH(uValue),2,"0") + "-" + PADL(DAY(uValue),2,"0") + ;
		                       [T] + PADL(HOUR(uValue),2,"0") + ":" + PADL(MINUTE(uValue),2,"0") + ":" + PADL(SEC(uValue),2,"0") + ["]
		         
		         CASE cValueType = "L"
		              cValue = IIF(uValue,"true","false")     
		           
		         CASE cValueType = "X"
		              cValue = "null"
		                   
		         OTHERWISE
		              cValue = NULL
		      ENDCASE
		      cJSON = cValue
	 ENDCASE
	 THIS.lastOpTime = SECONDS() - nStarted + IIF(SECONDS() < nStarted, 86400, 0)
	 
	 SELECT (nWkArea)
	 RETURN cJSON
	 *
	ENDPROC


    * Beautify (Method)
    * Takes a JSON object or string and returns a formatted
    * string representation 
    *
	PROCEDURE Beautify(puData, pcOut, pnMargin, pcAttr)
	 *
	 LOCAL nStarted
	 nStarted = SECONDS()
	 THIS.lastError.Clear()
	 
	 IF VARTYPE(puData)="C" AND LEFT(puData,1) $ "{[" AND PCOUNT() = 1
	  puData = THIS.Parse(puData)
	 ENDIF
	 
	 IF EMPTY(pcOut)
	  pcOut = ""
	 ENDIF
	 IF EMPTY(pnMargin)
	  pnMArgin = LEN(MLINE(pcOut, MEMLINES(pcOUt)))
	 ENDIF
	 
	 LOCAL cType
	 cType = VARTYPE(puData)

     pcOut = pcOut + SPACE(pnMargin)	 
	 IF !EMPTY(pcAttr)
	  IF THIS.useStrictNotation
 	   pcOut = pcOut + ["] + LOWER(pcAttr) + [" : ]
	  ELSE
	   pcOut = pcOut + LOWER(pcAttr) + ": "
	  ENDIF
	  pnMargin = pnMargin + LEN(pcAttr) + 1
	 ENDIF
	
	 
	 DO CASE
	    CASE cType = "C"    && String value
	         pcOut = pcOut + ["] + THIS.escapeHTML(ALLTRIM(puData)) + ["]

	    CASE cType = "N" AND puData = INT(puData)  && Int value
	         pcOut = pcOut + ALLTRIM(STR(puData))
	         
	    CASE cType = "N" AND puData <> INT(puData)  && Decimal value
	         pcOut = pcOut + ALLTRIM(STR(puData,20,SET("DECIMALS"))) 
	         
	    CASE cType = "L"     && Boolean value
	         pcOut = pcOut + IIF(puData,"true","false")
	         
	    CASE cType = "D"     && Date value
		     pcOut = pcOut + ["] + PADL(YEAR(puData),4,"0") + "-" + PADL(MONTH(puData),2,"0") + "-" + PADL(DAY(puData),2,"0") + ["]
	    
        CASE cType = "T"     && Datetime value
             pcOut = pcOut + ;
                       ["] + PADL(YEAR(puData),4,"0") + "-" + PADL(MONTH(puData),2,"0") + "-" + PADL(DAY(puData),2,"0") + ;
                       [T] + PADL(HOUR(puData),2,"0") + ":" + PADL(MINUTE(puData),2,"0") + ":" + PADL(SEC(puData),2,"0") + ["]

		CASE cType = "X"	&& NULL value
		     pcOut = pcOut + "null"
		     
		CASE cType = "O" AND TYPE("puData.Class")="C" AND LOWER(puData.class) = "collection"   && Array
		     LOCAL i,e
		     pcOut = pcOut + "["
		     FOR i = 1 TO puData.Count
		      e = puData.Item[i]
		      IF VARTYPE(e) = "O" 
		       pcOut = pcOut + CRLF + THIS.Beautify(e, "", pnMargin + VFP_JSON_BEAUTIFY_MARGIN + 1)
		      ELSE
		       pcOut = pcOut + IIF(i>1," ","") + THIS.Beautify(e, "", 0)
		      ENDIF
		      pcOut = pcOut + IIF(i < puData.Count,[,],"") 	
		     ENDFOR
		     pcOut = pcOut + IIF(VARTYPE(e)="O",CRLF + SPACE(pnMargin),"") + "]" 

		CASE cType = "O" AND TYPE("puData.Class")="C" AND PEMSTATUS(puData,"count",5) AND PEMSTATUS(puData,"Items",5)   && Array
		     LOCAL i,e
		     pcOut = pcOut + "["
		     FOR i = 1 TO puData.Count
		      e = puData.Items[i]
		      IF VARTYPE(e) = "O" 
		       pcOut = pcOut + CRLF + THIS.Beautify(e, "", pnMargin + VFP_JSON_BEAUTIFY_MARGIN + 1)
		      ELSE
		       pcOut = pcOut + IIF(i>1," ","") + THIS.Beautify(e, "", 0)
		      ENDIF
		      pcOut = pcOut + IIF(i < puData.Count,[,],"") 	
		     ENDFOR
		     pcOut = pcOut + IIF(VARTYPE(e)="O",CRLF + SPACE(pnMargin),"") + "]" 
		     		     
		CASE cType = "O"   && Object
		     pcOut = pcOut + "{" + CRLF
		     LOCAL ARRAY aElems[1]
		     LOCAL i,nCount,e,uValue
		     nCount = AMEMBERS(aElems, puData, 1)
		     
	     	 #IF VERSION(5) < 800
	     	  LOCAL lEmptyObject,oLine
	     	  lEmptyObject = (PEMSTATUS(puData,"class",5) AND LOWER(puData.Class) == "emptyobject")
	     	  IF lEmptyObject
 	     	   oLine = CREATE("Line")
 	     	  ENDIF
	     	 #ENDIF
		     
		     
		     LOCAL oProps
		     oProps = CREATEOBJECT("Collection")		     
		     FOR i = 1 TO nCount
			  e = aElems[i,1]  		     
	          IF aElems[i,2] <> "Property"
	           LOOP
	          ENDIF		      
		      IF "-"+LOWER(e)+"-" $ VFP_NOENCODABLE_PROPS
		       LOOP
		      ENDIF
		      #IF VERSION(5) < 800
		       IF lEmptyObject AND PEMSTATUS(oLine, e, 5)
		        LOOP
		       ENDIF
		      #ENDIF	          	          	
		      oProps.Add(e)	      
		     ENDFOR
		     FOR i = 1 TO oProps.Count
		      e = oProps.Item[i]
		      uValue = GETPEM(puData, e)
		      pcOut = THIS.Beautify(uValue, pcOut , pnMargin + VFP_JSON_BEAUTIFY_MARGIN + 1, e) + IIF(i < nCount, ",", "") + CRLF		     
		     ENDFOR
		     pcOut = pcOut + SPACE(pnMargin) + "}"
	 ENDCASE
     THIS.lastOpTime = SECONDS() - nStarted + IIF(SECONDS() < nStarted, 86400, 0)
     
     RETURN pcOut	 
	 *
	ENDPROC
	
	
	
	
	* toCursor (Method)
	* Takes an JSON object array and try to create
	* a cursor with it.
	*
	PROCEDURE toCursor(poJSON, pcAlias, pnDSID, poOptions)
	 *
	 LOCAL nStarted
	 nStarted = SECONDS()
	 THIS.lastError.Clear()
	 
	 * If received a JSON string, parse it first
	 IF VARTYPE(poJSON) = "C"
	  poJSON = THIS.Parse(poJSON)
	  IF THIS.lastError.hasError
 	   THIS.lastOpTime = SECONDS() - nStarted + IIF(SECONDS() < nStarted, 86400, 0)
	   RETURN .F.
	  ENDIF
	 ENDIF
	 
	 * Verify that the object is a collection. If not, convert it to one
	 IF !PEMSTATUS(poJSON, "class", 5) OR LOWER(poJSON.class) <> "collection" OR poJSON.Count = 0 OR VARTYPE(poJSON.Item[1])<>"O"
	  LOCAL oArray
	  oArray = CREATEOBJECT("Collection")
	  oArray.Add(poJSON)
	  poJSON = oArray
	 ENDIF
	 
	 * Change the datasession (if needed)
	 IF !EMPTY(pnDSID)
	  SET DATASESSION TO (pnDSID)
	 ENDIF
	 
	 * Determine the cursor structure by analizing the first element. We also
	 * create an instance of the element's baseclass, to rule out inhereted
	 * properties.
	 LOCAL oRow,nCount,i,cProp,uValue,oSchema,oColumn,oObjProps,oBase
	 LOCAL ARRAY aProps[1]
	 oRow = poJSON.Item[1]
	 IF TYPE("oRow.baseClass") = "C"
	 	oBase = CREATE(oRow.baseClass)
	 ELSE
	 	oBase = NULL
	 ENDIF
	 oSchema = CREATEOBJECT("jsonSchema")
	 oObjProps = CREATEOBJECT("Collection")
	 nCount = AMEMBERS(aProps, oRow)
	 FOR i = 1 TO nCount
	  cProp = LOWER(aProps[i])
	  IF (!ISNULL(oBase) AND TYPE("oBase." + cProp)<>"U") ;
	  OR INLIST(UPPER(cProp),"PARENT")
	  	LOOP
	  ENDIF
	  uValue = GETPEM(oRow, cProp)
	  oColumn = CREATEOBJECT("jsonColumn")
	  oColumn.initWithValue(uValue, cProp)
	  oSchema.addColumn(oColumn)
	  IF oColumn.Type = "M"
	   oObjProps.Add(cProp)
	  ENDIF
	  IF VARTYPE(uValue) = "O" AND TYPE("poOptions." + cProp + ".parentId") = "C"
	   
	  ENDIF
	 ENDFOR
	 
	 
	 oSchema.toCursor(pcalias, SET("DATASESSION"))
	 IF THIS.lastError.hasError
 	  THIS.lastOpTime = SECONDS() - nStarted + IIF(SECONDS() < nStarted, 86400, 0)
	  RETURN .F.
	 ENDIF
	
	 * Convert JSON array to rows	 
	 SELECT (pcAlias)
	 LOCAL j,cProp,uValue,cType
	 FOR i = 1 TO poJSON.Count
	  oRow = poJSON.Item[i]
	  SELECT (pcAlias)
	  APPEND BLANK
	  GATHER NAME oRow
	  FOR j = 1 TO oObjProps.Count
	   IF INLIST(UPPER(cProp),"PARENT")
	      LOOP
	   ENDIF
	   cProp = oObjProps.Item[j]
	   uValue = GETPEM(oRow, cProp)
	   cType = VARTYPE(uValue)
	   IF cType = "O"
	    uValue = THIS.stringify(uValue)
	   ENDIF
	   REPLACE (cProp) WITH uValue
	  ENDFOR
	 ENDFOR
	 GO TOP
	 THIS.lastOpTime = SECONDS() - nStarted + IIF(SECONDS() < nStarted, 86400, 0)
	  
	 RETURN !THIS.lastError.hasError
	 *
	ENDPROC



    * ToXml (Method)
    * Takes a JSON object or string and returns a Xml representation
    *
    * poOptions:
    * {
    *   style: 0-Values as nodes,  1-Values as attributes
    *  ,case: 0-Lower, 1-upper
    *  ,beautify: true, false
    *  ,margin: 0
    *  ,header: true
    * }
    *
	PROCEDURE ToXml(puData, pcParentNode, poOptions, plRecursive)
	 *
	 LOCAL nStarted
	 nStarted = SECONDS()
	 THIS.lastError.Clear()
	 	
	 IF VARTYPE(puData)="C" AND LEFT(puData,1) $ "{[" AND PCOUNT() = 1
	  puData = THIS.Parse(puData)
	 ENDIF

     IF VARTYPE(poOptions) = "C" AND LEFT(poOptions,1) = "{"
      poOptions = THIS.Parse(poOptions)
     ENDIF
     
	 IF VARTYPE(poOptions) <> "O"
	   poOptions = THIS.Parse("{ style: 0, case: 0, beautify: false, header: true }")
	 ENDIF
	 
	 LOCAL nStyle, nCase, lBeautify, nMargin, lHeader, cMargin, cSubMargin, cCRLF 
	 nStyle = IIF(TYPE("poOptions.style") = "N", poOptions.style, 0)
	 nCase = IIF(TYPE("poOptions.case") = "N", poOptions.case, 0)
	 lBeautify = IIF(TYPE("poOptions.beautify") = "L", poOptions.beautify, .F.)
	 nMArgin = IIF(TYPE("poOptions.margin") = "N", poOptions.margin, 0)
	 lHeader = IIF(TYPE("poOptions.header") = "L", poOptions.header, .T.)
     cMargin = IIF(lbeautify, SPACE(nMargin), "")
     cSubMargin = IIF(lbeautify, SPACE(nMargin + 2), "")
     cCRLF = IIF(lbeautify,CHR(13)+CHR(10),"")	 

	 LOCAL cXml,lIsArray
	 lIsArray = (VARTYPE(puData) = "O" AND TYPE("puData.Class")="C" AND LOWER(puData.class) == "collection")
	 
	 	 
	 IF lIsArray
	  LOCAL i
	  cXml = cMargin + "<" + pcParentNode + ">" + cCRLF
	  FOR i = 1 TO puData.Count
	   cXml = cXml + cSubMargin + THIS.ToXml(puData.Item[i], "item", poOptions, .T.) + cCRLF
	  ENDFOR
	  cXml = cXml + cMargin + "</" + pcParentNode + ">" + cCRLF
	  RETURN cXml
	 ENDIF
	 
     LOCAL ARRAY aElems[1]
     LOCAL i,nCount,e,uValue,oChildren,oChild,cType
     nCount = AMEMBERS(aElems, puData)
     oChildren = CREATEOBJECT("Collection")
     pcParentNode = IIF(ncase = 0, LOWER(pcParentNode), ;
                    IIF(ncase = 1, UPPER(pcParentNode), pcParentNode))
     cXml = cMargin + "<" + pcParentNode + IIF(nStyle = 0,">" + cCRLF,"")
     FOR i = 1 TO nCount
      *IF aElems[i,2] <> "Property"
      * LOOP
      *ENDIF		      
      e = aElems[i] 
      IF "-"+LOWER(e)+"-" $ VFP_NOENCODABLE_PROPS
       LOOP
      ENDIF
      uValue = GETPEM(puData, e)
      cType = VARTYPE(uValue)
      
      DO CASE
	    CASE cType = "C"    && String value
	         uValue = THIS.escapeHTML(ALLTRIM(uValue))

	    CASE cType = "N" AND uValue = INT(uValue)  && Int value
	         uValue = ALLTRIM(STR(uValue))
	         
	    CASE cType = "N" AND uValue <> INT(uValue)  && Decimal value
	         uvalue = ALLTRIM(STR(uValue,20,SET("DECIMALS"))) 
	         
	    CASE cType = "L"     && Boolean value
	         uValue = IIF(uValue,"true","false")
	         
	    CASE cType = "D"     && Date value
		     uValue = PADL(YEAR(uValue),4,"0") + "-" + PADL(MONTH(uValue),2,"0") + "-" + PADL(DAY(uValue),2,"0") 
	    
        CASE cType = "T"     && Datetime value
             uValue = PADL(YEAR(uValue),4,"0") + "-" + PADL(MONTH(uValue),2,"0") + "-" + PADL(DAY(uValue),2,"0") + ;
                       [T] + PADL(HOUR(uValue),2,"0") + ":" + PADL(MINUTE(uValue),2,"0") + ":" + PADL(SEC(uValue),2,"0")

		CASE cType = "X"	&& NULL value
		     uValue = ""

        CASE cType = "O"   && Child
             oChild = CREATEOBJECT(_EMPTY)
             ADDPROPERTY(oChild, "Node", e)
             ADDPROPERTY(oChild, "Value", uValue)
             oChildren.Add(oChild)
             LOOP
      ENDCASE

      e = IIF(ncase = 0, LOWER(e),;
          IIF(ncase = 1, UPPER(e), e))
	  DO CASE
	     CASE nStyle = 0
	          cXml = cXml + cSubMargin + "<" + e + ">" + uValue + "</" + e + ">" + cCRLF
	          
	     CASE nStyle = 1
	          cXml = cXml + " " + e + "=" + uValue 

	  ENDCASE
     ENDFOR
     
     IF nstyle = 1
      cXml = cXml + IIF(oChildent.Count > 0,">","/>") + cCRLF
     ENDIF

     IF oChildren.Count > 0
      IF TYPE("poOptions.margin") <> "N"
       ADDPROPERTY(poOptions, "margin", nMargin)
      ENDIF
      poOptions.margin = nmargin + 2     
     ENDIF     
     FOR i = 1 TO oChildren.Count
      oChild = oChildren.Item[i]
      cXml = cXml + THIS.toXml(oChild.Value, oChild.Node, poOptions, .T.)
     ENDFOR     
     IF oChildren.Count > 0 OR nStyle = 0 
      cXml = cXml + cMArgin + "</" + pcParentNode + ">" + cCRLF
     ENDIF
     
     IF !plRecursive
      IF lHeader
       cXml = [<?xml version="1.0" encoding="UTF-8"?>] + cCRLF + cXml
      ENDIF
     ENDIF
     
     THIS.lastOpTime = SECONDS() - nStarted + IIF(SECONDS() < nStarted, 86400, 0)
     
     RETURN cXML
	 *
	ENDPROC
	
	

	* httpRequest (Method)
	* Sends a HTTP request webservice that will answer with a JSON string.
	*
	* puData can be a json string or an object
	* pcHeaders can be a string with a one or more header lines separated by CRLF
	*
	PROCEDURE httpRequest(pcVerb, pcUrl, puData, pcHeaders, pnTimeout)
		LOCAL oResult,lUSN
		oResult = CREATEOBJECT(_EMPTY)
		ADDPROPERTY(oResult, "headers")
		ADDPROPERTY(oResult, "contentType", "")
		ADDPROPERTY(oResult, "statusCode", 0)
		ADDPROPERTY(oResult, "raw", "")
		ADDPROPERTY(oResult, "json", NULL)
		ADDPROPERTY(oResult, "hasError", .T.)
		ADDPROPERTY(oResult, "errorMsg", "")
		lUSN = THIS.useStrictNotation
		THIS.useStrictNotation = .T.
		THIS.lastError.Clear() 
		DO CASE
		   CASE VARTYPE(puData) = "O"
		        puData = THIS.stringify(puData)
		        
		   CASE VARTYPE(puData) <> "C"
		        puData = ""
		ENDCASE
		pnTimeout = IIF(VARTYPE(pnTimeOut)<>"N",15,pnTimeout)
	 	
		LOCAL ex,oHTTP
		ex = NULL
		oHTTP = NULL
	    _TRY	    
	       DO CASE
	          CASE THIS.httpClient = 0
	               oHTTP = CREATEOBJECT("Msxml2.ServerXMLHTTP.6.0")
	          
	          CASE THIS.httpClient = 1
	               oHTTP = CREATEOBJECT("MSXML2.XMLHTTP.6.0")

	          CASE THIS.httpClient = 2
	               oHTTP = CREATEOBJECT("MSXML2.XMLHTTP")

	          OTHERWISE
	               THIS.httpClient = 0
	               oHTTP = CREATEOBJECT("Msxml2.ServerXMLHTTP.6.0")
	       ENDCASE
	       
	    _CATCH
	       THIS.lastError.initWithEx(ex)
	    _ENDTRY
	    IF THIS.lastError.hasError
	      oResult.ErrorMsg = THIS.lastError.Message
	      THIS.useStrictNotation = lUSN
	      RETURN oResult
	    ENDIF

		LOCAL cResponse
		cResponse = ""
		_TRY
		    IF THIS.httpClient = 0 
		    	oHTTP.setOption(2) = 13056    && IGNORE CERTIFICATE ERRORS
		    ENDIF
		    oHTTP.open(pcVerb, pcUrl, .F.)
		    IF EMPTY(pcHeaders)
		       pcHeaders = ""
		    ENDIF
		    IF NOEX() AND INLIST(UPPER(pcVerb),"POST","PUT") AND !EMPTY(puData)
		        IF ATC("Content-Type",pcHeaders) = 0 
		    	   oHTTP.setRequestHeader("Content-Type", "application/json")
		    	ENDIF
		    	IF ATC("Content-Length",pcHeaders) = 0
		    		oHTTP.setRequestHeader("Content-Length", LEN(puData))
		    	ENDIF
		    ENDIF
		    IF NOEX() AND !EMPTY(pcHeaders)
		    	LOCAL ARRAY aHeaders[1]
		    	LOCAL nHeadersCount,nHeader,cHeader,cHeaderName,cHeaderValue,nHeaderSep
		    	nHeadersCount = ALINES(aHeaders, pcHeaders)
		    	FOR nHeader = 1 TO nHeadersCount
		    		cHeader = aHeaders[nHeader]
		    		nHeaderSep = AT(":",cHeader)
		    		IF nHeaderSep > 0
		    			cHeaderName = LEFT(cHeader, nHeaderSep - 1)
		    			cHeaderValue = ALLTRIM(SUBSTR(cHeader, nHeaderSep + 1))
		    			oHTTP.setRequestHeader(cHeaderName, cHeaderValue)
		    			IF !NOEX()
		    				EXIT
		    			ENDIF
		    		ENDIF
		    	ENDFOR
		    ENDIF
		    IF NOEX()
		    	IF !EMPTY(puData)
		    		oHTTP.Send(puData)
		    	ELSE
		    		oHTTP.Send()
		    	ENDIF
		    ENDIF
		    IF NOEX()
				LOCAL nTimeOut
				nTimeout = SECONDS()
				DO WHILE oHTTP.readyState<>4 AND (SECONDS() - nTimeout) < pnTimeout
				  DOEVENTS
				ENDDO
				IF oHTTP.readyState = 4 
					oResult.statusCode = oHTTP.status
					oResult.Headers = oHTTP.getAllResponseHeaders()
					oResult.contentType = oHTTP.getResponseHeader("Content-Type")
					DO CASE
					   CASE ATC("json",oResult.contentType) > 0
					        cResponse = oHTTP.responseText()
					        
					   CASE ATC("xml",oResult.contentType) > 0
					        cResponse = oHTTP.responseText()					        
					        
					   OTHERWISE
					        cResponse = oHTTP.responseBody()
					ENDCASE
				ELSE
					THIS.lastError.initWithString("No se pudo obtener respuesta del webservice")
				ENDIF		    		     	
		    ENDIF
		    
		_CATCH
		   	THIS.lastError.initWithEx(ex)
		_ENDTRY
	    IF THIS.lastError.hasError
	      oResult.ErrorMsg = THIS.lastError.Message
	      THIS.useStrictNotation = lUSN
	      RETURN oResult
	    ENDIF

		oResult.raw = cResponse
		IF !EMPTY(cResponse)
			DO CASE
			   CASE ATC("xml", oResult.contentType) > 0
			        oResult.json = THIS.parseXml(cResponse)
			        
			   CASE ATC("json", oResult.contentType) > 0
			   		oResult.json = THIS.parse(cResponse)		   
			ENDCASE
		ENDIF
		oResult.hasError = THIS.lastError.hasError
		IF oResult.hasError
			oResult.ErrorMsg = THIS.lastError.Message
		ENDIF
		THIS.useStrictNotation = lUSN
		RETURN oResult	




	* httpGet (Method)
	* Retrieves a JSON  or XML response from a given HTTP GET request
	*
	* httpGet(url, "json|xml", headers, timeout)
	* httpGet(url, headers, timeout)
	*
	PROCEDURE httpGet(pcUrl, pcContentType, pcHeaders, pnTimeout)
		IF PCOUNT() = 1
			pcContentType = "json"
		ENDIF
		IF !INLIST(LOWER(pcContentType),"json","xml")
			IF VARTYPE(pcHeaders) = "N"
				pnTimeout = pcHeaders
			ENDIF
			pcHeaders = pcContentType
			pcContentType = "json"
		ENDIF
		LOCAL oResp
		oResp = THIS.httpRequest("GET", pcUrl, "", pcHeaders, pnTimeout) 
		IF EMPTY(oResp.contentType) AND pcContentType == "xml"
	 		oResp.json = THIS.parseXml(cResponse)
			oResp.hasError = THIS.lastError.hasError
	 	ENDIF
		RETURN oResp



	* httpPost (Method)
	* Sends a POST request with optional JSON data to a
	* webservice that will answer with a JSON string.
	*
	* puData can be a json string or an object
	* pcHeaders can be a string with a one or more header lines separated by CRLF
	*
	PROCEDURE httpPost(pcUrl, puData, pcHeaders, pnTimeout)
		LOCAL oResp
		oResp = THIS.httpRequest("POST", pcUrl, puData, pcHeaders, pnTimeout) 
		RETURN oResp
		
	
	* isAlpha (Method)
	* Check if the given char is alphabetic
	*
	PROCEDURE isAlpha(pcChar)
	 RETURN UPPER(pcChar) $ "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ_"
	ENDPROC
	
	
    * escapeHTML (Method)
    * Takes a normal string and "escape" any special non-html character
    *
	PROCEDURE escapeHTML(pcValue, plUrlMode)	  
	  IF LEN(pcValue) > 1
	   LOCAL cEncoded,i,cChar
	   cEncoded = ""
	   FOR i = 1 TO LEN(pcValue)
	    cChar = SUBST(pcValue, i, 1)
	    cEncoded = cEncoded + THIS.escapeHTML(cChar)
	   ENDFOR
	   RETURN cEncoded
	  ENDIF
	  DO CASE
	     CASE pcValue = CHR(32) AND plUrlMode
	          pcValue = "&nbsp;"
	     CASE pcValue = CHR(34)
	          pcValue = [\"]
	     CASE pcValue = CHR(38)
	          pcValue = "&amp;"
	     CASE pcValue = CHR(60)
	          pcValue = "&lt;"
	     CASE pcValue = CHR(62)
	          pcValue = "&gt;"
	     CASE pcValue = CHR(92)
	          pcValue = "\\"
	     CASE pcValue = CHR(160)
	          pcValue = "&nbsp;"
	     CASE pcValue = CHR(161)
	          pcValue = "&iexcl;"
	     CASE pcValue = CHR(162)
	          pcValue = "&cent;"
	     CASE pcValue = CHR(163)
	          pcValue = "&pound;"
	     CASE pcValue = CHR(164)
	          pcValue = "&curren;"
	     CASE pcValue = CHR(165)
	          pcValue = "&yen;"
	     CASE pcValue = CHR(166)
	          pcValue = "&brvbar;"
	     CASE pcValue = CHR(167)
	          pcValue = "&sect;"
	     CASE pcValue = CHR(168)
	          pcValue = "&uml;"
	     CASE pcValue = CHR(169)
	          pcValue = "&copy;"
	     CASE pcValue = CHR(170)
	          pcValue = "&ordf;"
	     CASE pcValue = CHR(172)
	          pcValue = "&not;"
	     CASE pcValue = CHR(174)
	          pcValue = "&reg;"
	     CASE pcValue = CHR(175)
	          pcValue = "&macr;"
	     CASE pcValue = CHR(176)
	          pcValue = "&deg;"
	     CASE pcValue = CHR(177)
	          pcValue = "&plusmn;"
	     CASE pcValue = CHR(178)
	          pcValue = "&sup2;"
	     CASE pcValue = CHR(179)
	          pcValue = "&sup3;"
	     CASE pcValue = CHR(180)
	          pcValue = "&acute;"
	     CASE pcValue = CHR(181)
	          pcValue = "&micro;"
	     CASE pcValue = CHR(182)
	          pcValue = "&para;"
	     CASE pcValue = CHR(183)
	          pcValue = "&middot;"
	     CASE pcValue = CHR(184)
	          pcValue = "&cedil;"
	     CASE pcValue = CHR(185)
	          pcValue = "&sup1;"
	     CASE pcValue = CHR(186)
	          pcValue = "&ordm;"
	     CASE pcValue = CHR(187)
	          pcValue = "&raquo;"
	     CASE pcValue = CHR(188)
	          pcValue = "&frac14;"
	     CASE pcValue = CHR(189)
	          pcValue = "&frac12;"
	     CASE pcValue = CHR(190)
	          pcValue = "&frac34;"
	     CASE pcValue = CHR(191)
	          pcValue = "&iquest;"
	     CASE pcValue = CHR(192)
	          pcValue = "&Agrave;"
	     CASE pcValue = CHR(193)
	          pcValue = "&Aacute;"
	     CASE pcValue = CHR(194)
	          pcValue = "&Acirc;"
	     CASE pcValue = CHR(195)
	          pcValue = "&Atilde;"
	     CASE pcValue = CHR(196)
	          pcValue = "&Auml;"
	     CASE pcValue = CHR(197)
	          pcValue = "&Aring;"
	     CASE pcValue = CHR(198)
	          pcValue = "&AElig;"
	     CASE pcValue = CHR(199)
	          pcValue = "&Ccedil;"
	     CASE pcValue = CHR(200)
	          pcValue = "&Egrave;"
	     CASE pcValue = CHR(201)
	          pcValue = "&Eacute;"
	     CASE pcValue = CHR(202)
	          pcValue = "&Ecirc;"
	     CASE pcValue = CHR(203)
	          pcValue = "&Euml;"
	     CASE pcValue = CHR(204)
	          pcValue = "&Igrave;"
	     CASE pcValue = CHR(205)
	          pcValue = "&Iacute;"
	     CASE pcValue = CHR(206)
	          pcValue = "&Icirc;"
	     CASE pcValue = CHR(207)
	          pcValue = "&Iuml;"
	     CASE pcValue = CHR(208)
	          pcValue = "&ETH;"
	     CASE pcValue = CHR(209)
	          pcValue = "&Ntilde;"
	     CASE pcValue = CHR(210)
	          pcValue = "&Ograve;"
	     CASE pcValue = CHR(211)
	          pcValue = "&Oacute;"
	     CASE pcValue = CHR(212)
	          pcValue = "&Ocirc;"
	     CASE pcValue = CHR(213)
	          pcValue = "&Otilde;"
	     CASE pcValue = CHR(214)
	          pcValue = "&Ouml;"
	     CASE pcValue = CHR(215)
	          pcValue = "&times;"
	     CASE pcValue = CHR(216)
	          pcValue = "&Oslash;"
	     CASE pcValue = CHR(217)
	          pcValue = "&Ugrave;"
	     CASE pcValue = CHR(218)
	          pcValue = "&Uacute;"
	     CASE pcValue = CHR(219)
	          pcValue = "&Ucirc;"
	     CASE pcValue = CHR(220)
	          pcValue = "&Uuml;"
	     CASE pcValue = CHR(221)
	          pcValue = "&Yacute;"
	     CASE pcValue = CHR(222)
	          pcValue = "&THORN;"
	     CASE pcValue = CHR(223)
	          pcValue = "&szlig;"
	     CASE pcValue = CHR(224)
	          pcValue = "&agrave;"
	     CASE pcValue = CHR(225)
	          pcValue = "&aacute;"
	     CASE pcValue = CHR(226)
	          pcValue = "&acirc;"
	     CASE pcValue = CHR(227)
	          pcValue = "&atilde;"
	     CASE pcValue = CHR(228)
	          pcValue = "&auml;"
	     CASE pcValue = CHR(229)
	          pcValue = "&aring;"
	     CASE pcValue = CHR(230)
	          pcValue = "&aelig;"
	     CASE pcValue = CHR(231)
	          pcValue = "&ccedil;"
	     CASE pcValue = CHR(232)
	          pcValue = "&egrave;"
	     CASE pcValue = CHR(233)
	          pcValue = "&eacute;"
	     CASE pcValue = CHR(234)
	          pcValue = "&ecirc;"
	     CASE pcValue = CHR(235)
	          pcValue = "&euml;"
	     CASE pcValue = CHR(236)
	          pcValue = "&igrave;"
	     CASE pcValue = CHR(237)
	          pcValue = "&iacute;"
	     CASE pcValue = CHR(238)
	          pcValue = "&icirc;"
	     CASE pcValue = CHR(239)
	          pcValue = "&iuml;"
	     CASE pcValue = CHR(240)
	          pcValue = "&eth;"
	     CASE pcValue = CHR(241)
	          pcValue = "&ntilde;"
	     CASE pcValue = CHR(242)
	          pcValue = "&ograve;"
	     CASE pcValue = CHR(243)
	          pcValue = "&oacute;"
	     CASE pcValue = CHR(244)
	          pcValue = "&ocirc;"
	     CASE pcValue = CHR(245)
	          pcValue = "&otilde;"
	     CASE pcValue = CHR(246)
	          pcValue = "&ouml;"
	     CASE pcValue = CHR(247)
	          pcValue = "&divide;"
	     CASE pcValue = CHR(248)
	          pcValue = "&oslash;"
	     CASE pcValue = CHR(249)
	          pcValue = "&ugrave;"
	     CASE pcValue = CHR(250)
	          pcValue = "&uacute;"
	     CASE pcValue = CHR(251)
	          pcValue = "&ucirc;"
	     CASE pcValue = CHR(252)
	          pcValue = "&uuml;"
	     CASE pcValue = CHR(253)
	          pcValue = "&yacute;"
	     CASE pcValue = CHR(254)
	          pcValue = "&thorn;"
	  ENDCASE
	  RETURN pcValue
	ENDPROC


    * unescapeHTML (Method)
    * Takes an HTML escaped string and returns the original one.
    *
	PROCEDURE unescapeHTML(pcValue)
	  pcValue = STRT(pcValue,"&nbsp;",CHR(32))
	  pcValue = STRT(pcValue,[\\],[\])
	  pcValue = STRT(pcValue,[\"],CHR(34))
	  pcValue = STRT(pcValue,"&amp;",CHR(38))
	  pcValue = STRT(pcValue,"&lt;",CHR(60))
	  pcValue = STRT(pcValue,"&gt;",CHR(62))
	  pcValue = STRT(pcValue,"\",CHR(92))
	  pcValue = STRT(pcValue,"&nbsp;",CHR(160))
	  pcValue = STRT(pcValue,"&iexcl;",CHR(161))
	  pcValue = STRT(pcValue,"&cent;",CHR(162))
	  pcValue = STRT(pcValue,"&pound;",CHR(163))
	  pcValue = STRT(pcValue,"&curren;",CHR(164))
	  pcValue = STRT(pcValue,"&yen;",CHR(165))
	  pcValue = STRT(pcValue,"&brvbar;",CHR(166))
	  pcValue = STRT(pcValue,"&sect;",CHR(167))
	  pcValue = STRT(pcValue,"&uml;",CHR(168))
	  pcValue = STRT(pcValue,"&copy;",CHR(169))
	  pcValue = STRT(pcValue,"&ordf;",CHR(170))
	  pcValue = STRT(pcValue,"&not;",CHR(172))
	  pcValue = STRT(pcValue,"&reg;",CHR(174))
	  pcValue = STRT(pcValue,"&macr;",CHR(175))
	  pcValue = STRT(pcValue,"&deg;",CHR(176))
	  pcValue = STRT(pcValue,"&plusmn;",CHR(177))
	  pcValue = STRT(pcValue,"&sup2;",CHR(178))
	  pcValue = STRT(pcValue,"&sup3;",CHR(179))
	  pcValue = STRT(pcValue,"&acute;",CHR(180))
	  pcValue = STRT(pcValue,"&micro;",CHR(181))
	  pcValue = STRT(pcValue,"&para;",CHR(182))
	  pcValue = STRT(pcValue,"&middot;",CHR(183))
	  pcValue = STRT(pcValue,"&cedil;",CHR(184))
	  pcValue = STRT(pcValue,"&sup1;",CHR(185))
	  pcValue = STRT(pcValue,"&ordm;",CHR(186))
	  pcValue = STRT(pcValue,"&raquo;",CHR(187))
	  pcValue = STRT(pcValue,"&frac14;",CHR(188))
	  pcValue = STRT(pcValue,"&frac12;",CHR(189))
	  pcValue = STRT(pcValue,"&frac34;",CHR(190))
	  pcValue = STRT(pcValue,"&iquest;",CHR(191))
	  pcValue = STRT(pcValue,"&Agrave;",CHR(192))
	  pcValue = STRT(pcValue,"&Aacute;",CHR(193))
	  pcValue = STRT(pcValue,"&Acirc;",CHR(194))
	  pcValue = STRT(pcValue,"&Atilde;",CHR(195))
	  pcValue = STRT(pcValue,"&Auml;",CHR(196))
	  pcValue = STRT(pcValue,"&Aring;",CHR(197))
	  pcValue = STRT(pcValue,"&AElig;",CHR(198))
	  pcValue = STRT(pcValue,"&Ccedil;",CHR(199))
	  pcValue = STRT(pcValue,"&Egrave;",CHR(200))
	  pcValue = STRT(pcValue,"&Eacute;",CHR(201))
	  pcValue = STRT(pcValue,"&Ecirc;",CHR(202))
	  pcValue = STRT(pcValue,"&Euml;",CHR(203))
	  pcValue = STRT(pcValue,"&Igrave;",CHR(204))
	  pcValue = STRT(pcValue,"&Iacute;",CHR(205))
	  pcValue = STRT(pcValue,"&Icirc;",CHR(206))
	  pcValue = STRT(pcValue,"&Iuml;",CHR(207))
	  pcValue = STRT(pcValue,"&ETH;",CHR(208))
	  pcValue = STRT(pcValue,"&Ntilde;",CHR(209))
	  pcValue = STRT(pcValue,"&Ograve;",CHR(210))
	  pcValue = STRT(pcValue,"&Oacute;",CHR(211))
	  pcValue = STRT(pcValue,"&Ocirc;",CHR(212))
	  pcValue = STRT(pcValue,"&Otilde;",CHR(213))
	  pcValue = STRT(pcValue,"&Ouml;",CHR(214))
	  pcValue = STRT(pcValue,"&times;",CHR(215))
	  pcValue = STRT(pcValue,"&Oslash;",CHR(216))
	  pcValue = STRT(pcValue,"&Ugrave;",CHR(217))
	  pcValue = STRT(pcValue,"&Uacute;",CHR(218))
	  pcValue = STRT(pcValue,"&Ucirc;",CHR(219))
	  pcValue = STRT(pcValue,"&Uuml;",CHR(220))
	  pcValue = STRT(pcValue,"&Yacute;",CHR(221))
	  pcValue = STRT(pcValue,"&THORN;",CHR(222))
	  pcValue = STRT(pcValue,"&szlig;",CHR(223))
	  pcValue = STRT(pcValue,"&agrave;",CHR(224))
	  pcValue = STRT(pcValue,"&aacute;",CHR(225))
	  pcValue = STRT(pcValue,"&acirc;",CHR(226))
	  pcValue = STRT(pcValue,"&atilde;",CHR(227))
	  pcValue = STRT(pcValue,"&auml;",CHR(228))
	  pcValue = STRT(pcValue,"&aring;",CHR(229))
	  pcValue = STRT(pcValue,"&aelig;",CHR(230))
	  pcValue = STRT(pcValue,"&ccedil;",CHR(231))
	  pcValue = STRT(pcValue,"&egrave;",CHR(232))
	  pcValue = STRT(pcValue,"&eacute;",CHR(233))
	  pcValue = STRT(pcValue,"&ecirc;",CHR(234))
	  pcValue = STRT(pcValue,"&euml;",CHR(235))
	  pcValue = STRT(pcValue,"&igrave;",CHR(236))
	  pcValue = STRT(pcValue,"&iacute;",CHR(237))
	  pcValue = STRT(pcValue,"&icirc;",CHR(238))
	  pcValue = STRT(pcValue,"&iuml;",CHR(239))
	  pcValue = STRT(pcValue,"&eth;",CHR(240))
	  pcValue = STRT(pcValue,"&ntilde;",CHR(241))
	  pcValue = STRT(pcValue,"&ograve;",CHR(242))
	  pcValue = STRT(pcValue,"&oacute;",CHR(243))
	  pcValue = STRT(pcValue,"&ocirc;",CHR(244))
	  pcValue = STRT(pcValue,"&otilde;",CHR(245))
	  pcValue = STRT(pcValue,"&ouml;",CHR(246))
	  pcValue = STRT(pcValue,"&divide;",CHR(247))
	  pcValue = STRT(pcValue,"&oslash;",CHR(248))
	  pcValue = STRT(pcValue,"&ugrave;",CHR(249))
	  pcValue = STRT(pcValue,"&uacute;",CHR(250))
	  pcValue = STRT(pcValue,"&ucirc;",CHR(251))
	  pcValue = STRT(pcValue,"&uuml;",CHR(252))
	  pcValue = STRT(pcValue,"&yacute;",CHR(253))
	  pcValue = STRT(pcValue,"&thorn;",CHR(254))
	  RETURN pcValue
	ENDPROC


	* getFastParser (Method)
	* RETURNS AN INSTANCE OF THE FAST PARSER
	*
	HIDDEN FUNCTION _getFastParser(plForceNewInstance)
		IF !ISNULL(THIS.oFastParser) AND !plForceNewInstance
			RETURN THIS.oFastParser
		ENDIF
		THIS.oFastParser = CREATEOBJECT("MSScriptControl.ScriptControl")
		WITH THIS.oFastParser
			.Language = "JScript"
			.addCode( THIS._getJSONParserCode() )
			.addCode( THIS._getSupportCode() )
		ENDWITH
		RETURN THIS.oFastParser
		
	
	
	* getJSONParserCode (Method)
	* RETURNS JS CODE TO IMPLEMENT AND ECMA JSON PARSER
	*
	* AUTHOR: DOUGLAS CROCKFORD
	* SOURCE: https://raw.githubusercontent.com/douglascrockford/JSON-js/master/json2.js
	*
	HIDDEN FUNCTION _getJSONParserCode
		LOCAL cJSONParserCode
		#IF VERSION(5) = 600
			LOCAL cPrinter,cTmpFile
			cPrinter = SET("PRINTER")
			cTmpFile = ADDBS(GETENV("TEMP")) + "TM" + SYS(2015) + ".TMP"
			SET PRINTER TO FILE (cTmpFile)
			SET DEVICE TO PRINT
			SET CONSOLE OFF
			SET PRINT ON
		#ENDIF
		TEXT TO cJSONParserCode NOSHOW 
//  json2.js 
//  2022-10-30
//  Public Domain.
//  NO WARRANTY EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.

//  USE YOUR OWN COPY. IT IS EXTREMELY UNWISE TO LOAD CODE FROM SERVERS YOU DO
//  NOT CONTROL.

//  This file creates a global JSON object containing two methods: stringify
//  and parse. This file provides the ES5 JSON capability to ES3 systems.
//  If a project might run on IE8 or earlier, then this file should be included.
//  This file does nothing on ES5 systems.

//      JSON.stringify(value, replacer, space)
//          value       any JavaScript value, usually an object or array.
//          replacer    an optional parameter that determines how object
//                      values are stringified for objects. It can be a
//                      function or an array of strings.
//          space       an optional parameter that specifies the indentation
//                      of nested structures. If it is omitted, the text will
//                      be packed without extra whitespace. If it is a number,
//                      it will specify the number of spaces to indent at each
//                      level. If it is a string (such as "\t" or "&nbsp;"),
//                      it contains the characters used to indent at each level.
//          This method produces a JSON text from a JavaScript value.
//          When an object value is found, if the object contains a toJSON
//          method, its toJSON method will be called and the result will be
//          stringified. A toJSON method does not serialize: it returns the
//          value represented by the name/value pair that should be serialized,
//          or undefined if nothing should be serialized. The toJSON method
//          will be passed the key associated with the value, and this will be
//          bound to the value.

//          For example, this would serialize Dates as ISO strings.

//              Date.prototype.toJSON = function (key) {
//                  function f(n) {
//                      // Format integers to have at least two digits.
//                      return (n < 10)
//                          ? "0" + n
//                          : n;
//                  }
//                  return this.getUTCFullYear()   + "-" +
//                       f(this.getUTCMonth() + 1) + "-" +
//                       f(this.getUTCDate())      + "T" +
//                       f(this.getUTCHours())     + ":" +
//                       f(this.getUTCMinutes())   + ":" +
//                       f(this.getUTCSeconds())   + "Z";
//              };

//          You can provide an optional replacer method. It will be passed the
//          key and value of each member, with this bound to the containing
//          object. The value that is returned from your method will be
//          serialized. If your method returns undefined, then the member will
//          be excluded from the serialization.

//          If the replacer parameter is an array of strings, then it will be
//          used to select the members to be serialized. It filters the results
//          such that only members with keys listed in the replacer array are
//          stringified.

//          Values that do not have JSON representations, such as undefined or
//          functions, will not be serialized. Such values in objects will be
//          dropped; in arrays they will be replaced with null. You can use
//          a replacer function to replace those with JSON values.

//          JSON.stringify(undefined) returns undefined.

//          The optional space parameter produces a stringification of the
//          value that is filled with line breaks and indentation to make it
//          easier to read.

//          If the space parameter is a non-empty string, then that string will
//          be used for indentation. If the space parameter is a number, then
//          the indentation will be that many spaces.

//          Example:

//          text = JSON.stringify(["e", {pluribus: "unum"}]);
//          // text is '["e",{"pluribus":"unum"}]'

//          text = JSON.stringify(["e", {pluribus: "unum"}], null, "\t");
//          // text is '[\n\t"e",\n\t{\n\t\t"pluribus": "unum"\n\t}\n]'

//          text = JSON.stringify([new Date()], function (key, value) {
//              return this[key] instanceof Date
//                  ? "Date(" + this[key] + ")"
//                  : value;
//          });
//          // text is '["Date(---current time---)"]'

//      JSON.parse(text, reviver)
//          This method parses a JSON text to produce an object or array.
//          It can throw a SyntaxError exception.

//          The optional reviver parameter is a function that can filter and
//          transform the results. It receives each of the keys and values,
//          and its return value is used instead of the original value.
//          If it returns what it received, then the structure is not modified.
//          If it returns undefined then the member is deleted.

//          Example:

//          // Parse the text. Values that look like ISO date strings will
//          // be converted to Date objects.

//          myData = JSON.parse(text, function (key, value) {
//              var a;
//              if (typeof value === "string") {
//                  a =
//   /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)Z$/.exec(value);
//                  if (a) {
//                      return new Date(Date.UTC(
//                         +a[1], +a[2] - 1, +a[3], +a[4], +a[5], +a[6]
//                      ));
//                  }
//                  return value;
//              }
//          });

//          myData = JSON.parse(
//              "[\"Date(09/09/2001)\"]",
//              function (key, value) {
//                  var d;
//                  if (
//                      typeof value === "string"
//                      && value.slice(0, 5) === "Date("
//                      && value.slice(-1) === ")"
//                  ) {
//                      d = new Date(value.slice(5, -1));
//                      if (d) {
//                          return d;
//                      }
//                  }
//                  return value;
//              }
//          );

//  This is a reference implementation. You are free to copy, modify, or
//  redistribute.

/*jslint
    eval, for, this
*/

/*property
    JSON, apply, call, charCodeAt, getUTCDate, getUTCFullYear, getUTCHours,
    getUTCMinutes, getUTCMonth, getUTCSeconds, hasOwnProperty, join,
    lastIndex, length, parse, prototype, push, replace, slice, stringify,
    test, toJSON, toString, valueOf
*/


// Create a JSON object only if one does not already exist. We create the
// methods in a closure to avoid creating global variables.

if (typeof JSON !== "object") {
    JSON = {};
}

(function () {
    "use strict";

    var rx_one = /^[\],:{}\s]*$/;
    var rx_two = /\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4})/g;
    var rx_three = /"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g;
    var rx_four = /(?:^|:|,)(?:\s*\[)+/g;
    var rx_escapable = /[\\"\u0000-\u001f\u007f-\u009f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g;
    var rx_dangerous = /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g;

    function f(n) {
        // Format integers to have at least two digits.
        return (n < 10)
            ? "0" + n
            : n;
    }

    function this_value() {
        return this.valueOf();
    }

    if (typeof Date.prototype.toJSON !== "function") {

        Date.prototype.toJSON = function () {

            return isFinite(this.valueOf())
                ? (
                    this.getUTCFullYear()
                    + "-"
                    + f(this.getUTCMonth() + 1)
                    + "-"
                    + f(this.getUTCDate())
                    + "T"
                    + f(this.getUTCHours())
                    + ":"
                    + f(this.getUTCMinutes())
                    + ":"
                    + f(this.getUTCSeconds())
                    + "Z"
                )
                : null;
        };

        Boolean.prototype.toJSON = this_value;
        Number.prototype.toJSON = this_value;
        String.prototype.toJSON = this_value;
    }

    var gap;
    var indent;
    var meta;
    var rep;


    function quote(string) {

// If the string contains no control characters, no quote characters, and no
// backslash characters, then we can safely slap some quotes around it.
// Otherwise we must also replace the offending characters with safe escape
// sequences.

        rx_escapable.lastIndex = 0;
        return rx_escapable.test(string)
            ? "\"" + string.replace(rx_escapable, function (a) {
                var c = meta[a];
                return typeof c === "string"
                    ? c
                    : "\\u" + ("0000" + a.charCodeAt(0).toString(16)).slice(-4);
            }) + "\""
            : "\"" + string + "\"";
    }


// This variable is initialized with an empty array every time
// JSON.stringify() is invoked and checked by the str() function. It's
// used to keep references to object structures and capture cyclic
// objects. Every new object is checked for its existence in this
// array. If it's found it means the JSON object is cyclic and we have
// to stop execution and throw a TypeError accordingly the ECMA262
// (see NOTE 1 by the link https://tc39.es/ecma262/#sec-json.stringify).

    var seen;

// Emulate [].includes(). It's actual for old-fashioned JScript.

    function includes(array, value) {
        var i;
        for (i = 0; i < array.length; i += 1) {
            if (value === array[i]) {
                return true;
            }
        }
        return false;
    }


    function str(key, holder) {

// Produce a string from holder[key].

        var i;          // The loop counter.
        var k;          // The member key.
        var v;          // The member value.
        var length;
        var mind = gap;
        var partial;
        var value = holder[key];

// If the value has a toJSON method, call it to obtain a replacement value.

        if (
            value
            && typeof value === "object"
            && typeof value.toJSON === "function"
        ) {
            value = value.toJSON(key);
        }

// If we were called with a replacer function, then call the replacer to
// obtain a replacement value.

        if (typeof rep === "function") {
            value = rep.call(holder, key, value);
        }

// What happens next depends on the value's type.

        switch (typeof value) {
        case "string":
            return quote(value);

        case "number":

// JSON numbers must be finite. Encode non-finite numbers as null.

            return (isFinite(value))
                ? String(value)
                : "null";

        case "boolean":
        case "null":

// If the value is a boolean or null, convert it to a string. Note:
// typeof null does not produce "null". The case is included here in
// the remote chance that this gets fixed someday.

            return String(value);

// If the type is "object", we might be dealing with an object or an array or
// null.

        case "object":

// Due to a specification blunder in ECMAScript, typeof null is "object",
// so watch out for that case.

            if (!value) {
                return "null";
            }

// Check the value is not circular object. Otherwise throw TypeError.

            if (includes(seen, value)) {
                throw new TypeError("Converting circular structure to JSON");
            }

// Keep the value for the further check on circular references.

            seen.push(value);

// Make an array to hold the partial results of stringifying this object value.

            gap += indent;
            partial = [];

// Is the value an array?

            if (Object.prototype.toString.apply(value) === "[object Array]") {

// The value is an array. Stringify every element. Use null as a placeholder
// for non-JSON values.

                length = value.length;
                for (i = 0; i < length; i += 1) {
                    partial[i] = str(i, value) || "null";
                }

// Join all of the elements together, separated with commas, and wrap them in
// brackets.

                v = partial.length === 0
                    ? "[]"
                    : gap
                        ? (
                            "[\n"
                            + gap
                            + partial.join(",\n" + gap)
                            + "\n"
                            + mind
                            + "]"
                        )
                        : "[" + partial.join(",") + "]";
                gap = mind;
                return v;
            }

// If the replacer is an array, use it to select the members to be stringified.

            if (rep && typeof rep === "object") {
                length = rep.length;
                for (i = 0; i < length; i += 1) {
                    if (typeof rep[i] === "string") {
                        k = rep[i];
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (
                                (gap)
                                    ? ": "
                                    : ":"
                            ) + v);
                        }
                    }
                }
            } else {

// Otherwise, iterate through all of the keys in the object.

                for (k in value) {
                    if (Object.prototype.hasOwnProperty.call(value, k)) {
                        v = str(k, value);
                        if (v) {
                            partial.push(quote(k) + (
                                (gap)
                                    ? ": "
                                    : ":"
                            ) + v);
                        }
                    }
                }
            }

// Join all of the member texts together, separated with commas,
// and wrap them in braces.

            v = partial.length === 0
                ? "{}"
                : gap
                    ? "{\n" + gap + partial.join(",\n" + gap) + "\n" + mind + "}"
                    : "{" + partial.join(",") + "}";
            gap = mind;
            return v;
        }
    }

// If the JSON object does not yet have a stringify method, give it one.

    if (typeof JSON.stringify !== "function") {
        meta = {    // table of character substitutions
            "\b": "\\b",
            "\t": "\\t",
            "\n": "\\n",
            "\f": "\\f",
            "\r": "\\r",
            "\"": "\\\"",
            "\\": "\\\\"
        };
        JSON.stringify = function (value, replacer, space) {

// The stringify method takes a value and an optional replacer, and an optional
// space parameter, and returns a JSON text. The replacer can be a function
// that can replace values, or an array of strings that will select the keys.
// A default replacer method can be provided. Use of the space parameter can
// produce text that is more easily readable.

            var i;
            gap = "";
            indent = "";

// If the space parameter is a number, make an indent string containing that
// many spaces.

            if (typeof space === "number") {
                for (i = 0; i < space; i += 1) {
                    indent += " ";
                }

// If the space parameter is a string, it will be used as the indent string.

            } else if (typeof space === "string") {
                indent = space;
            }

// If there is a replacer, it must be a function or an array.
// Otherwise, throw an error.

            rep = replacer;
            if (replacer && typeof replacer !== "function" && (
                typeof replacer !== "object"
                || typeof replacer.length !== "number"
            )) {
                throw new Error("JSON.stringify");
            }

// Initialize the reference keeper.

            seen = [];

// Make a fake root object containing our value under the key of "".
// Return the result of stringifying the value.

            return str("", {"": value});
        };
    }


// If the JSON object does not yet have a parse method, give it one.

    if (typeof JSON.parse !== "function") {
        JSON.parse = function (text, reviver) {

// The parse method takes a text and an optional reviver function, and returns
// a JavaScript value if the text is a valid JSON text.

            var j;

            function walk(holder, key) {

// The walk method is used to recursively walk the resulting structure so
// that modifications can be made.

                var k;
                var v;
                var value = holder[key];
                if (value && typeof value === "object") {
                    for (k in value) {
                        if (Object.prototype.hasOwnProperty.call(value, k)) {
                            v = walk(value, k);
                            if (v !== undefined) {
                                value[k] = v;
                            } else {
                                delete value[k];
                            }
                        }
                    }
                }
                return reviver.call(holder, key, value);
            }


// Parsing happens in four stages. In the first stage, we replace certain
// Unicode characters with escape sequences. JavaScript handles many characters
// incorrectly, either silently deleting them, or treating them as line endings.

            text = String(text);
            rx_dangerous.lastIndex = 0;
            if (rx_dangerous.test(text)) {
                text = text.replace(rx_dangerous, function (a) {
                    return (
                        "\\u"
                        + ("0000" + a.charCodeAt(0).toString(16)).slice(-4)
                    );
                });
            }

// In the second stage, we run the text against regular expressions that look
// for non-JSON patterns. We are especially concerned with "()" and "new"
// because they can cause invocation, and "=" because it can cause mutation.
// But just to be safe, we want to reject all unexpected forms.

// We split the second stage into 4 regexp operations in order to work around
// crippling inefficiencies in IE's and Safari's regexp engines. First we
// replace the JSON backslash pairs with "@" (a non-JSON character). Second, we
// replace all simple value tokens with "]" characters. Third, we delete all
// open brackets that follow a colon or comma or that begin the text. Finally,
// we look to see that the remaining characters are only whitespace or "]" or
// "," or ":" or "{" or "}". If that is so, then the text is safe for eval.

            if (
                rx_one.test(
                    text
                        .replace(rx_two, "@")
                        .replace(rx_three, "]")
                        .replace(rx_four, "")
                )
            ) {

// In the third stage we use the eval function to compile the text into a
// JavaScript structure. The "{" operator is subject to a syntactic ambiguity
// in JavaScript: it can begin a block or an object literal. We wrap the text
// in parens to eliminate the ambiguity.

                j = eval("(" + text + ")");

// James Suárez 26-11-2022
// add prototype item function 

				function goodParse(obj){
					if(obj && typeof obj == "object"){
						if(!(obj instanceof Array)){
							for(var id in obj){
								var value = obj[id]
								if(id.toUpperCase() == "ITEM"){								
									// ocultar la variable
									obj["...." + id] = value
									delete obj[id]
								}
								if(typeof value == "object"){
									goodParse(value)
								}
							}
						}
					}
					return obj 
				}
				
				goodParse(j)
				Object.prototype.item = function() {
					var index = arguments[0]
					if(index === undefined || index === null) index = "....item"					
					if(typeof index == "string" && index.toUpperCase()=="ITEM"){
						index= "...." + index
					}
					return this[index]
				}

// In the optional fourth stage, we recursively walk the new structure, passing
// each name/value pair to a reviver function for possible transformation.

                return (typeof reviver === "function")
                    ? walk({"": j}, "")
                    : j;
            }

// If the text is not JSON parseable, then a SyntaxError is thrown.

            throw new SyntaxError("JSON.parse");
        };
    }
}());
		ENDTEXT
		#IF VERSION(5) = 600
			SET PRINT OFF
			SET CONSOLE ON
			SET DEVICE TO SCREEN
			SET PRINTER TO &cPrinter
			cJSONParserCode = FILETOSTR(cTmpFile)
			ERASE (cTmpFile)
		#ENDIF
		RETURN cJSONParserCode



	HIDDEN FUNCTION _getSupportCode
		LOCAL cCode
		#IF VERSION(5) = 600
			LOCAL cPrinter,cTmpFile
			cPrinter = SET("PRINTER")
			cTmpFile = ADDBS(GETENV("TEMP")) + "TM" + SYS(2015) + ".TMP"
			SET PRINTER TO FILE (cTmpFile)
			SET DEVICE TO PRINT
			SET CONSOLE OFF
			SET PRINT ON
		#ENDIF
		TEXT TO cCode NOSHOW

var buff = {
	json: "",
	normalize: true
}

function set(name, value) {
	buff[name] = value;
}

function get(name) {
	return buff[name];
}

function parseJSON() {
	var o = null;
	buff.lasterror = "";
	try {
		o = JSON.parse(buff.json);
	    if (buff.normalize) o = analyze(o);

	} catch (ex) {
	    o = null;
	    buff.lastError = ex.message;
	}
	return o;
}


function analyze(value, name) {
	var node = {
	    name: name,
		type: typeof value,
		value: value
	}
	
	if (node.type == "object" && value && value.constructor && value.constructor === Array)
		node.type = "array";
	
	switch (node.type) {
		case "object":
		    node.value = [];
		    for (k in value) {
            	if (Object.prototype.hasOwnProperty.call(value, k)) {
            		node.value.push(analyze(value[k], k));	
            	}
            }
			break;
			
		case "array":
		    node.value = [];
		    for (var i = 0; i < value.length; i++) {
		    	node.value.push(analyze(value[i]));
		    }
			break;
	}
	
	return node;
}
		ENDTEXT
		#IF VERSION(5) = 600
			SET PRINT OFF
			SET CONSOLE ON
			SET DEVICE TO SCREEN
			SET PRINTER TO &cPrinter
			cCode = FILETOSTR(cTmpFile)
			ERASE (cTmpFile)
		#ENDIF
		RETURN cCode


	HIDDEN FUNCTION _js2fox(poNode, poJS)
		IF PCOUNT() = 1
			poJS = THIS._getFastParser()
		ENDIF
	    LOCAL cType,fo,oNode
	    cType = poNode.type
	    DO CASE
	       CASE cType == "object"
	            fo = CREATEOBJECT(_Empty)
	            FOR EACH oNode IN poNode.value
	            	IF TYPE("oNode.name")<>"U"   && REQUIRED TO VOID "phantom" NODES
	            		ADDPROPERTY(fo, oNode.name, THIS._js2fox(oNode, poJS) )
	            	ENDIF
	            ENDFOR
	            
	       CASE cType == "array"
	            fo = CREATEOBJECT("Collection")
	            FOR EACH oNode IN poNode.value 
	            	IF TYPE("oNode.Name") <> "U"   && REQUIRED TO VOID "phantom" NODES
	            		fo.add( THIS._js2fox(oNode, poJS) )
	            	ENDIF
	            ENDFOR

	       OTHERWISE
	       		fo = poNode.Value
	    ENDCASE
		RETURN fo

		

ENDDEFINE




* jsonSchemas	(Class)	
* Handle Cursors Schemas for json
* 12-12-2014
*
DEFINE CLASS jsonSchemas AS Collection 

  lastError = NULL						&& Contains the object Exception
     
  * init	(Method)
  *
  PROCEDURE init()
    THIS.lastError = CREATEOBJECT("jsonError")
  ENDPROC 

  
  * new 	(Method)
  * Create a new empty Schema
  *
  PROCEDURE new(pcName)
    LOCAL oSchema
    oSchema = NULL
    
    _TRY
      THIS.lastError.hasError = .F.
      IF EMPTY(pcName)
        THROW(VFP_JSON_MSG_001)
      ENDIF 
      IF NOEX() AND THIS.exist(pcName)										&& Verify the exist Schema
        THROW(VFP_JSON_MSG_003)
      ENDIF 
      
      * Add Schema to Collections Schemas
      *
      IF NOEX()
	      LOCAL ojsonSchema, cSchemaName
	      cSchemaName		= ALLT(UPPER(pcName))
	      ojsonSchema 		= CREATEOBJECT("jsonSchema")
      ENDIF
      IF NOEX()	      
	      ojsonSchema.Name 	= cSchemaName
	      THIS.add(ojsonSchema, cSchemaName)
	      oSchema = THIS.get(cSchemaName)
	  ENDIF

    _CATCH
       THIS.lastError.initWithEx(ex)
    _ENDTRY 
    
    RETURN oSchema
  ENDPROC 
  
	
	* newFromCursor		(Method)
	* Create a new Schema from a Cursor
	*
	PROCEDURE newFromCursor(pcSchema, pcCursor, pnDSID)
		THIS.lastError.hasError = .F.
		*
		LOCAL oNewSchema
		oNewSchema	= NULL
		*
	    _TRY
			* Validations
			*
			IF EMPTY(pcSchema)
				THROW(VFP_JSON_MSG_001)
			ENDIF
			IF NOEX() AND EMPTY(pcCursor)
				THROW(VFP_JSON_MSG_010)
			ENDIF 
			IF NOEX() AND THIS.exist(pcSchema)
			  THROW(VFP_JSON_MSG_003)
			ENDIF 
			IF NOEX() AND !EMPTY(pnDSID)
			 SET DATASESSION TO (pnDSID)
			ENDIF
			IF NOEX() AND NOT USED(pcCursor)
			  THROW(VFP_JSON_MSG_011)
			ENDIF 

			LOCAL ARRAY aStruct(1)
			LOCAL nCount AS Integer, i AS Integer, oSchema AS Object
			*
			* Create the new Schema
			*
			oSchema = THIS.new(pcSchema)
			IF NOEX() AND !ISNULL(oSchema)
				oSchema.initWithAlias(pcCursor)
				oNewSchema = oSchema
		    ENDIF

		_CATCH 
			THIS.lastError.initWithEx(ex)
		_ENDTRY
		* 
		RETURN oNewSchema
	ENDPROC 
  

	* newFromString		(Method)
	* Create a new Schema from a String
	*
	PROCEDURE newFromString(pcSchema, pcString)
		THIS.lastError.hasError = .F.
		*
		LOCAL oNewSchema, cCurrAlias
		oNewSchema	= NULL
		*
		_TRY 
			*
			cCurrAlias	=	ALIAS()
			* Validations
			*
			IF EMPTY(pcSchema)
				THROW(VFP_JSON_MSG_001)
			ENDIF
			*
			IF NOEX() AND EMPTY(pcString)
				THROW(VFP_JSON_MSG_012)
			ENDIF 
			*
			IF NOEX() AND THIS.exist(pcSchema)
			  THROW(VFP_JSON_MSG_003)
			ENDIF 
			
			*
			* Create a temporal cursor with string structure
			*
			IF NOEX()
			 CREATE CURSOR VFPStructSchema (&pcString)
			ENDIF
			
			*
			* Create the Schema from Cursor
			*
			IF NOEX()
 			 LOCAL oSchema
			 oSchema = THIS.newFromCursor(pcSchema, "VFPStructSchema")
			 IF NOT ISNULL(oSchema)
				oNewSchema = oSchema
			 ENDIF
			ENDIF 
			*
		_CATCH
			THIS.lastError.initWithEx(ex)
			
		_ENDTRY 
		
		IF USED("VFPStructSchema")
		  USE IN "VFPStructSchema"
		ENDIF 
		IF VARTYPE(cCurrAlias)=="C" AND NOT EMPTY(cCurrAlias) AND USED(cCurrAlias)
		  SELECT(cCurrAlias)
		ENDIF  
		
		*
		RETURN oNewSchema
	ENDPROC  
 
 
  * get			(Method)
  * Return a Schema
  *
  PROCEDURE get(pcName)
    *
    LOCAL ex As Exception, loRet As Object
    *
    loRet = NULL
    *
    _TRY 
      *
      THIS.lastError.hasError = .F.
			*
      * Validations
      IF EMPTY(pcName)
        THROW(VFP_JSON_MSG_001)
      ENDIF 
	    *
	    IF NOEX() AND !THIS.Exist(pcName)
	      THROW(VFP_JSON_MSG_002)
	    ENDIF 
	    *
	    pcName = ALLT(UPPER(pcName))
	    *
	    loRet = THIS.Item(pcName)

	  _CATCH
	    THIS.lastError.initWithEx(ex)

	  _ENDTRY 
	  *
	  RETURN loRet
  ENDPROC  
  
  
  * Exist			(Method)
  * Determines if there a schema
  *
  PROCEDURE Exist(pcName)
	THIS.lastError.hasError = .F.
	pcName = ALLT(UPPER(pcName))
	LOCAL i AS Integer, lExist As Boolean 
	FOR i=1 TO THIS.Count
	 IF ALLT(UPPER(THIS.GetKey(i))) == pcName
	  lExist = .T.
	  EXIT 
	 ENDIF 
	ENDFOR 
    RETURN lExist 
  ENDPROC 


	* del		(Method)
	* Delete a Schema
	*
	PROCEDURE delete(pcSchema)
		*
		THIS.lastError.hasError = .F.
		*
		LOCAL lRet AS Boolean
		_TRY 
			* Validations
			*
			IF EMPTY(pcSchema)
			  THROW(VFP_JSON_MSG_001)
			ENDIF 
			IF NOEX() AND !THIS.exist(pcSchema)
				THROW(VFP_JSON_MSG_002)
			ENDIF
			IF NOEX()
			  pcSchema = ALLT(UPPER(pcSchema))
			ENDIF
			*		
			* Remove the Schema
			*
			IF NOEX() 
			 THIS.Remove(pcSchema)
			ENDIF
			lRet = .T.

		_CATCH
			THIS.lastError.initWithEx(ex)
			
		_ENDTRY 
		*
		RETURN lRet
	ENDPROC 
	
	
	* Create (Method)
	* Creates a cursor based on a given schema
	*
	PROCEDURE Create(pcAlias, pcSchema, pnDSID)
	  LOCAL lRet AS Boolean
	  _TRY
		* Validations
		*
		IF EMPTY(pcSchema)
		  THROW(VFP_JSON_MSG_001)
		ENDIF 
		
		IF NOEX()
			LOCAL oSchema
			oSchema = THIS.Get(pcSchema)
			IF ISNULL(oSchema)
				THROW(VFP_JSON_MSG_002)
			ENDIF
		ENDIF
		
		IF NOEX() AND !EMPTY(pnDSID)
		 SET DATASESSION TO (pnDSID)
		ENDIF
		IF NOEX() AND USED(pcAlias)
		  THROW(VFP_JSON_MSG_022)
		ENDIF
		
		IF NOEX()
		 lRet = oSchema.toCursor(pcAlias, pnDSID)
		ENDIF

	  _CATCH
	  	THIS.lastError.initWithEx(ex)
	  	
	  _ENDTRY
	  RETURN lRet
	ENDPROC

ENDDEFINE 


* jsonSchema 	(Class)
* 30-12-2014
*
DEFINE CLASS jsonSchema AS CUSTOM
  lastError	= NULL 
  Columns = NULL
  
  HIDDEN _columns  
  PROCEDURE Columns_Access
   RETURN THIS._columns
  ENDPROC
  
  
  * init	(Method)
  *
  PROCEDURE init(pcName)
    *
    WITH THIS
        .Name = EVL(pcName, .Name)
    	.lastError 	= CREATEOBJECT("jsonError")
    	._columns 	= CREATEOBJECT("Collection")    	
    ENDWITH 
    *
  ENDPROC 
  

  * initWithAlias (Method)
  * Initialize the schema using an existing alias
  *
  PROCEDURE initWithAlias(pcAlias)
  		THIS.lastError.hasError = .F.
		*
		_TRY 
			IF NOT USED(pcAlias)
			  THROW(VFP_JSON_MSG_011)
			ENDIF 
			*
			IF NOEX()
				LOCAL ARRAY aStruct(1)
				LOCAL nCount AS Integer, i AS Integer, oSchema AS Object
				nCount = AFIELDS(aStruct, pcAlias)
				FOR i = 1 TO nCount
				  THIS.addColumn( aStruct(i,1), aStruct(i,2), aStruct(i,3), aStruct(i,4) )
				ENDFOR 
			ENDIF
			
		_CATCH
			THIS.lastError.initWithEx(ex)
			
		_ENDTRY
	ENDPROC 
	
	
 	* initWithJSON (MEthod)
 	* Initialize the schema with a JSON cursor object
 	*	
	PROCEDURE initWithJSON(poJSON)
  		THIS.lastError.hasError = .F.		
		_TRY 
			DO CASE
			   CASE PCOUNT() = 0
			        THROW(VFP_JSON_MSG_017)
			        
			   CASE NOEX() AND VARTYPE(poJSON) <> "O"
			        THROW(VFP_JSON_MSG_018)
			        
			   CASE NOEX() AND !PEMSTATUS(poJSON, "schema", 5)
			        THROW(VFP_JSON_MSG_016)
			ENDCASE
		
		    IF NOEX()
				LOCAL nCount AS Integer, i AS Integer, oSchema AS Object
				nCount = poJSON.Schema.Count
				FOR i = 1 TO nCount
				  oColumn = poJSON.Schema.Item[i]
				  THIS.addColumn( oColumn.Name, oColumn.Type, oColumn.Lon, oColumn.Dec)
				ENDFOR 
			ENDIF
			
		_CATCH
			THIS.lastError.initWithEx(ex)
			
		_ENDTRY		
		
		RETURN !THIS.lastError.hasError
	ENDPROC
		

  
  * AddColumn	(Method)
  * Add a column to Schema
  *
  PROCEDURE addColumn(pcColumnName, pcColumnType, pnLong, pnDec)
  	*
  	IF PCOUNT() = 1 AND VARTYPE(pcColumnName) = "O" AND LOWER(pcColumnName.class) == "jsoncolumn"
  	 THIS.Columns.Add(pcColumnName)
  	 RETURN
  	ENDIF
  	
  	LOCAL lRet
  	_TRY
  		THIS.lastError.hasError = .F.
  		* Validations
  		*
  		IF EMPTY(pcColumnName)
  	  	 THROW(VFP_JSON_MSG_004)
  		ENDIF 
  		* 
  		pcColumnName	=	ALLT(UPPER(pcColumnName))
  		IF NOEX() AND EMPTY(pcColumnType)
  	  	 THROW(VFP_JSON_MSG_005)
  		ENDIF 
  		
  		IF NOEX()
			pcColumnType = UPPER(pcColumnType)
	  		IF NOT INLIST(pcColumnType, "C","D","T","N","F","I","B","Y","L","M","G")
	  		  THROW(VFP_JSON_MSG_008)
	  		ENDIF 
  		ENDIF
		IF NOEX() AND INLIST(pcColumnType, "C", "N", "F") AND EMPTY(pnLong)
		  THROW(VFP_JSON_MSG_006)
  		ENDIF 
  		IF NOEX() AND THIS.existColumn(pcColumnName)
  			THROW(VFP_JSON_MSG_007)
  		ENDIF 
  		*
  		IF NOEX()
	  		LOCAL oColumn
	  		oColumn = CREATEOBJECT("jsonColumn", pcColumnName, pcColumnType, pnLong, pnDec)
	  	ENDIF
	  	IF NOEX()	
	  		THIS.columns.add(oColumn, pcColumnName)
	  		lRet = .T. 
  		ENDIF

  	_CATCH
  		THIS.lastError.initWithEx(ex)
  		
  	_ENDTRY 
  	
  	*
  	RETURN lRet
  	*
  ENDPROC 
  


  * AddColumnFromString	(Method)
  * Add a column to Schema from a string
  *
  PROCEDURE addColumnFromString(pcColumnString)
  	*
  	THIS.lastError.hasError = .F.
  	LOCAL lRet As Boolean, cCurrAlias AS String, cCol AS String
  	_TRY 
  		*
  		cCurrAlias	= ALIAS() 		
  		*
  		* Validations
  		*
  		IF EMPTY(pcColumnString)
  		  THROW(VFP_JSON_MSG_009)
  		ENDIF
  		IF NOEX()
	  		cCol = UPPER(SUBSTR(pcColumnString,1,AT(" ",pcColumnString)))
	  		IF THIS.existColumn( cCol )
	  		  THROW(VFP_JSON_MSG_007)
	  		ENDIF 
  		ENDIF
  		
  		IF NOEX() AND USED("VFPStructSchema")
  		  USE IN "VFPStructSchema"
	  	  CREATE CURSOR VFPStructSchema (&pcColumnString)
	  	  LOCAL ARRAY aStruct(1)
	  	  AFIELDS(aStruct,"VFPStructSchema")
	  	  IF NOEX()
		   THIS.addColumn(cCol, aStruct(1,2), aStruct(1,3), aStruct(1,4) )
		  ENDIF
	  	  lRet = NOEX()
  		ENDIF
  		
  	_CATCH
  		THIS.lastError.initWithEx(ex)
  	_ENDTRY 

  	  IF VARTYPE(cCurrAlias)=="C" AND !EMPTY(cCurrAlias)
  	    SELECT(cCurrAlias)
  	  ENDIF 
  	  IF USED("VFPStructSchema")
  	    USE IN "VFPStructSchema"
  	  ENDIF 

  	*
  	RETURN lRet 
  ENDPROC 

	
	
	* delColumn	(Method)
	* Delete a Column of Schema
	*
	PROCEDURE delColumn(pcColName)
		THIS.lastError.hasError = .F.
		LOCAL lRet AS Boolean
		_TRY 
			* Validations
			*
			IF EMPTY(pcColName)
			  THROW(VFP_JSON_MSG_004)
			ENDIF 
			*
			IF NOEX() AND NOT THIS.existColumn(pcColName)
			  THROW(VFP_JSON_MSG_007)
			ENDIF 
			*
			* Remove the column
			*
			IF NOEX()
				pcColName = ALLT(UPPER(pcColName))
				THIS.Columns.Remove(pcColName)
				lRet = NOEX()
			ENDIF
			
		_CATCH
		  THIS.lastError.initWithEx(ex)
		  
		_ENDTRY 
		RETURN lRet 
	ENDPROC 
	

	* toString		(Method)
	* Return a string structure of Schema
	*
	PROCEDURE toString(plJSON)
		*
		LOCAL cText
		cText = NULL
		THIS.lastError.hasError = .F.
		LOCAL oColumn, i
		cText = ""
		FOR i = 1 tO THIS.Columns.Count
		  oColumn = THIS.Columns.Item[i]
		  cText = cText + IIF(NOT EMPTY(cText), "," , "") + oColumn.toString(plJSON)
		ENDFOR 
		IF plJSON
		 cText = "[" + cText + "]"
		ENDIF			
		RETURN cText
	ENDPROC 
	
	
	
  * existColumn		(Method)
  * Determines if there a column
  *
  PROCEDURE existColumn(pcName)
	THIS.lastError.hasError = .F.
    pcName = ALLT(UPPER(pcName))
    LOCAL i AS Integer, lExist As Boolean 
    FOR i=1 TO THIS.columns.Count
      IF ALLT(UPPER(THIS.columns.GetKey(i))) == pcName
        lExist = .T.
        EXIT 
      ENDIF 
    ENDFOR 
    RETURN lExist 
  ENDPROC 


  * toCursor			(Method)
  * Create a cursor from a Schema
  *
  PROCEDURE toCursor(pcCursorName, pnDSID)
  	THIS.lastError.hasError = .F.
  	LOCAL lRet As Boolean, cCurrAlias AS String
  	LOCAL nWkArea
  	nWkArea = SELECT()
  	_TRY
	  	IF !EMPTY(pnDSID)
	  	 SET DATASESSION TO (pnDSID)
	  	ENDIF

  		* Validations 
  		*
  		IF NOEX() AND EMPTY(pcCursorName)
  			THROW(VFP_JSON_MSG_010)
  		ENDIF
  		IF NOEX() AND THIS.Columns.Count = 0 
  		 	THROW(VFP_JSON_MSG_020)
  		ENDIF 
		*
		IF NOEX() AND USED(pcCursorName)
		  USE IN (pcCursorName)
		ENDIF 
		
		* Create the cursor
		IF NOEX()
			LOCAL cStruct
			cStruct = THIS.toString()
			SELECT 0
			CREATE CURSOR (pcCursorName) (&cStruct)
	  		lRet = NOEX()
	  	ENDIF
	  	
  	_CATCH
  		THIS.lastError.initWithEx(ex)
  	_ENDTRY 
  	
  	SELECT (nWkArea)
  	*
  	RETURN lRet 
  ENDPROC   
  
ENDDEFINE 


* jsonColumn (Class)
* 03-01-2015
*
DEFINE CLASS jsonColumn AS CUSTOM
   type				=		"C"
   long				=		0
   dec				=		0
   lastError	=		NULL
   
   * init 	(Method)
   PROCEDURE init(pcName,pcType,pnLong,pnDec)
	 THIS.lastError	=	CREATEOBJECT("jsonError")
     WITH THIS 
      .name = EVL(pcName, .name)
      .type = EVL(pcType, .type)
      .long = EVL(pnLong, .long)
      .dec = EVL(pnDec, .dec)
     ENDWITH 
   ENDPROC
   *
   
   PROCEDURE initWithValue(puValue, pcName)
    LOCAL cType 
    cType = VARTYPE(puValue)
    THIS.Name = LOWER(pcName)
    THIS.Type = cType
    DO CASE
       CASE cType = "C" AND LEN(puValue) <= 254
            THIS.Long = 254
            
       CASE cType = "C" AND LEN(puValue) > 254
            THIS.Type = "M"
            
       CASE cType = "N" AND INT(puValue) = puValue
            THIS.Long = 15
            
       CASE cType = "N" AND INT(puValue) <> puValue
            THIS.Long = 15
            THIS.Dec = 4
           
       CASE cType = "O"
            THIS.Type = "M"

       OTHERWISE
            THIS.Type = "C"
            THIS.Long = 254

    ENDCASE
   ENDPROC
   

   * toString		(Method)
   * Return a column string structure
   *
   PROCEDURE toString(plJSON)
   		THIS.lastError.hasError =.F.
   		LOCAL cText
   		cText = NULL
   		IF plJSON
   		 cText = [{"name" : "{0}", "type" : "{1}", "lon" : {2}, "dec" : {3} }]
   		 cText = STRT(cText, "{0}", THIS.Name)
   		 cText = STRT(cText, "{1}", THIS.Type)
   		 cText = STRT(cText, "{2}", ALLTRIM(STR(THIS.Long)))
   		 cText = STRT(cText, "{3}", ALLTRIM(STR(THIS.Dec)))
   		ELSE
			WITH THIS
			 cText = .name + " " + ;
			         .type + IIF(.type = "C", "(" + ALLT(STR(.long)) + ")",;
			                 IIF(.type $ "NF", "(" + ALLT(STR(.long)) + "," + ALLT(STR(.dec)) + ")",;
			                 IIF(.type = "B", "(" + ALLT(STR(.dec)) + ")", ""))) + ;
			         " NULL"
			ENDWITH 
		ENDIF	
		RETURN cText 
   ENDPROC 
   * 
ENDDEFINE 



* jsonError 	(Class)
* Represent an error raised from within json class.
* 30-12-2014
*
DEFINE CLASS jsonError AS JSONSingletonPattern
   
   * Properties
   className = "jsonError"			&& SingletonPattern
   
   errorType				= 0				&& Type Error. 1=Exception, 2=OLE Error, 3=ODBC Error, 4=VFP Error, 5=Unhandled Error, 6=Manual error
   errorNo					= 0
   details					= ""
   lineContents				= ""
   lineNo					= 0
   message					= ""
   procedure				= ""
   stackLevel				= ""
   tag						= ""
   userValue			 	= ""
   externalErrorNo			= 0
   hasError					= .F.
   customErrorNo			= NULL
   
   * hasError_Assing	(Method)
   *
   PROCEDURE hasError_Assign()
     *
     LPARAMETERS vNewVal
     WITH THIS
     	IF m.vNewVal 
     		.Clear()
     	ENDIF
	    .hasError = m.vNewVal
	 ENDWITH 
     *
   ENDPROC 
   
   
   * Clear	(Method)
   *
   PROCEDURE Clear()
     WITH THIS
       .errorNo						= NULL
       .details 					= NULL
       .lineContents 				= NULL
       .lineNo 						= NULL
       .message 					= NULL
       .procedure 					= NULL
       .stackLevel 					= NULL
       .tag		  					= ""
       .userValue 					= NULL
       .externalErrorNo				= NULL
       .hasError = .F.
     ENDWITH 
   ENDPROC 
   
   
   * initWithEx 	(Method)
   *
   PROCEDURE initWithEx(poEx)
     *
     IF PCOUNT() = 0
       RETURN 
     ENDIF 
    
     IF poEx.errorNo = 2071   && User thrown error
      IF TYPE("poEx.userValue.Message") = "C"
       poEx = poEx.userValue
      ELSE
       poEx.Message = poEx.userValue
      ENDIF
     ENDIF
     
     
     WITH THIS
       .hasError			= .T.
       .errorType			= 1
       .errorNo				= poEx.ErrorNo
       .details 			= poEx.Details
       .lineContents 		= poEx.LineContents
       .lineNo 				= poEx.LineNo
       .message 			= poEx.Message
       .procedure 			= poEx.Procedure
       .stackLevel 			= poEx.StackLevel
       .tag		  			= poEx.Tag
       .userValue 			= poEx.UserValue
     ENDWITH 
     *
   ENDPROC 


   * initWithString 	(Method)
   *
   PROCEDURE initWithString(pcString, pcProcedure)
     *
     IF PCOUNT() = 0
       RETURN 
     ENDIF 
    
     WITH THIS
       .hasError			= .T.
       .errorType			= 6
       .errorNo				= 0
       .details 			= ""
       .lineContents 		= ""
       .lineNo 				= 0
       .message 			= pcString
       .procedure 			= EVL(pcProcedure, "")
       .stackLevel 			= NULL
       .tag		  			= ""
       .userValue 			= NULL
     ENDWITH 
     *
   ENDPROC 


   * initWithOLE 		(Method)
   *
   PROCEDURE initWithOLE(paLastError)
     *
     IF PCOUNT() = 0 
      DIMENSION paLastError[1]
      AERROR(paLastError)
     ENDIF
     
     WITH THIS
       .hasError					= .T.
       .errorType					= 2
       .errorNo						= paLastError(1)
       .details 					= paLastError(2)
       .message 					= paLastError(3)
       .externalErrorNo				= paLastError(7)
     ENDWITH 
     *
   ENDPROC 


   * initWithODBC 		(Method)
   *
   PROCEDURE initWithODBC(paLastError)
     *
     IF PCOUNT() = 0 
      DIMENSION paLastError[1]
      AERROR(paLastError)
     ENDIF

     WITH THIS
       .hasError					= .T.    
       .errorType					= 3
       .errorNo						= paLastError(1)
       .details 					= paLastError(2)
       .message 					= paLastError(3)
       .externalErrorNo				= paLastError(5)
     ENDWITH 
     *
   ENDPROC 

   
   * initWithDefault		(Method)
   *
   PROCEDURE initWithDefault()
     *
   	 LOCAL ARRAY aLastError(1)
   	 =AERROR(aLastError)
   	 *
   	 LOCAL nError
   	 nError = aLastError(1)
   	 *
   	 _TRY
	   	 DO CASE
	   	   *
	   	   CASE nError = 1427 OR nError = 1429			&& OLE Error
	   	      THIS.initWithOLE(@aLastError)
	   	   
	   	   CASE nError = 1526							&& ODBC Error
	   	      THIS.initWithODBC(@aLastError)
	   	      
	   	   OTHERWISE 									&& VFP Error
		     WITH THIS
		       .hasError					= .T.    
		       .errorType					= 4
		       .errorNo						= aLastError(1)
		       .details 					= aLastError(3)
		       .message 					= aLastError(2)
		     ENDWITH 
	   	   *
	   	 ENDCASE 
	   	 
	 _CATCH
   	     WITH THIS
   	       .hasError	= .T.
   	       .errorType	= 5
   	       .message		= "Unhandled error" 
   	     ENDWITH 
	 
	 _ENDTRY
   ENDPROC 
   
   * toString()	
   * Return a full error information
   *
   PROCEDURE toString()
     *
     LOCAL cText
		 *	     
     DO CASE 
       
       CASE THIS.errorType	=	1								&& Exception Error
         LOCAL cText
         ex = THIS
         *
         IF NOT EMPTY(ex.userValue)
           cText = ex.userValue + ;
       		       " Line No.:  " 	+ LTRIM(TRANS(ex.lineNo))+;
       		       " Procedure: "	+ ex.procedure +;
       		       IIF(Not ISNULL(ex.customErrorNo), " .Custom Error No.: " + LTRIM(TRANS(ex.customErrorNo)), "")
         ELSE
           cText = "Error No.: "  	+ LTRIM(TRANS(ex.errorNo,"99999")) + ;
       		       " " 			  	+ ex.message +;
       		       " Line: " 		+ ex.lineContents +;
       		       " Line No.: " 	+ LTRIM(TRANS(ex.lineNo)) +;
       		       " Detail:   "	+ ex.details +;
       		       " Procedure: "	+ ex.procedure
         ENDIF 


       CASE THIS.errorType = 2 OR THIS.errorType = 3			&& OLE Error / ODBC Error
          WITH THIS
            cText = "Error No.: "				+ LTRIM(TRANS(.errorNo,"99999")) + ;
            		" "							+ .message +;
            		" External Error No: "		+ .externalErrorNo + ;
            		" Detail: "					+ .details 
          ENDWITH 
       
       CASE THIS.errorType = 4									&& Unhandled Error
	     cText = "Unhandled error by " + THIS.Name
	       
       OTHERWISE 
         cText = "Unhandled error by " + THIS.Name
     
     ENDCASE 
     *
     RETURN cText 
	 *
   ENDPROC 
   
   * getObject() Method
   * Return el Object for read Properties
   PROCEDURE getObject()
     RETURN THIS
   ENDPROC 

ENDDEFINE 



* SingletonPattern
* Clase para la implementacion del pattern Singleton en VFP
*
* Autor: Victor Espina
* Fecha: Abril 2012
*
* Uso:
* Para la implementacion de esta clase se requiere definir dos clases
* a) Una clase basada en SingletonPattern
* b) La clase real que se desea implementar como Singleton, la cual puede
*    estar basada en cualquier clase base o subclase.
*
* Ejemplo:
* Supongamos que tenemos una clase llamada AppContextClass que queremos
* implementar como singleton.  Lo unico que se debe hacer es declarar
* una clase basada en SingletonPattern y configurar su propiedad className:
*
* DEFINE CLASS appContext AS SingletonPattern
*  className = "appContextClass"
* ENDDEFINE
*
* Luego, cuando se desee crear una instancia de AppContextClass, se hace:
*
* oSingletonInstance = CREATE("appContext")
*
* Y se lograra el efecto de que todas las instancias de appContext apuntaran a
* una unica instancia de appContextClass.
*
* 
DEFINE CLASS JSONSingletonPattern AS Custom
 *
 className = ""
 
 * Constructor
 * El parametro plInstance es utilizado por el metodo createInstance() en el caso
 * de que la clase real sea una subclase de SingletonPattern, para indicar que se
 * debe crear la instancia directamente
 PROCEDURE Init(plInstanceMode)
  IF plInstanceMode
   RETURN
  ENDIF
  IF EMPTY(THIS.className)      && Si no se indica una clase real se asume
   THIS.className = THIS.Class  && esta misma clase
  ENDIF
  IF NOT THIS.checkInstance()   && Se verifica si ya existe una instancia de
   THIS.createInstance()        && la clase. Si no es si, se crea
  ENDIF
 ENDPROC
 
 * checkInstance
 * Determina si ya existe una instancia creada para la clase real
 PROCEDURE checkInstance
  IF NOT ISNULL(THIS.getInstance())   && Si podemos obtener una referencia a la instancia
   RETURN .T.                         && es porque la misma existe
  ENDIF
  IF !PEMSTATUS(_Screen,THIS.className, 5)    && Si no existe la propiedad asociada a la clase
   _Screen.addProperty(THIS.className, NULL)  && en _Screen, se crea
  ENDIF
  RETURN .F.
 ENDPROC

 * createInstance
 * Crea una instancia de la clase real 
 PROCEDURE createInstance
  LOCAL oInstance
  IF LOWER(THIS.Class) == LOWER(THIS.className)   && La clase real es una subclase directa de SingletonPattern ?
   oInstance = CREATE(THIS.className, .T.)
  ELSE
   oInstance = CREATE(THIS.className)
  ENDIF
  STORE oInstance TO ("_Screen." + THIS.className)
 ENDPROC

 * getInstance
 * Devuelve una referencia a la instancia unica de la clase real 
 PROCEDURE getInstance
  IF !PEMSTATUS(_Screen,THIS.ClassName,5) OR TYPE("_Screen." + THIS.className)<>"O"
   RETURN NULL
  ENDIF
  RETURN EVAL("_Screen." + THIS.className)
 ENDPROC
 
 * releaseInstance
 * Libera la instancia unica de la clase real
 PROCEDURE releaseInstance
  IF THIS.checkInstance()
   STORE NULL TO ("_Screen." + THIS.className)
  ENDIF
 ENDPROC
 
 * Accesor para la propiedad THIS
 * Este accesor decide si devuelve una referencia al controlador Singleton o a la clase real
 PROCEDURE THIS_Access(cMember)
  IF INLIST(LOWER(cMember),"classname","checkinstance","createinstance","getinstance","class")
   RETURN THIS
  ELSE
   RETURN EVAL("_Screen." + THIS.className)
  ENDIF
 ENDPROC
 *
ENDDEFINE


* VFPLEGACY.PRG
*
* ADD SUPPORT FOR FEATURES NOT PRESENT IN OLDER
* VERSIONS OF VFP
*
* AUTHOR: VICTOR ESPINA
*
* FEATURES IMPLEMENTED:
*
* A) EMPTY CLASS
* B) TRY-CATCH
* C) Exception CLASS
* D) Collection CLASS
* E) ADDPROPERTY FUNCTION
* F) EVL FUNCTION
*

******************************************************
**
**               VFP 6 SUPPORT
**
******************************************************
#IF VERSION(5) < 800

* EMPTY
* Empty class
*
DEFINE CLASS EmptyObject AS Line
ENDDEFINE


* TRYCATCH.PRG
* Funciones para la implementacion de bloques TRY-CATCH en versiones
* de VFP anteriores a 8.00
*
* Autor: Victor Espina
* Fecha: May 2014
*
*
* Uso:
*
* LOCAL ex
* TRY()
*   un comando
*   IF NOEX()
*    otro comando
*   ENDIF
*   IF NOEX()
*    otro comando
*   ENDIF
*
* IF CATCH(@ex)
*   manejo de error
* ENDIF
*
* ENDTRY()
*
*
* Ejemplo:
*
* lOk = .F.
* TRY()
*   Iniciar()
*   IF NOEX()
*    Terminar()
*   ENDIF
*   lOk = NOEX()
*
* IF CATCH(@ex)
*    MESSAGEBOX(ex.Message)
* ENDIF
* ENTRY()
*
* IF lok
*  ...
* ENDIF
*

PROCEDURE TRY
 IF VARTYPE(gcTRYOnError)="U"
  PUBLIC gcTRYOnError,goTRYEx,gnTRYNestingLevel
  gnTRYNestingLevel = 0
 ENDIF
 goTRYEx = NULL
 gnTRYNestingLevel = gnTRYNestingLevel + 1
 IF gnTRYNestingLevel = 1
  gcTRYOnError = ON("ERROR")
  ON ERROR tryCatch(ERROR(), MESSAGE(), MESSAGE(1), PROGRAM(), LINENO())
 ENDIF
ENDPROC


PROCEDURE CATCH(poEx)
 IF PCOUNT() = 1 AND !ISNULL(goTRYEx)
  poEx = goTRYEx.Clone()
 ENDIF
 LOCAL lEx
 lEx = !ISNULL(goTRYEx)
 ENDTRY()
 RETURN lEx
ENDPROC

PROCEDURE ENDTRY
 gnTRYNestingLevel = gnTRYNestingLevel - 1
 goTRYEx = NULL
 IF gnTRYNestingLevel = 0 
  IF !EMPTY(gcTRYOnError)
   ON ERROR &gcTRYOnError
  ELSE
   ON ERROR
  ENDIF
 ENDIF
ENDPROC

FUNCTION NOEX()
 RETURN ISNULL(goTRYEx)
ENDFUNC

FUNCTION THROW(pcError)
 ERROR (pcError)
ENDFUNC

PROCEDURE tryCatch(pnErrorNo, pcMessage, pcSource, pcProcedure, pnLineNo)
 goTRYEx = CREATE("_Exception")
 WITH goTRYEx
  .errorNo = pnErrorNo
  .Message = pcMessage
  .Source = pcSource
  .Procedure = pcProcedure
  .lineNo = pnLineNo
  .lineContents = pcSource
 ENDWITH
ENDPROC

DEFINE CLASS _Exception AS Custom
 errorNo = 0
 Message = ""
 Source = ""
 Procedure = ""
 lineNo = 0 
 Details = ""
 userValue = ""
 stackLevel = 0
 lineContents = ""
 

 PROCEDURE Clone
  LOCAL oEx 
  oEx = CREATEOBJECT(THIS.Class)
  oEx.errorNo = THIS.errorNo
  oEx.MEssage = THIS.Message
  oEx.Source = THIS.Source
  oEx.Procedure = THIS.Procedure
  oEx.lineNo = THIS.lineNo
  oEx.Details = THIS.Details
  oEx.stackLevel = THIS.stackLevel
  oEx.userValue = THIS.userValue
  oEx.lineContents = THIS.lineContents
  RETURN oEx
 ENDPROC
ENDDEFINE


* Collection (Class)
* Implementacion aproximada de la clase Collection de VFP8+
*
* Autor: Victor Espina
* Fecha: Octubre 2012
*
DEFINE CLASS Collection AS Custom

 DIMEN Keys[1]
 DIMEN Items[1]
 DIMEN Item[1]
 Count = 0
 
 PROCEDURE Init(pnCapacity)
  IF PCOUNT() = 0
   pnCapacity = 0
  ENDIF
  DIMEN THIS.Items[MAX(1,pnCapacity)]
  DIMEN THIS.Keys[MAX(1,pnCapacity)]
  THIS.Count = pnCapacity
 ENDPROC
  
 PROCEDURE Items_Access(nIndex1,nIndex2)
  IF VARTYPE(nIndex1) = "N"
   RETURN THIS.Items[nIndex1]
  ENDIF
  LOCAL i
  FOR i = 1 TO THIS.Count
   IF THIS.Keys[i] == nIndex1
    RETURN THIS.Items[i]
   ENDIF
  ENDFOR
 ENDPROC

 PROCEDURE Items_Assign(cNewVal,nIndex1,nIndex2)
  IF VARTYPE(nIndex1) = "N"
   THIS.Items[nIndex1] = m.cNewVal
  ELSE
   LOCAL i
   FOR i = 1 TO THIS.Count
    IF THIS.Keys[i] == nIndex1
     THIS.Items[i] = m.cNewVal
     EXIT
    ENDIF
   ENDFOR
  ENDIF 
 ENDPROC
 
 PROCEDURE Item_Access(nIndex1, nIndex2)
  RETURN THIS.Items[nIndex1]
 ENDPROC
 
 PROCEDURE Item_Assign(cNewVal, nIndex1, nIndex2)
  THIS.Items[nIndex1] = cNewVal
 ENDPROC


 PROCEDURE Clear
  DIMEN THIS.Items[1]
  DIMEN THIS.Keys[1]
  THIS.Count = 0
 ENDPROC
 
 PROCEDURE Add(puValue, pcKey)
  IF !EMPTY(pcKey) AND THIS.getKey(pcKey) > 0
   RETURN .F.
  ENDIF
  THIS.Count = THIS.Count + 1
  IF ALEN(THIS.Items,1) < THIS.Count
   DIMEN THIS.Items[THIS.Count]
   DIMEN THIS.Keys[THIS.Count]
  ENDIF
  THIS.Items[THIS.Count] = puValue
  THIS.Keys[THIS.Count] = IIF(EMPTY(pcKey),"",pcKey)
 ENDPROC
 
 PROCEDURE Remove(puKeyOrIndex)
  IF VARTYPE(puKeyOrIndex)="C"
   puKeyOrIndex = THIS.getKey(puKeyOrIndex)
  ENDIF
  LOCAL i
  FOR i = puKeyOrIndex TO THIS.Count - 1
   THIS.Items[i] = THIS.Items[i + 1]
   THIS.Keys[i] = THIS.Keys[i + 1]
  ENDFOR
  THIS.Items[THIS.Count] = NULL
  THIS.Keys[THIS.Count] = NULL
  THIS.Count = THIS.Count - 1
 ENDPROC

 PROCEDURE getKey(puKeyOrIndex)
  LOCAL i,uResult
  IF VARTYPE(puKeyOrIndex)="N"
   uResult = THIS.Keys[puKeyOrIndex]
  ELSE
   uResult = 0
   FOR i = 1 TO THIS.Count
    IF THIS.Keys[i] == puKeyOrIndex
     uResult = i
     EXIT
    ENDIF
   ENDFOR
  ENDIF
  RETURN uResult  
 ENDPROC

ENDDEFINE


* ADDPROPERTY
* Simula la funcion ADDPROPERTY existente en VFP9
*
PROCEDURE AddProperty(poObject, pcProperty, puValue)
 poObject.addProperty(pcProperty, puValue)
ENDPROC

* EVL
* Simula la funcion EVL de VFP9
*
FUNCTION EVL(puValue, puDefault)
 RETURN IIF(EMPTY(puValue), puDefault, puValue)
ENDFUNC

#ENDIF

#IF VERSION(5) > 600
FUNCTION NOEX
 RETURN .T.
ENDFUNC
#ENDIF
   
   