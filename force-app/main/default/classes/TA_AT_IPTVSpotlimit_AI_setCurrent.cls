/**
 * @description       : 
 * @author            : M B Adam 
 * @Test              : IPTVSpotlimitService_Test
 * @group             : 
 * @last modified on  : 07-04-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class TA_AT_IPTVSpotlimit_AI_setCurrent implements TriggerAction.AfterInsert {

    public void AfterInsert(List<IPTV_Spot_Limit__c> newList){
        System.debug('=== TA_AT_IPTVSpotLimit_AI_SetCurrent ===');

        try {
            Date today = Date.today();
            Set<Id> inventoryIdsToUpdate = new Set<Id>();

            // Filter the spot limits where start and end date are today from the trigger new list
            for (IPTV_Spot_Limit__c spotReq : newList) {
                if ((spotReq.Start_Date__c <= today && spotReq.End_Date__c >= today) && spotReq.Start_Date__c.month() == today.month() ) {
                    inventoryIdsToUpdate.add(spotReq.IPTV_Inventory__c);
                }
            }

            if (!inventoryIdsToUpdate.isEmpty()) {
                // Query the IPTV_Inventory__c records that need to be updated
                List<IPTV_Inventory__c> inventoriesToUpdate = [
                    SELECT Id
                    FROM IPTV_Inventory__c
                    WHERE Id IN :inventoryIdsToUpdate
                ];

                // Call the sub-method to process inventories
                IPTVInvService.updateIPTVInventorySpotLimit(inventoriesToUpdate);
            }
        } catch (Exception e) {
            System.debug('Erro After Inser Data ' + e.getMessage());
        }
    }
}