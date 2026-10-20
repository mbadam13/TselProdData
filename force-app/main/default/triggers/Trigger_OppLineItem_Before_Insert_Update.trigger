// Created By Debora E P
// 17 September 2020

trigger Trigger_OppLineItem_Before_Insert_Update on OpportunityLineItem (before insert, before update) {

if(label.Trigger_OppLineItem_Before_Insert_Update_On == 'YES'){

    if(trigger.isBefore){
        
        if(trigger.isUpdate){
            
            for(OpportunityLineItem oli : trigger.New){
                
                OpportunityLineItem oldOli = Trigger.oldMap.get(oli.Id);
                
                system.debug('*** oli.Opp_Adj_Ver__c = ' + oli.Opp_Adj_Ver__c);
                system.debug('*** oli.Opp_Check_PO__c = ' + oli.Opp_Check_PO__c);
                system.debug('*** oli.Opp_Approval_Status__c = ' + oli.Opp_Approval_Status__c);
                system.debug('*** oli.UnitPrice = ' + oli.UnitPrice);
                system.debug('*** oldOli.UnitPrice = ' + oldOli.UnitPrice);
                system.debug('*** oli.Quantity = ' + oli.Quantity);
                system.debug('*** oldOli.Quantity = ' + oldOli.Quantity);
                
                if(oli.Opp_Adj_Ver__c >= 1 
                   && oli.Opp_Check_PO__c == null 
                   && oli.Opp_Approval_Status__c == null
                   && (oldOli.UnitPrice != oli.UnitPrice || oldOli.Quantity != oli.Quantity)){
                    
                    system.debug('*** Ada perubahan OLI !!!');
                    
                    AggregateResult[] orderitem_aggr = [SELECT sum(Quantity) qtyOI, Opp_Product_Id__c FROM OrderItem WHERE Opportunity__c =: oli.OpportunityId GROUP BY Opp_Product_Id__c];
                    
                    system.debug('*** orderitem_aggr.size() = '+ orderitem_aggr.size());
                    system.debug('*** orderitem_aggr = '+ orderitem_aggr);
                    
                    Double totQty = 0;
                    Map<String,Double> orderItemtMap = new Map<String,Double>();
                    for(AggregateResult ar : orderitem_aggr) {
                        totQty = (Decimal) ar.get('qtyOI') ;
                        orderItemtMap.put((String) ar.get('Opp_Product_Id__c'),Double.valueof(totQty));
                    }
                    system.debug('*** orderItemtMap.size() = ' + orderItemtMap.size());
                    system.debug('*** orderItemtMap = ' + orderItemtMap);
                     
                    //validasi dibawah sudah tidak dibutuhkan 29-07-2024
                    /*if(oldOli.Quantity != oli.Quantity && oldOli.UnitPrice == oli.UnitPrice){
                        
                        Double TotalQty = orderItemtMap.get(oli.Id);
                        
                        system.debug('*** TotalQty = ' + TotalQty);
                        
                        if(TotalQty != null){
                            if(oli.Quantity < orderItemtMap.get(oli.Id)){
                                oli.addError('Quantity cannot less than Total Quantity in Order Product : ' + oli.Quantity + ' < ' + orderItemtMap.get(oli.Id));
                            }
                        }
                    }*/
                }
            }
        }
    }
}    
}