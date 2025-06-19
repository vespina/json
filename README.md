# JSON.PRG
**100% VFP Json Parser & Utilities**

Version: 1.34

Author: V. Espina / A. Ferreira

----

### BASIC USAGE

#### Load the library
Just add this code at the beginning of your main program:

    DO json
    
This will create a public object called JSON that you can use to perform many JSON-related tasks. If you prefer
to use local instances, then you can instantiate the class this way:

    LOCAL oJSON
    oJSON = CREATEOBJECT("JSON")
    
     
#### To parse a JSON string
    LOCAL oPerson
    oPerson = JSON.Parse('{ "firstName": "Victor", "lastName": "Espina", "YOB": 1970 }')
    IF JSON.lastError.hasError
      ?JSON.lastError.Message
      RETURN
    ENDIF
    ?oPerson.firstName --> "Victor"
    
*IMPORTANT*
Numeric properties will be parsed with an "_" prefix, since VFP does not support property names starting with numbers.    
    
#### To convert an object into a JSON string
    LOCAL oPerson,cPerson
    oPerson = CREATE("Empty")
    ADDProperty(oPerson, "firstName", "Victor")
    ADDProperty(oPerson, "lastName", "Espina")
    ADDProperty(oPerson, "YOB", 1970)
    
    cPerson = JSON.Stringify(oPerson)
    ?cPerson -> '{ "firstname" : "Victor", "lastname": "Espina", "yob": 1970 }'

*IMPORTANT*
Properties casing on the object will not be preserved into the JSON string. All properties will be added as lowercase. This is a VFP limitation.
    
#### To convert an array into a JSON string
    LOCAL ARRAY aFruits[3]
    aFruits[1] = "Apple"
    aFruits[2] = "Orange"
    aFruits[3] = "Pear"
    LOCAL cFruits
    cFruits = JSON.stringify(@aFruits)
    ?cFruits -> '["Apple","Orange","Pear"]'
    
#### To beautify a JSON object or string
    ?JSON.Beautify('{ "firstName" : "Victor", "lastName": "Espina", "YOB": 1970 }')
    --> {
          "firstName": "Victor",
          "lastName": "Espina",
          "YOB: 1970
        }
        
### ERROR HANDLING
The library uses a singleton class to handle errors in all classes, so any error ocurred anywhere in the library
can be checked using json.lastError object:


    IF json.lastError.hasError   && Something went wrong
      ?"Error #", json.lastError.errorNo
      ?"Message", json.lastError.Message
      ?"Procedure", json.lastError.Procedure
      ?"Line #", json.lastError.lineNo
      ?"Details", json.lastError.Details
    ENDIF


### NEW FAST PARSER MODE
If you need to parse a large JSON string, you can now activate a fast parser mode that will parse
the JSON much more faster than using the normal VFP-based parser. To activate this mode, just add this
command before the call to the Parse method:

    JSON.useFastParser = .T.
    
By default, the result obtained from fast parsing is a JS object that is automatically converted to 
foxpro objects to normalize the result between normal and fast parsing, but this adds a small performance
penalty to the process.  To avoid this, and receive the original JS object, set:

    JSON.normalizeResults = .F.
			
			
Take in consideration that JS objects does not behave the same way foxpro objects does. For example, you only can 
iterate on an array's elements using FOR EACH:

    FOR EACH oElem IN jsonData.arrayProperty
       * Here you can access element's properties
    ENDFOR
    
     

### CURSORS HANDLING
JSON library can convert a data cursor into a JSON string representation, optionally
including the cursor schema.  If a cursor is converted to JSON string including the schema
the cursor can be recreated later exactly as it was (using parseCursor).  If no schema was 
added, then cursor can still be recreated, but the library will deduce the schema from 
the cursor data (using toCursor).

    string = JSON.Stringify("alias" [,withSchema] [,datasession]) [8]
    JSON.parseCursor(string [, "alias"] [,datasession]) [1]
    JSON.toCursor(string | object, "alias" [,datasession, options]) [2]

*NEW IN 1.33*
The optional options parameter can be used to supply a custom schema to be used to parse
the cursor (instead of building one automatically from the data):

    LOCAL loOptions
    loOptions = JSON.options()
    loOptions.schema = JSON.schemas.newFromCursor("schema_name", "cursor-alias", datasessionid)
    
    JSON.toCursor("json-string","cursor-alias",[datasessionid],loOptions)
    

### SCHEMAS
Schemas allows to declare public reusable cursor structures (schemas) and 
create empty cursors based on those pre-declared schemas. Schemas are 
based on jsonSchema class, wich can be used directly also for on-the-fly
dinamically cursor creation.
 
    oSchema = JSON.Schemas.New(name) [3]
    oSchema = JSON.Schemas.newFromCursor(name, "alias" [,datasession])
    oSchema = JSON.Schemas.newFromString(name, string) [4]
    bool = JSON.Schemas.Create(cursorName, schemaName [,datasession])
    oSchema = JSON.Schemas.Get(name)
    bool = JSON.Schemas.Exist(name)
    bool = JSON.Schemas.Delete(name)

    bool = oSchema.initWithAlias("alias" [,datasession])
    bool = oSchema.initWithJSON(string) [1]
    bool = oSchema.addColumn(name, type [,lon] [,dec])
    bool = oSchema.addColumn(object) [5]
    bool = oSchema.addColumnFromString(string) [6]
    bool = oSchema.existColumn(name)
    bool = oSchema.delColumn(name)
    string = oSchema.toString([bool]) [7]
    bool = oSchema.toCursor("alias" [,datasession])
 
 
### REST Utilities
The JSON object implements 3 methods that are useful when sending and receiving data to/from a REST-like webservice. 

#### httpGet
This method allows to request information from a webservice that returns information in either JSON or XML format.  In boths cases, the method returns an object that represents the received information:

    LOCAL oResp
    oResp = JSON.httpGet("https://api.agify.io/?name=bella")
    IF NOT oResp.hasError
      ?oResp.JSON.name -> "bella"
      ?oResp.JSON.age -> 37
    ELSE
      ?oResp.errorMsg
    ENDIF
    
The full syntax of *httpGet()* is:

    resp = JSON.httpGet(cUrl [,cContentType] [,cHeaders] [,nTimeout[)
    
Multiple headers can be passed using CRLF to separate them.


#### httpPost
This method allows to send information to a webservice and receive an answert in either JSON or XML format. In boths cases, the method returns an object that represents the received information:

    #DEFINE CRLF  CHR(13)+CHR(10)
    LOCAL oResp,cData,cHeaders
    cData="q=Hello world&target=es&source=en"
    cHeaders = "content-type: application/x-www-form-urlencoded" + CRLF + ;
               "Accept-Encoding: application/gzip" + CRLF + ;
               "X-RapidAPI-Host': google-translate1.p.rapidapi.com" + CRLF + ;
               "X-RapidAPI-Key: SIGN-UP-FOR-KEY" 
               
    oResp = JSON.httpPost("ttps://google-translate1.p.rapidapi.com/language/translate/v2",cData,cHeaders)
    IF NOT oResp.hasError
      ?oResp.JSON.message -> "You are not subscribed to this API"
    ELSE
      ?oResp.errorMsg
    ENDIF

The full syntax of *httpPost()* is:

    resp = JSON.httpPost(cUrl [,uData], [,cContentType] [,cHeaders] [,nTimeout[)
    
Multiple headers can be passed using CRLF to separate them. The *uData* parameter can be an string or an object.


#### httpRequest
This method allows to send any kind of REST request to a webservice and receive an answer in either JSON or XML format.  Both *httpGet()* and *httpPost()* methods calls this method internaly.  The full sytax is:

    resp = JSON.httpRequest(cVerb, cUrl [,uData], [,cHeaders] [,nTimeout[)

where *cVerb* can be any of these:

    GET
    POST
    PUT
    DELETE
    OPTION    
    
The *resp* object contains the following properties:

    headers: string with the complete headers received from the server
    contentType:  content type of the response received
    statusCode: status code received (200, 404, 500, ...)
    raw: raw response received in text format
    json:  response parsed as an JSON or XML object
    hasError:  TRUE if an error ocurred with the request
    errorMsg:  string with the description of the error ocurred during the request
    

### NOTES
[1] The JSON string must be generated using Stringify method and INCLUDE the cursor schema. To convert other JSON strings to cursor, use toCursor().

[2] The JSON string must be an array of objects, ex:
    
    cJSON = '[{fname: "Victor", lname: "Espina", age: 44}, {fname: "Angel", lname: "Ferreira", age: 40}]'
    json.toCursor(cJSON, "qteam")
    SELECT qteam
    SCAN
      ?fname, lname, age
    ENDSCAN

	IF a single object is passed it would be transformed into an array before processing.
	

[3] All schemas has to be identified with an unique name. This name would be used later to access a particular schema, ex:
    
    JSON.Schemas.newFromString("userInfo","login C (25), fullname C (50), pwd C (50), role C (50)")
    ...
    JSON.Schemas.create("quser", "userInfo")
    INSERT INTO quser VALUES ('vespina','Victor Espina','1234','Admin')

[4] Example: 
    
    oSchema = json.Schemas.newFromString("fname C(50), lname C(50), age N (3), dob D")

[5] Object must be an instance of jsonColumn class

[6] Example: 
    
    oSchema.addColumnFromString("lname C (50)")

[7] The optional bool parameters allows to indicate that a JSON string representation of the schema is required

[8] If optional bool parameter withSchema is passed as True, the resulting JSON string will include the cursor's schema. Use this if you plan to recreate the cursor later from the JSON string.


### CHANGE HISTORY

|Date         |User|Description|
|-------------|----|-----------|
|06/19/2025|VES|Version 1.35. Fix for numeric properties (thanks to aless133) |
|02/27/2025|VES|Small fix on fastparse method to avoid program freeze after two consecutives call to fastParse.|
[02/20/2025|VES|Fix for toCursor() method when a row contained other objects. Fix to stringify() method to correctly encode array properties. New encodeHTMLEntities property |
|02/12/2025|VES|Improvements over unescapeHTML method. New options for toCursor method. Support to decode unicode characters|
|02/01/2025|VES|New version 1.33. Force to use our own JSON parser instead the native (if availale). Changes to support version 11 of JSScriptControl included in Windows 11 24H2|
|01/24/2025|VES|New version 1.32. Several small fixed. Lasterror is now initialized on every public method |
|05/10/2024|VES|New version 1.30. New property ignoreInvalidChars |
|04/22/2024|VES|New version 1.29. Fix on httpRequest to get the right value in RAW property for binary responses |
|01/07/2024|VES|New version 1.28. Fix of major bug on HTTPRequest causing any request to take AT LEAST 15s.
|07/31/2023|VES|New version 1.27. Change in ToCursor() method to allow single objects |
|06/21/2023|VES|New version 1.26. Int values greater than VFP's max INT value are now translated as strings |
|04/18/2023|VES|New version 1.25. External dependencies removed to solve a problem caused by nqinclude.prg being blocked for A/V as trojan|
|04/04/2023|VES|New version 1.24. Fix on invalid parameter for AMEMBERS on VFP6 (thanks to Ricardo Mata)|
|02/28/2023|VES|New version 1.23. Fix on timeout management for httpRequest and httpGetFile methdods|
[01/26/2022|VES|New version 1.22. Workaround for TEXT - ENDTEXT bug in VFP6.|
[01/26/2002|VES|Fix on legacy ADDPROPERTY for restricted property names |
[10/01/2022|VES|New version 1.21. Small fix on 	#DEFINE VFP_JSON_BEAUTIFY_MARGIN |
|11/26/2022|VES|Add new normalizeResults property and results-normalizing code for fast parsing|
|11/26/2022|JSZ|Added iterator to JS results when fast parsing|
|11/26/2022|VES|New version 1.20. Fast parse mode implemented |
|11/16/2022 |VES |New version 1.19. Changes to allow access to secured servers|
|10/26/2022 |VES |New version 1.18. Changes on jsonColumn class to support null values |
|5/9/2022  |VES |New version 1.17. Includes fixes on toCursor method for legacy VFP versions.|
|4/16/2022 |VES |Support for NQInclude to automatically download any dependencies.|
|4/6/2022  |VES |Nuevos metodos *httpRequest()* y *httpPost()*. Refactorizacion del metodo *httpGet()*. Mejora en metodo *ParseXML()* para tolerar el caracter "-" en nombres de nodo o atributos.|
|5/29/2019 |VES |Se corrigio el problema con el metodo *ToCursor()* (agradecimiento especial a Fernando Puyuelo) Soporte para mensajes en espanol (por Fernando Puyuelo)|
|5/6/2019  |AFG |Error en methodo *initWithEx()* de clase *JSONError* que usaba incorrectamente el no. de error 1525 para identificar errores de ODBC.|
|4/25/2017 |VES |Nueva propiedad *stringSeparator*|
|7/20/2016 |VES |Obviar caracters TAB en el analisis|
|5/16/2016 |VES |Correcciones menores en metodo *Stringify()*|
|12/18/2015 |VES |*SingletonPattern* class renamed to *JSONSingletonPattern*|
|9/11/2015 |VES |Improves in *Stringify()* method for versions of VFP with no Empty class.|
|8/24/2015 |VES |Improves in parseXml() method to handle repetitive sibling nodes as arrays.|
|8/22/2015 |VES |New improved *httpGet()* method with XML support. New *ParseXml()* method. New *ToXml()* method|
|8/20/2015 |VES |Fix on *_parse()* method for date values handling|
|8/12/2015 |VES |New *httpGet()* method. Small change in *Beautify()* method to ensure backward compatibility.|
|5/30/2015 |VES |Minor fixes on *Parse()* method for constant values like true, false or null|
|5/3/2015  |VES |Backward compatibility with previous versions of VFP (6+)|
|5/2/2015  |VES |Changes in *Stringify()* method to avoid errors while stringifying SCX files content. New property *lastOpTime* in *json* class. Changes in *Stringify()*, *Parse()* and *ParseCursor()* methods to implement *lastOpTime* property. Changes in *Parse()* method to support expression values|
|5/1/2015 |VES |*cursorSchemas* property on *json* class renamed to *Schemas*. *cursorSchemas* class renamed to *jsonSchemas*. New method *Create()* in *jsonSchemas* class. New error (22). Several changes in *jsonError* class. Changed *initWithDefault()* with *initWithEx()* for CATCH error handling|
|4/30/2015 |VES |New method *toCursor()* in *json* class. New method *initWithValue()* in *jsonColumn*. Changes in *jsonColumn* class's constructor. New error (21). New optional parameter *pnDSID* in *parseCursor()* method of *json* class. New optional parameter *pnDSID* in *Stringify()* method of *json* class. New optional parameter *pnDSID* in *newFromCursor()* method of *jsonScheme* class|
|4/10/2015 |VES |New method *initWithJSON()* in *jsonSchema*. Update to *ToString()* method in *jsonColumn* and *jsonSchema* to support JSON format. Update to *Stringif()* in *json* class to optional include the schema when stringifying a cursor. New method *parseCursor()* in *json* class. New method *initWithString()* in *jsonError* class. New errors (16 to 20). New property *useStrictNotation* in *json* class.|
| 2015 |AFG	|Multiple changes and fixes.  Schemas implementation.|
| 2014 |VES	|Initial version

