trigger Trigger_Delete_PerformanceCampaign on PERFORMANCE_Campaign__c (after delete) {
    List<Opportunity> oppList_update = new List<Opportunity>();
	for(PERFORMANCE_Campaign__c pcRec : trigger.old){
		List<Opportunity> oppList = [SELECT Id, Name, PC_Form_Counter__c FROM Opportunity WHERE Id =: pcRec.Campaign_Name__c];
        if(oppList.size() > 0){
        	oppList[0].PC_Form_Counter__c = oppList[0].PC_Form_Counter__c - 1;
            oppList_update.add(oppList[0]);
        }
   	}
    if(oppList_update.size() > 0){
    	update oppList_update;
   	}
}