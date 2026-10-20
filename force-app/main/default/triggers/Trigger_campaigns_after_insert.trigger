/**

**/
trigger Trigger_campaigns_after_insert on Campaigns__c (after insert, before insert, before update) {
    if (label.Trigger_campaigns_after_insert_On== 'YES') {
        if(trigger.isAfter){ 
            if(trigger.isInsert){
                TH_CampIklans_TriggerHandler.afterInsertHandler(Trigger.new);
            }
        }
        
        if(trigger.isBefore){
            if(trigger.isInsert){
                TH_CampIklans_TriggerHandler.beforeInsertHandler(Trigger.new);  
            }
        }
    }
}