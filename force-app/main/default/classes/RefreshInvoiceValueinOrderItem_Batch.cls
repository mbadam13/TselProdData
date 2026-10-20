/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 06-04-2024
 * @last modified by  : Yusuf Ramadhan
 * test class         : RefreshInvoiceValueinOrderItem_BatchTest
**/
global without sharing class RefreshInvoiceValueinOrderItem_Batch implements Database.Batchable<sObject>{
    list<string> QuoteorSOAIds;
    public RefreshInvoiceValueinOrderItem_Batch(list<string> QuoteOrSOARecordIds) {
        this.QuoteorSOAIds = QuoteOrSOARecordIds;
    }

    /*
    global Database.QueryLocator start(Database.BatchableContext BC){
        list<String> manipulateRecordIds = new List<String>();
        for(string QuoteorSOAIds :this.QuoteorSOAIds){
            manipulateRecordIds.add('\'' + QuoteorSOAIds + '\'');
        }

        String queryString =
        'SELECT id ' +
            // 'Pencatatan_Keuangan__c, ' +
            // 'Tanggal_Invoice__c, ' +
            // 'No_Invoice_Tsel__c, ' +
            // 'Invoice_Finance__c,  ' +
            // 'Order.SOA__r.Invoice__r.No_Invoice__c,  ' +
            // 'Order.SOA__r.Invoice__r.Tanggal_Invoice__c  ' +
        'FROM OrderItem ' +
        'WHERE ' +
            'Order.SOA__c IN ' + manipulateRecordIds +
            'OR Order.QuoteId IN ' + manipulateRecordIds;


        System.debug('queryString:: ' + queryString);
        return Database.getQueryLocator(queryString);
    } */

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // List to store manipulated record IDs
        List<String> manipulateRecordIds = new List<String>();
        for (String QuoteorSOAId : this.QuoteorSOAIds) {
            manipulateRecordIds.add('\'' + QuoteorSOAId + '\'');
        }
    
        // Convert list to a comma-separated string
        String recordIdsString = String.join(manipulateRecordIds, ',');
    
        // Construct the query string
        String queryString =
            'SELECT Id ' +
            'FROM OrderItem ' +
            'WHERE ' +
            '(Order.SOA__c IN (' + recordIdsString + ')) ' +
            'OR (Order.QuoteId IN (' + recordIdsString + '))';
    
        System.debug('queryString:: ' + queryString);
        return Database.getQueryLocator(queryString);
    }
    

    global void execute(Database.BatchableContext BC, List<OrderItem> orderItemList){
        System.debug('orderItemList:: ' + json.serialize(orderItemList));
        list<string> orderItemRecIdsList = new list<string>();
        for(orderItem orderItemListRec :orderItemList){
            orderItemRecIdsList.add(orderItemListRec.id);
        }
        System.debug('orderItemRecIdsList:: ' + orderItemRecIdsList);
        list<orderItem> newOrderItemList = [
            SELECT 
                Id, 
                Pencatatan_Keuangan__c, 
                Tanggal_Invoice__c,
                No_Invoice_Tsel__c, 
                Invoice_Finance__c, 
                OrderId,
                Order.SOA__c,
                Order.SOA__r.Invoice__r.No_Invoice__c, 
                Order.SOA__r.Invoice__r.Tanggal_Invoice__c,
                Order.QuoteId,
                Order.Quote.Invoice__r.No_Invoice__c, 
                Order.Quote.Invoice__r.Tanggal_Invoice__c   
            FROM OrderItem 
            WHERE 
            Id IN :orderItemRecIdsList
            AND (Order.SOA__r.Invoice__c != null OR Order.Quote.Invoice__c != null)
        ];

        for(orderItem newOrderItemListRec :newOrderItemList){
            if(newOrderItemListRec.Order.SOA__c != null){
                newOrderItemListRec.Pencatatan_Keuangan__c = newOrderItemListRec.Order.SOA__r.Invoice__r.Tanggal_Invoice__c;
                newOrderItemListRec.Tanggal_Invoice__c = newOrderItemListRec.Order.SOA__r.Invoice__r.Tanggal_Invoice__c;
                newOrderItemListRec.No_Invoice_Tsel__c = newOrderItemListRec.Order.SOA__r.Invoice__r.No_Invoice__c;
                if(newOrderItemListRec.Pencatatan_Keuangan__c != null){
                    newOrderItemListRec.Invoice_Finance__c = 'Done';
                }else{
                    newOrderItemListRec.Invoice_Finance__c = '';
                }
            }

            if(newOrderItemListRec.Order.QuoteId != null){
                newOrderItemListRec.Pencatatan_Keuangan__c = newOrderItemListRec.Order.Quote.Invoice__r.Tanggal_Invoice__c;
                newOrderItemListRec.Tanggal_Invoice__c = newOrderItemListRec.Order.Quote.Invoice__r.Tanggal_Invoice__c;
                newOrderItemListRec.No_Invoice_Tsel__c = newOrderItemListRec.Order.Quote.Invoice__r.No_Invoice__c;
                if(newOrderItemListRec.Pencatatan_Keuangan__c != null){
                    newOrderItemListRec.Invoice_Finance__c = 'Done';
                }else{
                    newOrderItemListRec.Invoice_Finance__c = '';
                }
            }
        }

        if(!newOrderItemList.isEmpty()){
            update newOrderItemList;
        }
        System.debug('newOrderItemList:: ' + json.serialize(newOrderItemList));
    }

    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [
            Select a.TotalJobItems, 
            a.Status, 
            a.NumberOfErrors,
            a.JobType, 
            a.JobItemsProcessed, 
            a.ExtendedStatus, 
            a.CreatedById,
            a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()
        ];
    }

}