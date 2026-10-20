/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 10-19-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
// Created By Debora E P
// 27 September 2020

trigger Trigger_OrderProduct_Before_Insert_Update on OrderItem (before insert, before update, after update) {
    
    if(label.Trigger_OrderProduct_Before_Insert_Update_On == 'YES'){
        
        if(trigger.isBefore){
            
            if(trigger.isUpdate){
                
                for(OrderItem oi : trigger.new){
                    if(oi.Opportunity__c != null){
                        OrderItem oldOi = trigger.oldMap.get(oi.Id);
                    
                        system.debug('*** oldOi.Quantity = ' + oldOi.Quantity);
                        system.debug('*** oi.Quantity = ' + oi.Quantity);
                        
                        if(oi.Quantity != oldOi.Quantity){
                            
                            AggregateResult[] usg_aggr = [SELECT sum(Amount__c) usg, Campaign_ID__c FROM Usage__c
                                                        WHERE Bucket_Detail__c =: oi.Id
                                                        GROUP BY Campaign_ID__c];
                            
                            system.debug('*** usg_aggr.size() = ' + usg_aggr.size());
                            system.debug('*** usg_aggr = ' + usg_aggr);
                                                
                            if(usg_aggr.size() == 1){
                                
                                system.debug('*** usg_aggr[0].get(\'usg\') = ' + usg_aggr[0].get('usg'));
                                
                                Decimal usgAct = (Decimal)usg_aggr[0].get('usg');
                                
                                system.debug('*** usgAct = ' + usgAct);
                                
                                // Validasi Qty Order tidak boleh lebih kecil dari Usage Actual
                                if(oi.Quantity < usgAct){
                                    oi.addError('Quantity cannot less than Usage Actual.');
                                }
                            }else{
                                if(usg_aggr.size() > 1){
                                    oi.addError('Check Usage : Multiple Campaign ID (' + usg_aggr.size() + ') for same Order Product.');
                                }
                            }
                            
                            AggregateResult[] oi_aggr = [SELECT sum(Quantity) sq, Opp_Product_Id__c FROM OrderItem 
                                                        WHERE Opportunity__c = : oi.Opportunity__c  
                                                        AND Opp_Product_Id__c =: oi.Opp_Product_Id__c 
                                                        GROUP BY Opp_Product_Id__c];
                            
                            system.debug('*** oi_aggr.size() = ' + oi_aggr.size());
                            system.debug('*** oi_aggr = ' + oi_aggr);
                            
                            if(oi_aggr.size() == 1){
                                
                                system.debug('*** oi_aggr[0].get(\'sq\') = ' + oi_aggr[0].get('sq'));
                                
                                Decimal totQty = (Decimal)oi_aggr[0].get('sq') - oldOi.Quantity + oi.Quantity;
                                
                                system.debug('*** totQty = ' + totQty);
                                
                                List<OpportunityLineItem> oli = [SELECT Id, Quantity FROM OpportunityLineItem WHERE Id =: oi.Opp_Product_Id__c];
                                
                                // Validasi Total Qty Order Product tidak boleh lebih besar dari Qty di OLI
                                if(oli.size() > 0){
                                    if(oli[0].Quantity < totQty){
                                        oi.addError('Total Quantity in Order Product cannot greater than Quantity in Opportunity Product : ' + totQty + ' > ' + oli[0].Quantity);
                                    }
                                }else{
                                    
                                    system.debug('Opportunity Product cannot found.');
                                    
                                    //oi.Quantity = 0; // Can't save order products with quantities of zero: Quantity
                                    oi.UnitPrice = 0;
                                }
                                
                            }else{
                                oi.addError('Check Opp_Product_Id__c ! ' + oi_aggr.size());
                            }
                            
                        }
                    }
                    
                    
                }
            }
        }
        if(trigger.isAfter){
            if(trigger.isUpdate){
                map<id, orderitem> oldMap = new map<id, orderitem>(Trigger.old);
                map<id, orderitem> orderItemMap = new map<id, orderitem>();
                set<string> orderItemIds = new set<string>();  // for triggering usage to update amount in monthly sales target
                set<string> orderItemOrderCompletedIds = new set<string>(); // untuk completedkan order 

                for(orderItem newOrderItem :Trigger.new ){
                    orderitem oldOrderItem = oldMap.get(newOrderItem.Id);
                    orderItemMap.put(newOrderItem.id, newOrderItem);

                    if(
                        (newOrderItem.usage_actual__c != oldOrderItem.usage_actual__c) &&
                        (newOrderItem.Monthly_Traffic_Unique_Id__c != null && newOrderItem.Monthly_Traffic_Unique_Id__c != '')
                    ){
                        orderItemIds.add(newOrderItem.id);
                    }

                    if(
                        (newOrderItem.Monthly_Traffic_Unique_Id__c != null && newOrderItem.Monthly_Traffic_Unique_Id__c != '') &&
                        ((oldOrderItem.Campaign_Status__c != newOrderItem.Campaign_Status__c) && newOrderItem.Campaign_Status__c == 'Completed' )
                    ){
                        orderItemOrderCompletedIds.add(newOrderItem.orderid);
                    }
                }

                if(!orderItemIds.isEmpty()){
                    List<Usage__c> usageList = [
                            SELECT id, 
                            amount__c, 
                            Monthly_Traffic_Unique_id__c, 
                            Bucket_Detail__c 
                            FROM Usage__c 
                            WHERE bucket_detail__c IN:orderItemIds  
                    ];

                    list<Usage__c> usagetoUpdateList = new list<Usage__c>();
                    for(Usage__c usageListRec :usageList){
                        orderItem orderItemMapRec = (orderItemMap != null) ? orderItemMap.get(usageListRec.Bucket_Detail__c) : null;
                        usageListRec.Monthly_Traffic_Unique_id__c = orderItemMapRec.Monthly_Traffic_Unique_id__c;

                        usagetoUpdateList.add(usageListRec);
                    }

                    if(!usagetoUpdateList.isempty()){
                        update usagetoUpdateList;
                    }
                }
                
                if(!orderItemOrderCompletedIds.isEmpty()){
                    list<order> orderList = [SELECT id, status from order where id IN:orderItemOrderCompletedIds];

                    list<order> ordertoUpdateList = new list<order>();
                    for(order orderListRec :orderList){
                        orderListRec.Status  = 'Completed';

                        ordertoUpdateList.add(orderListRec);
                    }

                    if(!ordertoUpdateList.isEmpty()){
                        update ordertoUpdateList;
                    }
                }
            }
        }
    }
}