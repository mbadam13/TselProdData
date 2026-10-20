global with sharing class Schedule_EB_ConfirmedExpired implements Schedulable {
    
	// Daily Scheduler
    global void execute(SchedulableContext sc){
        
        Date executeDate = null;
        if(!Test.isRunningTest()){
            executeDate = system.today();
            if(label.ManualRunSchedulerClass == 'YES'){executeDate = date.parse(Label.SchDateForTesting);} // For Run Manual
        }else{
            executeDate = system.today().addDays(7);
        } 
        system.debug('*** executeDate = ' + executeDate);
        
        // --------------------------------------- Check Usage then Auto Confirmed Expired / Full Usage --------------------------------------- //
        List<Expired_Bucket__c> ebToConfirm_list = [SELECT Id, Name, Order_Product__c, Order_Product__r.OrderItemNumber, Status__c, Remaining_Usage__c 
                                                    FROM Expired_Bucket__c 
                                               		WHERE Status__c = 'Waiting Confirmation'
                                                    AND Confirm_Expired_Date__c = null 
                                                   	AND Order_End_Date__c =: executeDate];
        system.debug('*** ebToConfirm_list = ' + ebToConfirm_list.size() + ' | ' + ebToConfirm_list);
        
        if(ebToConfirm_list.size() > 0){
            
            List<String> orderItemIdList = new List<String>();
            
            for(Expired_Bucket__c eb : ebToConfirm_list){
                orderItemIdList.add(eb.Order_Product__c);
            }
            system.debug('*** orderItemIdList.size() = ' + orderItemIdList.size());
            
            //--- Query & create map for total usage per order product ---//
            AggregateResult[] usage_agr = [SELECT Bucket_Detail__c OrderProduct, SUM(Amount__c) QtyUsage 
                                           FROM Usage__c  
                                           WHERE Bucket_Detail__c IN: orderItemIdList 
                                           GROUP BY Bucket_Detail__c];
            system.debug('*** usage_agr = ' + usage_agr.size() + ' | ' + usage_agr);
            
            Map<Id,Decimal> map_oiId_oiUsg = new Map<Id,Decimal>();
            for(AggregateResult usg : usage_agr){
            
                Id oi_id = (Id) usg.get('OrderProduct');
                Decimal oi_qtyUsg = (Decimal) usg.get('QtyUsage');
                
                map_oiId_oiUsg.put(oi_id,oi_qtyUsg);
            }
            system.debug('*** map_oiId_oiUsg = ' + map_oiId_oiUsg.size() + ' | ' + map_oiId_oiUsg);
            
            //--- Query quantity & create map for saldo per order product ---//
            List<OrderItem> orderItemList = [SELECT Id, OrderItemNumber, Quantity, Usage_Actual__c FROM OrderItem WHERE Id IN: orderItemIdList];
            system.debug('*** orderItemList.size() = ' + orderItemList.size());
            
            Decimal saldo = 0;
            Map<Id,Decimal> map_oiId_saldo = new Map<Id,Decimal>();
            for(OrderItem oiRec : orderItemList){
                
                Decimal qty_out = map_oiId_oiUsg.get(oiRec.Id);
                if(qty_out == null){qty_out = 0;}
                Decimal qty_in = oiRec.Quantity;
                saldo = qty_in - qty_out;
                
                map_oiId_saldo.put(oiRec.Id,saldo);
            }
            system.debug('*** map_oiId_saldo = ' + map_oiId_saldo.size() + ' | ' + map_oiId_saldo);
                        
            //--- Query & create map for total usage per order product ---//
            for(Expired_Bucket__c ebToConfirm_rec : ebToConfirm_list){
                
                Decimal saldo_orderItem = map_oiId_saldo.get(ebToConfirm_rec.Order_Product__c);
                system.debug('*** saldo_orderItem = ' + saldo_orderItem + ' | EB ' + ebToConfirm_rec.Id + '-' + ebToConfirm_rec.Name + ' | OI ' + ebToConfirm_rec.Order_Product__c + '-' + ebToConfirm_rec.Order_Product__r.OrderItemNumber);
                
                if(saldo_orderItem > 0){
                    ebToConfirm_rec.Status__c = 'Confirmed Expired';
                    if(ebToConfirm_rec.Remaining_Usage__c != saldo_orderItem){ebToConfirm_rec.Remaining_Usage__c = saldo_orderItem;}
                }else{
                    ebToConfirm_rec.Status__c = 'Full Usage';
                }
                
            }
            system.debug('*** ebToConfirm_list akhir = ' + ebToConfirm_list.size() + ' | ' + ebToConfirm_list);
            
            //--- Batch update record Expired Bucket ---//
            if(Label.Execute_Batch_EB_ConfirmedExpired == 'YES'){Id batchInstanceId = Database.executeBatch(new Batch_EB_ConfirmedExpired(ebToConfirm_list), 5);}
        }
                
	}

}