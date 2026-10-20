/**
 * @description       : 
 * @author            : Doddy Prima
 * @group             : 
 * @last modified on  : 08-22-2024
 * @last modified by  : Doddy Prima
**/
// Created By Debora E P
// 17 September 2020

trigger Trigger_OppLineItem_After_Insert_Update on OpportunityLineItem (after insert, after update) {

if(label.Trigger_OppLineItem_After_Insert_Update_On == 'YES'){

    List<Adjustment_Log__c> list_adjLog = new List<Adjustment_Log__c>();
        
    for(OpportunityLineItem oli : trigger.New){
        
        if(trigger.isInsert){
        
            if(oli.Opp_Adj_Ver__c >= 1 && oli.Opp_Check_PO__c == null && oli.Opp_Approval_Status__c == null){
                        
                Adjustment_Log__c adjLog = new Adjustment_Log__c();
                adjLog.Product__c = oli.Product2Id;
                adjLog.Action__c = 'Add';
                adjLog.Old_Sales_Price__c = null;
                adjLog.New_Sales_Price__c = oli.UnitPrice;
                adjLog.Old_Quantity__c = null;
                adjLog.New_Quantity__c = oli.Quantity;
                adjLog.Opportunity__c = oli.OpportunityId;
                adjLog.Version__c = oli.Opp_Adj_Ver__c;
                adjLog.Opp_Product_Id__c = oli.Id;
                adjLog.Product_Id_Number__c = oli.Product_id_number__c;
                adjLog.Opportunity_Product__c = oli.Id;                     // add by doddy
                        
                list_adjLog.add(adjLog);
            }
        }
        
        if(trigger.isUpdate){
            
            OpportunityLineItem oldOli = Trigger.oldMap.get(oli.Id);
            
            if(oli.Opp_Adj_Ver__c >= 1 
               && oli.Opp_Check_PO__c == null 
               && oli.Opp_Approval_Status__c == null
               && (oldOli.UnitPrice != oli.UnitPrice || oldOli.Quantity != oli.Quantity)){
                
                Adjustment_Log__c adjLog = new Adjustment_Log__c();
                adjLog.Product__c = oli.Product2Id;
                adjLog.Action__c = 'Change';
                adjLog.Old_Sales_Price__c = oldOli.UnitPrice;
                adjLog.New_Sales_Price__c = oli.UnitPrice;
                adjLog.Old_Quantity__c = oldOli.Quantity;
                adjLog.New_Quantity__c = oli.Quantity;
                adjLog.Opportunity__c = oli.OpportunityId;
                adjLog.Version__c = oli.Opp_Adj_Ver__c;
                adjLog.Opp_Product_Id__c = oli.Id;
                adjLog.Product_Id_Number__c = oli.Product_id_number__c;
                adjLog.Opportunity_Product__c = oli.Id;                     // add by doddy
                        
                list_adjLog.add(adjLog);
                
            }
        }
    }
    
    if(list_adjLog.size() > 0){
        insert list_adjLog;
    }
    
}    
}