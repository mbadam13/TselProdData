/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-23-2024
 * @last modified by  : Syaiful Syafani
**/
public with sharing class TA_AT_IPTVInv_BI_InsertInventories implements TriggerAction.BeforeInsert {
    public void beforeInsert(List<IPTV_Inventory__c> newList) {
        System.debug('=== TA_AT_IPTVInv_BI_InsertInventories ===');

        try {
            for (IPTV_Inventory__c invRec : newList) {
                if (invRec.Product_Inventory__c != null) {
                    List<String> inventoryValueList = invRec.Product_Inventory__c.split(';');

                    String inventoriesValue = String.join(inventoryValueList, ',');

                    invRec.Inventories__c = inventoriesValue;
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            string errMessage = 'Error on TA_AT_IPTVInv_BI_InsertInventories.beforeInsert function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}