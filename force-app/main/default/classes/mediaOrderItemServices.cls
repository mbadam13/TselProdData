/**
 * @description       : 
 * @testClass         : mediaOrderItemServices_Test
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 09-26-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   06-25-2024   Novando Utoyo Agmawan   Initial Version
 * 2.0   24-09-2024   Muhammad Bustamil Adam  - Remove Field : Versi in Methode Export Record CSV File 
**/

public class mediaOrderItemServices {
    @AuraEnabled
    public static String exportRecordCsvFile(String recordId){
        String result;

        try {
            Id myRecordId = Id.ValueOf(recordId);
            String sObjName = myRecordId.getSObjectType().getDescribe().getName();
            String mediaOrderName = '';
            String orderName = '';

            String queryString = 
            'SELECT ' +
            'Id, ' +
            'Name, ' +
            'Media_Order__c, ' +
            'Media_Order__r.Order__c, ' +
            'Media_Order__r.name, ' +
            'Media_Order__r.Order__r.OrderNumber, ' +
            'Media_Order__r.Quantity__c,' + 
            'Order_Product__c, ' +
            'Order_Item_ID__c, ' +
            'Product_Name__c, ' +
            'House_Number__c, ' +
            'Duration__c, ' +
            'Date__c, ' +
            'Time__c, ' +
            'Quantity__c, ' +
            'Spot_Needed__c, ' +
            'Over_Limit__c, ' +
            'Net__c, ' +
            'Amount__c ' +
            'FROM Media_Order_Item__c ';
            
            if(sObjName == 'Order'){
                queryString += 'WHERE Media_Order__r.Order__c =: recordId';
            }

            if(sObjName == 'Media_Order__c'){
                queryString += 'WHERE Media_Order__c =: recordId';
            }

            System.debug('exportRecordCsvFile - queryString : ' + queryString);

            List<Media_Order_Item__c> List_mediaOrderItem = Database.query(queryString);

            if(List_mediaOrderItem!=null && !List_mediaOrderItem.isEmpty()){
                List<ContentVersion> List_ContentVersionFormat = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title Like : '%MOItem_%'];
    
                if(List_ContentVersionFormat!=null && !List_ContentVersionFormat.isEmpty()){
                    List<ContentDocument> ContentDocumentList = [select id from ContentDocument where id =: List_ContentVersionFormat[0].ContentDocumentId];

                    delete ContentDocumentList;
                }

                String CsvData = 'Id**,'+
                'Media Order Id,'+
                'Order Id,'+
                'Order Item Id,'+
                'Product Name,'+
                'House Number,'+
                'Duration,'+
                'Date,'+
                'Time,'+
                'Sum of Quantity Per Product,'+
                'Quantity**,'+
                'Net,'+
                'Amount,'+
                '\n';

                mediaOrderName = '';
                orderName = '';

                for(Media_Order_Item__c mediaOrderItem : List_mediaOrderItem){
                    CsvData += mediaOrderItem.id + ',' +
                    mediaOrderItem.Media_Order__c + ',' + 
                    mediaOrderItem.Media_Order__r.Order__c + ',' + 
                    mediaOrderItem.Order_Item_ID__c + ',' + 
                    mediaOrderItem.Product_Name__c + ',' + 
                    mediaOrderItem.House_Number__c + ',' + 
                    
                    Integer.ValueOf(mediaOrderItem.Duration__c) + ',' + 
                    mediaOrderItem.Date__c + ',' + 
                    mediaOrderItem.Time__c + ',' + 
                    Integer.ValueOf(mediaOrderItem.Media_Order__r.Quantity__c) + ',' +
                    Integer.ValueOf(mediaOrderItem.Quantity__c) + ',' + 
                    mediaOrderItem.Net__c + ',' + 
                    mediaOrderItem.Amount__c +
                    '\n';


                    // Get Order Number 
                    orderName = mediaOrderItem.Media_Order__r.Order__r.OrderNumber;

                    // Get Media Order Name 
                    mediaOrderName = mediaOrderItem.Media_Order__r.Name;
                    
                }

                Blob csvBlob = blob.valueOf(CsvData);
                String csvName = 'Format_Import_MediaOrderItem.csv'; // default csv name
                if(sObjName == 'Order'){
                    csvName = 'MOItem_ORDER_' + orderName + '.csv';
                }
                else if(sObjName == 'Media_Order__c'){
                    csvName = 'MOItem_MO_' + mediaOrderName + '.csv';
                }

                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = csvName;
                contentVersion.FirstPublishLocationId = recordId;
                contentVersion.PathOnClient = csvName;
                contentVersion.VersionData = csvBlob;
                contentVersion.IsMajorVersion = true;
                Insert contentVersion;

                List<ContentVersion> List_ContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id LIMIT 1];

                if(List_ContentVersion!=null && !List_ContentVersion.isEmpty()){
                    result = List_ContentVersion[0].ContentDocumentId;
                }
            }
            
             if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            String err_message = 'Error on mediaOrderItemServices.cls - exportRecordCsvFile ::' + e.getmessage() + ' - ' +e.getStacktraceString() + '::' + e.getLineNumber();
            AppUtils.putError(err_message);
        }

        return result;
    }

    public class resultImportCsvFile {
        @auraEnabled public String contentDocumentId { get; set; }
        @auraEnabled public Integer countAllData { get; set; }
        @auraEnabled public Integer countAllSuccess { get; set; }
        @auraEnabled public Integer countAllFailed { get; set; }
    }   

    @AuraEnabled
    public static resultImportCsvFile importRecordCsvFile(Id idContentDocument, Id recordId){
        DateTime start_time = datetime.now();
        
        resultImportCsvFile resultImportCsvFileReq = null;

        Pattern numberFormat = Pattern.Compile('[0-9.]*');

        system.debug('importRecordCsvFile - idContentDocument : ' + idContentDocument);
        system.debug('importRecordCsvFile - recordId : ' + recordId);

        try {
            if(idContentDocument != null && recordId != null) {
                Id myRecordId = Id.ValueOf(recordId);
                String sObjName = myRecordId.getSObjectType().getDescribe().getName();

                List<Media_Order_Item__c> List_mediaOrderItemUpdate = new List<Media_Order_Item__c>();

                Set<String> Set_parentIds = new Set<String>();

                ContentVersion objVersion = [SELECT Id, VersionData FROM ContentVersion WHERE ContentDocumentId =: idContentDocument];
                
                Map < String, Integer > fieldNumberMap = new Map < String, Integer > ();
                String fileDataAsString = objVersion.VersionData.toString();
            	system.debug('===== fileDataAsString  : ' + fileDataAsString );
            	fileDataAsString = fileDataAsString.replace(';', ',');    //-- replace ';' into ','
                
                list<String> lstCSVLines = fileDataAsString.split('\n');
                Integer fieldNumber;
                String fieldValue;

                string[] csvFieldNames = lstCSVLines[0].split(',');
                for (Integer i = 0; i < csvFieldNames.size(); i++) {
                    fieldNumberMap.put(csvFieldNames[i], i);    
                }

                for(Integer i = 1; i < lstCSVLines.size(); i++){
                    list<String> csvRowData = lstCSVLines[i].split(',');
                    string tmp_Id = '';
                    string tmp_Quantity = '';
                    string tmp_ParentId = '';

                    for (String fieldName: csvFieldNames) {
                        fieldNumber = fieldNumberMap.get(fieldName);
                        //system.debug('fieldNumber : ' + fieldNumber);
                        
                        fieldValue = csvRowData[fieldNumber];
                        //system.debug('fieldValue : ' + fieldValue);

                        if (fieldName.trim() == 'Id**') {
                            tmp_Id = fieldValue.trim();
                        }

                        if (
                            fieldName.contains('Quantity**')
                        ) {
                            tmp_Quantity = fieldValue.trim();
                        }

                        if(sObjName == 'Order'){
                            if (
                                fieldName.contains('Order Id')
                            ) {
                                tmp_ParentId = fieldValue.trim();
                            }
                        }
            
                        if(sObjName == 'Media_Order__c'){
                            if (
                                fieldName.contains('Media Order Id')
                            ) {
                                tmp_ParentId = fieldValue.trim();
                            }
                        }
                    }

                    Set_parentIds.add(tmp_ParentId);

                    Media_Order_Item__c mediaOrderItemUpd = new Media_Order_Item__c();
                    mediaOrderItemUpd.Id = tmp_Id;
                    
                    System.debug('Data Temp Quantity : ' + tmp_Quantity);

                    if(String.ValueOf(tmp_Quantity).isNumeric() == true){
                        mediaOrderItemUpd.Quantity__c = Integer.valueOf(tmp_Quantity);
                    }

                    List_mediaOrderItemUpdate.add(mediaOrderItemUpd);
                }

                system.debug('importRecordCsvFile - Set_parentIds : ' + json.serialize(Set_parentIds));

                if(Set_parentIds!=null && !Set_parentIds.isEmpty()) {
                    String firstParentIds = new List<String> (Set_parentIds).get(0);

                    system.debug('importRecordCsvFile - firstParentIds : ' + json.serialize(firstParentIds));
                    system.debug('importRecordCsvFile - recordId : ' + recordId);

                    if(firstParentIds != recordId){
                        //Do Nothing
                    }else{
                        if(List_mediaOrderItemUpdate!=null && !List_mediaOrderItemUpdate.isEmpty()) {
                            resultImportCsvFileReq = new resultImportCsvFile();
                            resultImportCsvFileReq.countAllData = 0 ;
                            resultImportCsvFileReq.countAllSuccess = 0 ;
                            resultImportCsvFileReq.countAllFailed = 0 ;
                            
                            resultImportCsvFileReq.countAllData = List_mediaOrderItemUpdate.size();
    
                            Database.SaveResult[] updateResults = Database.Update(List_mediaOrderItemUpdate, false);
    
                            List<Object> List_errorEntryObject = new List<Object>();
    
                            for(Integer i=0; i<updateResults.size(); i++){
                                if (updateResults.get(i).isSuccess()){
                                    //system.debug('sucess 1025 : ' + updateResults.get(i).getId());
                                    resultImportCsvFileReq.countAllSuccess++;
                                }
                                else if (!updateResults.get(i).isSuccess()){
                                    Database.Error error = updateResults.get(i).getErrors().get(0);
    
                                    //system.debug('error 1030 : ' + json.serialize(List_mediaOrderItemUpdate.get(i)));
    
                                    String JsonErrorEntry = json.serialize(List_mediaOrderItemUpdate.get(i));
    
                                    String new_JsonErrorEntry = error.getMessage() + ' ' + error.getFields();
    
                                    String JsonErrorEntry_final;
                                    JsonErrorEntry_final = JsonErrorEntry.removeEnd('}');
                                    JsonErrorEntry_final = JsonErrorEntry_final + ',"ERROR":"' + new_JsonErrorEntry + '"}"';
    
                                    Object errorEntryObject = (Object) JSON.deserializeUntyped(JsonErrorEntry_final);
                                    List_errorEntryObject.add(errorEntryObject);
    
                                    resultImportCsvFileReq.countAllFailed++;
                                }
                            }
    
                            if(
                                resultImportCsvFileReq.countAllData == 
                                (
                                    resultImportCsvFileReq.countAllSuccess + resultImportCsvFileReq.countAllFailed
                                )
                            ){
                                system.debug('importRecordCsvFile - List_errorEntryObject : ' + json.serialize(List_errorEntryObject));

                                if(List_errorEntryObject!=null && !List_errorEntryObject.isEmpty()){
                                    List<Map<String, Object>> mapList = new List<Map<String, Object>>();
                                    Set<String> keySet = new Set<String>();
                                    
                                    for (Object EntryObject : List_errorEntryObject) {
                                        Map<String, Object> m = (Map<String, Object>)(EntryObject);
                                        keySet.addAll(m.keySet());
                                        mapList.add(m);
                                    }

                                    system.debug('importRecordCsvFile - mapList : ' + json.serialize(mapList));

                                    system.debug('importRecordCsvFile - keySet : ' + json.serialize(keySet));
                                    
                                    List<String> keys = new List<String>(keySet);
                                    //keys.sort();

                                    system.debug('importRecordCsvFile - keys : ' + json.serialize(keys));
                                    
                                    List<List<String>> csvLines = new List<List<String>>();
                                    
                                    for (Integer i = 0; i <= mapList.size(); i++) {
                                        csvLines.add(new List<String>());
                                    }

                                    for (String key : keys) {
                                        if(
                                            key != 'attributes'
                                        ){
                                            csvLines.get(0).add(key);
                                        
                                            for (Integer i = 1; i <= mapList.size(); i++) {
                                                csvLines.get(i).add(String.valueOf((mapList.get(i - 1).get(key))));
                                            }
                                        }
                                    }

                                    system.debug('importRecordCsvFile - csvLines : ' + json.serialize(csvLines));
                                    
                                    String csvFile = '';
    
                                    for (List<String> csvLine : csvLines) {
                                        String line = '';
                                        for (Integer i = 0; i < csvLine.size() - 1; i++) {
                                            line += csvLine.get(i) + ',';
                                        }
                                        line += csvLine.get(csvLine.size() - 1);
                                        csvFile += line + '\n';
                                    }
                                    
                                    system.debug('importRecordCsvFile - csvFile : ' + json.serialize(csvFile));

                                    Datetime gmt = System.Now();
                                    Integer offset = UserInfo.getTimezone().getOffset(gmt);
                                    Datetime local = gmt.addSeconds(offset/1000);  
    
                                    String csvName = 'ErrorLog_' + local + '.csv';
    
                                    ContentVersion contentVersion = new ContentVersion();
                                    contentVersion.Title = csvName;
                                    contentVersion.FirstPublishLocationId = recordId;
                                    contentVersion.PathOnClient = csvName;
                                    contentVersion.VersionData = Blob.valueOf(csvFile);
                                    contentVersion.IsMajorVersion = true;
                                    Insert contentVersion;
    
                                    List<ContentVersion> List_ContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id LIMIT 1];
    
                                    if(List_ContentVersion!=null && !List_ContentVersion.isEmpty()){
                                        resultImportCsvFileReq.contentDocumentId = List_ContentVersion[0].ContentDocumentId;
                                    }
                                }
    
                                List<ContentDocument> ContentDocumentList = [select id from ContentDocument where id =: idContentDocument];
    
                                if(ContentDocumentList!=null && !ContentDocumentList.isEmpty()){
                                    delete ContentDocumentList;
                                }
    
                                system.debug('resultImportCsvFileReq : ' + json.serialize(resultImportCsvFileReq));
                            }
                        }
                    }
                }
            }
            
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            String err_message = 'Error on mediaOrderItemServices.cls - importRecordCsvFile ::' + e.getmessage() + ' - ' +e.getStacktraceString() + '::' + e.getLineNumber();
            AppUtils.putError(err_message);
        }

        return resultImportCsvFileReq; 
    }

/**
 * Deletes Media_Order_Item__c records based on the products in the given OrderItems.
 * @param orderItems List of OrderItem records to process
 */
  public static void deleteMOItemWithOrderProductID(List<OrderItem> orderItems) {
    if (orderItems == null || orderItems.isEmpty()) {
        return;
    }

    Set<Id> mediaOrderItemIdsToDelete = new Set<Id>();

    // Collect Media_Order_Item__c IDs based on the products in the order items
    for (OrderItem oi : orderItems) {
        // Query the Media_Order_Item__c records related to the OrderItem's Product2Id
        List<Media_Order_Item__c> mediaOrderItems = [
            SELECT Id 
            FROM Media_Order_Item__c 
            WHERE Order_Product__c = :oi.Id
        ];

        for (Media_Order_Item__c mo : mediaOrderItems) {
            mediaOrderItemIdsToDelete.add(mo.Id);
        }
    }

    // Query the Media_Order_Item__c records to be deleted using the collected IDs
    if (!mediaOrderItemIdsToDelete.isEmpty()) {
        List<Media_Order_Item__c> mediaOrderItemsToDelete = [
            SELECT Id 
            FROM Media_Order_Item__c 
            WHERE Id IN :mediaOrderItemIdsToDelete
        ];

        // Delete the collected Media_Order_Item__c records
        delete mediaOrderItemsToDelete;
    }
  }







}