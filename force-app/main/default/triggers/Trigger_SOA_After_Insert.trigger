/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 04-29-2024
 * @last modified by  : Ahmat Zulkifli Murad
**/
// Modified by Debora E P - 6 October 2020

trigger Trigger_SOA_After_Insert on SOA__c (after insert, after update) {
   if (label.Trigger_SOA_After_Insert_ON == 'YES') {
        if(trigger.isafter){
            if(trigger.isinsert){
                System.debug('MASUK AFTER INSERT SOA');
                // if(!Test.isRunningTest()){
                    SoaTriggerHandler.afterInsert(Trigger.new);
                // }             
                /*  for(SOA__c SOANew : system.trigger.new)
                {    
                    SOA__c allSOA = [SELECT Id,Opportunity__c,Name,Account_ID__c FROM SOA__c WHERE Id = :SOANew.id];
                    Order newOrder = new order();
                    newOrder.SOA__c= SOANew.id;
                    newOrder.EffectiveDate = SOANew.SOA_Start_Date__c;
                    newOrder.EndDate= SOANew.SOA_End_Date__c;
                    newOrder.OpportunityId = SOANew.Opportunity__c;
                    newOrder.AccountId = allSOA.Account_ID__c;
                    newOrder.Status = 'Draft';
                    newOrder.SOA_Quotation_No__c = SOANew.Name;
                    insert newOrder;
                    
                    SOA_ID = allSOA.Name;
                    SOA_IDSF = allSOA.Id;
                    OpportunityId = SOANew.Opportunity__c;
                    Account_ID = allSOA.Account_ID__c;
                    
                    List<OpportunityLineItem> SOA_clis = [SELECT Id,OpportunityId,UnitPrice,ListPrice,Discount__c,Quantity,PricebookEntryId,Product_id_number__c,opportunity.Pricebook2Id,Product2Id FROM OpportunityLineItem WHERE OpportunityId= :OpportunityId ORDER BY CreatedDate ASC];
                    AutoNumber=0;
                    for(OpportunityLineItem thisItem : SOA_clis)
                    {
                        AutoNumber=AutoNumber+1;
                        CampaignId = SOA_ID+'_'+thisItem.Product_id_number__c+'_'+AutoNumber;
                        SOA_Detail__c newOi = new SOA_Detail__c(
                            SOA__c = SOA_IDSF,
                            Discount__c= thisItem.Discount__c,
                            List_Price__c= thisItem.ListPrice,Unit_Price__c= thisItem.UnitPrice,Quantity__c = thisItem.Quantity,Product__c=thisItem.Product2Id,Campaign_ID__c=CampaignId,PricebookEntryId__c=thisItem.PricebookEntryId,Start_Date__c=SOANew.SOA_Start_Date__c,End_Date__c=SOANew.SOA_End_Date__c,Opp_Product_Id__c=thisItem.Id);
                        system.debug('+++++ newOi : ' + newOi );
                        
                        SOA_Detail_list.add(newOi);
                        system.debug('+++++ SOA_Detail_list: ' + SOA_Detail_list);
                        TempOpportunityId=thisItem.OpportunityId;
                    }
                        insert SOA_Detail_list;
                }*/                
            }

            if(trigger.isUpdate){
                SoaTriggerHandler.afterUpdate(Trigger.old, Trigger.new);
            }
        }   
    }
}