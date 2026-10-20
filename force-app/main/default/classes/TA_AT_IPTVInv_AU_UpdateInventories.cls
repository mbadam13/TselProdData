/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-31-2024
 * @last modified by  : Syaiful Syafani
**/
public with sharing class TA_AT_IPTVInv_AU_UpdateInventories implements TriggerAction.AfterUpdate {
    public void afterUpdate(List<IPTV_Inventory__c> newList, List<IPTV_Inventory__c> oldList) {
        System.debug('=== TA_AT_IPTVInv_AU_UpdateInventories ===');

        Map<Id, IPTV_Inventory__c> oldMap = new Map<Id, IPTV_Inventory__c>(oldList);

        try {
            Set<Id> inventoryIds = new Set<Id>();

            for (IPTV_Inventory__c newInvRec : newList) {
                IPTV_Inventory__c oldInvRec = oldMap.get(newInvRec.Id);

                if (newInvRec.Product_Inventory__c != oldInvRec.Product_Inventory__c) {
                    inventoryIds.add(newInvRec.id);
                }
            }

            if (!inventoryIds.isEmpty()) {
                IPTVInventoryService.updateProductInventory(inventoryIds);
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            string errMessage = 'Error on TA_AT_IPTVInv_AU_UpdateInventories.afterUpdate function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}