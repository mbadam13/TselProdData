global with sharing class Schedule_ExpiredBucket implements Schedulable {
    
	// Daily Scheduler
    global void execute(SchedulableContext sc){
        
        String emailErrorRecipient = Label.KK_EmailError_Recipient;
        emailErrorRecipient = emailErrorRecipient.trim();
        String [] email = emailErrorRecipient.split(','); system.debug('*** email = ' + email);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        try{
        
            Date executeDate = null;
            if(!Test.isRunningTest()){
                executeDate = system.today();
                if(label.ManualRunSchedulerClass == 'YES'){executeDate = date.parse(Label.SchDateForTesting);} // For Run Manual
            }else{
                executeDate = system.today();
            } 
            system.debug('*** executeDate = ' + executeDate);
            
            // -------------------------------------------------- Get Prepaid Order -------------------------------------------------- //
            List<Order> orderList = [SELECT Id, Name FROM Order 
                                     WHERE Expired_Notif_Date__c =: executeDate 
                                     AND Opportunity.Penagihan_based_on__c = 'Prepaid' 
                                     AND Status = 'Running'
                                    ];
            system.debug('***orderList = ' + orderList.size() + ' | ' + orderList);
            
            List<Id> orderIdList = new List<Id>();
            for(Order orderRec : orderList){
                orderIdList.add(orderRec.Id);
            }
            
            // -------------------------------------------------- Get Usage -------------------------------------------------- //
            AggregateResult[] usage_agr = [SELECT Bucket_Detail__c OrderProduct, SUM(Amount__c) QtyUsage 
                                           FROM Usage__c  
                                           WHERE Bucket_Detail__r.OrderId IN: orderIdList 
                                           GROUP BY Bucket_Detail__c];
            system.debug('*** usage_agr = ' + usage_agr.size() + ' | ' + usage_agr);
            
            Map<Id,Decimal> map_oiId_oiUsg = new Map<Id,Decimal>();
            for(AggregateResult usg : usage_agr){
                
                Id oi_id = (Id) usg.get('OrderProduct');
                Decimal oi_qtyUsg = (Decimal) usg.get('QtyUsage');
                
                map_oiId_oiUsg.put(oi_id,oi_qtyUsg);
            }
            system.debug('*** map_oiId_oiUsg = ' + map_oiId_oiUsg.size() + ' | ' + map_oiId_oiUsg);
            
            // -------------------------------------------------- Get Order Product -------------------------------------------------- //
            List<OrderItem> orderItemList = [SELECT Id, OrderItemNumber, Quantity, Order.EndDate,  
                                                    OrderId, Order.OrderNumber, Product2Id, Product2.Name, Order.Opportunity.OwnerId 
                                             FROM OrderItem WHERE OrderId =: orderIdList];
            system.debug('*** orderItemList = ' + orderItemList.size() + ' | ' + orderItemList);
            
            List<Expired_Bucket__c> ebList = new List<Expired_Bucket__c>();
            
            for(OrderItem oi : orderItemList){
                
                Decimal qty_out = map_oiId_oiUsg.get(oi.Id);
                if(qty_out == null){qty_out = 0;}
                
                Decimal qty_in = oi.Quantity;
                
                Decimal saldo = qty_in - qty_out; system.debug('*** saldo = ' + saldo);
                
                if(saldo > 0){
                    Expired_Bucket__c eb = new Expired_Bucket__c();
                    eb.Order_Product__c = oi.Id;
                    eb.Remaining_Usage__c = saldo;
                    eb.Status__c = 'Waiting Confirmation';
                    eb.Current_End_Date__c = oi.Order.EndDate; 
                    eb.OwnerId = oi.Order.Opportunity.OwnerId;
                    ebList.add(eb);
                    system.debug('*** eb = ' + eb);
                    system.debug('*** oi Order = ' + oi.OrderId + ' | ' + oi.Order.OrderNumber);
                    system.debug('*** oi Product = ' + oi.Product2Id + ' | ' + oi.Product2.Name);
                    system.debug('*** eb saldo = ' + saldo);
                }
            }
            system.debug('*** ebList = ' + ebList.size() + ' | ' + ebList);
            
            insert ebList;
        	
        }
        catch(exception e)
        {
			// Below code will send an email to User about the status
            mail.setToAddresses(email);
            mail.setReplyTo(Label.KK_EmailError_ReplyTo);
            mail.setSenderDisplayName('Apex Catch Processing Module');
            mail.setSubject('Catch Processing');
            String body = 'Error on Schedule_ExpiredBucket function <br/><br/> Error Message :: ' + e.getmessage() + '<br/> Line :: ' + e.getLineNumber();
            mail.setHtmlBody(body);
            system.debug('*** Error on Schedule_ExpiredBucket function == Line ' + e.getLineNumber() + ' | Message : ' + e.getmessage());
            Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
        }
        
    }
}