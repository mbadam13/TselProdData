/**
 * @description       : 
 * @author            : Debora E.P.
 * @group             : 
 * test class         : Trigger_Update_ExpiredBucketTest
 * @last modified on  : 10-19-2023
 * @last modified by  : Ahmat Zulkifli Murad
 *  03/10/2023 tambah week pada saat pembuatan usage - Ahmat Zulkifli Murad
**/
trigger Trigger_Update_ExpiredBucket on Expired_Bucket__c (before update, after update) {

    if(Label.Trigger_Update_ExpiredBucket_On == 'YES'){
        for(Expired_Bucket__c ebRec : trigger.new){
            
            Expired_Bucket__c oldEbRec = Trigger.oldMap.get(ebRec.Id);
            
            if(Trigger.isBefore){
                if(ebRec.Status__c != oldEbRec.Status__c && ebRec.Status__c == 'Confirmed Expired'){
                    ebRec.Confirm_Expired_Date__c = system.today();
                    ebRec.Confirm_Expired_By__c = UserInfo.getUserId();
                }
            }
            
            if(Trigger.isAfter){
                if(ebRec.Status__c != oldEbRec.Status__c){ 
                    if(ebRec.Status__c == 'Confirmed Expired'){ 
                        
                        OrderItem oi = [SELECT Id, OrderItemNumber, EmployeeID_SF__c, NIK__c, Campaign_ID__c FROM OrderItem WHERE Id =: ebRec.Order_Product__c];
                        system.debug('*** oi = ' + oi);
                        
                        // Create usage 
                        Usage__c usage_eb = new Usage__c();
                        usage_eb.Sales__c = oi.EmployeeID_SF__c;
                        usage_eb.OwnerId = oi.EmployeeID_SF__c;
                        usage_eb.Bucket_Detail__c= ebRec.Order_Product__c;
                        usage_eb.NIK__c = oi.NIK__c;
                        usage_eb.Campaign_ID__c = oi.Campaign_ID__c;
                        usage_eb.Amount__c = ebRec.Remaining_Usage__c;
                        usage_eb.Date__c = system.today();
                        usage_eb.Unique_ID__c = usage_eb.Campaign_ID__c + '_' + system.now() + '_' + usage_eb.NIK__c;
                        usage_eb.Expired_Bucket_No__c = ebRec.Name;
                        usage_eb.Usage_for_Expired_Bucket__c = true;
                        usage_eb.week__c = 'Week ' + string.valueOf(AppUtils.weekOfMonth(system.today()));
                        insert usage_eb;
                        system.debug('*** usage_eb = ' + usage_eb);
                    }else if(ebRec.Status__c == 'Extended'){
                        
                        // Update order dengan end date proposed
                        Order orderRec = [SELECT Id, Name, EndDate FROM Order WHERE Id =: ebRec.Order_Id__c];
                        system.debug('*** orderRec = ' + orderRec);
                        
                        orderRec.EndDate = ebRec.Proposed_End_Date__c;
                        update orderRec;
                    }
                    
                }
            }
        }
    }
    
}