/**
 *  Author      :   Yusuf Ramadhan  (yusuf.ramadhan@saasten.com)
 *  Purposes    :   [the Controller for MediaOrderItemExpLwc.js]
 *  Test Class  :   [MediaOrderItemExpControllerTEST]
 * 
 *  Date        PIC         Brief of changes        Ticket
 *  02/07/24    Yusuf       Initial Create          https://saasten.odoo.com/web#id=534&cids=1&menu_id=132&action=217&active_id=10&model=project.task&view_type=form
 *  08/07/24    Yusuf       New Method for
 *                          Order ID
 *  10/07/24    Yusuf       row based on quantity 
 * 
 * 
 */
public without sharing class MediaOrderItemExpController {
    @AuraEnabled(cacheable=true)
    public static String getMediaOrderItems(String mediaOrderId) {
        List<Media_Order_Item__c> items = [
            SELECT 
                Name, 
                Media_Order__r.Channel__c, 
                Product_Name__c,
                Media_Order__r.House_Number__c, 
                Media_Order__r.Brand__c,
                Media_Order__r.Versi__c, 
                Date__c,
                Quantity__c,
                Media_Order__r.Showtimes__c,
                Media_Order__r.Duration__c
            FROM 
                Media_Order_Item__c
            WHERE 
                Media_Order__c = :mediaOrderId
        ];

        return generateCsvContent(items);
    }

    @AuraEnabled(cacheable=true)
    public static String getMediaOrderItemsByOrderId(String orderId) {
        List<Media_Order__c> mediaOrders = [
            SELECT Id FROM Media_Order__c WHERE Order__c = :orderId
        ];
        
        Set<Id> mediaOrderIds = new Set<Id>();
        for (Media_Order__c mediaOrder : mediaOrders) {
            mediaOrderIds.add(mediaOrder.Id);
        }
        
        List<Media_Order_Item__c> items = [
            SELECT 
                Id, 
                Name, 
                Media_Order__r.Channel__c, 
                Product_Name__c,
                Media_Order__r.House_Number__c, 
                Media_Order__r.Brand__c,
                Media_Order__r.Versi__c, 
                Date__c,
                Quantity__c,
                Media_Order__r.Showtimes__c,
                Media_Order__r.Duration__c
            FROM 
                Media_Order_Item__c
            WHERE 
                Media_Order__c IN :mediaOrderIds
        ];

        return generateCsvContent(items);
    }

    private static String generateCsvContent(List<Media_Order_Item__c> items) {
        String csvContent = 'No MO Item,IPTV Channel,Product Name,House Number,Brand House Number,Versi House Number,Duration,Showtime,Date(YYYY-MM-DD),Spot ke,Broadcast time,Viewers,Note\n';
        
        for (Media_Order_Item__c item : items) {
            Integer quantity = item.Quantity__c != null && item.Quantity__c > 0 ? Integer.valueOf(item.Quantity__c) : 1;
            Integer rowNum = item.Quantity__c != null && item.Quantity__c > 0 ? 1 : 0;
            for (Integer i = 0; i < quantity; i++) {
                String formattedDate = item.Date__c != null ? String.valueOf(item.Date__c) : '';  // Format date to 'YYYY-MM-DD'
                csvContent += item.Name + ',' 
                                    + item.Media_Order__r.Channel__c + ',' 
                                    + escapeDoubleQuotes(item.Product_Name__c) + ','
                                    + item.Media_Order__r.House_Number__c + ','
                                    + item.Media_Order__r.Brand__c + ','
                                    + item.Media_Order__r.Versi__c + ','
                                    + item.Media_Order__r.Duration__c + ','
                                    + item.Media_Order__r.Showtimes__c + ','
                                    + formattedDate + ','
                                    + rowNum + ','
                                    + ','
                                    + ','
                                    +'\n';
                rowNum++;
            }
        }
        return csvContent;
    }

    public static String escapeDoubleQuotes(String input) {
        return input.replace('"', '\"');
    }
}