// Modified by Debora E P - 6 October 2020

trigger Trigger_Opportunity_Before_Insert on Opportunity(before insert, before update) {
    if (label.Trigger_Opportunity_Before_Insert_On== 'YES') {
        If(trigger.isBefore)
        {
            If(Trigger.isInsert){                
                for(Opportunity newOppty :system.trigger.new)
                {                  
                    if(newOppty.getCloneSourceId()!=Null)
                    {
                        newOppty.Opportunity_Related__c=newOppty.getCloneSourceId();
                    }
                    
                    //Stamping Contract
                    List<Contract> newContractRec = [Select id, Name 
                                                     FROM Contract 
                                                     WHERE AccountId =: newOppty.AccountId 
                                                     and archive__c = False 
                                                     and StartDate <= TODAY 
                                                     and EndDate >= TODAY
                                                     ORDER BY CreatedDate 
                                                     DESC LIMIT 1];
                    if(newContractRec.size() > 0)
                    {
                        newOppty.ContractId = newContractRec[0].id;
                    }else{
                        //newOppty.addError('Mohon untuk create contract terlebih dahulu');
                    }
                    
                    //====================================================================                    
                } 
            }
            
            if(trigger.isUpdate){                
                for(Opportunity opp : trigger.New){
                    system.debug('Opp ====' + opp.StageName); 
                                     
                    
                    Opportunity oppOld = trigger.oldMap.get(opp.Id);                    
                    if(oppOld.StageName == 'Closed Won' && opp.StageName != oppOld.StageName){
                        system.debug('StageName = ' + oppOld);  
                        if(opp.Penagihan_based_on__c == 'Prepaid'){
                            
                            List<Quote> qListCheck = [SELECT Id, Name, IsSyncing 
                                                      FROM Quote 
                                                      WHERE OpportunityId =: opp.Id 
                                                      ORDER BY CreatedDate ASC];                           
                            if(qListCheck.size() == 1){
                                if(!Test.isRunningTest()){
                                    if(qListCheck[0].IsSyncing == false){
                                        opp.addError('Please start sync Quotation "' + qListCheck[0].Name + '" before adjust Opportunity Product.');
                                    }
                                }
                            }else{
                                if(qListCheck.size() > 1){
                                    opp.addError('There are more than 1 Quotation.');
                                }
                            }
                        }
                        
                        if(oppOld.Adjustment_Version__c == null){
                            opp.Adjustment_Version__c = 1;
                        }else{
                            opp.Adjustment_Version__c = oppOld.Adjustment_Version__c + 1;
                        }                                                  
                    }                
                }                
            }
        }
    }
}