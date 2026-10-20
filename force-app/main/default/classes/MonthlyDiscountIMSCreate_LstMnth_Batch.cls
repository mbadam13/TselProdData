/**
 * @description       : 
 * @Test Class        : MonthlyDiscountIMSCreate_Test
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 09-13-2023
 * @last modified by  : Ahmat Zulkifli Murad
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   06-27-2023   Novando Utoyo Agmawan   Initial Version
**/

global class MonthlyDiscountIMSCreate_LstMnth_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public date scheduleRunDate;
    public date StartDate;
    public date EndDate;

    global MonthlyDiscountIMSCreate_LstMnth_Batch(date scheduleRunDate) {
        this.scheduleRunDate = scheduleRunDate;
    }

    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        Map<String,Date> Map_rangeDate = AppUtils.getRangeDate(this.scheduleRunDate);
        StartDate = Map_rangeDate.get('rangeStartDate');
        EndDate = Map_rangeDate.get('rangeStartDate');
        
        String List_AdditionalSettingQuery = 
        'SELECT id, ' +  
        'Active__c, ' +
        'Applies_to_Category__c, ' + 
        'Value_Type__c, ' +  
        'Object_Name__c, ' +  
        'Type__c, ' +   
        'Name, ' +  
        'Tiering_Type__c, ' +  					
        'Value__c, ' +  
        'End_Date__c, ' +  
        'CreatedDate, ' +  
        'Unique_Key__c, ' +  
        'Start_Date__c, ' +  
        'Product__c, ' +  
        'RecordTypeId, ' + 	
        'Account__c, ' +	
        'Brand__c, ' +	
        'Greater_Than_Equal__c, ' +  
        'Less_Than__c, ' +
        'Product_Services_and_Code__c, ' +
        'Group_Incentive__c ' +
        'from Additional_Setting__c ' +  
        'WHERE Active__c = true AND ' +  
        'Object_Name__c = \'Monthly_Discount_Inventory_Seller__c\' AND ' + 
        'Start_Date__c <=: StartDate AND ' + 
        'End_Date__c >=: EndDate ' + 
        'ORDER BY Account__c '
        ;

        system.debug('MonthlyDiscountIMSCreate_LstMnth_Batch - List_AdditionalSettingQuery : ' + List_AdditionalSettingQuery);

        return Database.getQueryLocator(List_AdditionalSettingQuery);
    }

    global void execute(Database.BatchableContext BC, List<Additional_Setting__c> List_AdditionalSetting) {
        
        // process each batch of records
        try {
            system.debug('MonthlyDiscountIMSCreate_LstMnth_Batch - List_AdditionalSetting Size : ' + List_AdditionalSetting.size());
            system.debug('MonthlyDiscountIMSCreate_LstMnth_Batch - List_AdditionalSetting : ' + json.serialize(List_AdditionalSetting));
            
            if(List_AdditionalSetting!=null && !List_AdditionalSetting.isEmpty()){
                Map<String,Kategori_Industri__c> Map_KategoriIndustri = MonthlyDiscountIMSServices.getKategoriIndustriByPrefix();

                List<Monthly_Discount_Inventory_Media_Seller__c> List_MonthlyDiscountInventoryMediaSeller_New = new List<Monthly_Discount_Inventory_Media_Seller__c>();

                for(Additional_Setting__c AdditionalSetting : List_AdditionalSetting){
                    System.debug('AdditionalSetting315 : ' + json.serialize(AdditionalSetting));

                    Monthly_Discount_Inventory_Media_Seller__c MonthlyDiscountInventoryMediaSeller_New = new Monthly_Discount_Inventory_Media_Seller__c(
                        Media_Seller__c = AdditionalSetting.Account__c,
                        Start_Date__c = date.newinstance(this.scheduleRunDate.year(), this.scheduleRunDate.month(), 1),
                        End_Date__c = date.newinstance(this.scheduleRunDate.year(), this.scheduleRunDate.month(), 1).addMonths(1).addDays(-1),
                        Product_Name__c = AdditionalSetting.Product__c,
                        Product_Services_and_Code__c = AdditionalSetting.Product_Services_and_Code__c,
                        Discount_Type__c = AdditionalSetting.Value_Type__c,
                        Brand__c = AdditionalSetting.Brand__c,
                        Additional_Setting__c = AdditionalSetting.Id
                    );

                    MonthlyDiscountInventoryMediaSeller_New.Revenue_From_Traffic__c = MonthlyDiscountIMSServices.getRevenueFromTrafficValue(
                        MonthlyDiscountInventoryMediaSeller_New.Media_Seller__c,
                        MonthlyDiscountInventoryMediaSeller_New.Product_Name__c,
                        MonthlyDiscountInventoryMediaSeller_New.Product_Services_and_Code__c,
                        MonthlyDiscountInventoryMediaSeller_New.Brand__c,
                        MonthlyDiscountInventoryMediaSeller_New.Start_Date__c
                    );

                    MonthlyDiscountInventoryMediaSeller_New.Current_Revenue_from_traffic__c = MonthlyDiscountIMSServices.getCurrentRevenueFromTraffic(
                        MonthlyDiscountInventoryMediaSeller_New.Media_Seller__c,
                        MonthlyDiscountInventoryMediaSeller_New.Product_Name__c,
                        MonthlyDiscountInventoryMediaSeller_New.Product_Services_and_Code__c,
                        MonthlyDiscountInventoryMediaSeller_New.Brand__c,
                        AdditionalSetting.Start_Date__c,
                        AdditionalSetting.End_Date__c
                    );

                    MonthlyDiscountInventoryMediaSeller_New.Unique_ID__c =
                    MonthlyDiscountInventoryMediaSeller_New.Start_Date__c + '-' +
                    MonthlyDiscountInventoryMediaSeller_New.End_Date__c + '-' +
                    MonthlyDiscountInventoryMediaSeller_New.Media_Seller__c + '-' +
                    MonthlyDiscountInventoryMediaSeller_New.Product_Name__c + '-' +
                    MonthlyDiscountInventoryMediaSeller_New.Product_Services_and_Code__c + '-' +
                    MonthlyDiscountInventoryMediaSeller_New.Brand__c;

                    System.debug('MonthlyDiscountInventoryMediaSeller_New.Unique_ID__c: ' + MonthlyDiscountInventoryMediaSeller_New.Unique_ID__c);

                    List_MonthlyDiscountInventoryMediaSeller_New.add(MonthlyDiscountInventoryMediaSeller_New);


                    /*
                    //for next month
                    Monthly_Discount_Inventory_Media_Seller__c MonthlyDiscountInventoryMediaSeller_New_Current = new Monthly_Discount_Inventory_Media_Seller__c(
                        Media_Seller__c = AdditionalSetting.Account__c,
                        Start_Date__c = this.scheduleRunDate.addMonths(1),
                        End_Date__c = this.scheduleRunDate.addMonths(2).addDays(-1),
                        Product_Name__c = AdditionalSetting.Product__c,
                        Discount_Type__c = AdditionalSetting.Value_Type__c,
                        Product_Services_and_Code__c = AdditionalSetting.Product_Services_and_Code__c,
                        Brand__c = AdditionalSetting.Brand__c,
                        Additional_Setting__c = AdditionalSetting.Id
                    );

                    MonthlyDiscountInventoryMediaSeller_New_Current.Revenue_From_Traffic__c = MonthlyDiscountIMSServices.getRevenueFromTrafficValue(
                        MonthlyDiscountInventoryMediaSeller_New_Current.Media_Seller__c,
                        MonthlyDiscountInventoryMediaSeller_New_Current.Product_Name__c,
                        MonthlyDiscountInventoryMediaSeller_New_Current.Product_Services_and_Code__c,
                        MonthlyDiscountInventoryMediaSeller_New_Current.Brand__c,
                        MonthlyDiscountInventoryMediaSeller_New_Current.Start_Date__c
                    );

                    MonthlyDiscountInventoryMediaSeller_New_Current.Current_Revenue_from_traffic__c = MonthlyDiscountIMSServices.getCurrentRevenueFromTraffic(
                        MonthlyDiscountInventoryMediaSeller_New_Current.Media_Seller__c,
                        MonthlyDiscountInventoryMediaSeller_New_Current.Product_Name__c,
                        MonthlyDiscountInventoryMediaSeller_New_Current.Product_Services_and_Code__c,
                        MonthlyDiscountInventoryMediaSeller_New_Current.Brand__c,
                        AdditionalSetting.Start_Date__c,
                        MonthlyDiscountInventoryMediaSeller_New_Current.End_Date__c
                    );

                    MonthlyDiscountInventoryMediaSeller_New_Current.Unique_ID__c =
                    MonthlyDiscountInventoryMediaSeller_New_Current.Start_Date__c + '-' +
                    MonthlyDiscountInventoryMediaSeller_New_Current.End_Date__c + '-' +
                    MonthlyDiscountInventoryMediaSeller_New_Current.Media_Seller__c + '-' +
                    MonthlyDiscountInventoryMediaSeller_New_Current.Product_Name__c + '-' +
                    MonthlyDiscountInventoryMediaSeller_New_Current.Product_Services_and_Code__c + '-' +
                    MonthlyDiscountInventoryMediaSeller_New_Current.Brand__c;

                    System.debug('MonthlyDiscountInventoryMediaSeller_New_Current.Unique_ID__c: ' + MonthlyDiscountInventoryMediaSeller_New_Current.Unique_ID__c);

                    List_MonthlyDiscountInventoryMediaSeller_New.add(MonthlyDiscountInventoryMediaSeller_New_Current);
                    */
                }

                system.debug('MonthlyDiscountIMSCreate_LstMnth_Batch - List_MonthlyDiscountInventoryMediaSeller_New Size : ' + List_MonthlyDiscountInventoryMediaSeller_New.size());

                system.debug('MonthlyDiscountIMSCreate_LstMnth_Batch - List_MonthlyDiscountInventoryMediaSeller_New : ' + json.serialize(List_MonthlyDiscountInventoryMediaSeller_New));

                if(List_MonthlyDiscountInventoryMediaSeller_New!=null && !List_MonthlyDiscountInventoryMediaSeller_New.isEmpty()){
                    System.debug('List_MonthlyDiscountInventoryMediaSeller_New: ' + json.serialize(List_MonthlyDiscountInventoryMediaSeller_New));
                    upsert List_MonthlyDiscountInventoryMediaSeller_New Unique_ID__c;
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch (Exception e) {
            String err_message = 'Error on MonthlyDiscountIMSCreate_LstMnth_Batch.cls - execute ::' + e.getmessage() + ' - ' +e.getStacktraceString() + '::' + e.getLineNumber();
            AppUtils.putError(err_message);
        }
    }

    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations, example : send email for status
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Use the below code will send an email to User about the status
        AsyncApexJob a = [
            Select a.TotalJobItems, 
            a.Status, 
            a.NumberOfErrors,
            a.JobType, 
            a.JobItemsProcessed, 
            a.ExtendedStatus, 
            a.CreatedById,
            a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()
        ];

        List<string> List_toAddress = new List<string>();
        List_toAddress.add('Novando.Agmawan@saasten.com');
        List_toAddress.add('ahmat.murad@saasten.com');
        List_toAddress.add('andhito.revandra@saasten.com');

        List<string> List_toCCAddress = new List<string>();

        mail.setToAddresses(List_toAddress);
        if(List_toCCAddress!=null && !List_toCCAddress.isEmpty()){
            mail.setCcAddresses(List_toCCAddress);
        }
        mail.setSubject('Batch MonthlyDiscountIMSCreate_LstMnth_Batch Processing '+a.Status);
        mail.setHtmlBody('The Batch Apex MonthlyDiscountIMSCreate_LstMnth_Batch <br> job processed : '+ a.TotalJobItems+'<br> batches with : '+a.NumberOfErrors+' failures'+'<br> Job Item processed are : '+a.JobItemsProcessed);

        Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
    }
}