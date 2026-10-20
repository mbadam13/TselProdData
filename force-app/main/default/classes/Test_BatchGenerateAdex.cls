/*
	Created by Victor
	28 January 2022
	
	This test class is for GenerateAdexBrand.class and BatchGenerateAdex.class
*/

@isTest
private class Test_BatchGenerateAdex {

    static testMethod void myUnitTest() {
    	Adex_Transaction__c newAdexTransaction = new Adex_Transaction__c();
    	newAdexTransaction.Section__c = 'S SERVICES - MEDIA & PROMOTION';
    	newAdexTransaction.Category__c = 'S1 MEDIA, AD AGENCY, PRODUCTIO';
    	newAdexTransaction.Advertiser__c = 'GRAMEDIA';
    	newAdexTransaction.Product__c = 'OTOMOTIF - TABLOID';
    	newAdexTransaction.Brand_Name__c = 'OTOMOTIF';
    	newAdexTransaction.Brand_Type__c = 'TABLOID';
    	newAdexTransaction.Outlet__c = 'TRIBUNNEWS.COM';
    	newAdexTransaction.Inventory_Type__c = 'HTML5';
    	newAdexTransaction.Ad_Type__c = 'DISPLAY';
    	newAdexTransaction.Device_Type__c = 'Mobile';
    	newAdexTransaction.Buy_Type__c = 'Programmatic';
    	newAdexTransaction.IAB_Slot_Name__c = 'Half banner';
    	newAdexTransaction.AdSpend__c = 1;
    	newAdexTransaction.Spot_Number__c = 1;
    	newAdexTransaction.AdImp__c = 1;
    	newAdexTransaction.Creatives_Number__c = 1;
		newAdexTransaction.Date__c = system.today();
        newAdexTransaction.Week_Per_Month__c = '1';  
    	insert newAdexTransaction;
        
        GenerateAdexBrand myGenerateAdexBrand = new GenerateAdexBrand();        
        myGenerateAdexBrand.execute();
    }
}