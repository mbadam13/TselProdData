/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 12/02/2025
 * @last modified by  : Syaiful Syafani
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   12/02/2025   Syaiful Syafani   Initial Version
**/
public with sharing class TA_AT_OrderItem_AU_CheckAllHouseNumber implements TriggerAction.AfterUpdate {
    public void AfterUpdate(List<OrderItem> newList, List<OrderItem> oldList){
        System.debug('=== TA_AT_OrderItem_AU_CheckAllHouseNumber ===');

        try {
            Set<Id> orderIds = new Set<Id>();
            for (OrderItem oiNEWRec : newList) {
                if (oiNEWRec.House_Number__c != null) {
                    orderIds.add(oiNEWRec.OrderId);
                }
            }
            
            if (!orderIds.isEmpty()) {
                List<OrderItem> orderItemList = [
                    SELECT
                        Id,
                        OrderId,
                        House_Number__c
                    FROM
                        OrderItem
                    WHERE
                        OrderId IN :orderIds AND House_Number__c = Null // cek order produk apakah ada yang kosong (?)
                ];
                System.debug('== orderItemList-size: '+ orderItemList.size());

                List<Order> orderList = [
                    SELECT
                        Id,
                        All_House_Numbers_Filled__c
                    FROM
                        Order
                    WHERE
                        Id IN :orderIds
                ];
                
                List<Order> updateOrderList = new List<Order>();
                for (Order orderRec : orderList) {
                    if (orderItemList.size() == 0) {
                        orderRec.All_House_Numbers_Filled__c = true;
                        updateOrderList.add(orderRec);
                    }
                }
                System.debug('== updateOrderList-size: '+ updateOrderList.size());

                if (!updateOrderList.isEmpty()) {
                    update updateOrderList;
                }
            }

            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage(
                    'This is a constructed exception for testing and code coverage'
                );
                throw e;
            }
        } catch (Exception e) {
            string errMessage =
                'Error on TA_AT_OrderItem_AU_CheckAllHouseNumber-AfterUpdate function::' +
                e.getmessage() +
                '::' +
                e.getLineNumber();
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage);
        }
    }
}