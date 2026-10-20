// Created By Debora E P
// 29 September 2020

trigger Trigger_Order_After_Update on Order (before update, after update) {
    
if (label.Trigger_Order_After_Update_On == 'YES'){
    
    if(trigger.isUpdate){
        
        if(trigger.isBefore){
            
            for(Order ord : trigger.new){
                
                Order oldOrd = trigger.oldMap.get(ord.Id);
                
                if(ord.Status == 'Running' && oldOrd.Status <> 'Running'){
                    
                    Order ord_rec = [SELECT Id, Name, Opportunity.StageName, Opportunity.Approval_Status__c FROM Order WHERE Id =: ord.Id];
                    
                    if(ord_rec.Opportunity.StageName <> 'Closed Won' || ord_rec.Opportunity.Approval_Status__c <> 'Approved'){
                        
                        ord.addError('Order will be run only for Closed Won & Approved Opportunity.');
                    }
                }
                
                if(ord.Status == 'Completed' && oldOrd.Status <> 'Completed'){
                    ord.Order_Completed_Date__c = system.today();
                }
            }
        }
    }
}
}