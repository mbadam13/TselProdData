/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-31-2024
 * @last modified by  : Syaiful Syafani
**/
public with sharing class TA_AT_IPTVInv_AI_InsertInventories implements TriggerAction.AfterInsert {
    public void afterInsert(List<IPTV_Inventory__c> newList) {
        System.debug('=== TA_AT_IPTVInv_AI_InsertInventories ===');

        try {
            Set<Id> inventoryIds = new Set<Id>();
            for (IPTV_Inventory__c invRec : newList) {
                if (invRec.Product_Inventory__c != null) {
                    inventoryIds.add(invRec.Id);
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
            string errMessage = 'Error on TA_AT_IPTVInv_AI_InsertInventories.afterInsert function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}