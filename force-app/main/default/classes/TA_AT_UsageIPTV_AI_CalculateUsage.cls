/**
 * @description       : Create or update Data Usage based on MO item after insert using aggregate result grouped by date
 * @author            : M B Adam
 * @group             : 
 * @last modified on  : 07-12-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class TA_AT_UsageIPTV_AI_CalculateUsage implements TriggerAction.AfterInsert {
   
    public void AfterInsert(List<Usage_IPTV__c> newList) {
        System.debug('=== TA_AT_UsageIPTV_AI_CalculateUsage ===');
        Set<Id> UsageIPTVMOitemset = new Set<Id>();

      
        for (Usage_IPTV__c usage : newList) {
            if (usage.Media_Order_Item__c != null) {
                UsageIPTVMOitemset.add(usage.Media_Order_Item__c);
            }
        }
        
        System.debug('Data Usage IPTVMoitem' + UsageIPTVMOitemset);

   
        Map<Id, Media_Order_Item__c> moItemMap = new Map<Id, Media_Order_Item__c>(
            [SELECT 
                Id, Name, Order_Product__c, Order_Product__r.NIK__c, Order_Product__r.EmployeeID_SF__c
             FROM Media_Order_Item__c 
             WHERE Id IN :UsageIPTVMOitemset]
        );

       
        List<AggregateResult> groupedResults = [SELECT Media_Order_Item__c, Date__c, COUNT(Id) usageCount
                                                FROM Usage_IPTV__c
                                                WHERE Media_Order_Item__c IN :UsageIPTVMOitemset
                                                GROUP BY Media_Order_Item__c, Date__c];

        System.debug('Agregate resultData Usage IPTVMoitem' + groupedResults);
        List<Usage__c> usageToUpsert = new List<Usage__c>();

       for (AggregateResult ar : groupedResults) {
          Id moItemId = (Id) ar.get('Media_Order_Item__c');
           Date usageDate = (Date) ar.get('Date__c');
           Integer usageCount = (Integer) ar.get('usageCount');

           Media_Order_Item__c moItem = moItemMap.get(moItemId);

         Usage__c usage = new Usage__c();
         usage.Media_Order_Item__c = moItemId;
         usage.Bucket_Detail__c = moItem.Order_Product__c;
         usage.Date__c = usageDate;
         usage.Amount__c = usageCount;
         usage.Unique_ID__c = moItem.Name + '_' + usage.Date__c.day() + '/' + usage.Date__c.month() + '/' + usage.Date__c.year();

    // Conditionally set Sales__c and OwnerId if they are not empty
       if (moItem.Order_Product__r.EmployeeID_SF__c != null && moItem.Order_Product__r.EmployeeID_SF__c != '') {
          usage.Sales__c = moItem.Order_Product__r.EmployeeID_SF__c;
          usage.OwnerId = moItem.Order_Product__r.EmployeeID_SF__c;
          usage.NIK__c = moItem.Order_Product__r.NIK__c;
        }

         usageToUpsert.add(usage);
        }

        if (usageToUpsert.size() > 0) {
            upsert usageToUpsert Unique_ID__c;
        }

        // Create a map to store uniqueId to Usage__c Id mapping
        Map<String, Id> uniqueIdToUsageIdMap = new Map<String, Id>();
        for (Usage__c usage : usageToUpsert) {
            uniqueIdToUsageIdMap.put(usage.Unique_ID__c, usage.Id);
        }

        System.debug('Data Usage for Update:' + uniqueIdToUsageIdMap );

        // List to store updated Usage_IPTV__c records
        List<Usage_IPTV__c> usageIPTVToUpdate = new List<Usage_IPTV__c>();

        // Loop through newList and create new instances for update
        for (Usage_IPTV__c usageIPTV : newList) {
            Media_Order_Item__c moItem = moItemMap.get(usageIPTV.Media_Order_Item__c);
            System.debug('Data MO Item' + moItem);
            Date usageDate = usageIPTV.Date__c;
            String uniqueId = moItem.Name + '_' + usageDate.day() + '/' + usageDate.month() + '/' + usageDate.year();

            Id UsageRecIdNEW = uniqueIdToUsageIdMap.get(uniqueId);
            if (UsageRecIdNEW != null) {
                Usage_IPTV__c updatedUsageIPTV = new Usage_IPTV__c(
                    Id = usageIPTV.Id,
                    Usage__c = UsageRecIdNEW
                );
                usageIPTVToUpdate.add(updatedUsageIPTV);
            }
        }

        System.debug('Usage IPTV Update Data :' + usageIPTVToUpdate);
        if (usageIPTVToUpdate.size() > 0) {
            update usageIPTVToUpdate;
        }
    }
}