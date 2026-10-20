@isTest
public with sharing class DSPFeeTriggerHandlerTest {
   
    @isTest
    public static void insertDSPFeesRecordNormal(){
        DSP_Fee__c dspFeesRecord = new DSP_Fee__c(
            Date__c = date.newinstance(2023, 02, 01),
            Deal_ID__c = 'PM-DAOB-0603-001',                                                                  // Deal ID
            Campaign__c = 'TADEX_TELKOMSEL_TTD_3300_DISPLAY_10122022-31122023_Newstle UAT_PM-DAOB-0603-001',  // Campaign
            Impression__c = 1315250,                                                                      // Impression
            Charge_Description__c = 'Feature Cost',                                                           // Charge Description
            Amount__c = 531999.68,                                                                         // Amount
            Brand__c = 'Newstle UAT'                                                                         // Brand
        );
        test.startTest();
        insert dspFeesRecord;
        test.stopTest();
    }

    @isTest
    public static void insertDSPFeesRecordWrongFormat(){
        DSP_Fee__c dspFeesRecord = new DSP_Fee__c(
            Date__c = date.newinstance(2023, 02, 01),
            Deal_ID__c = 'PM-DAOB-0603-001',                                                                  // Deal ID
            Campaign__c = 'TADEX_TELKOMSEL_TTD_3300_DISPLAY_10122022-31122023',  // Campaign
            Impression__c = 1315250,                                                                      // Impression
            Charge_Description__c = 'Feature Cost',                                                           // Charge Description
            Amount__c = 531999.68,                                                                         // Amount
            Brand__c = 'Newstle UAT'                                                                         // Brand
        );
        test.startTest();
        insert dspFeesRecord;
        test.stopTest();
    }
}