/**
 * @description       : This test class is for GenerateAdexWeekly.class and BatchGenerateAdexWeekly.class
 * @author            : Victor Soewanto & Andre Prasetya
 * @created date      : 09-15-2022 
 * @last modified on  : 12-21-2022
 * @last modified by  : Andre Prasetya
**/

@isTest
public class Test_BatchGenerateAdexWeekly {

		static testMethod void adexWeekly() {
		Adex_Brand__c newAdexBrand = new Adex_Brand__c();
		newAdexBrand.Advertiser__c = 'YAMAHA';
		newAdexBrand.Section__c = 'K AUTOMOTIVE & ACCESSORIES';
		newAdexBrand.Brand_Name__c = 'YAMAHA FREEGO';
		newAdexBrand.Category__c = 'K4 MOTORCYCLES, SCOOTERS, BIKES';
		newAdexBrand.Brand_Type__c = 'MOTORCYCLE';
		insert newAdexBrand;
        
		//AdexTransaction data 1
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
        newAdexTransaction.Date__c = date.today().addMonths(-1); //must be filled h-1 month from today
        newAdexTransaction.Week_Per_Month__c = '1';  
        insert newAdexTransaction;

		//AdexTransaction data 2
        Adex_Transaction__c newAdexTransaction2 = new Adex_Transaction__c();
        newAdexTransaction2.Adex_Brand__c = newAdexBrand.id;
    	newAdexTransaction2.Section__c = 'S SERVICES - MEDIA & PROMOTION';
    	newAdexTransaction2.Category__c = 'S1 MEDIA, AD AGENCY, PRODUCTIO';
    	newAdexTransaction2.Advertiser__c = 'GRAMEDIA';
    	newAdexTransaction2.Product__c = 'OTOMOTIF - TABLOID';
    	newAdexTransaction2.Brand_Name__c = 'OTOMOTIF';
    	newAdexTransaction2.Brand_Type__c = 'TABLOID';
    	newAdexTransaction2.Outlet__c = 'TRIBUNNEWS.COM';
    	newAdexTransaction2.Inventory_Type__c = 'HTML5';
    	newAdexTransaction2.Ad_Type__c = 'DISPLAY';
    	newAdexTransaction2.Device_Type__c = 'Mobile';
    	newAdexTransaction2.Buy_Type__c = 'Programmatic';
    	newAdexTransaction2.IAB_Slot_Name__c = 'Half banner';
    	newAdexTransaction2.AdSpend__c = 2000;
    	newAdexTransaction2.Spot_Number__c = 1;
    	newAdexTransaction2.AdImp__c = 2000;
    	newAdexTransaction2.Creatives_Number__c = 1;
        newAdexTransaction2.Date__c = date.today().addMonths(-1); //must be filled h-1 month from today
        newAdexTransaction2.Week_Per_Month__c = '1';  
        insert newAdexTransaction2;

        GenerateAdexWeekly GenerateAdexWeeklyCont = new GenerateAdexWeekly();
        GenerateAdexWeeklyCont.execute();
    }
}