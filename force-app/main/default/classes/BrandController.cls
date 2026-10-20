/*
	Created by Victor
	18 January 2022
*/

Public Class BrandController {
	// Inner class
	public class WrapperAdexBrand{
        public Boolean Selected {get; set;}
        public Adex_Brand__c AdexBrand {get; set;}
        
        WrapperAdexBrand(){
        	AdexBrand = new Adex_Brand__c();
            Selected = false;
        }
    }
	
	Public User user {get;set;}
	Public Brand__c brand {get;set;}
	Public Task task {get;set;}
	Public List<WrapperAdexBrand> listWrapperAdexBrand {get;set;}
	Public List<Adex_Brand__c> listAdexBrand {get;set;}
	Public List<WrapperAdexBrand> listSelectedAdexBrand {get;set;}
	Public Boolean renderedAdexBrand {get;set;}
	Public Boolean renderedTask {get;set;}
	Public Boolean renderedInputTask {get;set;}
	Public Id myAccountId {get;set;}
		
    // Constructor
    public BrandController(ApexPages.StandardController controller) {
    	myAccountId = ((Brand__c)controller.getRecord()).Advertiser__c;
    	user = [SELECT id, name, UserRole.Name FROM user WHERE name = 'Nedya Loeren'];
    	brand = new Brand__c();
    	task = new Task();
    	listWrapperAdexBrand = new List<WrapperAdexBrand>();
    	listAdexBrand = new List<Adex_Brand__c>();
    	renderedAdexBrand = false;
    	renderedTask = false;
    	renderedInputTask = false;
    }
    
    public void checkValid(){
    	listWrapperAdexBrand = new List<WrapperAdexBrand>();
    	
		listAdexBrand = [SELECT id, LOB__c, LOB__r.name, Brand_Salesforce__c FROM Adex_Brand__c WHERE Brand_Salesforce__c like :'%'+brand.name+'%'];
		
		if(listAdexBrand.size() == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'Brand belum terdaftar. Silahkan klik "create task" untuk request pendaftaran brand oleh Marketing'));
        }
		
		for(Adex_Brand__c myAdexBrand : listAdexBrand){
			WrapperAdexBrand newWrapperAdexBrand = new WrapperAdexBrand();
			newWrapperAdexBrand.AdexBrand = myAdexBrand;
			
			listWrapperAdexBrand.add(newWrapperAdexBrand);
		}
		
		renderedAdexBrand = true;
		renderedTask = true;
    }
    
    public PageReference save() {
    	listSelectedAdexBrand = new List<WrapperAdexBrand>();
		
		// Validation start
		
		for(WrapperAdexBrand myWrapperAdexBrand : listWrapperAdexBrand){
    		if(myWrapperAdexBrand.Selected == true){
    			listSelectedAdexBrand.add(myWrapperAdexBrand);
    		}
    	}
    	
        if(listSelectedAdexBrand.size() != 1){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'Please Select 1 Brand Name'));
            return null;
        }
        
        if(brand.PIC_Advertiser__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'Please Fill PIC Advertiser'));
            return null;
        }
        
        if(brand.Product_Name__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'Please Fill Product Name'));
            return null;
        }
        
        // Validation end
        
    	for(WrapperAdexBrand myWrapperAdexBrand : listSelectedAdexBrand){
    		brand.name = myWrapperAdexBrand.AdexBrand.Brand_Salesforce__c;
    		brand.Brand_Category__c = myWrapperAdexBrand.AdexBrand.LOB__c;
			brand.isValidSaved__c = true;
			
			insert brand;
    	}
        
		PageReference pageRef = new ApexPages.StandardController(brand).view();
        pageRef.setRedirect(true);
        return pageRef;
	}
	
	public void createTask(){
		String myRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Create Brand').getRecordTypeId();
		
		task = new Task();
		task.RecordTypeId = myRecordTypeId;
		task.Subject = 'Create Brand';
		task.WhatId = myAccountId;
		task.OwnerId = user.id;
		task.Brand_Name__c = brand.name;
		task.Product_Name__c = brand.Product_Name__c;
		task.PIC_Advertiser__c = brand.PIC_Advertiser__c;
		task.IsReminderSet = true;
		task.ReminderDateTime = DateTime.now();

		renderedInputTask = true;
    }
    
    public PageReference saveTask(){
    	if(brand.name == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'Please Fill Brand Name'));
            return null;
        }
        
        if(brand.PIC_Advertiser__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'Please Fill PIC Advertiser'));
            return null;
        }
        
        if(brand.Product_Name__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'Please Fill Product Name'));
            return null;
        }
        
        if(task.LOB__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.warning,'Please Fill LOB'));
            return null;
        }
    	
    	insert task;
    	
    	PageReference pageRef = new ApexPages.StandardController(task).view(); 
        pageRef.setRedirect(true);
        return pageRef;
    }
}