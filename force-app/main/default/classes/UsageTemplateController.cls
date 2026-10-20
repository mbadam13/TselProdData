/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 17/04/2025
 * @last modified by  : Syaiful Syafani
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   08/01/2025   Syaiful Syafani   Initial Version
 * 2.0   10/02/2025   Syaiful Syafani   add method getOrderNumber
**/
public without sharing class UsageTemplateController {
    @AuraEnabled(cacheable=true)
    public static string getOrderItems(String orderId){
        List<OrderItem> orderItemList = [
            SELECT
                Id,
                Campaign_ID__c,
                OrderId,
                Order.OrderNumber
            FROM
                OrderItem
            WHERE
                OrderId =: orderId
        ];
        return generateCSVContent(orderItemList);
    }

    @AuraEnabled(cacheable=true)
    public static string getOrderNumber(String orderId){ // new - 10 feb 2025
        Order orderRec = [SELECT OrderNumber FROM Order WHERE Id = :orderId LIMIT 1];

        String orderNumber = orderRec.OrderNumber;
        System.debug('== orderNumber: '+ orderNumber);
        return orderNumber;
    }

    private static String generateCSVContent(List<OrderItem> orderItemList){
        String csvContent = 'Date,Campaign_Id,Usage\n';

        for (OrderItem orderItemRec : orderItemList) {
            String formattedDate = String.valueOf(Date.today().day()) + '/'
                                + String.valueOf(Date.today().month()) + '/'
                                + String.valueOf(Date.today().year());

            String resultFormattedDate = formattedDate != null ? formattedDate : '';
                csvContent += resultFormattedDate + ',' 
                    + orderItemRec.Campaign_ID__c + ',' 
                    + '\n';
        }
        return csvContent;
    }
}