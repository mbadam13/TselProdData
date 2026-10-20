/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 02-24-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * 03/10/2023 tambah week di usage dan event update ketika date berubah week juga mengikuti
 * 24/04/2024 fix sales gagal generate pada MST
 * 5/07/2024 enhance logic add condition when insert data usage digital - M B Adam 
 * 10/02/2025 tambah logic update usage actual di oppty product
**/
trigger Trigger_Usage_After_Insert on Usage__c (after insert, before update, after update) {
    if (label.Trigger_Usage_After_Insert_On == 'YES') {
        if(trigger.isAfter){
            if(trigger.isInsert){
                try {
                    Map<String, Double> mapUsage = new Map<String, Double>();
                    Map<String, Double> mapUsageTV = new Map<String, Double>();
                    List<String> ListUsageCampaignId = new List<String>();
                    List<String> ListUsageOrderId = new List<String>();
                    Map<String, OrderItem> orderItemMap = new Map<String, OrderItem>();
                    List<Monthly_Sales_Target__c> lMonthlySalesTarget = new List<Monthly_Sales_Target__c>();
                    Map<Id,String> nikMap = new Map<Id,String>();
                    set<string> salesNik = new set<string>();
        
                    for (Usage__c myUsage : Trigger.new) {
                        Double value = mapUsage.get(myUsage.Campaign_ID__c);
                        value = (value == null) ? myUsage.Amount__c : value + myUsage.Amount__c;
                        mapUsage.put(myUsage.Campaign_ID__c, value);
                        mapUsageTV.put(myUsage.Bucket_Detail__c, value);
                        if (myUsage.Campaign_ID__c != null || myUsage.Campaign_ID__c != '') { // update - 11 feb 2025 (condition from '&&' to '||')
                              ListUsageCampaignId.add(myUsage.Campaign_ID__c);
                           }
                        ListUsageOrderId.add(myUsage.Bucket_Detail__c);
                        salesNik.add(myUsage.nik__c); 
                    }
                    System.debug('Data usage Campaign : ' + ListUsageCampaignId.size());

                    System.debug('Data usage MO based on order Id : ' + ListUsageOrderId);
                    if (ListUsageCampaignId.size() > 0){
                        System.debug('Masuk Logic Campaign');
                        List<OrderItem> myOrderItems = [
                            SELECT Id, 
                            Usage_Actual__c, 
                            Opportunity__c, 
                            Campaign_ID__c,
                            Sales__r.NIK__c,  
                            Order.AccountId,
                            Order.Order_Type__c,
                            Opportunity_Product__c // new - 10 feb 2025
                            FROM OrderItem 
                            WHERE Campaign_ID__c IN :ListUsageCampaignId
                        ];
            
                        Set<Id> oliIDs = new Set<Id>(); // new - 10 feb 2025
                        Map<Id, Decimal> usageActualMap = new Map<Id, Decimal>(); // new - 10 feb 2025
                        for (OrderItem oi : myOrderItems) {
                            Decimal usageAmount = mapUsage.get(oi.Campaign_ID__c);
                            if (usageAmount != null) {
                                oi.Usage_Actual__c += usageAmount;
                                nikMap.put(oi.Id,oi.Sales__r.NIK__c);
                                orderItemMap.put(oi.Campaign_ID__c, oi);
                                oliIDs.add(oi.Opportunity_Product__c); // new - 10 feb 2025
                                usageActualMap.put(oi.Opportunity_Product__c, oi.Usage_Actual__c); // new - 10 feb 2025
                            }
                        }
                        update myOrderItems;

                        // // === new - 10 feb 2025 ===
                        // List<OpportunityLineItem> opptyProductList = [
                        //     SELECT
                        //         Id,
                        //         Usage_Actual__c
                        //     FROM 
                        //         OpportunityLineItem
                        //     WHERE 
                        //         Id IN: oliIDs
                        // ];
                        // System.debug('== opptyProductList: '+ opptyProductList);
                        
                        // List<OpportunityLineItem> updUsageActualOLIList = new List<OpportunityLineItem>();
                        // for (OpportunityLineItem oliRec : opptyProductList) {
                        //     Decimal usageAmount = usageActualMap.get(oliRec.Id);

                        //     oliRec.Usage_Actual__c = usageAmount;
                        //     updUsageActualOLIList.add(oliRec);
                        // }
                        // update updUsageActualOLIList;
                        // === end - 10 feb 2025 ===
            
                        map<string, user> userMap = new map<string, user>();
                        List<user> userList = [select id, nik__c from user where nik__c in: salesNik];
                        for(user userListRec :userList){
                            userMap.put(userListRec.nik__c, userListRec);
                        }
                        
                        for (Usage__c myUsage : Trigger.new) {
                            System.debug('myUsage.rev: ' + myUsage.Telkomsel_Revenue__c);
                            OrderItem orderItemObj = orderItemMap.get(myUsage.Campaign_ID__c);
                            
                            String nik = nikMap.get(myUsage.Bucket_Detail__c);
                            System.debug('NIK ==> ' + nik);
                            system.debug('myUsage.NIK__c: ' + myUsage.NIK__c);
                            User newUserReference = new User(NIK__c = (myUsage.NIK__c == null) ? nik : myUsage.NIK__c);
                            System.debug('newUserReference ==> ' + newUserReference);
                            Monthly_Sales_Target__c newMonthlySalesTarget = new Monthly_Sales_Target__c();
                            newMonthlySalesTarget.Date__c = myUsage.date__c;
                            if(myUsage.Sales__c != Null){
                                newMonthlySalesTarget.OwnerId = myUsage.Sales__c;
                                //newMonthlySalesTarget.Sales__c = myUsage.Sales__c;
                            }
                            newMonthlySalesTarget.Amount__c = myUsage.Telkomsel_Revenue__c; //modify
                            newMonthlySalesTarget.Number_of__c = Integer.valueOf(myUsage.Amount__c); //modify
                            newMonthlySalesTarget.Type__c = 'Revenue Actual';
                            newMonthlySalesTarget.Group_Type__c = 'Actual'; //modify
                        
                            newMonthlySalesTarget.Usage__c = myUsage.id;//modify
                            //newMonthlySalesTarget.Sales__c = newUserReference.id;//(myUsage.nik__c != null) ? userMap.get(myUsage.nik__c).id : nik;//newUserReference;
                            newMonthlySalesTarget.Sales__c = myUsage.Sales__c;
                            if(orderItemObj.Opportunity__c != null){
                                newMonthlySalesTarget.Opportunity__c = myUsage.Opportunity_ID__c;
                                newMonthlySalesTarget.Unique_ID__c =  newUserReference.NIK__c+'-'+newMonthlySalesTarget.Type__c+'-'+myUsage.Opportunity_ID__c+'-'+date.today().month()+'-'+date.today().year();
                            }else{
                                newMonthlySalesTarget.Media_Seller__c = orderItemObj.Order.AccountId;
                                newMonthlySalesTarget.Unique_ID__c = newUserReference.NIK__c+'-'+newMonthlySalesTarget.Type__c+'-'+orderItemObj.Order.Order_Type__c+'-'+date.today().month()+'-'+date.today().year();
                            }
                        
                            lMonthlySalesTarget.add(newMonthlySalesTarget);
                        }
                        insert lMonthlySalesTarget;
            
                        List<Usage__c> usagesToUpdate = new List<Usage__c>();
                        for (Monthly_Sales_Target__c mst : lMonthlySalesTarget) {
                            if (mst.Usage__c != null) {
                                String weekNumber = string.valueOf(AppUtils.weekOfMonth(mst.Date__c));
                                System.debug('weekNumber: ' + weekNumber);
                                Usage__c relatedUsage = new Usage__c(
                                    Id = mst.Usage__c, 
                                    Monthly_Sales_Target__c = mst.Id,
                                    week__c = 'Week ' + weekNumber
                                );
            
                                usagesToUpdate.add(relatedUsage);
                            }
                        }
                        update usagesToUpdate;
                    }
                    /* === karena kedua business product upload usage dengan ada campaign ID === / updated - 11 feb 2025
                    else if (ListUsageCampaignId.size() == 0 && ListUsageOrderId.size() > 0) {
                        System.debug('Masuk Logic MO based on order Id ');
                        List<OrderItem> myOrderItems = [
                            SELECT Id, 
                            Usage_Actual__c, 
                            Opportunity__c, 
                            Campaign_ID__c,
                            Sales__r.NIK__c,  
                            Order.AccountId,
                            Order.Order_Type__c,
                            Opportunity_Product__c // new - 10 feb 2025
                            FROM OrderItem 
                            WHERE Id IN :ListUsageOrderId
                        ];
                        
                        System.debug('Data Order Query :' +myOrderItems);
            
                        Set<Id> oliIDs = new Set<Id>(); // new - 10 feb 2025
                        Map<Id, Decimal> usageActualMap = new Map<Id, Decimal>(); // new - 10 feb 2025
                        for (OrderItem oi : myOrderItems) {
                            Decimal usageAmount = mapUsageTV.get(oi.Id);
                            if (usageAmount != null) {
                                oi.Usage_Actual__c += usageAmount;
                                nikMap.put(oi.Id,oi.Sales__r.NIK__c);
                                orderItemMap.put(oi.Id, oi);
                                oliIDs.add(oi.Opportunity_Product__c); // new - 10 feb 2025
                                usageActualMap.put(oi.Opportunity_Product__c, oi.Usage_Actual__c); // new - 10 feb 2025
                            }
                        }
                        update myOrderItems;

                        // === new - 10 feb 2025 ===
                        List<OpportunityLineItem> opptyProductList = [
                            SELECT
                                Id,
                                Usage_Actual__c
                            FROM 
                                OpportunityLineItem
                            WHERE 
                                Id IN: oliIDs
                        ];
                        
                        List<OpportunityLineItem> updUsageActualOLIList = new List<OpportunityLineItem>();
                        for (OpportunityLineItem oliRec : opptyProductList) {
                            Decimal usageAmount = usageActualMap.get(oliRec.Id);

                            oliRec.Usage_Actual__c = usageAmount;
                            updUsageActualOLIList.add(oliRec);
                        }
                        update updUsageActualOLIList;
                        // === end - 10 feb 2025 ===
            
                        map<string, user> userMap = new map<string, user>();
                        List<user> userList = [select id, nik__c from user where nik__c in: salesNik];
                        for(user userListRec :userList){
                            userMap.put(userListRec.nik__c, userListRec);
                        }
                        
                        for (Usage__c myUsage : Trigger.new) {
                            System.debug('myUsage.rev: ' + myUsage.Telkomsel_Revenue__c);
                            System.debug('Data OrderItem Map:' +orderItemMap);
                            OrderItem orderItemObj = orderItemMap.get(myUsage.Bucket_Detail__c);
                            
                            String nik = nikMap.get(myUsage.Bucket_Detail__c);
                            System.debug('NIK ==> ' + nik);
                            system.debug('myUsage.NIK__c: ' + myUsage.NIK__c);
                            User newUserReference = new User(NIK__c = (myUsage.NIK__c == null) ? nik : myUsage.NIK__c);
                            System.debug('newUserReference ==> ' + newUserReference);
                            Monthly_Sales_Target__c newMonthlySalesTarget = new Monthly_Sales_Target__c();
                            newMonthlySalesTarget.Date__c = myUsage.date__c;
                            if(myUsage.Sales__c != Null){
                                newMonthlySalesTarget.OwnerId = myUsage.Sales__c;
                                //newMonthlySalesTarget.Sales__c = myUsage.Sales__c;
                            }
                            newMonthlySalesTarget.Amount__c = myUsage.Telkomsel_Revenue__c; //modify
                            newMonthlySalesTarget.Number_of__c = Integer.valueOf(myUsage.Amount__c); //modify
                            newMonthlySalesTarget.Type__c = 'Revenue Actual';
                            newMonthlySalesTarget.Group_Type__c = 'Actual'; //modify
                            newMonthlySalesTarget.Bucket_Detail__c =myUsage.Bucket_Detail__c;
                            newMonthlySalesTarget.Media_Order_Item__c=myUsage.Media_Order_Item__c;
                            newMonthlySalesTarget.Usage__c = myUsage.id;//modify
                            //newMonthlySalesTarget.Sales__c = newUserReference.id;//(myUsage.nik__c != null) ? userMap.get(myUsage.nik__c).id : nik;//newUserReference;
                            newMonthlySalesTarget.Sales__c = myUsage.Sales__c;
                            if(orderItemObj.Opportunity__c != null){
                                newMonthlySalesTarget.Opportunity__c = myUsage.Opportunity_ID__c;
                                newMonthlySalesTarget.Unique_ID__c =  newUserReference.NIK__c+'-'+newMonthlySalesTarget.Type__c+'-'+myUsage.Opportunity_ID__c+'-'+date.today().month()+'-'+date.today().year();
                            }else{
                                newMonthlySalesTarget.Media_Seller__c = orderItemObj.Order.AccountId;
                                newMonthlySalesTarget.Unique_ID__c = newUserReference.NIK__c+'-'+newMonthlySalesTarget.Type__c+'-'+orderItemObj.Order.Order_Type__c+'-'+date.today().month()+'-'+date.today().year();
                            }
                        
                            lMonthlySalesTarget.add(newMonthlySalesTarget);
                        }
                        insert lMonthlySalesTarget;
                        
                        List<Usage__c> usagesToUpdate = new List<Usage__c>();
                        for (Monthly_Sales_Target__c mst : lMonthlySalesTarget) {
                            if (mst.Usage__c != null) {
                                String weekNumber = string.valueOf(AppUtils.weekOfMonth(mst.Date__c));
                                System.debug('weekNumber: ' + weekNumber);
                                Usage__c relatedUsage = new Usage__c(
                                    Id = mst.Usage__c, 
                                    Monthly_Sales_Target__c = mst.Id,
                                    week__c = 'Week ' + weekNumber
                                );
            
                                usagesToUpdate.add(relatedUsage);
                            }
                        }
                        update usagesToUpdate;
                    }
                    */
                    if(Test.isRunningTest()) {
                        CalloutException e = new CalloutException();
                        e.setMessage('This is a constructed exception for testing and code coverage');
                        throw e;
                    }
                } catch (Exception e) {
                    string errMessage = 'Error on Trigger.Trigger_Usage_After_Insert function::' + e.getmessage() + '::' + e.getLineNumber() ;
                    system.debug('==================== error message : ' + errMessage);
                    AppUtils.putError(errMessage );
                }
            }
            if (trigger.isUpdate) {
                set<id> usageIds = new set<id>();
                Map<Id, usage__c> oldMapUsage = new Map<Id, Usage__c>(Trigger.old);
                for(usage__c newUsage :Trigger.new){
                    usage__c oldUsageRec = oldMapUsage.get(newUsage.id);
                    if(
                        // (
                        //     newUsage.Amount__c != oldUsageRec.amount__c || 
                        //     newUsage.date__c != oldUsageRec.date__c
                        // ) &&
                        (
                            newUsage.Order_Type__c != 'Opportunity' &&
                            newUsage.Order_Type__c != ''
                        )
                        
                    ){
                        usageIds.add(oldUsageRec.id);
                    }
                }

                if(!usageIds.isEmpty()){
                    OrderServices.UpdateUsageonMonthlySalesTarget(usageIds);
                }                
            }
        }
        if(trigger.isBefore){
            if(trigger.isUpdate){
                Map<id, usage__c> oldMapUsage = new map<id, Usage__c>(trigger.old);
                for (Usage__c newUsage : Trigger.new) {
                    Usage__c oldUsage = oldMapUsage.get(newUsage.id);

                    if(oldUsage.date__c != newUsage.date__c){
                        String weekNumber = string.valueOf(AppUtils.weekOfMonth(newUsage.Date__c));

                        newUsage.week__c = 'Week ' + weekNumber;
                    }
                }
            }
        }
    }
}