/*
	Created by Victor
	28 January 2022
*/

@isTest
private class Test_Trigger_Adex_Brand {

    static testMethod void myUnitTest() {
		LOB__c newLob = new LOB__c();
   		newLob.name = 'test lob';
   		newLob.Active__c = true;
   		insert newLob;
   		
   		Adex_Brand__c newAdexBrand = new Adex_Brand__c();
   		newAdexBrand.Section__c = 'V SERVICES - CORPORATE & PUBLIC SERV ADV';
   		newAdexBrand.Category__c = 'V1 CORPORATE ADS, SOCIAL SERVICES';
   		newAdexBrand.Advertiser__c = 'VININDO';
   		newAdexBrand.Brand_Name__c = 'VININDO';
   		newAdexBrand.Brand_Type__c = 'CORPORATE';
   		insert newAdexBrand;
   		
   		newAdexBrand.Brand_Salesforce__c = 'test brand';
   		newAdexBrand.LOB_Salesforce__c = 'test lob';
   		update newAdexBrand;
    }
}