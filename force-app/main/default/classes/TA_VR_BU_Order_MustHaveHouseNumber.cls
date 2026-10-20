/**
 * Author       :   Yusuf Ramadhan (yusuf.ramadhan@saasten.com)
 * Purposes     :   Validation before Order Approve (Running)
 * Test Class   :   TA_VR_AU_Order_MustHaveHouseNumberTest
 * 
 * 
 * Date         PIC         Brief of changes
 * 09/01/2024   Yusuf       Initial Create
 * 23/01/2024   Yusuf       Prepare for Devops Center
 */
public with sharing class TA_VR_BU_Order_MustHaveHouseNumber implements TriggerAction.BeforeUpdate {

    public void beforeUpdate(List<Order> newOrders, List<Order> oldOrders) {
        System.debug('### Entering beforeUpdate method');
        
        Map<Id, Order> newOrderMap = new Map<Id, Order>(newOrders);
        Map<Id, Order> oldOrderMap = new Map<Id, Order>(oldOrders); 

        Set<Id> orderIds = new Set<Id>();
        
        for(Order newOrder : newOrders) {
            // Debugging the order's status and Business Product
            System.debug('### Checking Order: ' + newOrder.Id + ', Status: ' + newOrder.Status + ', Business Product: ' + newOrder.Business_Product__c);
            
            if(oldOrderMap.get(newOrder.Id).Status != 'Running' && newOrder.Status == 'Running' && newOrder.Business_Product__c == 'TV Media') {
                orderIds.add(newOrder.Id);
                System.debug('### Adding Order to orderIds: ' + newOrder.Id);
            }
        }

        // Debugging if any order ids were found
        System.debug('### orderIds after loop: ' + orderIds);

        if(!orderIds.isEmpty()) {
            // Query for OrderItems related to the orders that need validation
            List<OrderItem> orderItems = [SELECT Id, House_Number__c, OrderItemNumber, OrderId   
                                         FROM OrderItem 
                                         WHERE OrderId IN :orderIds];
            System.debug('### Retrieved Order Items: ' + orderItems.size());

            Map<Id, List<OrderItem>> orderItemsMap = new Map<Id, List<OrderItem>>();
            for(OrderItem oi : orderItems) {
                if(!orderItemsMap.containsKey(oi.OrderId)) {
                    orderItemsMap.put(oi.OrderId, new List<OrderItem>());
                    System.debug('### Creating new list for OrderId: ' + oi.OrderId);
                }
                orderItemsMap.get(oi.OrderId).add(oi);
                System.debug('### Adding OrderItem to OrderId ' + oi.OrderId + ': ' + oi.OrderItemNumber);
            }

            for(Order newOrder : newOrders) {
                if(orderIds.contains(newOrder.Id)) {
                    List<OrderItem> orderItemsForOrder = orderItemsMap.get(newOrder.Id); 
                    Set<String> invalidOrderItemNumbers = new Set<String>();

                    // Debugging OrderItem list processing
                    System.debug('### Processing Order Items for Order: ' + newOrder.Id);

                    if(orderItemsForOrder != null) {
                        for(OrderItem orderItem : orderItemsForOrder) {
                            // Debugging each OrderItem and its House Number field
                            System.debug('### Checking OrderItem: ' + orderItem.OrderItemNumber + ', House Number: ' + orderItem.House_Number__c);

                            if (orderItem.House_Number__c == null) {
                                invalidOrderItemNumbers.add(orderItem.OrderItemNumber);
                                System.debug('### House Number is missing for OrderItem: ' + orderItem.OrderItemNumber);
                            }
                        }

                        if (!invalidOrderItemNumbers.isEmpty()) {
                            String errMsg = 'Harap isi house number terlebih dahulu: ' + String.join(invalidOrderItemNumbers, ', ');
                            System.debug('### Error message to be added to Order: ' + errMsg);
                            newOrder.addError(errMsg);
                        }
                    }
                }
            }
        } else {
            System.debug('### No orders matched the conditions for processing.');
        }

        System.debug('### Exiting beforeUpdate method');
    }

}