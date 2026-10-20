/*
    Created By : Victor S
    17 January 2022
    
    This trigger is used to mapping LOB.
*/

trigger Trigger_Adex_Brand on Adex_Brand__c (before update) {
	Map<String, Id> wholeLOB = new Map<String, Id>();
	List<LOB__c> listLOB = new List<LOB__c>();
	
	if(trigger.isBefore && trigger.isUpdate){
		listLOB = [SELECT id, name FROM LOB__c];
		
		for(LOB__c myLOB : listLOB){
			wholeLOB.put(myLOB.name.toLowercase() , myLOB.id);
		}
				
		for(Adex_Brand__c myAdexBrand : trigger.new) {
			if(myAdexBrand.LOB__c == null && myAdexBrand.LOB_Salesforce__c != null){
				myAdexBrand.LOB__c = wholeLOB.get(myAdexBrand.LOB_Salesforce__c.toLowercase());
			}
		}
	}
}