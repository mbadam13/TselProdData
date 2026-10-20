trigger Trigger_Insert_PerformanceCampaign on PERFORMANCE_Campaign__c (before insert, after insert) {
    
    if(trigger.isBefore){
        for(PERFORMANCE_Campaign__c pcRec : trigger.new){
            List<PERFORMANCE_Campaign__c> pcList_check = [SELECT Id, Name FROM PERFORMANCE_Campaign__c WHERE Campaign_Name__c =: pcRec.Campaign_Name__c];
            if(pcList_check.size() > 0){
                pcRec.addError('There is Performance Campaign "' + pcList_check[0].Name + '" for this Opportunity.');
            }
        }
    }
    
    if(trigger.isAfter){
        List<Opportunity> oppList_update = new List<Opportunity>();
        for(PERFORMANCE_Campaign__c pcRec : trigger.new){
            List<Opportunity> oppList = [SELECT Id, Name, PC_Form_Counter__c FROM Opportunity WHERE Id =: pcRec.Campaign_Name__c];
            if(oppList.size() > 0){
            	oppList[0].PC_Form_Counter__c = oppList[0].PC_Form_Counter__c + 1;
                oppList_update.add(oppList[0]);
            }
        }
        if(oppList_update.size() > 0){
        	update oppList_update;
        }
    }
}