/*
  Created by : David W
  09 Jan 2020
*/

public class MSR_Target_utopup_Controller {
public Blob csvFileBody{get;set;}
public String csvAsString{get;set;}
public String[] csvFileLines{get;set;}
public List<Monthly_Sales_Target__c> MSRlist{get;set;} //List MSR Upload
public List<Monthly_Sales_Target__c> tempMSRlist{get;set;} // List Temp MSR
public List<Monthly_Sales_Target__c> InsertMSRlist{get;set;} //declare insert list MSR

ApexPages.StandardSetController setCon; 
ApexPages.StandardController con;


    class Wrap_Item { 
       public Monthly_Sales_Target__c MSR {get;set;}
       public String notes {get;set;}
       public Integer month {get;set;}
       public integer year {get;set;}
    }   
    
    public list <Wrap_Item> MSRList2 {get;set;}
    
  public MSR_Target_utopup_Controller (){
    csvFileLines = new String[]{};
    MSRlist = New List<Monthly_Sales_Target__c>(); 
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
            
            List<String> linkIDList = new List<String> ();
            
            for (Integer i = 1; i < dataLines.size(); i++) {
            system.debug('%%%%% loop i : ' + i);
                String[] csvRecordData = dataLines[i].split(',');
                //-- loop for FIELDS
                tmpUser = '';
                for (String fieldName: csvFieldNames) {
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
                            MSR.Type__c = 'Target User Top Up';
                            MSR.MST_Type__c='SME';
                            //MSR.RecordTypeId = Target;
                            MSR.Date__c = Date.valueOf(tmpdate);
                            MSR.Number_of__c = Double.valueOf(tmpToBeTarget);
                            //MSR.Target__c = Double.valueOf(tmpToBeTarget);
                            MSR.Unique_ID__c = tmpNIK+'-'+MSR.Type__c+'-'+tmpMonth+'-'+tmpYear;
                            system.debug('===== MSR : ' + i + ' : ' + MSR);
                            MSRlist.add(MSR);
 
                            
                            //Declarewrapping MSR
                            Wrap_Item wrapItem = new Wrap_Item();
                            wrapItem.MSR=MSR;
                            wrapItem.notes = 'Ok';
                            //wrapItem.month = tmpMonth;
                            
                            if(MSR.AM__c == null) wrapItem.notes = 'NOT OK. check AM!';
                                                        
                            Date d = Date.valueOf(tmpdate); //date send to sales
                            Integer tempYear = d.year();
                            Integer tempMonth = d.month();
                            wrapItem.year = tempYear;
                            wrapItem.month = tempMonth;
  
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
            Database.UpsertResult[] results = Database.upsert(tempMSRlist, Monthly_Sales_Target__c.Unique_ID__c);
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
            }//end upsert
                           
        }
        
        catch(exception e){
            //readSuccess = FALSE;
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR,'Error reading CSV file. '+e.getMessage());
            ApexPages.addMessage(errorMessage);
        }     
        //getLinkList (changePriceID, mapDataEffectiveDate, mapDataToBeAutoRenewal);
  }
    public void insertCSVFile(){
        try{
            InsertMSRlist= New List<Monthly_Sales_Target__c>();
            for (Wrap_Item CekWrap : MSRList2) {
                if (CekWrap.notes == 'Ok') {
                        InsertMSRlist.add(CekWrap.MSR);
                    }
                //InsertSTRlist
            }          
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