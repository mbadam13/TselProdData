/**
 * @description       : 
 * @author            : Doddy Prima
 * @group             : 
 * @last modified on  : 06-27-2024
 * @last modified by  : Doddy Prima
**/
// Modified by Debora E P - 6 October 2020

trigger DeleteTrigger on OpportunityLineItem (Before Delete, after delete) {
    
	if (label.Trigger_Opportunityproduct_Before_Delete_On== 'YES') {
        
		If(trigger.isBefore){
            
   			If(Trigger.isDelete){
                
                system.debug('*** trigger.old BEFORE = ' + trigger.old);
                
       			for(OpportunityLineItem a: trigger.old){
                    
           			if(a.Marketing_Package__c=='Yes'){
               			a.adderror(' You cant delete Marketing Package Product');
                 	}
                    
                    if(a.Opportunity_Status__c == 'Closed Won'){
                        a.addError('Cannot delete Opportunity Product for Closed Won Opportunity.');
                    }
                    
                    system.debug('*** a.Opp_Adj_Ver__c - Before = ' + a.Opp_Adj_Ver__c);

                    /** 
                     ** Deactive this Validation for new rules of opportunity product changes AFTER Closed Won
                        by Doddy  June 27, 2024
                    
                    if(a.Opp_Adj_Ver__c >= 1){
                        
                        List<OrderItem> oilistcheck = [SELECT Id, OrderItemNumber , OrderId, Order.OrderNumber FROM OrderItem WHERE Opp_Product_Id__c =: a.Id ORDER BY CreatedDate DESC];
                        
                        system.debug('*** oilistcheck.size() = ' + oilistcheck.size());
                        system.debug('*** oilistcheck = ' + oilistcheck);
                        
                        if(oilistcheck.size() > 0){
                            a.addError('Cannot delete this Opportunity Product due to Order Product "'+ oilistcheck[0].OrderItemNumber + '" in Order "' + oilistcheck[0].Order.OrderNumber +'"');
                        }
                    }
                    */
                    
             	}
        	}
   		}
        
		If(trigger.isAfter){
            
   			If(Trigger.isDelete){
                
                List<Adjustment_Log__c> list_adjLog = new List<Adjustment_Log__c>();
                
                system.debug('*** trigger.old AFTER = ' + trigger.old);
                
                for(OpportunityLineItem o: trigger.old){
                    
                    system.debug('*** o.Opp_Adj_Ver__c - After = ' + o.Opp_Adj_Ver__c);
                    system.debug('*** o.Opp_Check_PO__c - After = ' + o.Opp_Check_PO__c);
                    system.debug('*** o.Opp_Approval_Status__c - After = ' + o.Opp_Approval_Status__c);

            		if(o.Opp_Adj_Ver__c >= 1 && o.Opp_Check_PO__c == null && o.Opp_Approval_Status__c == null){
                        
                        system.debug('*** Action Delete Opp Product - After!!!');
                        
                        Adjustment_Log__c adjLog = new Adjustment_Log__c();
                        adjLog.Product__c = o.Product2Id;
                        adjLog.Action__c = 'Delete';
                        adjLog.Old_Sales_Price__c = o.UnitPrice;
                        adjLog.New_Sales_Price__c = null;
                        adjLog.Old_Quantity__c = o.Quantity;
                        adjLog.New_Quantity__c = null;
                        adjLog.Opportunity__c =o.OpportunityId;
                        adjLog.Version__c = o.Opp_Adj_Ver__c;
                        adjLog.Opp_Product_Id__c = o.Id;
                        adjLog.Product_Id_Number__c = o.Product_id_number__c;
                                        
                        list_adjLog.add(adjLog);
            		}
                }
                
                if(list_adjLog.size() > 0){
                    insert list_adjLog;
                }
            }
        }
        
	}
    
}