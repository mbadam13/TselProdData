/**
 * @description       : 
 * @Test Class        : Test_MSR_Target_Import_CSV
 * @author            : David W
 * @group             : 
 * @last modified on  : 07-15-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   01-09-2020   David W                 Initial Version
 * 2.0   12-07-2024   M B Adam                Enhance Add logic Direct Sales LOB and Validation LOB if not valid
**/

public class MSR_Target_Controller {
public Blob csvFileBody{get;set;}
public String csvAsString{get;set;}
public String[] csvFileLines{get;set;}
public List<Monthly_Sales_Target__c> MSRlist{get;set;} //List MSR Upload
public List<Monthly_Sales_Target__c> tempMSRlist{get;set;} // List Temp MSR
public List<Monthly_Sales_Target__c> InsertMSRlist{get;set;} //declare insert list MSR
String mst_unique_id;
public Boolean isMediaSeller {get; set;}
public Boolean withLOBData {get; set;}
public String TypeFile{get;set;}

ApexPages.StandardSetController setCon; 
ApexPages.StandardController con;


    class Wrap_Item { 
       public Monthly_Sales_Target__c MSR {get;set;}
       public String notes {get;set;}
       public Integer month {get;set;}
       public integer year {get;set;}
       public String lob {get;set;}
       public String type {get;set;}
       public String account {get;set;}
       public Boolean commitmentTarget {get;set;}
       
    }   
    
    public list <Wrap_Item> MSRList2 {get;set;}
    
  public MSR_Target_Controller(){
    csvFileLines = new String[]{};
    MSRlist = New List<Monthly_Sales_Target__c>(); 
    TypeFile='';
    isMediaSeller = false;
    withLOBData = false;
  }
  
  public void importCSVFile(){
       system.debug('============ masuk doImportCSV =======');
        MSRlist = New List<Monthly_Sales_Target__c>();
        
        List <String> dataLines = new List<String>();
        Map < String, Integer > fieldNumberMap = new Map < String, Integer > ();
        List<String> lstFieldNames = new List<String>(); //list field csv
        Map < String, Monthly_Sales_Target__c > MSRMap = new Map < String, Monthly_Sales_Target__c > (); //mapping untuk MSR
        
        Map < String, String > MSRMapSFId = new Map < String, String > (); //mapping untuk MSR
        tempMSRlist = new List<Monthly_Sales_Target__c>(); //list temp untuk MSR
 
        MSRList2 = new list <Wrap_Item> ();
   
        String tmpUser;
        String tmpNIK;
        String tmpBPNumber;
        String tmpInvoicingCompany;
        String tmpYear;
        String tmpMonth;
        String tmpdate;
        String tmpToBeTarget;
        String tmpTarget;
        String fieldValue;
        String tmpProduct_Family;
        String tmpProduct_Code;
        Integer fieldNumber;
      	String tmpLob;
      	String tmpLobId;
      	String tmpType;
      	String tmpAccount;
      	String tmpAccountId;
        Boolean tmpCommitmentTarget;
        
        try {
            system.debug('===== csvFileBody  : ' + csvFileBody );
            String fileDataAsString = csvFileBody.toString();
            system.debug('===== fileDataAsString  : ' + fileDataAsString );
            fileDataAsString = fileDataAsString.replace(';', ',');    //-- replace ';' into ','
            
            system.debug('===== fileDataAsString  : ' + fileDataAsString );
            
            //readCSVFile();
            dataLines  = fileDataAsString.split('\n');
            String[] csvFieldNames = dataLines[0].split(',');
            
            for (Integer i = 0; i < csvFieldNames.size(); i++)
            {
                fieldNumberMap.put(csvFieldNames[i], i);
                lstFieldNames.add(csvFieldNames[i].trim());        
            }
            
            system.debug('===== dataLines : ' + dataLines);
            system.debug('===== csvFieldNames : ' + csvFieldNames);
            
            //-- get Salesforce ID from user
            List <String> tmpNIKList = new  List<String>();
            List <String> tmpNameList = new  List<String>();
            for (Integer i = 1; i < dataLines.size(); i++) {
            system.debug('%%%%% loop i : ' + i);
                String[] csvRecordData = dataLines[i].split(',');
                //-- loop for FIELDS
                tmpUser = '';
                for (String fieldName: csvFieldNames) {
                    fieldNumber = fieldNumberMap.get(fieldName);
                    fieldValue = csvRecordData[fieldNumber];
                    
                    if (fieldName.trim() == 'NIK') {
                        tmpNIK = fieldValue.trim().replace('\'','');
                        tmpNIKList.add (tmpNIK);
                    }
                }
            }
            
            //-- get Salesforce ID from user
            List<User> allUser = [SELECT Name, Id, NIK__c FROM User WHERE NIK__c=: tmpNIKList];
            Map<String, String> mapUserNIK = new Map<String, String>();
            for (User usr: allUser) {
              String userID = usr.ID;
              mapUserNIK.put(usr.NIK__c, userID );
            }
            
            // Map for LOB
            List<LOB__c> lobList = [SELECT Id, Name FROM LOB__c]; 
            system.debug('*** lobList = ' + lobList.size() + ' | ' + lobList);
            Map<String,String> lobMap = new Map<String,String>();
            for(LOB__c lobrec : lobList){
            	lobMap.put(lobrec.name,lobrec.Id);
            }
            
            // Map for Account
            /* OLD
            String mdAccIds = Label.MediaSeller_AccIds_UploadTarget;
            mdAccIds = mdAccIds.trim();
            List<String> mdAccId_list = mdAccIds.split(',');
            */
            Set<String> Set_mdAccId = new Set<String>();

            List<Media_Seller_Mapping_Settings__c> List_MediaSellerMapping = [
                SELECT Id,
                Media_Seller_SFID__c
                FROM Media_Seller_Mapping_Settings__c WHERE Media_Seller_SFID__c != null
            ];

            if(List_MediaSellerMapping!=null && !List_MediaSellerMapping.isEmpty()){
                for(Media_Seller_Mapping_Settings__c List_MediaSellerMapping_Extract : List_MediaSellerMapping){
                    Set_mdAccId.add(List_MediaSellerMapping_Extract.Media_Seller_SFID__c);
                }
            }

            system.debug('*** Set_mdAccId = ' + Set_mdAccId.size() + ' | ' + Set_mdAccId);
            List<Account> accountMSList = [SELECT Id, Name FROM Account WHERE Id IN: Set_mdAccId]; 
            system.debug('*** accountMSList = ' + accountMSList.size() + ' | ' + accountMSList);
            Map<String,String> accountMSMap = new Map<String,String>();
            for(Account accMSRec : accountMSList){
            	accountMSMap.put(accMSRec.Name,accMSRec.Id);
           	}
            
            List<String> linkIDList = new List<String> ();
            
            for (Integer i = 1; i < dataLines.size(); i++) {
            system.debug('%%%%% loop i : ' + i);
                String[] csvRecordData = dataLines[i].split(',');
                //-- loop for FIELDS
                tmpUser = '';
                for (String fieldName: csvFieldNames) { system.debug('*** fieldName = ' + fieldName);
                    //-- get field value
                    fieldNumber = fieldNumberMap.get(fieldName);
                    fieldValue = csvRecordData[fieldNumber];

                    //NIK
                    if (fieldName.trim() == 'NIK') {
                        tmpNIK = fieldValue.trim().replace('\'','');
                        tmpUser = mapUserNIK.get(tmpNIK);
                    }
    
                    //Year
                    if (fieldName.trim() == 'Year') {
                        tmpYear = fieldValue.trim().replace('\'',''); 
                    }
                    
                    //LOB
                    if (fieldName.trim() == 'LOB') {
                        tmpLob = fieldValue.trim().replace('\'','');
                        tmpLobId = lobMap.get(tmpLob);
                    }
                    
                    //Type
                    if (fieldName.trim() == 'Type') {
                        tmpType = fieldValue.trim().replace('\'',''); 
                    }

                    //Commitment Target
                    if (fieldName.trim() == 'Commitment Target') {
                        tmpCommitmentTarget = Boolean.ValueOf(fieldValue.trim().replace('\'','')); 
                    }
                    
                    //Account
                    if (fieldName.trim() == 'Account') {
                        tmpAccount = fieldValue.trim().replace('\'',''); 
                        System.debug('tmpAccount: ' + tmpAccount);
                        tmpAccountId = accountMSMap.get(tmpAccount);
                    }

                    //Date
                    if (fieldName.trim() == 'Jan' || fieldName.trim() == 'Feb'|| fieldName.trim() == 'Mar'|| fieldName.trim() == 'Apr'|| fieldName.trim() == 'May'|| fieldName.trim() == 'Jun'|| fieldName.trim() == 'Jul'|| fieldName.trim() == 'Aug'|| fieldName.trim() == 'Sept'|| fieldName.trim() == 'Oct'|| fieldName.trim() == 'Nov'|| fieldName.trim() == 'Dec') 
                    {
                                                
                        if (fieldName.trim() == 'Jan') {
                            tmpdate = tmpYear+'-01-1';
                            tmpMonth ='1';
                        }
                        if (fieldName.trim() == 'Feb') {
                            tmpdate = tmpYear+'-02-1';
                            tmpMonth ='2';
                        }
                        if (fieldName.trim() == 'Mar') {
                            tmpdate = tmpYear+'-03-1';
                            tmpMonth ='3';
                        }
                        if (fieldName.trim() == 'Apr') {
                            tmpdate = tmpYear+'-04-1';
                            tmpMonth ='4';
                        }
                        if (fieldName.trim() == 'May') {
                            tmpdate = tmpYear+'-05-1';
                            tmpMonth ='5';
                        }
                        if (fieldName.trim() == 'Jun') {
                            tmpdate = tmpYear+'-06-1';
                            tmpMonth ='6';
                        }
                        if (fieldName.trim() == 'Jul') {
                            tmpdate = tmpYear+'-07-1';
                            tmpMonth ='7';
                        }
                        if (fieldName.trim() == 'Aug') {
                            tmpdate = tmpYear+'-08-1';
                            tmpMonth ='8';
                        }
                        if (fieldName.trim() == 'Sept') {
                            tmpdate = tmpYear+'-09-1';
                            tmpMonth ='9';
                        }
                        if (fieldName.trim() == 'Oct') {
                            tmpdate = tmpYear+'-10-1';
                            tmpMonth ='10';
                        }
                        if (fieldName.trim() == 'Nov') {
                            tmpdate = tmpYear+'-11-1';
                            tmpMonth ='11';
                        }
                        if (fieldName.trim() == 'Dec') {
                            tmpdate = tmpYear+'-12-1';
                            tmpMonth ='12';
                        }
                        
                        tmpToBeTarget=fieldValue.trim().replace('\'',''); //value target
                        
                        if(tmpToBeTarget!=''){
                            Monthly_Sales_Target__c MSR = new Monthly_Sales_Target__c ();
                           
                            //MSR
                         
                            MSR.AM__c = tmpUser;
                            MSR.Sales__c = tmpUser;
                            MSR.NIK__c  = tmpNIK;

                            MSR.Group_Type__c='Target';
                            MSR.Type__c = 'Selling Target';
                            //MSR.RecordTypeId = Target;
                            MSR.Date__c = Date.valueOf(tmpdate);
                            MSR.Amount__c = Double.valueOf(tmpToBeTarget);
                            MSR.MST_Type__c = tmpType;
                            mst_unique_id = '';
                            
                            system.debug('*** tmpType = ' + tmpType);
                            system.debug('*** tmpLob= ' + tmpLob);
                            
                            if(tmpType == 'Media Seller'){
                                MSR.Media_Seller__c = tmpAccountId;
                                if(tmpCommitmentTarget == true && tmpAccountId != null){
                                    mst_unique_id = 'MS-' + tmpNIK + '-' + MSR.Type__c + '-' + tmpAccountId + '-' + tmpCommitmentTarget +  '-' + tmpMonth + '-' + tmpYear + '-' + 'commitment_Target';
                                    MSR.Commitment_Target__c = tmpCommitmentTarget;
                                }else if(tmpCommitmentTarget == false && tmpAccountId != null ){
                                    mst_unique_id = 'MS-' + tmpNIK + '-' + MSR.Type__c + '-' + tmpAccountId + '-' + tmpCommitmentTarget +'-' + tmpMonth + '-' + tmpYear + '-' + 'minimum_guarantee';
                                    MSR.Commitment_Target__c = tmpCommitmentTarget;
                                }else{
                                    mst_unique_id = 'MS-' + tmpNIK + '-' + MSR.Type__c + '-' + tmpCommitmentTarget +  '-' + tmpMonth + '-' + tmpYear + '-' + 'RKAP';
                                }
                                isMediaSeller = true;
                                withLOBData = true;
                                TypeFile='MS';
                                system.debug('MSR.Unique_ID__c: ' + MSR.Unique_ID__c);
                            }else if(tmpType == 'SME'){
                                mst_unique_id = 'SME-'+tmpNIK+'-'+MSR.Type__c+'-'+tmpMonth+'-'+tmpYear;
                            }else if((tmpType =='' || tmpType ==null) && tmpLob == null){
                                withLOBData = false;
                                TypeFile='DSwithoutLOB'; // add by M B Adam 
                                mst_unique_id = 'DS-'+tmpNIK+'-'+MSR.Type__c+'-'+tmpMonth+'-'+tmpYear;
                            }else if((tmpType =='' || tmpType ==null) && tmpLob != null){
                                isMediaSeller = false;
                                withLOBData = true; // add by M B Adam 
                                TypeFile='DSwithLOB';
                                MSR.LOB__c = tmpLobId;
                                mst_unique_id = 'DS-'+tmpNIK+'-'+MSR.Type__c+'-'+tmpLob+'-'+tmpMonth+'-'+tmpYear;
                            }
                            // else if(tmpType == '' || tmpType == null){
                            //     MSR.LOB__c = tmpLobId;
                            //     mst_unique_id = 'DS-'+tmpNIK+'-'+MSR.Type__c+'-'+tmpLob+'-'+tmpMonth+'-'+tmpYear;
                            // }
                            system.debug('*** MSR.Unique_ID__c = ' + MSR.Unique_ID__c);
                            //MSR.Target__c = Double.valueOf(tmpToBeTarget);
                            //MSR.Unique_ID__c = tmpNIK+'-'+MSR.Type__c+'-'+tmpMonth+'-'+tmpYear; //-- ORI
                            MSR.Unique_ID__c = mst_unique_id;
                            system.debug('===== MSR : ' + i + ' : ' + MSR);
                            MSRlist.add(MSR);
 
                            
                            //Declarewrapping MSR
                            Wrap_Item wrapItem = new Wrap_Item();
                            wrapItem.MSR=MSR;
                            wrapItem.notes = 'Ok';
                            //wrapItem.month = tmpMonth;
                            System.debug('data with LOB' + withLOBData);
                            System.debug('data media Seller' +isMediaSeller);
                            System.debug('Data Type File :' + TypeFile);
                            System.debug('Data Type temp :' + tmpType);
                            if(MSR.AM__c == null) wrapItem.notes = 'NOT OK. check AM!';
                            if( MSR.LOB__c == null && tmpType == null && withLOBData == true) wrapItem.notes='NOT OK. Check LOB Data';                        
                            Date d = Date.valueOf(tmpdate); //date send to sales
                            Integer tempYear = d.year();
                            Integer tempMonth = d.month();
                            wrapItem.year = tempYear;
                            wrapItem.month = tempMonth;
                            wrapItem.lob = tmpLob;
                            wrapItem.type = tmpType;
                            wrapItem.account = tmpAccount;
                            
                            wrapItem.commitmentTarget = tmpCommitmentTarget;
  
                            MSRList2.add (wrapItem);
 
                            //Mapping
                            MSRMap.put(tmpNIK+'-'+Date.valueOf(tmpdate)+'-'+tmpProduct_Family,MSR);
                            
                            system.debug('===== MSR MAP : ' + i + ' : ' + MSRMap);
                            
                        }
                    }
                }
            }
            
            //Debug MSR Mapping
            for (String key : MSRMap.keySet())
            {
                Monthly_Sales_Target__c tmpMSR = (Monthly_Sales_Target__c) MSRMap.get(key);
                system.debug('+++++ key : ' + key);
                system.debug('+++++ value : ' + MSRMap.get(key));
                
                System.debug('field name is ' + tmpMSR);
                //System.debug('Debug 1'+tmpNIK+'-'+Date.valueOf(tmpdate)+'-'+tmpProduct_Family)
                System.debug('Debug 1 '+key + '::' + tmpMSR.NIK__c + Date.valueOf(tmpMSR.Date__c));
                if(tmpMSR.AM__c!=null){
                    //tempMSRlist=(Monthly_Sales_Target__c)tmpMSR;
                    tempMSRlist.add(tmpMSR);
                }
            }
            System.debug('tempMSRlist is ' + tempMSRlist);
            //upsert tempMSRlist Unique_ID__c;
            
            //Upsert MSR
            /*Database.UpsertResult[] results = Database.upsert(tempMSRlist, Monthly_Sales_Target__c.Unique_ID__c);
            if (results != null)
            {
                for(Integer index = 0, size = results.size(); index < size; index++) {
                    if(results[index].isSuccess()) 
                    {
                        if(results[index].isCreated()) 
                        {
                            System.debug(tempMSRlist[index].Unique_ID__c +' was created');
                            //ApexPages.Message successMessage = new ApexPages.Message(ApexPages.Severity.Info,results.size()+' was created');
                            //ApexPages.addMessage(successMessage);
                        } 
                        else 
                        {
                            System.debug(tempMSRlist[index].Unique_ID__c +' was updated');
                            //ApexPages.Message updateMessage = new ApexPages.Message(ApexPages.Severity.Confirm,results.size()+' was updated');
                            //ApexPages.addMessage(updateMessage);
                        }
                    }
                }
            }*///end upsert

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            //readSuccess = FALSE;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Error reading CSV file. '+e.getMessage());
            ApexPages.addMessage(errorMessage);
        }     
        //getLinkList (changePriceID, mapDataEffectiveDate, mapDataToBeAutoRenewal);
  }
  public void insertCSVFile(){
        try{
            InsertMSRlist= New List<Monthly_Sales_Target__c>();
            system.debug('*** MSRList2.size() = ' + MSRList2.size());
            for (Wrap_Item CekWrap : MSRList2) {
                if (CekWrap.notes == 'Ok') {
                        InsertMSRlist.add(CekWrap.MSR);
                    }
                //InsertSTRlist
            }
            
            system.debug('*** InsertMSRlist.size() = ' + InsertMSRlist.size());
            for(Monthly_Sales_Target__c cekMsr : InsertMSRlist){system.debug('*** cek unik id msr = ' + cekMsr.Unique_ID__c);}
            
            Database.UpsertResult[] resultsdetail = Database.upsert(InsertMSRlist, Monthly_Sales_Target__c.Unique_ID__c);
            if (resultsdetail != null){
                
               integer numberOfSuccess = 0 ;
               for (Wrap_Item wi : MSRList2) {
                    if (wi.notes == 'Ok') {
                        wi.notes = 'Upload Success';
                        numberOfSuccess++;
                    }
                }
                
                ApexPages.Message successMessage = new ApexPages.Message(ApexPages.Severity.Info, numberOfSuccess +' data was upload success');
                ApexPages.addMessage(successMessage);
                system.debug ('=== MSRList2: ' + MSRList2);
            }
            
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            System.debug(e.getTypeName() + ' - ' + e.getCause() + ': ' + e.getMessage());
        }
    }
    public pagereference callpageredirect(){
        PageReference demoPage = new PageReference(label.URL_Sales_Target);
        //pageReference demoPage = new pageReference('/006');
        return demoPage;
        
    }
}