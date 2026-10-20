/**
 *  Author      :   Yusuf Ramadhan  (yusuf.ramadhan@saasten.com)
 *  Purpose     :   Handle all the trigger events for Invoice object After Update
 *  Test class  :   [TA_AT_AU_InvoiceHandlerTEST]
 * 
 *  Date        PIC             Brief of changes            Ticket
 *  130624      Yusuf           Initial Create              https://saasten.odoo.com/web#id=522&cids=1&model=project.task&view_type=form
 * 
 */
public with sharing class TA_AT_AU_InvoiceHandler implements TriggerAction.AfterUpdate  {
    public void AfterUpdate(List<Invoice__c> newInvoiceRecords, List<Invoice__c> oldInvoiceRecords) {
        // Set to hold the Ids of changed Invoices
        Set<Id> changedInvoiceIds = new Set<Id>();
    
        // Map oldInvoiceRecords by Id for easy lookup
        Map<Id, Invoice__c> oldInvoiceMap = new Map<Id, Invoice__c>(oldInvoiceRecords);
    
        // Iterate through new records to check for changes
        for (Invoice__c newInvoice : newInvoiceRecords) {
            Invoice__c oldInvoice = oldInvoiceMap.get(newInvoice.Id);
    
            // Check if Hak_Telkomsel__c, Tanggal_Invoice__c or No_Invoice__c has changed
            if (
                newInvoice.Hak_Telkomsel__c != oldInvoice.Hak_Telkomsel__c ||
                newInvoice.Tanggal_Invoice__c != oldInvoice.Tanggal_Invoice__c ||
                newInvoice.No_Invoice__c != oldInvoice.No_Invoice__c
            ) {
                changedInvoiceIds.add(newInvoice.Id);
            }
        }
    
        if (!changedInvoiceIds.isEmpty()) {
            // Query for related SOA__c and Quote records
            List<String> relatedSOAorQuoteIds = new List<String>();
            
            // Query SOA__c records
            List<SOA__c> relatedSOAs = [
                SELECT Id
                FROM SOA__c
                WHERE Invoice__c IN :changedInvoiceIds
            ];
            for (SOA__c soa : relatedSOAs) {
                relatedSOAorQuoteIds.add(String.valueOf(soa.Id));
            }
    
            // Query Quote records
            List<Quote> relatedQuotes = [
                SELECT Id
                FROM Quote
                WHERE Invoice__c IN :changedInvoiceIds
            ];
            for (Quote quote : relatedQuotes) {
                relatedSOAorQuoteIds.add(String.valueOf(quote.Id));
            }
    
            if (!relatedSOAorQuoteIds.isEmpty()) {
                // Call the batch with related SOA__c or Quote IDs
                RefreshInvoiceValueinOrderItem_Batch batch = new RefreshInvoiceValueinOrderItem_Batch(relatedSOAorQuoteIds);
                Database.executeBatch(batch);
            }
        }
    }
    
}