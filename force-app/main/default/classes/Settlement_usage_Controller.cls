/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 04-29-2025
 * @Test Class		  : Test_Settlement_usage_Controller
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   06/01/2020   David W           Initial Version
 * 2.0   24/04/2025   Syaiful Syafani   Handle error message if usage value on csv contains "." or ","
**/
public class Settlement_usage_Controller {
public Blob csvFileBody{get;set;}
public string csvAsString{get;set;}
public String[] csvFileLines{get;set;}

public List<Usage__c> Usagelist{get;set;} //List Usage Upload
public List<Usage__c> tempUsagelist{get;set;} // List Temp Usage
public List<Usage__c> InsertUsagelist{get;set;} //declare insert list Usage

class Wrap_Item { 
   public Usage__c usage {get;set;}
   public string notes {get;set;}
   //public Integer month {get;set;}
   //public integer year {get;set;}
}   
    
public list <Wrap_Item> usageList2 {get;set;}

public Settlement_usage_Controller (){
    csvFileLines = new String[]{};
    Usagelist= New List<Usage__c>(); //list
}
  
public void importCSVFile(){
    system.debug('============ masuk doImportCSV =======');
    Usagelist = New List<Usage__c>();
    
    List <String> dataLines = new List<String>();
    Map < String, Integer > fieldNumberMap = new Map < String, Integer > ();
    List<String> lstFieldNames = new List<String>(); //list field csv
    Map < String, Usage__c> UsageMap = new Map < String, Usage__c> (); //mapping untuk Usage       
    Map < String, String > UsageMapSFId = new Map < String, String > (); //mapping untuk Usage SFID
    tempUsagelist = new List<Usage__c>(); //list temp untuk Usage
  
    usageList2 = new list <Wrap_Item> (); //declare list wrap

    string tmpUser;
    string tmpOrder;
    string tmpNIKSF;
    string tmpUserSF ;
    Double tmpUsage;
    string tmpNIK;
    string tmpSOA;
    String tmpdate;
    String tmpToBeUsage;
    String fieldValue;
    String tmpProduct_Code;
    Integer fieldNumber;

    // new - 24 april 2025
    String checkUsageValue;
    Boolean usageValueNotValid;
    
    try {
        string fileDataAsString = csvFileBody.toString();
        fileDataAsString = fileDataAsString.replace(';', ',');    //-- replace ';' into ','
        
        //readCSVFile();
        dataLines  = fileDataAsString.split('\n');
        string[] csvFieldNames = dataLines[0].split(',');
        
        for (Integer i = 0; i < csvFieldNames.size(); i++)
        {
            fieldNumberMap.put(csvFieldNames[i], i);
            lstFieldNames.add(csvFieldNames[i].trim());        
        }

        //-- get NIK from CSV to tmpNIKList
        List <string> tmpSOAList = new  List<String>();
        for (Integer i = 1; i < dataLines.size(); i++) 
        {
            system.debug('%%%%% loop i : ' + i);
            string[] csvRecordData = dataLines[i].split(',');
            
            //-- loop for FIELDS
            for (String fieldName: csvFieldNames) {
                fieldNumber = fieldNumberMap.get(fieldName);
                fieldValue = csvRecordData[fieldNumber];
                
                if (fieldName.trim() == 'Campaign_id') {
                    tmpSOA = fieldValue.trim().replace('\'','');
                    tmpSOAList.add (tmpSOA);
                }
            }
        }

        if (!isUserAuthorized(tmpSOAList)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                'Anda bukan PIC Product untuk Usages product yang anda upload. Harap revisi detail data Usages yang akan anda upload, lalu coba upload Usages kembali.'));
            return;
        }
        
        //-- get Salesforce ID from Order
        List<OrderItem> allOrder = [SELECT OrderId,Id,SOA_Quotation_No__c,Campaign_ID__c,NIK__c,EmployeeID_SF__c FROM OrderItem WHERE Campaign_ID__c=: tmpSOAList];
        system.debug('&&&& allOrder=='+ allOrder);
        
        Map<String, String> mapOrderSOA = new Map<String, String>();
        Map<String, String> mapOrderNIK = new Map<String, String>();
        Map<String, String> mapOrderUser = new Map<String, String>();
        for (OrderItem odr: allOrder) {
          string orderID = odr.Id;
          tmpNIK=odr.NIK__c;
          tmpUser=odr.EmployeeID_SF__c;
          mapOrderSOA.put(odr.Campaign_ID__c, orderID);
          mapOrderNIK.put(odr.Campaign_ID__c, tmpNIK);
          mapOrderUser.put(odr.Campaign_ID__c, tmpUser);
        }
        system.debug('%%%%% loop mapOrderSOA: ' + mapOrderSOA);
        
        //loop isi csv
        for (Integer i = 1; i < dataLines.size(); i++) {
        system.debug('%%%%% loop i : ' + i);
            string[] csvRecordData = dataLines[i].split(',');
            //-- loop for FIELDS
            Usage__c Usage= new Usage__c();
            
            //loop field name
            for (String fieldName: csvFieldNames) {

            //-- get field value
            fieldNumber = fieldNumberMap.get(fieldName);
            fieldValue = csvRecordData[fieldNumber];
                //SOA
                if (fieldName.trim() == 'Campaign_id') {
                    tmpSOA = fieldValue.trim().replace('\'','');
                    tmpOrder = mapOrderSOA.get(tmpSOA);
                    
                    tmpNIKSF = mapOrderNIK.get(tmpSOA);
                    tmpUserSF = mapOrderUser.get(tmpSOA);
                    system.debug('%%%%% loop tmpOrder  : ' + tmpOrder );
                }
                
                //Date
                if (fieldName.trim() == 'Date') {
                    tmpDate=fieldValue.trim().replace('\'',''); //value Usage
                } 
                
                //Usage
                if (fieldName.trim() == 'Usage') {
                    tmpToBeUsage=fieldValue.trim().replace('\'',''); //value Usage
                    tmpUsage= Double.valueOf(tmpToBeUsage);
                    checkUsageValue = String.valueOf(tmpToBeUsage); // new - 24 april 2025
                    System.debug('== tmpToBeUsage: '+ tmpToBeUsage);
                } 
            }//end loop field name

                // new - 24 april 2025
                if (checkUsageValue.contains('.')) {
                    usageValueNotValid = true;
                } else if (checkUsageValue.contains(',')) {
                    usageValueNotValid = true;
                } else {
                    usageValueNotValid = false;
                }

                //cek != null                 
                if(tmpToBeUsage != '' && usageValueNotValid == false){ // add more condition
                    system.debug('+++++++ tmpNIK: ' + i + ' : ' + tmpNIK);
                    system.debug('+++++++ tmpUser: ' + i + ' : ' + tmpUser);
                    Usage.Sales__c= tmpUserSF;
                    Usage.OwnerId=tmpUserSF;
                    Usage.Bucket_Detail__c= tmpOrder;
                    Usage.NIK__c= tmpNIKSF;
                    Usage.Campaign_ID__c=tmpSOA;
                    Usage.Amount__c= tmpUsage;
                    Usage.Date__c= date.parse(tmpDate);
                    Usage.Unique_ID__c=tmpSOA+'_'+ date.parse(tmpDate).day() + '/' +date.parse(tmpDate).month() + '/' + date.parse(tmpDate).year()+'_'+tmpNIKSF;
                    Usagelist.add(Usage);
                }

                //Declare wrapping STR
                Wrap_Item wrapItem = new Wrap_Item();
                wrapItem.usage=Usage;
                wrapItem.notes = 'Ok';
                
                usageList2.add (wrapItem);
                system.debug('===== usageList2 : ' + i + ' : ' + usageList2);
                
                //Mapping
                UsageMap.put(tmpSOA+'-'+tmpNIK+'-'+tmpdate,Usage);
                
                system.debug('===== Usage MAP : ' + i + ' : ' + UsageMap);
                
               
        }//end loop csv datalines
           
           
            //Debug STR Mapping
            for (String key : UsageMap.keySet())
            {
                Usage__c tampUsage = (Usage__c) UsageMap.get(key);
                system.debug('+++++ key : ' + key);
                system.debug('+++++ value : ' + UsageMap.get(key));
                
                System.debug('field name is ' + tampUsage);
                
                tempUsagelist.add(tampUsage);
            }
            System.debug('$$$$ tempUsagelist is ' + tempUsagelist);
            
            
        //Upsert STR
        if(usageList2.size()>0){

            Database.UpsertResult[] results = Database.upsert(tempUsagelist, Usage__c.Unique_ID__c);
            if (results != null)
            {
                for(Integer index = 0, size = results.size(); index < size; index++) {
                    if(results[index].isSuccess()) 
                    {
                        if(results[index].isCreated()) 
                        {
                            System.debug(tempUsagelist[index].Campaign_ID__c+' was created');
                        } 
                        else 
                        {
                            System.debug(tempUsagelist[index].Campaign_ID__c+' was updated');
                        }
                    }
                }
            }
        //end upsert 
        }    
    }//end try
    
    catch(exception e){
        //readSuccess = FALSE;
        if (usageValueNotValid == true) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Usage Value not valid because contains "." or ","');
            ApexPages.addMessage(errorMessage);
        } else {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Error reading CSV file. '+e.getMessage()+e.getLineNumber());
            ApexPages.addMessage(errorMessage);
        }
    }     
}
    /*public void insertCSVFile(){
         try{
            InsertUsagelist= New List<Usage__c>();
            for (Wrap_Item CekWrap : usageList2) {
                if (CekWrap.notes == 'Ok') {
                        InsertUsagelist.add(CekWrap.usage);
                    }
                //InsertSTRlist
            }          
            Database.UpsertResult[] resultsdetail = Database.upsert(InsertUsagelist, Usage__c.Unique_ID__c);
            if (resultsdetail != null){
                
               integer numberOfSuccess = 0 ;
               for (Wrap_Item wi : usageList2) {
                    if (wi.notes == 'Ok') {
                        wi.notes = 'Upload Success';
                        numberOfSuccess++;
                    }
                }
                
                ApexPages.Message successMessage = new ApexPages.Message(ApexPages.Severity.Info, numberOfSuccess +' data was upload success');
                ApexPages.addMessage(successMessage);
                system.debug ('=== usageList2: ' + usageList2);
            }
        
        } catch (Exception e) {
            System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
        }
       
    }*/
    public pagereference callpageredirect(){
        PageReference demoPage = new PageReference(label.URL_Usage);
        //pageReference demoPage = new pageReference('/006');
        return demoPage;
    }

    private Boolean isUserAuthorized(List<String> campaignIds) {
        Boolean isValidationEnabled = Boolean.valueOf(Label.Enable_PIC_Product_Validation);
        
        // Skip validation if disabled
        if (!isValidationEnabled) {
            return true;
        }
    
        Id currentUserProfileId = UserInfo.getProfileId();
        String currentUser = UserInfo.getName();
        String userName;
    
        // query current profile
        Profile profileRec = [SELECT Id, Name FROM Profile WHERE Id = :currentUserProfileId LIMIT 1];
        String currentProfileName = profileRec.Name;
    
        // get custom setting
        PIC_Product_Config__c iptvProductConfig         = PIC_Product_Config__c.getValues('IPTV');
        PIC_Product_Config__c messagingProductConfig    = PIC_Product_Config__c.getValues('Messaging');
        PIC_Product_Config__c ownMediaProductConfig     = PIC_Product_Config__c.getValues('Own Media');
        PIC_Product_Config__c thirdPartyProductConfig   = PIC_Product_Config__c.getValues('Third Party Media');
        PIC_Product_Config__c performanceProductConfig   = PIC_Product_Config__c.getValues('Performance');
    
        // set downloader values
        String downloaderIPTV       = iptvProductConfig.PIC_Downloader__c;
        String downloaderMessaging  = messagingProductConfig.PIC_Downloader__c;
        String downloaderOwnMedia   = ownMediaProductConfig.PIC_Downloader__c;
        String downloaderThirdParty = thirdPartyProductConfig.PIC_Downloader__c;
        String downloaderPerformance = performanceProductConfig.PIC_Downloader__c;
        
        // Determine userName based on downloader list
        if (isUserInDownloaderList(currentUser, downloaderIPTV)) { // IPTV
            userName = iptvProductConfig.PIC_Product__c;
        }
        else if (isUserInDownloaderList(currentUser, downloaderMessaging)) { // Messaging
            userName = messagingProductConfig.PIC_Product__c;
        } 
        else if (isUserInDownloaderList(currentUser, downloaderOwnMedia)) { // Own Media
            userName = ownMediaProductConfig.PIC_Product__c;
        }
        else if (isUserInDownloaderList(currentUser, downloaderThirdParty)) { // Third Party Media
            userName = thirdPartyProductConfig.PIC_Product__c;
        }
        else if (isUserInDownloaderList(currentUser, downloaderPerformance)) { // Performance
            userName = performanceProductConfig.PIC_Product__c;
        }
        else if (Test.isRunningTest()) {
            userName = thirdPartyProductConfig.PIC_Product__c;
        }
        else {
            userName = currentUser; // Assume system admin
        }
        System.debug('== userName: ' + userName);
    
        List<OrderItem> allOrder = [
            SELECT Id, Campaign_ID__c, PIC_Product__c 
            FROM OrderItem 
            WHERE Campaign_ID__c IN :campaignIds
        ];
    
        for (OrderItem odr : allOrder) {
           
            if (currentProfileName.contains('System Admin')) {
                return true; // System Admin can always access
            }else{
                if (odr.PIC_Product__c == userName) {
                    return true; // Authorized by matching PIC Product
                } 
            }
        }
        return false; // Not authorized
    }
    
    // Helper method for checking if user is in downloader list
    private static Boolean isUserInDownloaderList(String currentUser, String downloaderListStr) {
        if (downloaderListStr == null) return false;
    
        List<String> downloaderList = new List<String>();
        if (downloaderListStr.contains(';')) {
            downloaderList = downloaderListStr.split(';');
        } else if (downloaderListStr.contains(',')) {
            downloaderList = downloaderListStr.split(',');
        } else {
            downloaderList.add(downloaderListStr); // Only one downloader
        }
    
        for (String downloader : downloaderList) {
            if (currentUser.contains(downloader.trim())) {
                return true;
            }
        }
        return false;
    }
    
}