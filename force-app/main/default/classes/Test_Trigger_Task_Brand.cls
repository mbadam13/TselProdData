/*
	Created by Victor
	28 January 2022
*/

@isTest
private class Test_Trigger_Task_Brand {

    static testMethod void myUnitTest() {
    	Account newAccount = new Account();
    	newAccount.name = 'test account';
    	insert newAccount;
    	
    	Contact newContact = new Contact();
    	newContact.lastName = 'test contact';
    	insert newContact;
    	
    	LOB__c newLob = new LOB__c();
   		newLob.name = 'test lob';
   		insert newLob;
    	
        Task newTask = new Task();
		newTask.Subject = 'Create Brand';
		newTask.WhatId = newAccount.id;
		newTask.OwnerId = UserInfo.getUserId();
		newTask.Brand_Name__c = 'test brand';
		newTask.Product_Name__c = 'test product';
		newTask.PIC_Advertiser__c = newContact.id;
		newTask.LOB__c = newLob.id;
        insert newTask;
        
        newTask.Status = 'Completed';
        update newTask;
    }
}