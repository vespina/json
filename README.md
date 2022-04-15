# JSON.PRG
**100% VFP Json Parser & Utilities**

Version: 1.16

Author: V. Espina / A. Ferreira

----

### BASIC USAGE

#### Load the library
Simplt addd this code at the begining of your main program:

    DO json
    
#### To parse a JSON string
    LOCAL oPerson
    oPerson = JSON.Parse('{ "firstName": "Victor", "lastName": "Espina", "YOB": 1970 }')
    IF JSON.lastError.hasError
      ?JSON.lastError.Message
      RETURN
    ENDIF
    ?oPerson.firstName --> "Victor"
    
#### To convert an object into a JSON string
    LOCAL oPerson,cPerson
    oPerson = CREATE("Empty")
    ADDProperty(oPerson, "firstName", "Victor")
    ADDProperty(oPerson, "lastName", "Espina")
    ADDProperty(oPerson, "YOB", 1970)
    
    cPerson = JSON.Stringify(oPerson)
    ?cPerson -> '{ "firstName" : "Victor", "lastName": "Espina", "YOB": 1970 }'

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
*
* May 3, 2015	VES		Backward compatibility with previous versions of VFP (6+)
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
