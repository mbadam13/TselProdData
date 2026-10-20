/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-23-2024
 * @last modified by  : Syaiful Syafani
**/
public with sharing class TA_AT_IPTVInv_BU_UpdateInventories implements TriggerAction.BeforeUpdate {
    public void beforeUpdate(List<IPTV_Inventory__c> newList, List<IPTV_Inventory__c> oldList) {
        System.debug('=== TA_AT_IPTVInv_BU_UpdateInventories ===');

        Map<Id, IPTV_Inventory__c> oldMap = new Map<Id, IPTV_Inventory__c>(oldList);
        List<IPTV_Inventory__c> updateINVList = new List<IPTV_Inventory__c>();

        try {
            for (IPTV_Inventory__c newInvRec : newList) {
                IPTV_Inventory__c oldInvRec = oldMap.get(newInvRec.Id);

                if (newInvRec.Product_Inventory__c != oldInvRec.Product_Inventory__c) {
                    List<String> inventoryValueList = newInvRec.Product_Inventory__c.split(';');

                    String inventoriesValue = String.join(inventoryValueList, ',');

                    newInvRec.Inventories__c = inventoriesValue;
                    updateINVList.add(newInvRec);
                }
            }

            if (!updateINVList.isEmpty()) {
                Update updateINVList;
            }
        } catch (Exception e) {
            string errMessage = 'Error on TA_AT_IPTVInv_BU_UpdateInventories.beforeUpdate function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}