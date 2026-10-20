/**
 * @description       : 
 * @Test Class        : TEST_AppUtils
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 07-12-2024
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   05-25-2023   Novando Utoyo Agmawan   Initial Version
**/

public with sharing class AppUtils {

    public static string stripJsonNulls(string JsonString)
    { 
        if(JsonString != null)      
        {
            JsonString = JsonString.replaceAll('\"[^\"]*\":null',''); //basic removeal of null values
            JsonString = JsonString.replaceAll(',{2,}', ','); //remove duplicate/multiple commas
            JsonString = JsonString.replace('{,', '{'); //prevent opening brace from having a comma after it
            JsonString = JsonString.replace(',}', '}'); //prevent closing brace from having a comma before it
            JsonString = JsonString.replace('[,', '['); //prevent opening bracket from having a comma after it
            JsonString = JsonString.replace(',]', ']'); //prevent closing bracket from having a comma before it
            
            //'"canBeIndividual":{}'
            JsonString = JsonString.replaceAll('\"[^\"]*\":\\{\\}',''); //basic removeal of null values
            JsonString = JsonString.replaceAll(',{2,}', ','); //remove duplicate/multiple commas
            JsonString = JsonString.replace('{,', '{'); //prevent opening brace from having a comma after it
            JsonString = JsonString.replace(',}', '}'); //prevent closing brace from having a comma before it
            JsonString = JsonString.replace('[,', '['); //prevent opening bracket from having a comma after it
            JsonString = JsonString.replace(',]', ']'); //prevent closing bracket from having a comma before it 
            
            //'"hasAccountDetailsIn":[]'
            JsonString = JsonString.replaceAll('\"[^\"]*\":\\[\\]',''); //basic removeal of null values  
            JsonString = JsonString.replaceAll(',[2,]', ','); //remove duplicate/multiple commas
            JsonString = JsonString.replaceAll(',{2,}', ','); //remove duplicate/multiple commas
            JsonString = JsonString.replace('{,', '{'); //prevent opening brace from having a comma after it
            JsonString = JsonString.replace(',}', '}'); //prevent closing brace from having a comma before it
            JsonString = JsonString.replace('[,', '['); //prevent opening bracket from having a comma after it
            JsonString = JsonString.replace(',]', ']'); //prevent closing bracket from having a comma before it  
            
            
            
        }   
        return JsonString;
    }

/*
    public static Map<String, Object> getObjectDataOnMap(Map<String, Object> m, string keysets) 
    {
        system.debug ('=');
        system.debug ('====== GET KEYSET VALUE');
        system.debug ('====== KEYSETS Name  : ' + keysets );
        List<string> keysetList = keysets.split('::');
    
        Map<String, Object>  mTemp = new Map<String, Object>(); 
        string s='';
        integer i=0;
        for (string keyset : keysetList) {
            //system.debug ('====== Keyset Value ' + keyset );
            if (i < keysetList.size()-1) {
                mTemp = new Map<String, Object>();
                try {
                    if (keyset.contains('[') ) {
                        integer index = integer.valueOf( keyset.substring(keyset.indexOf('[')+1, keyset.indexOf(']') ));
                        List<Object> tmpLo = (List<Object>) m.get(keyset.substring(0,keyset.indexOf('[')) );
                        mTemp = (Map<String, Object>) tmpLo[index];
                    }   
                    else {
                        //system.debug ('====== m value ' + m );
                        boolean b = isCollection(m.get(keyset));
                        //system.debug('===== b :' + b);
                        if (b) {
                            List<Object> tmpLo = (List<Object>) m.get(keyset);
                            mTemp = (Map<String, Object>) tmpLo[0];
                        }
                        else {
                            mTemp = (Map<String, Object>) m.get(keyset);
                        }
                        //system.debug ('====== mTemp value ' + mTemp );
                    }
                } catch (Exception e) {
                    system.debug ('== getStringDataOnMap ERROR get MAP Object (' + keyset + ') :' + e.getMessage());
                    //s='keyset "' + keyset + '" is not found';
                }
                m = mTemp;
            } 
            else {
                try {
                     m = (Map<String, Object>) m.get(keyset);

                } catch (Exception e) {
                    system.debug ('================ getObjectDataOnMap ERROR get MAP Objeect (' + keyset + ') :' + e.getMessage());
                }
            }
            i++;
        }
        //system.debug ('=');
        
        return m ; 
    }    
*/

    public static string getStringDataOnMap(Map<String, Object> m, string keysets) 
    {
        system.debug ('=');
        system.debug ('====== GET KEYSET VALUE');
        system.debug ('====== KEYSETS Name  : ' + keysets );
        List<string> keysetList = keysets.split('::');
    
        Map<String, Object>  mTemp = new Map<String, Object>(); 
        string s='';
        integer i=0;
        for (string keyset : keysetList) {
            //system.debug ('====== Keyset Value ' + keyset );
            if (i < keysetList.size()-1) {
                mTemp = new Map<String, Object>();
                try {
                    if (keyset.contains('[') ) {
                        integer index = integer.valueOf( keyset.substring(keyset.indexOf('[')+1, keyset.indexOf(']') ));
                        List<Object> tmpLo = (List<Object>) m.get(keyset.substring(0,keyset.indexOf('[')) );
                        mTemp = (Map<String, Object>) tmpLo[index];
                    }   
                    else {
                        //system.debug ('====== m value ' + m );
                        boolean b = isCollection(m.get(keyset));
                        //system.debug('===== b :' + b);
                        if (b) {
                            List<Object> tmpLo = (List<Object>) m.get(keyset);
                            mTemp = (Map<String, Object>) tmpLo[0];
                        }
                        else {
                            mTemp = (Map<String, Object>) m.get(keyset);
                        }
                        //system.debug ('====== mTemp value ' + mTemp );
                    }
                } catch (Exception e) {
                    system.debug ('== getStringDataOnMap ERROR get MAP Object (' + keyset + ') :' + e.getMessage());
                    //s='keyset "' + keyset + '" is not found';
                }
                m = mTemp;
            } 
            else {
                try {
                    //Object oo = m.get(keyset);
                    //s = (string) oo.;
                    if (m.containsKey(keyset)) {
                        s = (string) String.valueOf (m.get(keyset));
                        system.debug ('================ GET : ' + keyset + ' <-- ' + s);
                    
                    } else { //s='keyset "' + keyset + '" is not found';
                        system.debug ('== Keyset NOT found  : (' + keyset + ') ## Keysets : ' + keysets ); 
                        s = '== Keyset NOT found ==';
                        }
                    
                    //system.debug ('================ CHECK VALUE OF MAP  ('+ keyset + ': ' + s + ') (m: ' + m + ') (m.get(keyset): ' + m.get(keyset)  + ')'  );
                } catch (Exception e) {
                    system.debug ('================ getStringDataOnMap ERROR get MAP String (' + keyset + ') :' + e.getMessage());
                }
            }
            i++;
        }
        //system.debug ('=');
        
        return s ; 
    }    
    
    public static List<Object> getListDataOnMap(Map<String, Object> m, string keysets) {
        system.debug ('=');
        system.debug ('====== GET LIST OBJECT');
        system.debug ('====== KEYSETS Name  : ' + keysets );
        
        List<string> keysetList = keysets.split('::');
    
        Map<String, Object>  mTemp = new Map<String, Object>(); 
        List<Object> lo = null;
        
        integer i=0;
        for (string keyset : keysetList) {
            
            if (i < keysetList.size()-1) {
                mTemp = new Map<String, Object>();
                try {
                    if (keyset.contains('[') ) {
                        system.debug('ini');
                        integer index = integer.valueOf( keyset.substring(keyset.indexOf('[')+1, keyset.indexOf(']') ));
                        //system.debug('===== index :' + index);
                        
                        List<Object> tmpLo = (List<Object>) m.get(keyset.substring(0,keyset.indexOf('[')) );
                        //system.debug('===== tmpLo :' + tmpLo +' ' + keyset.substring(0,keyset.indexOf('[') ));
                        
                        mTemp = (Map<String, Object>) tmpLo[index];
                        //system.debug('===== mTemp :' + mTemp);
                    }
                    else {
                        boolean b = isCollection(m.get(keyset));
                        //system.debug('===== b :' + b);
                        if (b) {
                            List<Object> tmpLo = (List<Object>) m.get(keyset);
                            mTemp = (Map<String, Object>) tmpLo[0];
                        }
                        else {
                            mTemp = (Map<String, Object>) m.get(keyset);
                        }
                    }
                } catch (Exception e) {
                    system.debug ('================ getListDataOnMap ERROR get MAP Object (' + keyset + ') :' + e.getMessage());
                }
                m = mTemp;
            } 
            else {
                try {
                    if (m.containsKey(keyset)) {
                        //s = (string) String.valueOf (m.get(keyset));
                        lo = (List<Object>) m.get(keyset);
                        system.debug ('================ GET : ' + keyset + ' <-- ' + lo);
                    
                    } else {system.debug ('== Keyset NOT found  : (' + keyset + ') ## Keysets : ' + keysets ); }
                    
                } catch (Exception e) {
                    system.debug ('================ getListDataOnMap ERROR get MAP Object List (' + keyset + ') :' + e.getMessage());
                }
            }
            i++;
        }
        return lo ; 
    }
    
    public static Boolean isCollection(Object input)
    {
        object test;
        try{
           test = (List<Object>)input;
           return true;
        }
        catch(System.TypeException ex)
        {
            String message = ex.getMessage();
            //system.debug ('============= message :' + message );
            //if (message.contains('Set<') || message.contains('Map<'))
            //    return true;
                
            return false;
        }
        
        
        //return false;
    }    
   
    public static Date strToDate(string s, string f){ 
        string dd;
        string mm;
        string yyyy;
        date d=null;
        
        s = s.trim();
        
        try {
            if (f==''){
                s = s.replaceAll('-','').replaceAll('/', '').replaceAll('\\.', '');
                f = 'yyyymmdd';
            }
                
            if (f=='yyyy-mm-dd'){
                s = s.replaceAll('-','');
                f = 'yyyymmdd';
            }
        
        
            if (f=='yyyymmdd'){
                if (s != '' &&  s!=null) {
                    dd = s.substring(6,8);
                    mm = s.substring(4,6);
                    yyyy = s.substring(0,4);
                    try {
                        d = Date.newInstance(integer.valueOf(yyyy), integer.valueOf(mm), integer.valueOf(dd) );
                    }
                    catch(Exception e) {
                        d = null;
                        system.debug ('============= strToDate message1 : ' + e.getMessage() );
                    }
                }
                else {
                    dd = '01';
                    mm = '01';
                    yyyy = '1900';
                    d = null;
                }
            }
            if (f=='yyyy/mm/dd'){  ///persiapan !!!
                if (s != '' &&  s!=null) {
                    dd = s.substring(6,8);
                    mm = s.substring(4,6);
                    yyyy = s.substring(0,4);
                    try {
                        d = Date.newInstance(integer.valueOf(yyyy), integer.valueOf(mm), integer.valueOf(dd) );
                    }
                    catch(Exception e) {
                        d = null;
                        system.debug ('============= strToDate message1 : ' + e.getMessage() );
                    }
                }
                else {
                    dd = '01';
                    mm = '01';
                    yyyy = '1900';
                    d = null;
                }
            }
                        
        }
        catch(Exception e) {
                    d = null;
                    system.debug ('============= strToDate message2 : ' + e.getMessage() );
                }
                
        return d;       
    } 
    public static DateTime strToDateTime (string s, string f){ 
        string dd;
        string mm;
        string yyyy;
        string hh;
        string nn;
        string ss;
        
        
        DateTime d=null;
        //system.debug('==test s: '+ s);
        //system.debug('==test f: '+ f);
        
        s = s.trim();
        
        try {
            if (f==''){
                s = s.replaceAll('-','').replaceAll('/', '').replaceAll('\\.', '');
                f = 'yyyymmdd';
            }
                
            if (f=='yyyy-mm-dd'){
                s = s.replaceAll('-','');
                f = 'yyyymmdd';
            }
            
            if (f=='yyyymmdd'){
                if (s != '' &&  s!=null) {
                    dd = s.substring(6,8);
                    mm = s.substring(4,6);
                    yyyy = s.substring(0,4);
                    try {
                        d = DateTime.newInstance(integer.valueOf(yyyy), integer.valueOf(mm), integer.valueOf(dd) );
                        //DateTime myDateTime = DateTime.newInstance(1997, 1, 31, 7, 8, 16)
                    }
                    catch(Exception e) {
                        d = null;
                        system.debug ('============= strToDateTime message1 : ' + e.getMessage() );
                    }
                }
                else {
                    dd = '01';
                    mm = '01';
                    yyyy = '1900';
                    d = null;
                }
            }
            else if (f=='yyyy-mm-dd hh:mm:ss') {
                if (s != '' &&  s!=null) {
                    yyyy = s.substring(0,4);
                    mm = s.substring(5,7);
                    dd = s.substring(8,10);
                    
                    hh = s.substring(11,13);
                    nn = s.substring(14,16);
                    ss = s.substring(17,19);
                    
                    system.debug('==full datetime : '+ s);
                    system.debug('==part of datetime : '+ yyyy + '::'+ mm + '::'+ dd + '::'+ hh + '::'+ nn + '::'+ ss + '::');
                    
                    
                    try {
                        d = Datetime.newInstance(integer.valueOf(yyyy), integer.valueOf(mm), integer.valueOf(dd), integer.valueOf(hh), integer.valueOf(nn), integer.valueOf(ss) );
                        system.debug('==test d1: '+ d);     
                    }
                    catch(Exception e) {
                        d = null;
                        system.debug ('============= strToDateTime message2 : ' + e.getMessage() );
                    }
                }
                else {
                    dd = '01';
                    mm = '01';
                    yyyy = '1900';
                    d = null;
                }
            }
            else if (f=='yyyymmddhhmmss') {
                if (s != '' &&  s!=null) {
                    yyyy = s.substring(0,4);
                    mm = s.substring(4,6);
                    dd = s.substring(6,8);
                    
                    hh = s.substring(8,10);
                    nn = s.substring(10,12);
                    ss = s.substring(12,14);
                    
                    system.debug('==full datetime : '+ s);
                    system.debug('==part of datetime : '+ yyyy + '::'+ mm + '::'+ dd + '::'+ hh + '::'+ nn + '::'+ ss + '::');
                    
                    
                    try {
                        d = Datetime.newInstance(integer.valueOf(yyyy), integer.valueOf(mm), integer.valueOf(dd), integer.valueOf(hh), integer.valueOf(nn), integer.valueOf(ss) );
                        system.debug('==test d1: '+ d);     
                    }
                    catch(Exception e) {
                        d = null;
                        system.debug ('============= strToDateTime message2 : ' + e.getMessage() );
                    }
                }
                else {
                    dd = '01';
                    mm = '01';
                    yyyy = '1900';
                    d = null;
                }
            }
        }
        catch(Exception e) {
                    d = null;
                }
        system.debug('==test d2: '+ d);     
        return d;       
    } 
    
    public static string birthToAge(Date birthDate){ 
        
        if (birthDate == null) return null;
        else {
            Age a = new Age(birthDate);
            //return  a.years  + ' years, ' + a.months + ' months ' ;
            return  a.years  + ' years';
        }
        
    }
    
    public class Age {
        public integer years ;
        public integer months ;
        public integer days ;
        
        public Age(Date birthDate){
            //long r = null;
            //r = (long.valueOf(Date.TODAY()) - long.valueOf(birthDate)) ;
            
            //long r = birthDate.daysBetween(Date.Today());
            integer r = birthDate.daysBetween(Date.Today());
            
            //long dy = (long) 365.2425;
            
            //years  = FLOOR( r / dy ); 
            //months = FLOOR( MOD(r , dy ) /30) ;
            //days   = Floor( MOD( Floor( MOD( r, dy )),30)) ;
            
            //years  = FLOOR( (decimal) r / 365.2425 );
            
            /*
            years  = (integer) math.floor( (r/3652425) * 1000);
            months = (integer) math.floor( (math.mod(r , 3652425 ) /30)  * 1000) ;
            */
            
            DateTime start_date_time;
            DateTime end_date_time;
             
            start_date_time = birthDate;
            end_date_time = Date.Today();
            
            Integer start_year_as_int = start_date_time.year(); //grab the start year
            Integer start_day_as_int = start_date_time.dayOfYear(); //grab the start day
            Integer start_hour_as_int = start_date_time.hour(); //grab the start hour
            Integer start_minute_as_int = start_date_time.minute(); //grab the start minute
            Integer start_second_as_int = start_date_time.second(); //grab the start second
            Integer start_in_seconds = (start_year_as_int * 31556926) + (start_day_as_int * 86400) + (start_hour_as_int * 3600) + (start_minute_as_int * 60) + (start_second_as_int * 1); //convert the start date to a value in seconds
            //there are 31556926 seconds in one year and that is why we are mutiplying the start_year_as_int value by 31556926 > this same logic applies to the days, hours & minutes logic which is why there are weird multipliers in that line of code
            Integer end_year_as_int = end_date_time.year(); //grab the end year
            Integer end_day_as_int = end_date_time.dayOfYear(); //grab the end day
            Integer end_hour_as_int = end_date_time.hour(); //grab the end hour
            Integer end_minute_as_int = end_date_time.minute(); //grab the end minute
            Integer end_second_as_int = end_date_time.second(); //grab the end second
            Integer end_in_seconds = (end_year_as_int * 31556926) + (end_day_as_int * 86400) + (end_hour_as_int * 3600) + (end_minute_as_int * 60) + (end_second_as_int * 1); //convert the end date to a value in seconds
            
            Integer total_duration_in_seconds = end_in_seconds - start_in_seconds; //duration in seconds
            Integer year_result = math.mod(math.floor(total_duration_in_seconds/31556926).intValue(),10000000); //number of years
            
            years = year_result;
            
             
        }
        
        //IF(ISNULL(DateofBirth__c),"",TEXT(FLOOR((TODAY()-DateofBirth__c)/365.2425)) & " year's " & TEXT(FLOOR(MOD((TODAY()-DateofBirth__c),365.2425)/30)) & " Month's " & Text(Floor(MOD(Floor(MOD((TODAY()-DateofBirth__c),365.2425)),30))) & " Day's ",
//NULL

    }
    
    public static decimal strToDec(string s){ 
        decimal d=null;
        s = s.trim();
        try {
            d = (s==null || s=='') ? null: (decimal) decimal.valueOf(s);
        }
        catch(Exception e) {
            d = null;
            system.debug ('============= strToDec message : ' + e.getMessage() );
        }
        return d;
    }   
    
    
    public static string getNewGUID() 
    {
        // Generate GUID
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        system.debug('========= guid :' + guid);
        
        return guid;
    }   

    public static string getUniqueNumber(){
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        String h = hexDigest ;
        //String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        //hexDigest  = hexDigest + ' * ' + guid ;
        
        system.debug('##########' + hexDigest );        
        return hexDigest;
    }
    
    public static string getSessionID() {
         return  UserInfo.getUserId() +'-' + Datetime.now().format('yyyyMMdd') +'-'+ AppUtils.getUniqueNumber();
    }
 /*   
  public static String randomStringAll(Integer count) {
      Integer[] chars = new Integer[0],  
          offsets = new Integer[] { 48, 65, 97 },
              mods = new Integer[] { 10, 26, 26 };
  
      while(count > chars.size()) {
          Integer cat = Math.abs(Math.mod(Crypto.getRandomInteger(),3));
          chars.add(Math.mod(Math.abs(Crypto.getRandomInteger()), mods[cat])+offsets[cat]);
      }
      return String.fromCharArray(chars);
  }     
 */   
    
    public static Map<String, Object> getMapPackageFromJSON (string jsonStr){
        Map<String, Object> mapWS = new Map<String, Object>();
            
        try {
            // deserializeUntyped to mapData
            Map<String, Object> mapData = (Map<String, Object>) JSON.deserializeUntyped(jsonStr); 
            String status= AppUtils.getStringDataOnMap(mapData, 'Body::status');    
            String service = AppUtils.getStringDataOnMap(mapData, 'Body::service');     
            String operation = AppUtils.getStringDataOnMap(mapData, 'Body::operation');     
            String appID = AppUtils.getStringDataOnMap(mapData, 'Body::appID');     
            String entity = AppUtils.getStringDataOnMap(mapData, 'Body::entity');   
            String transactionId = AppUtils.getStringDataOnMap(mapData, 'Body::transactionId');     
            String exceptionMessage ='';
            String exceptionBackEndError ='';
            String exceptionCode ='';
            
            
            if (status=='0') {
                  exceptionMessage = AppUtils.getStringDataOnMap(mapData, 'Body::exception::message');
                  exceptionBackEndError = AppUtils.getStringDataOnMap(mapData, 'Body::exception::backEndError');
                  exceptionCode = AppUtils.getStringDataOnMap(mapData, 'Body::exception::code');
            }   
            
            
            mapWS.put('status', status);
            mapWS.put('exceptionMessage', exceptionMessage);
            mapWS.put('exceptionBackEndError', exceptionBackEndError);
            mapWS.put('exceptionCode', exceptionCode);
            mapWS.put('service', service);
            mapWS.put('operation', operation);
            mapWS.put('appID', appID);
            mapWS.put('entity', entity);
            mapWS.put('transactionId', transactionId);
            mapWS.put('mapData', mapData);  
            mapWS.put('jsonStr', jsonStr);      
        } 
        catch (Exception e) {
            mapWS.put('status', '-1');    // <<-- error on deserializeUntyped
            mapWS.put('mapData', 'null');
            mapWS.put('jsonStr', jsonStr);
            system.debug('============ error on try deserializeUntyped :' + e.getMessage());
        }
        
        return mapWS;
    }
    
    
    public static Datetime addHours(Datetime l, integer h)
    {    
         return l.addHours(h);
    }    
    
    public static decimal getDecimalOrNull (string value) {
        return  (value==null || value=='') ? null: (decimal) decimal.valueOf( value);               
    } 
    
    public static string getStringOrNull (string value) {
        return  (value==null) ? null: (string) value;               
    } 
    
    
    /*public static Boolean listContains(Object[] source, Object target) {
      return (new Set<Object>(source)).contains(target);
    }*/
  
    
    public static Boolean isKeysetNotFound (string s) {
        return (s == '== Keyset NOT found ==') ? true : false;
    }
    
    
    
    //-----
/*    
public static String create_multi_param (String boundary, String name, String val) {
    String param = '-' + boundary + '\r\n'
    + 'Content-Disposition: form-data; name = "' + name + '"'
    + '\r\n\r\n' + val + '\r\n';
    return param;
}


    
    public static void testconntransdb() {

// Body
String boundary = '------------' + String.valueOf (DateTime.now().GetTime());
String body = '';
//body + = this.create_multi_param (boundary, 'grant_type', 'password');
//body + = this.create_multi_param (boundary, 'name', '[sample]');
//body + = this.create_multi_param (boundary, 'client_id', '[sample]');
//body + = this.create_multi_param (boundary, 'client_secret', '[sample]');
body  = body + create_multi_param (boundary, 'username', 'apidemo');
body  = body + create_multi_param (boundary, 'password', 'password*1');
body  = body + '--' + boundary + '--\r\n';
System.debug ('================= body : ' + body);


Http http = new Http ();
HttpRequest req = new HttpRequest ();
req.setHeader ('Cache-Control', 'no-cache');
req.setHeader ('Content-Length', String.valueOf (body.length ()));
req.setHeader ('Content-Type', 'multipart / form-data; boundary =' + body);

string param='?username=apidemo&password=password*1';

req.setEndpoint ('https://easy-ops.xl.co.id/dev/api/auth/token' + param);
req.setBody (body);
req.setMethod ('POST');
HttpResponse res = http.send (req);
System.debug ('================= response message : ' + res.getBody ());

    }
    
    */
    



    // encrypt
    Public static string doEncrypt (string s) {
        String encryptName;

        try {
            Blob cryptoKey = Blob.valueOf('380db410e8b11fa9');
            Blob data = Blob.valueOf(s);
            Blob encryptedData = Crypto.encryptWithManagedIV('AES128', cryptoKey , data );
            String b64Data = EncodingUtil.base64Encode(encryptedData);
            encryptName = b64Data ;
        }
        catch (Exception e) {
            putError('Error on doEncrypt function::' + e.getmessage() + '::' + e.getLineNumber()  );
            encryptName='failed:' + e.getmessage();
        }
        
        System.debug('============= Printing encryptName :  '+encryptName);
        return encryptName;
    }

    // decrypt
    Public static string doDecrypt (String s) {
        String dryptData;

        try {
            Blob cryptoKey = Blob.valueOf('380db410e8b11fa9');
            Blob data = EncodingUtil.base64Decode(s);
            Blob decryptedData = Crypto.decryptWithManagedIV('AES128', cryptoKey , data);
            dryptData = decryptedData.toString();
        }
        catch (Exception e) {
            putError('Error on doDecrypt function::' + e.getmessage() + '::' + e.getLineNumber()  );
            dryptData='failed:' + e.getmessage();
        }

        System.debug('============= Printing dryptData '+dryptData);   
        return dryptData; 
    }

    public static void putError(string errString) {
        /* note::message::linenumber 
         * 0 : notes 
         * 1 : message
         * 2 : linenumber
         * ...
         */
        List<Log_Error__c> tmpLogErrors = new List<Log_Error__c>();
        Log_Error__c tmpLogError = new Log_Error__c();

        List<string> ss = errString.split('::');
        integer index = 0;
        for (String s: ss) {
            if (index == 0) { tmpLogError.notes__c = s; }
            if (index == 1) { tmpLogError.message__c = s; }
            if (index == 2) { tmpLogError.line_number__c = integer.valueof(s); }

            index=index+1;
        }
        try  {
            tmpLogErrors.add (tmpLogError);
            insert tmpLogErrors;
        } catch (Exception e) {
            string errMessage = e.getmessage() + ' - error line : '  + e.getLineNumber() ;
            //
        }

    }

/*
    public static string getToken(string endpoint, string username, string password, Integer type) {
        String token = '';
        String body = '';
        
        Call_Log__c calllog = new Call_Log__c();
        calllog.type__c='Callout';
        calllog.method__c='POST';
        calllog.request_start_time__c = datetime.now();
        
        if (type == 1) {
            body =  'username=' + username + '&password=' + password ; //'username=apidemo&password=password*1';
        }

        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setbody(body);
        req.setHeader('Accept', 'application/json');

        Http http = new Http();
        HTTPResponse response = new HTTPResponse() ;

        
        if (!Test.isRunningTest()) {
          http = new Http();
          response = http.send(req);
          
          try {
              System.debug ('================= response message : ' + response.getBody ());
              Map<String,Object> responsemap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody ());
              
              token = (string) responsemap.get('token');
              System.debug ('================= response token : ' + responsemap.get('token') );
              System.debug ('================= response message : ' + response.getBody ());         
  
              if (! isKeysetNotFound(token) ) {
                  calllog.status__c = 'Success';
              } else {
                  calllog.status__c = 'Failed';
                  token = 'failed'; 
              }
          } catch (Exception e) {
              token ='failed';
              putError('Error on getToken function::' + e.getmessage() + '::' + e.getLineNumber()  );
              
              calllog.request_message__c = body;
            if (!Test.isRunningTest()) {
              calllog.response_message__c = response.getBody ();
            }
            
            //calllog.uri__c = req.requestURI;        
            calllog.callerFrom__c = 'salesforce' ; 
            calllog.endpoint__c = endpoint ; // currentRequestURL.replace (calllog.uri__c,'');
            calllog.response_end_time__c = datetime.now();     
            insert calllog;
          }
          
        }
        //-- PUT callout information then save the data on Call_Log object          
        calllog.request_message__c = body;
        if (!Test.isRunningTest()) {
          calllog.response_message__c = response.getBody ();
        }
        //calllog.uri__c = req.requestURI;        
        calllog.callerFrom__c = 'salesforce' ; 
        calllog.endpoint__c = endpoint ; // currentRequestURL.replace (calllog.uri__c,'');
        calllog.response_end_time__c = datetime.now();     
        //insert calllog;

        return token;
    } 
 */


    //fungsirandomstring
    public static string fungsirandom()
    { 
        final String chars = '0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < 5) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }

    //getfileprivyid
    public static List<ContentVersion> getPrivyFilesOnBase64(String recordID) {    

        //------ get base64 attachment files on opportunity
        try {
            List<ContentDocumentLink>
                attachments = [SELECT ContentDocumentId, ContentDocument.title, LinkedEntityId, ShareType, Visibility
                            FROM ContentDocumentLink WHERE LinkedEntityId = :recordID] ; //'0065D000003MGBE'];

            List<string> cdIDs = new List<string>();
            for (ContentDocumentLink att : attachments) {
                cdIDs.add (att.ContentDocumentId);
            }             

            system.debug('=========== cdIDs : ' + cdIDs);      

            list <contentdocument> 
                cds= [select id, LatestPublishedVersionId 
                        from contentdocument where
                        id in :cdIDs];

            List<string> lpvIDs = new List<string>();
            for (ContentDocument cd : cds) {
                lpvIDs.add (cd.LatestPublishedVersionId);
            }             
            system.debug('=========== lpvIDs : ' + lpvIDs);
            
                  
            String searchString = '%' + Label.keyword_privydid+ '%';
            list <contentversion> 
                cvs = [select id, Checksum, ContentDocumentId
                            , ContentLocation, ContentModifiedById
                            , ContentModifiedDate, ContentSize, ContentUrl, Description
                            , ExternalDataSourceId, ExternalDocumentInfo1
                            , ExternalDocumentInfo2, 
                            title, VersionData, VersionNumber
                        from contentversion 
                        where ID in :lpvIDs and title LIKE :searchString];

            system.debug('=========== cvs : ' + cvs);  
            for (ContentVersion cv : CVs) {
                system.debug('=========== title : ' + cv.title 
                    + '. Body :' 
                    + EncodingUtil.base64Encode(cv.VersionData)  );    
            }
            return cvs;

        } catch (Exception e) {
                string errMessage = 'Error on AppUtils getPrivyFilesOnBase64 method.::' + e.getmessage() + '::' + e.getLineNumber() ;
                system.debug('==================== error message : ' + errMessage);
                AppUtils.putError(errMessage );
            }
            return null;

        
        
    }
    
    //getsffiles
     public static List<ContentVersion> getFilesOnBase64(String recordID) {    

        //------ get base64 attachment files on opportunity
        try {
            List<ContentDocumentLink>
                attachments = [SELECT ContentDocumentId, ContentDocument.title, LinkedEntityId, ShareType, Visibility
                            FROM ContentDocumentLink WHERE LinkedEntityId = :recordID] ; //'0065D000003MGBE'];

            List<string> cdIDs = new List<string>();
            for (ContentDocumentLink att : attachments) {
                cdIDs.add (att.ContentDocumentId);
            }             

            system.debug('=========== cdIDs : ' + cdIDs);      

            list <contentdocument> 
                cds= [select id, LatestPublishedVersionId 
                        from contentdocument where
                        id in :cdIDs];

            List<string> lpvIDs = new List<string>();
            for (ContentDocument cd : cds) {
                lpvIDs.add (cd.LatestPublishedVersionId);
            }             
            system.debug('=========== lpvIDs : ' + lpvIDs);

            list <contentversion> 
                cvs = [select id, Checksum, ContentDocumentId
                            , ContentLocation, ContentModifiedById
                            , ContentModifiedDate, ContentSize, ContentUrl, Description
                            , ExternalDataSourceId, ExternalDocumentInfo1
                            , ExternalDocumentInfo2, 
                            title, VersionData, VersionNumber
                        from contentversion 
                        where ID in :lpvIDs];

            system.debug('=========== cvs : ' + cvs);  
            for (ContentVersion cv : CVs) {
                system.debug('=========== title : ' + cv.title 
                    + '. Body :' 
                    + EncodingUtil.base64Encode(cv.VersionData)  );    
            }
            return cvs;

        } catch (Exception e) {
                string errMessage = 'Error on AppUtils getPrivyFilesOnBase64 method.::' + e.getmessage() + '::' + e.getLineNumber() ;
                system.debug('==================== error message : ' + errMessage);
                AppUtils.putError(errMessage );
            }
            return null;

        
        
    }
    
    
    public static date getNewContractEndDate (Date lastContractStartDate, Date lastContractEndDate, Integer ContractTerm, Date newContractStartDate) {
      Date newContractEndDate=null;
      
    //Date lastContractStartDate = Date.newInstance(2017, 1, 1);
    //Date lastContractEndDate = Date.newInstance(2017, 12, 31);
    //Integer ContractTerm = 6;
    
    //lastContractEndDate = lastContractStartDate.addMonths(ContractTerm).adddays(-1);
    //Date newContractStartDate = Date.newInstance(2019, 2, 1);

    boolean ketemu = false;
    
    date startDateTmp = lastContractStartDate;
    //date startDateTmp = lastContractEndDate.addmonths(ContractTerm * -1).adddays(1);
    date endDateTmp = lastContractEndDate;
    integer counter = 0;
    system.debug ('==== newContractStartDate : ' + newContractStartDate);
    
    while ( ketemu==false && counter < 50 ) {
      system.debug ('==== startDateTmp : ' + startDateTmp + '  -----  ' + 'endDateTmp   : ' + endDateTmp);
      try {
        if (newContractStartDate > startDateTmp && newContractStartDate < endDateTmp) {
          ketemu=true;
          system.debug ('==== * newContractStartDate : ' + newContractStartDate + '  -----  ' + 'newContractEndDate   : ' + endDateTmp );
          newContractEndDate = endDateTmp;
        }
      
        startDateTmp = startDateTmp.addMonths(ContractTerm);
        endDateTmp = endDateTmp.addMonths(ContractTerm);
      } catch (Exception e) {
        string errMessage = 'Error on AppUtils getNewContractEndDate method.::' + e.getmessage() + '::' + e.getLineNumber() ;
                system.debug('==================== error message : ' + errMessage);
                AppUtils.putError(errMessage );
      }
      counter++;
    }      
      
      return newContractEndDate;
    } 
    
    
    
    public static void lockOpportunities (List <String> oppids) {
      
      /**
        * To enable this feature, from Setup, enter Process Automation Settings in the Quick Find box, then click Process Automation Settings. Then, select Enable record locking and unlocking in Apex.
        *
        * //-- call this function sample 
      //-- turn on system.debug
      List <string> oppids = new List <string> {'1811-001221','1901-001257'};
      apputils.lockOpportunities(oppids);
      
       */
      
    // Query the oportunities to lock
    Opportunity[] opps = [SELECT Id from opportunity WHERE Opportunity_ID__c in :oppids];
    
    // Lock the opportunities
    if(!test.isrunningtest())
    {
    Approval.LockResult[] lrList = Approval.lock(opps, false);
    
    // Iterate through each returned result
    
    for(Approval.LockResult lr : lrList) {
        if (lr.isSuccess()) {
            // Operation was successful, so get the ID of the record that was processed
            System.debug('Successfully locked opportunity with ID: ' + lr.getId());
        }
        else {
            // Operation failed, so get all errors                
            for(Database.Error err : lr.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Opportunity fields that affected this error: ' + err.getFields());
            }
        }
    }
    }      
    }
    
    
    public static date nextDate (Date startDate, integer daysAdd, boolean incHoliday, boolean incSaturday, boolean incSunday)   {
        //Integer daysAdd = 8;
        //Datetime createdDate = system.now();
        //Datetime dueDate = startDate.addDays(daysAdd);
        
        Datetime nextDate = startDate;
        //Datetime nextDate = Datetime.newInstance(startDate.year(), startDate.month(), startDate.day(), 0, 0, 0);
    
        /*
        Integer holidaysCount = 0;
    
        BusinessHours bh = [SELECT ID, Name, IsDefault, IsActive From BusinessHours 
                        WHERE IsDefault = true LIMIT 1];
        */
    
        List<Holiday> holidays=[Select h.StartTimeInMinutes, h.Name, h.ActivityDate From Holiday h];
        system.debug ('== holidays : '  + holidays);
        Map<Date,boolean> holidayMap = new Map<Date,boolean>();
    
        for (Holiday h : holidays) {
            Date tmpDate = Date.newInstance (h.ActivityDate.year(), h.ActivityDate.month(), h.ActivityDate.day()) ;
            holidayMap.put(tmpDate, true);
        }                
        system.debug ('== holidayMap : '  + holidayMap);
    
    
        Integer nbDaysAdded = 0;
        boolean ketemuAkhir=false;
        while (nbDaysAdded != daysAdd  || !ketemuAkhir) {
            //Datetime now = Datetime.newInstance(nextDate.year(), nextDate.month(), nextDate.day(), 0, 0, 0);
            //Boolean isHoliday = !BusinessHours.isWithin(bh.Id, now);
    
            Date tmpDate = Date.newInstance(nextDate.year(), nextDate.month(), nextDate.day());
            boolean isHoliday = holidayMap.get(tmpDate);
            system.debug ('== nextDate  : '  + nextDate);
            system.debug ('== tmpDate   : '  + tmpDate);
            system.debug ('== isHoliday : '  + isHoliday );
            
            if (isHoliday==null) isHoliday=false;
    
            //if(( (isHoliday) || nextDate.format('E') == 'Sat' || nextDate.format('E') == 'Sun') == false){
    
            if (  (   (incHoliday==false && isHoliday==true ) ||
                    (incSaturday==false && nextDate.format('E') == 'Sat' ) ||
                    (incSunday==false && nextDate.format('E') == 'Sun' ) 
                    ) == false 
               ) {
               nbDaysAdded++;
               
            }
            system.debug ('nbDaysAdded  : ' + nextDate + ' - ' + nbDaysAdded);
            nextDate = nextDate.addDays(1);
            
            
            //-- cek di akhir apakah masuk holiday
            if (nbDaysAdded == daysAdd) {
                system.debug ('=== akhir');

                tmpDate = Date.newInstance(nextDate.year(), nextDate.month(), nextDate.day());
                isHoliday = holidayMap.get(tmpDate);    


                system.debug ('== nextDate  : '  + nextDate);
                system.debug ('== tmpDate   : '  + tmpDate);
                system.debug ('== isHoliday : '  + isHoliday );
                system.debug ('== nextDate.format(E) : '  + nextDate.format('E') );
                system.debug ('== daysAdd : '  + daysAdd );


                if (  (   (incHoliday==false && isHoliday==true ) ||
                        (incSaturday==false && nextDate.format('E') == 'Sat' ) ||
                        (incSunday==false && nextDate.format('E') == 'Sun' ) 
                        ) == true
                   ) {
                    ketemuAkhir=false;
                    //system.debug ('=== add bro');
                } else {
                    ketemuAkhir=true;
                }
                system.debug ('ketemuAkhir : ' + ketemuAkhir);
                
            }
            
            system.debug ('nbDaysAdded == daysAdd : ' + nbDaysAdded + ' - ' + daysAdd);  
                        
        }  
    
        system.debug ('startDate  : ' + startDate);
        //system.debug ('dueDate      : ' + dueDate);
        system.debug ('nextDate     : ' + nextDate);
    
    
        return Date.newInstance(nextDate .year(), nextDate .month(), nextDate .day());
    }

    public static Additional_Setting__c getAdditionalValue(string type, string objectName, date rangeDate){
        decimal value = 0;

        Additional_Setting__c additionalSettingRecord = new Additional_Setting__c(); 
        string convertionRangeDate =''; 
        if(rangeDate != null){
           convertionRangeDate = string.valueOf(rangeDate);
        list<string>  convertionDateList = convertionRangeDate.split(' '); 
        convertionRangeDate = convertionDateList[0];
        date rangeDateAfrterConvert =  date.valueOf(convertionRangeDate);

        list<Additional_Setting__c> addistionalSettingList = [SELECT Id, 
                                                                        OwnerId, 
                                                                        Name, 
                                                                        CreatedById, 
                                                                        LastModifiedById, 
                                                                        
                                                                        Type__c, 
                                                                        Start_Date__c, 
                                                                        End_Date__c, 
                                                                        Value__c,
                                                                        channel__c,  
                                                                        Object_Name__c 
                                                                        FROM Additional_Setting__c 
                                                                        WHERE Object_Name__c =:objectName
                                                                            and active__c = true
                                                                            and type__c =:type
                                                                                and Start_Date__c <= :rangeDateAfrterConvert and End_Date__c >= :rangeDateAfrterConvert
                                                                                    LIMIT 1
        ];
                    
        if(addistionalSettingList.size() > 0 ){
            for(Additional_Setting__c addistionalSettingListRec :addistionalSettingList){
                additionalSettingRecord = addistionalSettingListRec;
            } 
        }
        System.debug('value: ' + value);
        }
        

        return additionalSettingRecord;
    }

    public static List<Additional_Setting__c> getListAdditionalSettingByObjectName(string objectName){
        list<Additional_Setting__c> List_AdditionalSetting = [
            SELECT Id, 
            Active__c, 
            Type__c, 
            Applies_to_Category__c, 
            Tiering_Type__c, 
            Value_Type__c, 
            Object_Name__c, 
            Name, 
            Value__c,
            End_Date__c,
            CreatedDate,
            LastModifiedDate,
            Unique_Key__c,
            Start_Date__c,
            Less_Than__c,
            Greater_Than_Equal__c,
            RecordTypeId,
            CreatedById,
            LastModifiedById,
            OwnerId,
            Account__c,
            Group_Incentive__c,
            Product__c,
            Brand__c,
            Product_Services_and_Code__c
            FROM Additional_Setting__c 
            WHERE Object_Name__c =: objectName
        ];

        return List_AdditionalSetting;
    }

    public static Map<String,Date> getRangeDate(date rangeDate){
        Map<String,Date> Map_rangeDate = new Map<String,Date>();

        string dateRange = '';
        dateRange = string.valueOf(rangeDate);
        list<string> splitDate = dateRange.split(' ');
        dateRange = splitDate[0];

        list<string> dateSplit = dateRange.split('-');

        integer rangeYear = integer.valueOf(dateSplit[0]);
        integer rangeMonth = integer.valueOf(dateSplit[1]);
        System.debug('rangeYear: ' + rangeYear);
        System.debug('rangeMonth: ' + rangeMonth);

        Date rangeStartDate = date.newInstance(rangeYear, rangeMonth,1);
        system.debug('rangeStartDate: ' + rangeStartDate);

        Date rangeEndDate = date.newInstance(rangeYear, rangeMonth, 1).addmonths(1).addDays(-1); system.debug('rangeEndDate: ' + rangeEndDate);

        Map_rangeDate.put('rangeStartDate',rangeStartDate);
        Map_rangeDate.put('rangeEndDate',rangeEndDate);

        return Map_rangeDate;
    }

    public static List<Kategori_Industri__c> getListKategoriIndustri(){
        list<Kategori_Industri__c> List_KategoriIndustri = [
            SELECT Id, 
            Name,
            prefix_ms__c
            FROM Kategori_Industri__c 
            WHERE prefix_ms__c != null
        ];

        return List_KategoriIndustri;
    }

    public static List<Media_Seller_Mapping_Settings__c> getListMediaSellerMapping(){
        List<Media_Seller_Mapping_Settings__c> List_MediaSellerMappingSettings = [
            SELECT Id,
            Name,
            Key__c,
            Media_Seller_SFID__c
            FROM Media_Seller_Mapping_Settings__c WHERE Media_Seller_SFID__c != null AND Key__c != null
        ];

        return List_MediaSellerMappingSettings;
    }
    
    public static List<Monthly_Discount_Inventory_Media_Seller__c> getListMonthlyDiscountInventoryMediaSeller(){
        List<Monthly_Discount_Inventory_Media_Seller__c> List_MonthlyDiscountInventoryMediaSeller = [
            SELECT Id,
            Media_Seller__c,
            Start_Date__c,
            Product_Name__c,
            End_Date__c,
            Discount_Type__c,
            Additional_Setting__c,
            Value__c,
            Revenue_From_Traffic__c,
            Brand__c,
            Current_Revenue_from_traffic__c,
            Periode__c,
            Product_Services_and_Code__c,
            Name
            FROM Monthly_Discount_Inventory_Media_Seller__c
        ];

        return List_MonthlyDiscountInventoryMediaSeller;
    }

    public static List<Media_Seller_Exclude_Revenue__c> getListMediaSellerExcludeRevenue(){
        List<Media_Seller_Exclude_Revenue__c> List_MediaSellerExcludeRevenue = [
            SELECT Id,
            Name
            FROM Media_Seller_Exclude_Revenue__c
        ];

        return List_MediaSellerExcludeRevenue;
    }

    public static ExchangeRates__c exchangeRateConversion(Date datePeriod){

     ExchangeRates__c exchangeRate = [
            SELECT Id, ConversionRate__c, Start_Date__c, End_Date__c
            FROM ExchangeRates__c WHERE Start_Date__c <= :datePeriod AND End_Date__c >= :datePeriod and isActive__c = true
        ];

        // TODO Buat fungsi untuk konversi amount di semua object yang memilik amount
      return exchangeRate;
    }

    public static Id VAT(){
        Additional_Setting__c adsSetting = [
               SELECT Id,Type__c,Value__c 
               FROM Additional_Setting__c WHERE Type__c = 'VAT'
           ];
   
           // TODO Buat fungsi untuk konversi amount di semua object yang memilik amount
         return adsSetting.Id;
    }

    public static Integer weekOfMonth(Date todaysDate){
        Integer weekCount = 0;
        Integer startWeekResidue = 0;
        Integer endWeekResidue = 0;
         
        //Calculating startWeekResidue
        Date dt = todaysDate.toStartOfMonth().addDays(-1);
        Date dtFirstWeekend = dt.toStartOfWeek().addDays(7);
        startWeekResidue = dt.daysBetween(dtFirstWeekend);
         
        //Calculating endWeekResidue
        Date dtLastWeekend = todaysDate.toStartOfWeek();

        endWeekResidue = dtLastWeekend.daysBetween(todaysDate);
         
        //Counting the weeks
        weekCount = (todaysDate.day() - (startWeekResidue + endWeekResidue))/7;
        weekCount += (startWeekResidue > 0 ? 1:0)+(endWeekResidue > 0 ? 1:0);
        return weekCount;
    }

    public static Integer weekOfYear(Datetime todaysDateTime){
        Integer weekCount = Integer.valueof(todaysDateTime.Format('w'));
        
        return weekCount;
    }

    public static Map<String,ProcessInstanceStep> getMapLastApprovalStep(Set<String> set_recordIds){
        Map<String,ProcessInstanceStep>  map_result = new Map<String,ProcessInstanceStep>();
        
        List<ProcessInstance> List_ProcessInstance = [
            SELECT
                Id, TargetObjectId
            FROM
                ProcessInstance
            WHERE
                TargetObjectId IN : set_recordIds
            ORDER BY TargetObjectId DESC
        ];

        system.debug (' === List_ProcessInstance : ' + json.serialize(List_ProcessInstance) + ' === ');

        if(List_ProcessInstance!=null && !List_ProcessInstance.isEmpty()){
            Set<String> Set_ProcessInstanceIds = new Set<String>();

            for(ProcessInstance processInstanceRec : List_ProcessInstance){
                Set_ProcessInstanceIds.add(processInstanceRec.Id);
            }

            List<ProcessInstanceStep> List_ProcessInstanceStep = [
                SELECT
                    Comments,StepStatus,ProcessInstanceId,ProcessInstance.TargetObjectId
                FROM
                    ProcessInstanceStep
                WHERE
                    ProcessInstanceId IN : Set_ProcessInstanceIds
                ORDER BY CreatedDate ASC
            ];

            system.debug (' === List_ProcessInstanceStep : ' + json.serialize(List_ProcessInstanceStep) + ' === ');

            if(List_ProcessInstanceStep!=null && !List_ProcessInstanceStep.isEmpty()){
                for(ProcessInstanceStep processInstanceStep : List_ProcessInstanceStep){
                    map_result.put(processInstanceStep.ProcessInstance.TargetObjectId,ProcessInstanceStep);
                }
            }
        }

        return map_result;
    }
}