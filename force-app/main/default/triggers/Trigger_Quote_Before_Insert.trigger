// Created By Debora E P
// 2 October 2020

trigger Trigger_Quote_Before_Insert on Quote (before insert) {
    
if(label.Trigger_Quote_Before_Insert_On == 'YES'){
    
    if(trigger.isBefore){
        
        if(trigger.isInsert){
            
            for(Quote qt : trigger.New){
                
                List<Quote> existQuote = [SELECT Id, Name, Penagihan__c, SOA__c FROM Quote WHERE OpportunityId =: qt.OpportunityId];
                
                if(existQuote.size() > 0){
                    
                    if(existQuote[0].Penagihan__c == 'Prepaid'){
                        qt.addError('Cannot create more than 1 Quote for 1 Opportunity.');
                    }
                    
                }
            }
        }
    }
}
}