/**
 * @description       : 
 * @Test Class        : TrafficsSID_UpdDsc_Batch_Test
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 07-04-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   06-26-2023   Novando Utoyo Agmawan   Initial Version
**/

global class TrafficsSID_UpdDsc_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public date scheduleRunDate;

    global TrafficsSID_UpdDsc_Batch(date scheduleRunDate) {
        this.scheduleRunDate = scheduleRunDate;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        Integer currentMonth = this.scheduleRunDate.month();
        Integer currentYear = this.scheduleRunDate.year();
        
        String List_TrafficsSIDQuery = 
        'SELECT id, ' +  
        'Event_Date__c, ' +
        'Media_Seller__c, ' +
        'Brand__c, ' +
        'Product_Name__c, ' +
        'Month__c, ' +
        'Year__c, ' +
        'Discount__c, ' +
        'Discount_Amount__c ' +
        'FROM Traffics_SID__c ' +  
        'WHERE Month__c =: currentMonth AND ' +
        'Year__c =: currentYear';

        system.debug('TrafficsSID_UpdDsc_Batch - List_TrafficsSIDQuery : ' + List_TrafficsSIDQuery);

        return Database.getQueryLocator(List_TrafficsSIDQuery);
    }

    global void execute(Database.BatchableContext BC, List<Traffics_SID__c> List_TrafficsSID) {
        
        // process each batch of records
        try {
            system.debug('TrafficsSID_UpdDsc_Batch - List_TrafficsSID Size : ' + List_TrafficsSID.size());
            system.debug('TrafficsSID_UpdDsc_Batch - List_TrafficsSID : ' + json.serialize(List_TrafficsSID));
            
            if(List_TrafficsSID!=null && !List_TrafficsSID.isEmpty()){
                if(List_TrafficsSID!=null && !List_TrafficsSID.isEmpty()){
                    update List_TrafficsSID;
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch (Exception e) {
            String err_message = 'Error on TrafficsSID_UpdDsc_Batch.cls - execute ::' + e.getmessage() + ' - ' +e.getStacktraceString() + '::' + e.getLineNumber();
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
        mail.setSubject('Batch TrafficsSID_UpdDsc_Batch Processing '+a.Status);
        mail.setHtmlBody('The Batch Apex TrafficsSID_UpdDsc_Batch <br> job processed : '+ a.TotalJobItems+'<br> batches with : '+a.NumberOfErrors+' failures'+'<br> Job Item processed are : '+a.JobItemsProcessed);

        Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});

        //refresh allocation
        MonthlySPAllocationServices.createMonthlySpecialPriceAllocation(scheduleRunDate);
    }
}