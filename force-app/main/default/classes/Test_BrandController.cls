/*
	Created by Victor
	21 February 2022
	
*/

@isTest
private class Test_BrandController {

    static testMethod void myUnitTest() {
    	Account newAccount = new Account();
    	newAccount.name = 'test account';
    	insert newAccount;
    	
    	Contact newContact =  new Contact();
    	newContact.lastname = 'test name';
    	newContact.accountId = newAccount.id;
    	insert newContact;
    	
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
   		newAdexBrand.Brand_Salesforce__c = 'test brand';
   		newAdexBrand.LOB__c = newLob.id;
   		
   		insert newAdexBrand;
    	
        Brand__c myBrand = new Brand__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(myBrand);
        BrandController myBrandController = new BrandController(sc);
        
        // METHOD checkValid
        // test validation
        myBrandController.brand.name = 'testing';
        myBrandController.checkValid();
        
        //test main method
        myBrandController.brand.name = 'test brand';
        myBrandController.checkValid();
        
        // METHOD save
        // test validation
        myBrandController.save();
        
        for(BrandController.WrapperAdexBrand myWrapperAdexBrand : myBrandController.listWrapperAdexBrand){
        	myWrapperAdexBrand.Selected = true;
        }
        myBrandController.save();
        
        myBrandController.brand.PIC_Advertiser__c = newContact.id;
        myBrandController.save();
        
        myBrandController.brand.Product_Name__c = 'test product name';
        
        //test main method
        myBrandController.save();
        
        // METHOD createTask
        //test main method
        myBrandController.createTask();
        
        // METHOD saveTask
        // test validation
        myBrandController.brand.name = null;
        myBrandController.brand.PIC_Advertiser__c = null;
        myBrandController.brand.Product_Name__c = null;
        
        myBrandController.saveTask();
        
        myBrandController.brand.name = 'test brand';
        myBrandController.saveTask();
        
        myBrandController.brand.PIC_Advertiser__c = newContact.id;
        myBrandController.saveTask();
        
        myBrandController.brand.Product_Name__c = 'test product name';
        myBrandController.saveTask();
        
        myBrandController.task.LOB__c = newLob.id;
        
        //test main method
        myBrandController.saveTask();
    }
}