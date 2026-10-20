/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 10-05-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
public with sharing class ExchangeRatesTriggerHandler {
    
    public static void BeforeInsertExchangeRatesTriggerHandler(List<ExchangeRates__c> newExchangeRatesList) {
        ExchangeRatesServices.validationDuplicateExchangesRate(newExchangeRatesList);
    }
}