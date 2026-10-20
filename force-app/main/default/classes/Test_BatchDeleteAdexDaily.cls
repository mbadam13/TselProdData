/**
 * @description       : This test class is for DeleteAdexDaily.class and BatchDeleteAdexDaily.class
 * @author            : Andre Prasetya
 * @created date      : 09-15-2022 
 * @last modified on  : 09-21-2022
 * @last modified by  : Andre Prasetya
**/

@isTest
public class Test_BatchDeleteAdexDaily {

		static testMethod void adexDeleteDaily() {
		Adex_Brand__c newAdexBrand = new Adex_Brand__c();
		newAdexBrand.Advertiser__c = 'YAMAHA';
		newAdexBrand.Section__c = 'K AUTOMOTIVE & ACCESSORIES';
		newAdexBrand.Brand_Name__c = 'YAMAHA FREEGO';
		newAdexBrand.Category__c = 'K4 MOTORCYCLES, SCOOTERS, BIKES';
		newAdexBrand.Brand_Type__c = 'MOTORCYCLE';
		insert newAdexBrand;
        
        Adex_Transaction__c newAdexTransaction = new Adex_Transaction__c();
        newAdexTransaction.Adex_Brand__c = newAdexBrand.id;
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
    	newAdexTransaction.AdSpend__c = 1000;
    	newAdexTransaction.Spot_Number__c = 1;
    	newAdexTransaction.AdImp__c = 1000;
    	newAdexTransaction.Creatives_Number__c = 1;
        newAdexTransaction.Date__c = date.today().addMonths(-2); //must be filled h-2 month from today
        newAdexTransaction.Week_Per_Month__c = '1';  
        insert newAdexTransaction;
        
        DeleteAdexDaily DeleteAdexDailyCont = new DeleteAdexDaily();
        DeleteAdexDailyCont.execute();
    }
}