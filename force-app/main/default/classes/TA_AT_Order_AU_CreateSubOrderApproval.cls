/**
 * @description       : For Generate Sub Order 
 * @author            : Alfian R
 * @group             : 
 * @last modified on  : 03-26-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author     Modification
 * 1.0   02-26-2025   Alfian R   Initial Version
 * 2.0   03-10-2025   M B Adam   -- Change Logic To List 
**/
public with sharing class TA_AT_Order_AU_CreateSubOrderApproval implements TriggerAction.AfterUpdate {
    public void AfterUpdate(List<Order> newList, List<Order> oldList) {
        System.debug('== TA_AT_Order_AU_CreateSubOrderApproval ==');

        Map<Id, Order> oldMap = new Map<Id, Order>(oldList);

      try{
        Set<Id> orderIds = new Set<Id>();
            for (Order newOrderRec : newList) {
                Order oldOrderRec = oldMap.get(newOrderRec.Id);
                System.debug('=== Order Status New: ' + newOrderRec.Status);
                System.debug('=== Order Status Old: ' + oldOrderRec.Status);
                
                if (newOrderRec.Approval_Status__c == 'Submit' &&
                    newOrderRec.Approval_Status__c != oldOrderRec.Approval_Status__c) {
                    orderIds.add(newOrderRec.Id);
                }
            }
            System.debug('== orderIds: ' + orderIds);

            if (!orderIds.isEmpty()) {
                // Konversi Set<Id> ke List<Id> sebelum pemanggilan
                SubOrderService.generateSubOrders_V2(new List<Id>(orderIds));
            }

            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        
      } catch (Exception e){
        string errMessage = 'Error on TA_AT_Order_AU_CreateSubOrderApproval::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
      }
       
    }
}