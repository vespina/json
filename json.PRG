* JSON.PRG
* 100% VFP Json Parser
*
* Version: 1.17
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
*
* CHANGE HISTORY
* Abr 16, 2022  VES     Support for NQInclude to automatically download any dependencies.
*
* Abr 6, 2022   VES     Nuevos metodos httpRequest() y httpPost(). Refactorizacion del metodo httpGet(). Mejora en
*                       metodo ParseXML() para tolerar el caracter "-" en nombres de nodo o atributos.
*
* May 29, 2019  VES     Se corrigio el problema con el metodo ToCursor (agradecimiento especial a Fernando Puyuelo)
*                       Soporte para mensajes en espanol (por Fernando Puyuelo)
*
* May 6, 2019   AFG     Error en methodo initWithEx de clase JSONError que usaba incorrectamente
*                       el no. de error 1525 para identificar errores de ODBC.
*
* Abr 25, 2017	VES		Nueva propiedad stringSeparator
*
* Jul 20, 2016	VES		Obviar caracters TAB en el analisis
*
* May 16, 2016  VES		Correcciones menores en metodo Stringify
*
* Dec 18, 2015	VES		SingletonPattern class renamed to JSONSingletonPattern
*
* Sep 11, 2015  VES     Improves in stringify method for versions of VFP with no Empty class.
*
* Aug 24, 2015  VES		Improves in parseXml() method to handle repetitive sibling nodes as arrays.
*
* Aug 22, 2015  VES     New improved httpGet() method with XML support
*                       New ParseXml() method
*                       New ToXml() method
*
* Aug 20, 2015  VES		Fix on _parse method for date values handling
*
* Aug 12, 2015	VES		New httpGet() method. Small change in Beautify() method to ensure backward compatibility.
*
* May 30, 2015  VES		Minor fixes on Parse method for constant values like true, false or null
** May 3, 2015	VES		Backward compatibility with previous versions of VFP (6+)
*
* May 2, 2015	VES		Changes in Stringify method to avoid errors while stringifying SCX files content.
*						New property lastOpTime in json class
*						Changes in Stringify, Parse and ParseCursor methods to implement lastOpTime property
*                       Changes in Parse method to support expression values
*
* May 1, 2015	VES		cursorSchemas property on json class renamed to Schemas
*						cursorSchemas class renamed to jsonSchemas
*						New method Create in jsonSchemas class
*						New error (22)
*						Several changes in jsonError class
*						Changed initWithDefault with initWithEx for CATCH error handling
*
* Apr 30, 2015  VES		New method toCursor in json class
*                       New method initWithValue in jsonColumn
* 						Changes in jsonColumn constructor
*						New error (21)
*						New optional parameter pnDSID in parseCursor method of json class
*						New optional parameter pnDSID in Stringify method of json class
*						New optional parameter pnDSID in newFromCursor method of jsonScheme class
*
* Apr 10, 2015	VES		New method initWithJSON in jsonSchema
*						Update to ToString method in jsonColumn and jsonSchema to support JSON format
*						Update to Stringify in json class to optional include the schema when stringifying a cursor
*						New method parseCursor in json class
*						New method initWithString in jsonError class
*						New errors (16 to 20)
*						New property useStrictNotation in json class
*
* 2015		    AFG		Multiple changes and fixes.  Schemas implementation.
*
* 2014			VES		Initial version
*

checkForNQInclude()

IF !FILE("vfplegacy.prg") OR !FILE("vfplegacy.h")
	IF NOT NQInclude("vfplegacy") 
		CANCEL
	ENDIF
	MESSAGEBOX("This library requires VFPLEGACY.PRG library wich has been automatically downloaded. Please, erase JSON.FXP file and try again",48,"JSON.PRG")
	CANCEL
ENDIF

#DEFINE VFP_JSON_LANG		        "EN"    && Cambiar a ES para mensajes en espanol
#DEFINE VFP_NOENCODABLE_PROPS		"-controls-controlcount-objects-parent-class-baseclass-classlibrary-parentclass-helpcontextid-whatsthishelpid-top-left-width-height-picture-_customproplist-activecontrol-activeform-forms-"
#DEFINE CRLF 						CHR(13)+CHR(10)

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
	#DEFINE VFP_JSON_BEAUTIFY_MARGIN	2
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


#INCLUDE vfplegacy.h


SET PROCEDURE TO json ADDITIVE
SET PROCEDURE TO vfplegacy ADDITIVE

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
		
	
	PROCEDURE version_access
	 RETURN 1.15
	ENDPROC
	
    
    * Init	(Method)
    * Constructor of Class
    *
    PROCEDURE Init()
      * Add Property for handle of Cursors Schemas
      THIS.Schemas = CREATEOBJECT("jsonSchemas")
      
      * Add Property for handle of jSon Errors
      THIS.lastError = CREATEOBJECT("jsonError")
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
		 IF PCOUNT() < 2
		  pcJSON = ALLTRIM(CHRT(pcJSON, CHR(13) + CHR(10), ""))
		  pnPos = 1
		 ENDIF

	     LOCAL nStarted, oJSON, oEX
	     nStarted = SECONDS()

		 ex = TRY()
	     	oJSON = THIS._Parse(pcJson, pnPos)
	     	
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
		 IF PCOUNT() < 2
		  pcJSON = ALLTRIM(CHRT(pcJSON, CHR(13) + CHR(10), ""))
		  pnPos = 1
		 ENDIF
	     LOCAL nStarted, oJSON
	     nStarted = SECONDS()
	     oJSON = THIS._Parse(pcJson, pnPos)
		 THIS.lastOpTime = SECONDS() - nStarted + IIF(SECONDS() < nStarted, 86400, 0)
		 RETURN oJSON
	    ENDPROC        
    #ENDIF
	HIDDEN PROCEDURE _Parse(pcJSON, pnPos)
	 *	 
	 DO WHILE AT("{ ",pcJSON)<>0
	  pcJson = STRT(pcJSON,"{ ","{")
	 ENDDO

	 DO WHILE AT(" }",pcJSON)<>0
	  pcJson = STRT(pcJSON," }","}")
	 ENDDO
	 
	 DO WHILE AT("[ ",pcJSON)<>0
	  pcJson = STRT(pcJSON,"[ ","[")
	 ENDDO
	 
	 DO WHILE AT(" ]",pcJSON)<>0
	  pcJson = STRT(pcJSON," ]","]")
	 ENDDO	 
	 
	 
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
	 THIS.lastError.hasError = .F.

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
	          
	     CASE nMode = 1 AND !THIS.isAlpha(cChar) AND !ISDIGIT(cChar) AND !INLIST(cChar,":",SPACE(1),cStringSep)  && Invalid char in property mode
	          THROW(VFP_JSON_MSG_013 + " (" + SUBSTR(pcJSON, i - 10, 10) + " -->" + cChar + "<-- " + SUBSTR(pcJSON,i+1,20) + ") " + TRANSFORM(lIsString,"") + " " + TRANSFORM(uBuff,""))
	          
	     CASE  !INLIST(cChar, cStringSep, ":", SPACE(1)) AND nMode = 1  && Property name
	          uBuff = uBuff + cChar
	          
	     CASE cChar = ":" AND nMode = 1   && Close property name
	          cProp = ALLTRIM(uBuff)
	          uBuff = ""
	          nMode = 2
	          lIsString = .F.
	          lExprMode = .F.
	          lVarMode = .F.	          
	          IF cProp = "codlts"
	            *SET STEP ON 
	          ENDIF
	          	          
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
	          uBuff = IIF(AT(".",uBuff) = 0, INT(VAL(uBuff)), VAL(uBuff))
	   ENDCASE
	   IF lIsArray
	    oTarget.Add(uBuff)
	    uBuff = ""
	    nMode = 2	    
	   ELSE
	    IF !EMPTY(cProp)	     
	     ADDPROPERTY(oTarget, cProp, uBuff)
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
 	 IF !EMPTY(pnDSID)
 	  SET DATASESSION TO (pnDSID)
 	 ENDIF	 
	 
	 * An array is:
	 * a) An object with a baseClass equal to "Collection" and a Count property [1]
	 * b) An array
	 *
	 * [1] The Count property verification is required to avoid an error when stringifing SCX files as cursors, because SCX
	 *     doesn contains a BASECLASS column and could contains Collection objets, wich would be wrongly tested as "array".
	 lIsArray = ((cType = "O" AND PEMSTATUS(puObjectOrAlias,"baseClass",5) AND ;
	                              PEMSTATUS(puObjectOrAlias, "Count", 5) AND ;
	                              PEMSTATUS(puObjectOrAlias, "Item", 5) AND ;
	                              LOWER(puObjectOrAlias.baseClass) == "collection") OR ;
	             (TYPE("ALEN(puObjectOrAlias)") = "N"))
	 
	 DO CASE
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
		     
		CASE cType = "O"   && Object
		     pcOut = pcOut + "{" + CRLF
		     LOCAL ARRAY aElems[1]
		     LOCAL i,nCount,e,uValue
		     nCount = AMEMBERS(aElems, puData, 1)
		     
	     	 #IF VERSION(5) < 800
	     	  LOCAL lEmptyObject,oLine
	     	  lEmptyObject = (LOWER(puData.Class) == "emptyobject")
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
	 
	 * If received a JSON string, parse it first
	 IF VARTYPE(poJSON) = "C"
	  poJSON = THIS.Parse(poJSON)
	  IF THIS.lastError.hasError
 	   THIS.lastOpTime = SECONDS() - nStarted + IIF(SECONDS() < nStarted, 86400, 0)
	   RETURN .F.
	  ENDIF
	 ENDIF
	 
	 * Verify that the object is a collection
	 IF !PEMSTATUS(poJSON, "class", 5) OR LOWER(poJSON.class) <> "collection" OR poJSON.Count = 0 OR VARTYPE(poJSON.Item[1])<>"O"
	  THIS.lastError.initWithString(VFP_JSON_MSG_021, "toCursor")
	  THIS.lastOpTime = SECONDS() - nStarted + IIF(SECONDS() < nStarted, 86400, 0)
	  RETURN .F.
	 ENDIF
	 
	 * Change the datasession (if needed)
	 IF !EMPTY(pnDSID)
	  SET DATASESSION TO (pnDSID)
	 ENDIF
	 
	 * Determine the cursor structure by analizing the first element
	 LOCAL oRow,nCount,i,cProp,uValue,oSchema,oColumn,oObjProps
	 LOCAL ARRAY aProps[1]
	 oRow = poJSON.Item[1]
	 oSchema = CREATEOBJECT("jsonSchema")
	 oObjProps = CREATEOBJECT("Collection")
	 nCount = AMEMBERS(aProps, oRow, 0)
	 FOR i = 1 TO nCount
	  cProp = LOWER(aProps[i])
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
	       oHTTP = CREATEOBJECT("MSXML2.XMLHTTP")
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
		    oHTTP.open(pcVerb, pcUrl, .F.)
		    IF NOEX() AND INLIST(UPPER(pcVerb),"POST","PUT") AND !EMPTY(puData)
		    	oHTTP.setRequestHeader("Content-Type", "application/json")
		    	oHTTP.setRequestHeader("Content-Length", LEN(puData))
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
				DO WHILE oHTTP.readyState<>4 OR (SECONDS() - nTimeout) > 15
				  DOEVENTS
				ENDDO
				IF oHTTP.readyState = 4 
					oResult.statusCode = oHTTP.status
					cResponse = oHTTP.responseText()
					oResult.Headers = oHTTP.getAllResponseHeaders()
					oResult.contentType = oHTTP.getResponseHeader("Content-Type")
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
			 cText = .name + " " + .type + IIF(.type = "C", "(" + ALLT(STR(.long)) + ")",;
			                               IIF(.type $ "NF", "(" + ALLT(STR(.long)) + "," + ALLT(STR(.dec)) + ")",;
			                               IIF(.type = "B", "(" + ALLT(STR(.dec)) + ")", "")))
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


	
PROCEDURE checkForNQInclude
   IF NOT FILE("nqinclude.prg")
      STRTOFILE(httpGetFile("https://raw.githubusercontent.com/vespina/nqinclude/main/nqinclude.prg"),"nqinclude.prg")
      IF NOT FILE("nqinclude.prg")
         MESSAGEBOX("This library requires NQINCLUDE.PRG wich could not be downloaded at this time",48)
         CANCEL
      ENDIF
   ENDIF
   RETURN

PROCEDURE httpGetFile(pcUrl)
   pnTimeout = IIF(VARTYPE(pnTimeOut)<>"N",15,pnTimeout) 	
   LOCAL oHTTP
   oHTTP = CREATEOBJECT("MSXML2.XMLHTTP")
   oHTTP.open("GET", pcUrl, .F.)
   oHTTP.Send()
   LOCAL nTimeOut
   nTimeout = SECONDS()
   DO WHILE oHTTP.readyState<>4 OR (SECONDS() - nTimeout) > 15
      DOEVENTS
   ENDDO
   IF oHTTP.readyState <> 4 OR !BETWEEN(oHTTP.status,200,299)
      RETURN ""
   ENDIF 
   RETURN oHTTP.responseText()