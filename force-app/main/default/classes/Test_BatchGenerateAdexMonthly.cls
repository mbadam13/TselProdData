/**
 * @description       : This test class is for GenerateAdexMonthly.class and BatchGenerateAdexMonthly.class
 * @author            : Andre Prasetya
 * @group             : 09-15-2022 
 * @last modified on  : 12-21-2022
 * @last modified by  : Andre Prasetya
**/

@isTest
public class Test_BatchGenerateAdexMonthly {

		static testMethod void adexMonthly() {
			
		//date untuk last month
		Date targetDate = date.today().addmonths(-1); //must fill last month
		String month = string.ValueOf(targetDate.month());
		String year = string.ValueOf(targetDate.year());		

		Adex_Brand__c newAdexBrand = new Adex_Brand__c();
		newAdexBrand.Advertiser__c = 'YAMAHA';
		newAdexBrand.Section__c = 'K AUTOMOTIVE & ACCESSORIES';
		newAdexBrand.Brand_Name__c = 'YAMAHA FREEGO';
		newAdexBrand.Category__c = 'K4 MOTORCYCLES, SCOOTERS, BIKES';
		newAdexBrand.Brand_Type__c = 'MOTORCYCLE';
		insert newAdexBrand;

		//Adex Transaction Weekly data 1
		Adex_Transaction_Weekly__c newAdexTransactionWeekly = new Adex_Transaction_Weekly__c();
		newAdexTransactionWeekly.Adex_Brand__c  = newAdexBrand.id;
    	newAdexTransactionWeekly.Week__c  = '1' ;
    	newAdexTransactionWeekly.Section__c = 'L INDUSTRIAL PRODUCTS';
    	newAdexTransactionWeekly.Month__c   = month;
		newAdexTransactionWeekly.Year__c = year;
    	newAdexTransactionWeekly.Category__c  = 'L1 INDUSTRIAL EQUIPMENT';
    	newAdexTransactionWeekly.AdSpend__c = 99999;
    	newAdexTransactionWeekly.Advertiser__c  = 'BODOR';
    	newAdexTransactionWeekly.AdImp__c = 333.999;
    	newAdexTransactionWeekly.Product__c = 'BODOR - INDUSTRIAL EQUIPMENT';
    	newAdexTransactionWeekly.Count_Data__c = 3;
    	newAdexTransactionWeekly.Brand_Name__c = 'BODOR';
    	newAdexTransactionWeekly.Brand_Type__c = 'INDUSTRIAL EQUIPMENT';
    	newAdexTransactionWeekly.Inventory_Type__c  = 'HTML5';
    	newAdexTransactionWeekly.Buy_Type__c = 'Programmatic';	
        insert newAdexTransactionWeekly;

		//Adex Transaction Weekly data 2
		Adex_Transaction_Weekly__c newAdexTransactionWeekly2 = new Adex_Transaction_Weekly__c();
		newAdexTransactionWeekly2.Adex_Brand__c  = newAdexBrand.id;
    	newAdexTransactionWeekly2.Week__c  = '1' ;
    	newAdexTransactionWeekly2.Section__c = 'L INDUSTRIAL PRODUCTS';
    	newAdexTransactionWeekly2.Month__c   = month; 
		newAdexTransactionWeekly2.Year__c = year;
    	newAdexTransactionWeekly2.Category__c  = 'L1 INDUSTRIAL EQUIPMENT';
    	newAdexTransactionWeekly2.AdSpend__c = 11111;
    	newAdexTransactionWeekly2.Advertiser__c  = 'BODOR';
    	newAdexTransactionWeekly2.AdImp__c = 555.999;
    	newAdexTransactionWeekly2.Product__c = 'BODOR - INDUSTRIAL EQUIPMENT';
    	newAdexTransactionWeekly2.Count_Data__c = 3;
    	newAdexTransactionWeekly2.Brand_Name__c = 'BODOR';
    	newAdexTransactionWeekly2.Brand_Type__c = 'INDUSTRIAL EQUIPMENT';
    	newAdexTransactionWeekly2.Inventory_Type__c  = 'HTML5';
    	newAdexTransactionWeekly2.Buy_Type__c = 'Programmatic';	
        insert newAdexTransactionWeekly2;

        GenerateAdexMonthly GenerateAdexMonthlyCont = new GenerateAdexMonthly();
        GenerateAdexMonthlyCont.execute();
    }
}