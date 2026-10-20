/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 10-05-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
trigger ExchangeRatesTrigger on ExchangeRates__c (before insert) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            ExchangeRatesTriggerHandler.BeforeInsertExchangeRatesTriggerHandler(Trigger.new);
        }

    }
}