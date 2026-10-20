/*
	Created by Victor
	26 January 2022
*/

@isTest
private class Test_Trigger_Adex_Transaction {

    static testMethod void myUnitTest() {
        List<Adex_Transaction__c> lAdexTransaction = new List<Adex_Transaction__c>();
        
        Adex_Transaction__c newAdexTransaction1 = new Adex_Transaction__c();
        newAdexTransaction1.Date__c = system.today();
        newAdexTransaction1.Section__c = 'A FOOD';
        newAdexTransaction1.Category__c = 'A2 CEREALS, BREAKFAST FOOD';
        newAdexTransaction1.Advertiser__c = 'KAKAO MAS GEMILANG';
        newAdexTransaction1.Product__c = 'ENERGEN - INSTANT CEREAL';
        newAdexTransaction1.Outlet__c = 'YOUTUBE.COM NEWAFI2013';
        newAdexTransaction1.Inventory_Type__c = 'Video';
        newAdexTransaction1.Ad_Type__c = 'VIDEO';
        newAdexTransaction1.Device_Type__c = 'Mobile';
        newAdexTransaction1.Buy_Type__c = 'Programmatic';
        newAdexTransaction1.IAB_Slot_Name__c = 'Video';
        newAdexTransaction1.AdSpend__c = 12475;
        newAdexTransaction1.Spot_Number__c = 1;
        newAdexTransaction1.AdImp__c = 138618;
        newAdexTransaction1.Creatives_Number__c = 1;
        
        Adex_Transaction__c newAdexTransaction2 = new Adex_Transaction__c();
        newAdexTransaction2.Date__c = system.today();
        newAdexTransaction2.Section__c = 'A FOOD';
        newAdexTransaction2.Category__c = 'A2 CEREALS, BREAKFAST FOOD';
        newAdexTransaction2.Advertiser__c = 'KAKAO MAS GEMILANG';
        newAdexTransaction2.Product__c = 'ENERGEN';
        newAdexTransaction2.Outlet__c = 'YOUTUBE.COM NEWAFI2013';
        newAdexTransaction2.Inventory_Type__c = 'Video';
        newAdexTransaction2.Ad_Type__c = 'VIDEO';
        newAdexTransaction2.Device_Type__c = 'Mobile';
        newAdexTransaction2.Buy_Type__c = 'Programmatic';
        newAdexTransaction2.IAB_Slot_Name__c = 'Video';
        newAdexTransaction2.AdSpend__c = 12475;
        newAdexTransaction2.Spot_Number__c = 1;
        newAdexTransaction2.AdImp__c = 138618;
        newAdexTransaction2.Creatives_Number__c = 1;
        
        lAdexTransaction.add(newAdexTransaction1);
        lAdexTransaction.add(newAdexTransaction2);
        
        insert lAdexTransaction;
    }
}