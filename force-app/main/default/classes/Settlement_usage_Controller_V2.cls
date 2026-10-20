/**
 * @description       : 
 * @author            : M B Adam 
 * @group             : 
 * @last modified on  : 08-08-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Settlement_usage_Controller_V2 {
    public Blob csvFileBody { get; set; }
    public String csvAsString { get; set; }
    public String[] csvFileLines { get; set; }
    public List<Usage__c> Usagelist { get; set; } // List Usage Upload
    public List<Usage_IPTV__c> UsageIPTVlist { get; set; } // List Usage Upload
    public List<Usage__c> tempUsagelist { get; set; } // List Temp Usage
    public List<Usage_IPTV__c> tempUsageIPTVlist { get; set; } // List Temp Usage
    public List<Usage__c> InsertUsagelist { get; set; } // Declare insert list Usage
    public List<Wrap_Item> usageList2 { get; set; }
    public List<Wrap_Item> digitalUsageList { get; set; }
    public List<Wrap_Item> tvUsageIPTVList { get; set; }
    public String selectedFileType { get; set; }
    public Boolean showUpload { get; set; }


    public Settlement_usage_Controller_V2() {
        csvFileLines = new String[]{};
        Usagelist = new List<Usage__c>(); // List
        UsageIPTVlist = new List<Usage_IPTV__c>(); // List
        digitalUsageList = new List<Wrap_Item>();
        tvUsageIPTVList = new List<Wrap_Item>();
        selectedFileType = 'Digital'; // Default selection
        showUpload = false; 
      
    
    }

    public void showUploadForm() {
        showUpload = true;
        
    }



    public void importCSVFileDigital() {
        system.debug('============ masuk doImportCSV =======');
        Usagelist = new List<Usage__c>();

        List<String> dataLines = new List<String>();
        Map<String, Integer> fieldNumberMap = new Map<String, Integer>();
        List<String> lstFieldNames = new List<String>(); // List field csv
        Map<String, Usage__c> UsageMap = new Map<String, Usage__c>(); // Mapping untuk Usage       
        Map<String, String> UsageMapSFId = new Map<String, String>(); // Mapping untuk Usage SFID
        tempUsagelist = new List<Usage__c>(); // List temp untuk Usage

        usageList2 = new List<Wrap_Item>(); // Declare list wrap

        String tmpUser;
        String tmpOrder;
        String tmpNIKSF;
        String tmpUserSF;
        Double tmpUsage;
        String tmpNIK;
        String tmpSOA;
        String tmpDate;
        String tmpToBeUsage;
        String fieldValue;
        String tmpProduct_Code;
        Integer fieldNumber;

        try {
            
            usageList2.clear();
            String fileDataAsString = csvFileBody.toString();
            fileDataAsString = fileDataAsString.replace(';', ','); // Replace ';' into ','

            // Read CSV File
            dataLines = fileDataAsString.split('\n');
            String[] csvFieldNames = dataLines[0].split(',');

            for (Integer i = 0; i < csvFieldNames.size(); i++) {
                fieldNumberMap.put(csvFieldNames[i], i);
                lstFieldNames.add(csvFieldNames[i].trim());        
            }

            // Get NIK from CSV to tmpSOAList
            List<String> tmpSOAList = new List<String>();
            for (Integer i = 1; i < dataLines.size(); i++) {
                system.debug('%%%%% loop i : ' + i);
                String[] csvRecordData = dataLines[i].split(',');
                // Loop for FIELDS
                for (String fieldName: csvFieldNames) {
                    fieldNumber = fieldNumberMap.get(fieldName);
                    fieldValue = csvRecordData[fieldNumber];

                    if (fieldName.trim() == 'Campaign_id') {
                        tmpSOA = fieldValue.trim().replace('\'', '');
                        tmpSOAList.add(tmpSOA);
                    }
                }
            }

            // Get Salesforce ID from Order
            List<OrderItem> allOrder = [SELECT OrderId, Id, SOA_Quotation_No__c, Campaign_ID__c, NIK__c, EmployeeID_SF__c FROM OrderItem WHERE Campaign_ID__c =: tmpSOAList];
            system.debug('&&&& allOrder==' + allOrder);

            Map<String, String> mapOrderSOA = new Map<String, String>();
            Map<String, String> mapOrderNIK = new Map<String, String>();
            Map<String, String> mapOrderUser = new Map<String, String>();
            for (OrderItem odr: allOrder) {
                String orderID = odr.Id;
                tmpNIK = odr.NIK__c;
                tmpUser = odr.EmployeeID_SF__c;
                mapOrderSOA.put(odr.Campaign_ID__c, orderID);
                mapOrderNIK.put(odr.Campaign_ID__c, tmpNIK);
                mapOrderUser.put(odr.Campaign_ID__c, tmpUser);
            }
            system.debug('%%%%% loop mapOrderSOA: ' + mapOrderSOA);

            // Loop isi csv
            for (Integer i = 1; i < dataLines.size(); i++) {
                system.debug('%%%%% loop i : ' + i);
                String[] csvRecordData = dataLines[i].split(',');
                // Loop for FIELDS
                Usage__c Usage = new Usage__c();

                // Loop field name
                for (String fieldName: csvFieldNames) {
                    // Get field value
                    fieldNumber = fieldNumberMap.get(fieldName);
                    fieldValue = csvRecordData[fieldNumber];
                    // SOA
                    if (fieldName.trim() == 'Campaign_id') {
                        tmpSOA = fieldValue.trim().replace('\'', '');
                        tmpOrder = mapOrderSOA.get(tmpSOA);

                        tmpNIKSF = mapOrderNIK.get(tmpSOA);
                        tmpUserSF = mapOrderUser.get(tmpSOA);
                        system.debug('%%%%% loop tmpOrder  : ' + tmpOrder );
                    }

                    // Date
                    if (fieldName.trim() == 'Date') {
                        tmpDate = fieldValue.trim().replace('\'', ''); // Value Usage
                    } 

                    // Usage
                    if (fieldName.trim() == 'Usage') {
                        tmpToBeUsage = fieldValue.trim().replace('\'', ''); // Value Usage
                        tmpUsage = Double.valueOf(tmpToBeUsage);
                    } 
                } // End loop field name

                // Check != null                 
                if (tmpToBeUsage != '') {
                    system.debug('+++++++ tmpNIK: ' + i + ' : ' + tmpNIK);
                    system.debug('+++++++ tmpUser: ' + i + ' : ' + tmpUser);
                    Usage.Sales__c = tmpUserSF;
                    Usage.OwnerId = tmpUserSF;
                    Usage.Bucket_Detail__c = tmpOrder;
                    Usage.NIK__c = tmpNIKSF;
                    Usage.Campaign_ID__c = tmpSOA;
                    Usage.Amount__c = tmpUsage;
                    Usage.Date__c = Date.parse(tmpDate);
                    Usage.Unique_ID__c = tmpSOA + '_' +  Usage.Date__c.day() +'-'+Usage.Date__c.month()+'-'+Usage.Date__c.year()+ '_' + tmpNIKSF;
                    Usagelist.add(Usage);
                }

                // Declare wrapping STR
                Wrap_Item wrapItem = new Wrap_Item();
                wrapItem.usage = Usage;
                wrapItem.notes = 'Ok';

                usageList2.add(wrapItem);
                system.debug('===== usageList2 : ' + i + ' : ' + usageList2);

                // Mapping
                UsageMap.put(tmpSOA + '-' + tmpNIK + '-' + tmpDate, Usage);

                system.debug('===== Usage MAP : ' + i + ' : ' + UsageMap);
            } // End loop csv datalines

            // Debug STR Mapping
            for (String key : UsageMap.keySet()) {
                Usage__c tampUsage = (Usage__c) UsageMap.get(key);
                system.debug('+++++ key : ' + key);
                system.debug('+++++ value : ' + UsageMap.get(key));

                System.debug('field name is ' + tampUsage);

                tempUsagelist.add(tampUsage);
            }
            System.debug('$$$$ tempUsagelist is ' + tempUsagelist);

            // Upsert STR
            if (usageList2.size() > 0) {
                Database.UpsertResult[] results = Database.upsert(tempUsagelist, Usage__c.Unique_ID__c);
                if (results != null) {
                    for (Integer index = 0, size = results.size(); index < size; index++) {
                        if (results[index].isSuccess()) {
                            if (results[index].isCreated()) {
                                System.debug(tempUsagelist[index].Campaign_ID__c + ' was created');
                            } else {
                                System.debug(tempUsagelist[index].Campaign_ID__c + ' was updated');
                            }
                        }
                    }
                }
            } // End upsert 
        } // End try

        catch (Exception e) {
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error reading CSV file. ' + e.getMessage() + e.getLineNumber());
            ApexPages.addMessage(errorMessage);
        }     
    }
    

    
    public void importCSVFileTV() {
        system.debug('============ masuk doImportCSV =======');
        UsageIPTVlist = new List<Usage_IPTV__c>();
        List<String> dataLines = new List<String>();
        Map<String, Integer> fieldNumberMap = new Map<String, Integer>();
        List<String> lstFieldNames = new List<String>(); // List field csv
        Map<String, Usage_IPTV__c> UsageIPTVMap = new Map<String, Usage_IPTV__c>(); // Mapping untuk UsageIPTV      
        Map<String, String> UsageIPTVMapSFId = new Map<String, String>(); // Mapping untuk Usage SFID
        tempUsageIPTVlist = new List<Usage_IPTV__c>(); // List temp untuk UsageIPTV
    
        tvUsageIPTVList = new List<Wrap_Item>(); // Declare list wrap
    
        String tmpUser;
        String tmpOrder;
        String tmpProduct;
        String tmpNIKSF;
        String tmpUserSF;
        String tmpNote;
        Integer tmpViewer;
        Double tmpUsage;
        String tmpNIK;
        String tmpDate;
        String tmpToBeUsage;
        String fieldValue;
        Integer tempNodata;
        String tmpProduct_Code;
        Integer fieldNumber;
        String tmpMoItemId;
        String tmpMoItem;
        String tmpIPTVChanel;
        String tmpProductName;
        String tmpHouseNumber;
        String tmpBrandHouse;
        String tmpversionHouseNum;
        Time tempBroadcasttime;
        List<Integer> errorRows = new List<Integer>();
    
        try {
            tvUsageIPTVList.clear();
            
            String fileDataAsString = csvFileBody.toString();
            fileDataAsString = fileDataAsString.replace(';', ','); // Replace ';' into ','
    
            // Read CSV File
            dataLines = fileDataAsString.split('\n');
            String[] csvFieldNames = dataLines[0].split(',');
    
            for (Integer i = 0; i < csvFieldNames.size(); i++) {
                fieldNumberMap.put(csvFieldNames[i], i);
                lstFieldNames.add(csvFieldNames[i].trim());
            }
    
            // Get NIK from CSV to Mo Item
            List<String> tmpMoItemList = new List<String>();
            for (Integer i = 1; i < dataLines.size(); i++) {
                system.debug('%%%%% loop i : ' + i);
                String[] csvRecordData = dataLines[i].split(',');
                // Loop for FIELDS
                for (String fieldName : csvFieldNames) {
                    fieldNumber = fieldNumberMap.get(fieldName);
                    fieldValue = csvRecordData[fieldNumber];
    
                    if (fieldName.trim() == 'No MO Item') {
                        tmpMoItem = fieldValue;
                        tmpMoItemList.add(tmpMoItem);
                    }
                }
            }
    
            List<Media_Order_Item__c> allMOItem = [SELECT Id, Name, Order_Product__c FROM Media_Order_Item__c WHERE Name IN :tmpMoItemList];
            system.debug('%%%%% allMOItem : ' + allMOItem);
            system.debug('%%%%% tmpMOList : ' + tmpMoItemList);
            Map<String, String> mapMoItemId = new Map<String, String>();
    
            Set<Id> orderProductIds = new Set<Id>();
            for (Media_Order_Item__c moItem : allMOItem) {
                if (moItem.Order_Product__c != null) {
                    orderProductIds.add(moItem.Order_Product__c);
                }
                mapMoItemId.put(moItem.Name, moItem.Id);
            }
    
            // Get Salesforce ID from Order
            List<OrderItem> allOrder = [SELECT OrderId, Id, Product2Id, Campaign_ID__c, NIK__c, EmployeeID_SF__c FROM OrderItem WHERE Id IN :orderProductIds];
            system.debug('&&&& allOrder==' + allOrder);
    
            for (OrderItem odr : allOrder) {
                String orderID = odr.Id;
                tmpNIK = odr.NIK__c;
                tmpUser = odr.EmployeeID_SF__c;
                tmpOrder = odr.Id;
                tmpProduct = odr.Product2Id;
            }
    
            // Loop through CSV data
            for (Integer i = 1; i < dataLines.size(); i++) {
                system.debug('%%%%% loop i : ' + i);
                String[] csvRecordData = dataLines[i].split(',');
                Usage_IPTV__c UsageIPTV = new Usage_IPTV__c();
                Boolean hasEmptyField = false; // Flag to check if any field is empty
    
                // Loop through field names
                for (String fieldName : csvFieldNames) {
                    fieldNumber = fieldNumberMap.get(fieldName);
                    fieldValue = csvRecordData[fieldNumber];
    
                    if (String.isBlank(fieldValue) && fieldName.trim() != 'Note') {
                        hasEmptyField = true;
                    }
    
                    if (fieldName.trim() == 'No MO Item') {
                        tmpMoItem = fieldValue;
                        tmpMoItemId = mapMoItemId.get(tmpMoItem);
                    }
    
                    if (fieldName.trim() == 'IPTV Channel') {
                        tmpIPTVChanel = fieldValue;
                    }
    
                    if (fieldName.trim() == 'Product Name') {
                        tmpProductName = fieldValue;
                    }
    
                    if (fieldName.trim() == 'House Number') {
                        tmpHouseNumber = fieldValue;
                    }
    
                    if (fieldName.trim() == 'Brand House Number') {
                        tmpBrandHouse = fieldValue;
                    }
    
                    if (fieldName.trim() == 'Versi House Number') {
                        tmpversionHouseNum = fieldValue;
                    }
    
                    if (fieldName.trim() == 'Broadcast time') {
                        if (String.isBlank(fieldValue)) {
                            tempBroadcasttime = null;
                        } else {
                            String trimmedFieldValue = fieldValue.trim();
                    
                            // Split the time and period (AM/PM)
                            String[] parts = trimmedFieldValue.split(' ');
                            String timePart = parts[0].trim();
                            String periodPart = parts[1].trim();
                    
                            // Split the time parts
                            String[] timeParts = timePart.split(':');
                            system.debug('Data Time :' + timeParts);
                    
                            // Convert the time parts to integers
                            Integer hour = Integer.valueOf(timeParts[0].trim());
                            Integer minute = Integer.valueOf(timeParts[1].trim());
                            Integer second = Integer.valueOf(timeParts[2].trim());
                    
                            // Handle the AM/PM part
                            Boolean isPM = periodPart.equalsIgnoreCase('PM');
                            if (isPM && hour != 12) {
                                hour += 12;
                            } else if (!isPM && hour == 12) {
                                hour = 0;
                            }
                    
                            // Create the time instance
                            tempBroadcasttime = Time.newInstance(hour, minute, second, 0);
                        }
                    }
    
                    if (fieldName.trim() == 'Date(YYYY-MM-DD)') {
                        tmpDate = fieldValue.trim().replace('\'', '');
                    }
    
                    if (fieldName.trim() == 'Spot ke') {
                        tempNodata = Integer.valueOf(fieldValue);
                    }

                    if (fieldName.trim() == 'Viewers') {
                        tmpViewer = Integer.valueOf(fieldValue);
                    }

                    if (fieldName.trim() == 'Note') {
                        if (String.isBlank(fieldValue)) {
                            tmpNote = null;
                        } else {
                            tmpNote = fieldValue;
                        }
                    }

                }
    
                if (hasEmptyField) {
                    errorRows.add(i + 1); // Adding 1 to account for the header row
                    continue; // Skip processing this row
                }
    
                // Proceed with processing the valid row
                UsageIPTV.OwnerId = tmpUser;
                UsageIPTV.Status__c='Play';
                UsageIPTV.Notes__c = tmpNote;
                UsageIPTV.Viewers__c=tmpViewer;
                UsageIPTV.Product__c = tmpProduct;
                UsageIPTV.Media_Order_Item__c = tmpMoItemId;
                UsageIPTV.No__c = tempNodata;
                UsageIPTV.Broadcast_Time__c = tempBroadcasttime;
                UsageIPTV.Date__c = AppUtils.strToDate(tmpDate, 'yyyy-mm-dd');
                UsageIPTV.Unique_ID__c = tmpMoItem + '_' + UsageIPTV.Date__c.day() + '/' + UsageIPTV.Date__c.month() + '/' + UsageIPTV.Date__c.year() + '_' + tempBroadcasttime.hour() + ':' + tempBroadcasttime.minute() + ':' + tempBroadcasttime.second();
    
                UsageIPTVlist.add(UsageIPTV);
    
                Wrap_Item wrapItem = new Wrap_Item();
                wrapItem.usageIPTV = UsageIPTV;
                wrapItem.notes = tmpNote;
                wrapItem.sequenceNumber= i;
                wrapItem.MOItem = tmpMoItem;
                wrapItem.IPTV_Channel = tmpIPTVChanel;
                wrapItem.Product_Name = tmpProductName;
                wrapItem.House_Number = tmpHouseNumber;
                wrapItem.No = tempNodata;
                wrapItem.Viewers=tmpViewer;
                wrapItem.Brand_House_Number = tmpBrandHouse;
                wrapItem.Version_House_Number = tmpversionHouseNum;
                wrapItem.Broadcast_time = tempBroadcasttime;
                tvUsageIPTVList.add(wrapItem);
                system.debug('===== usageList2 : ' + i + ' : ' + tvUsageIPTVList);
    
                UsageIPTVMap.put(UsageIPTV.Unique_ID__c, UsageIPTV);
                system.debug('===== Usage IPTV MAP : ' + i + ' : ' + UsageIPTV);
            }
    
            if (!errorRows.isEmpty()) {
                for (Integer rowNum : errorRows) {
                    tvUsageIPTVList.clear();
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Missing data at row ' + rowNum);
                    ApexPages.addMessage(errorMessage);
                }
            }else{

                for (String key : UsageIPTVMap.keySet()) {
                    Usage_IPTV__c tampUsage = (Usage_IPTV__c) UsageIPTVMap.get(key);
                    system.debug('+++++ key : ' + key);
                    system.debug('+++++ value : ' + UsageIPTVMap.get(key));
    
                    System.debug('field name is ' + tampUsage);
    
                    tempUsageIPTVlist.add(tampUsage);
                }
                System.debug('$$$$ tempUsagelist is ' + tempUsagelist);
            }
    
            // Upsert STR
            if (tempUsageIPTVlist.size() > 0) {
                Database.UpsertResult[] results = Database.upsert(tempUsageIPTVlist, Usage_IPTV__c.Unique_ID__c);
                if (results != null) {
                    for (Integer index = 0, size = results.size(); index < size; index++) {
                        if (results[index].isSuccess()) {
                            if (results[index].isCreated()) {
                                system.debug(tempUsageIPTVlist[index].Unique_ID__c + ' was created');
                            } else {
                                system.debug(tempUsageIPTVlist[index].Unique_ID__c + ' was updated');
                            }
                        } else {
                            system.debug('Failed to upsert Usage__c with Unique_ID__c: ' + tempUsageIPTVlist[index].Unique_ID__c + '. Error: ' + results[index].getErrors());
                        }
                    }
                }
            }
    
        } catch (Exception e) {
            tvUsageIPTVList.clear();
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error reading CSV file. ' + e.getMessage() + e.getLineNumber());
            ApexPages.addMessage(errorMessage);
        }
    }
    

    
    public PageReference callpageredirect() {
        PageReference demoPage = new PageReference(label.URL_Usage);
        // PageReference demoPage = new PageReference('/006');
        return demoPage;
    }

    // Wrapper class to hold the usage data and notes
    public class Wrap_Item { 
        public Usage__c usage { get; set; }
        public Integer sequenceNumber { get; set; }
        public Usage_IPTV__c usageIPTV { get; set; }
        public String notes { get; set; }
        public String MOItem { get; set; }
        public String IPTV_Channel { get; set; }
        public String Product_Name { get; set; }
        public String House_Number { get; set; }
        public Integer No {get; set;}
        public Integer Viewers {get; set;}
        public String Brand_House_Number { get; set; }
        public String Version_House_Number { get; set; }
        public Time Broadcast_time { get; set; }
    }   
}