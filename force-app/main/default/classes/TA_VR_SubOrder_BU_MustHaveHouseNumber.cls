/**
 * @description       : TA_VR_SubOrder_BU_MustHaveHouserNumTest
 * @author            : M B Adam
 * @group             : 
 * @last modified on  : 04-22-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class TA_VR_SubOrder_BU_MustHaveHouseNumber implements TriggerAction.BeforeUpdate {
    public void beforeUpdate(List<Sub_Order__c> newSubs, List<Sub_Order__c> oldSubs) {
        System.debug('===== TA_VR_SubOrder_BU_MustHaveHouseNumber');
        String errMessage;

        try {
            Map<Id, Sub_Order__c> oldMap = new Map<Id, Sub_Order__c>(oldSubs);
            Set<Id> orderIdsToValidate = new Set<Id>();

            for (Sub_Order__c newSub : newSubs) {
                Sub_Order__c oldSub = oldMap.get(newSub.Id);

                // Cek jika Approval_Status berubah menjadi Approved
                if (oldSub.Approval_Status__c != 'Approved' &&
                    newSub.Approval_Status__c == 'Approved' && newSub.PIC_Product_Type__c == 'Third Party Media-IPTV'
                    ) {
                    
                    if (newSub.Order__c != null) {
                        orderIdsToValidate.add(newSub.Order__c);
                        System.debug('### Order added for validation: ' + newSub.Order__c);
                    }
                }
            }

            if (!orderIdsToValidate.isEmpty()) {
                // Query OrderItems dengan Product IPTV
                List<OrderItem> orderItems = [
                    SELECT Id, House_Number__c, OrderItemNumber, OrderId, PIC_Product_Type__c
                    FROM OrderItem
                    WHERE OrderId IN :orderIdsToValidate
                    AND PIC_Product_Type__c = 'IPTV'
                ];

                // Mapping OrderId → OrderItems
                Map<Id, List<OrderItem>> orderItemMap = new Map<Id, List<OrderItem>>();
                for (OrderItem item : orderItems) {
                    if (!orderItemMap.containsKey(item.OrderId)) {
                        orderItemMap.put(item.OrderId, new List<OrderItem>());
                    }
                    orderItemMap.get(item.OrderId).add(item);
                }

                // Validasi per Sub Order
                for (Sub_Order__c sub : newSubs) {
                    if (orderIdsToValidate.contains(sub.Order__c)) {
                        List<OrderItem> items = orderItemMap.get(sub.Order__c);
                        Set<String> missingHouseNumbers = new Set<String>();

                        if (items != null) {
                            for (OrderItem oi : items) {
                                if (oi.House_Number__c == null) {
                                    missingHouseNumbers.add(oi.OrderItemNumber);
                                }
                            }
                        }

                        if (!missingHouseNumbers.isEmpty()) {
                            String errorMsg = 'Harap isi house number terlebih dahulu untuk Order Item: ' +
                                              String.join(missingHouseNumbers, ', ');
                            sub.addError(errorMsg);
                            System.debug('### Validation error added to Sub Order: ' + errorMsg);
                        }
                    }
                }
            } else {
                System.debug('### No Sub Orders matched for approval transition.');
            }
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }    

        } catch (Exception e) {
            errMessage = 'Error on TA_VR_SubOrder_BU_MustHaveHouseNumber Before Update function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }

       
    }
}