@isTest
public with sharing class PubmaticBillingTriggerHandlerTest {
    @IsTest
    static void updateBillingUSD(){
        Monthly_Settlement__c monthlySettlmentRecord = new Monthly_Settlement__c(
            Date__c = date.newinstance(2023, 2, 1),// Date
            Unique_Key__c = 'MS_202302'           // Unique Key
        );
        insert monthlySettlmentRecord;
        
        Pubmatic_Billing__c pubmaticBillingRecord = new Pubmatic_Billing__c(
        
            Monthly_Settlement__c = monthlySettlmentRecord.id,     // Monthly Settlement
            Date__c = date.newinstance(2023, 2, 1),    // Date
            Sum_of_Revenue_USD__c = 223.4751,      // Sum of Revenue (USD)
            Exchange_Rate__c = 14300.00,          // Exchange Rate
            Sum_of_Paid_Impressions__c = 214794,  // Sum of Paid Impressions
            Sum_of_Net_Revenue_USD__c = 201.1200,  // Sum of Net Revenue (USD)
            Billing_USD__c = 123.0000,             // Billing USD
            Unique_Key__c = 'PB_202302_867235'      // Unique Key
        );
        insert pubmaticBillingRecord;

        Test.startTest();
        pubmaticBillingRecord.Billing_USD__c = 123;
        update pubmaticBillingRecord;
        Test.stopTest();
        
    }
}