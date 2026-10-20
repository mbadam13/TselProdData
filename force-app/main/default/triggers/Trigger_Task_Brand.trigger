/*
    Created By : Victor S
    24 January 2022
    
    This trigger is used to create brand after status = completed
*/

trigger Trigger_Task_Brand on Task (after update) {
    for(Task myTask : trigger.new) {
    	if(myTask.Subject == 'Create Brand' && myTask.Status == 'Completed'){
    		Brand__c newBrand = new Brand__c();
    		newBrand.name = myTask.Brand_Name__c;
    		newBrand.Product_Name__c = myTask.Product_Name__c;
    		newBrand.PIC_Advertiser__c = myTask.PIC_Advertiser__c;
    		newBrand.Advertiser__c = myTask.WhatId;
    		newBrand.Brand_Category__c = myTask.LOB__c;
    		newBrand.isValidSaved__c = true;
    		
    		insert newBrand;
    	}
    }
}