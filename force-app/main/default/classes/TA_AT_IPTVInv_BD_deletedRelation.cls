/**
 * @description       : 
 * @Test Class        : TA_AT_IPTVInv_BD_deletedRelation
 * @author            : M B Adam 
 * @group             : 
 * @last modified on  : 07-05-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class TA_AT_IPTVInv_BD_deletedRelation implements TriggerAction.BeforeDelete {
    public void BeforeDelete(List<IPTV_Inventory__c> oldList ) {
        System.debug('=== TA_AT_IPTVInv_BD_deletedRelation ===');

        Set<Id> deletedInventoryIds = new Set<Id>();

        // Collect the IDs of the deleted IPTV inventories
        for (IPTV_Inventory__c inv : oldList) {
            deletedInventoryIds.add(inv.Id);
        }

          System.debug('Data IPT inventory IDs: ' + deletedInventoryIds);

        
            // Query the related IPTV Spot Limit records
           List<IPTV_Spot_Limit__c> spotLimitsToDelete = [
                SELECT Id, IPTV_Inventory__c
                FROM IPTV_Spot_Limit__c 
                WHERE IPTV_Inventory__c IN :deletedInventoryIds
            ];
            

           System.debug('Data List SPOT Limit: ' + spotLimitsToDelete);
           Set<Id> spotLimitIds = new Set<Id>();
            
            
            for (IPTV_Spot_Limit__c spotLimit : spotLimitsToDelete) {
                spotLimitIds.add(spotLimit.Id);
            }

          
                // Query and delete related IPTV Daily Status records
                List<IPTV_Spot_Daily_Status__c> dailyStatusToDelete = [
                    SELECT Id, IPTV_Spot_Limit__c
                    FROM IPTV_Spot_Daily_Status__c 
                    WHERE IPTV_Spot_Limit__c IN :spotLimitIds
                ];

               
                // Delete the daily status Spot limit Record
                delete dailyStatusToDelete;
                

                // Delete the IPTV Spot Limit records
                delete spotLimitsToDelete;
            
        
    }
}