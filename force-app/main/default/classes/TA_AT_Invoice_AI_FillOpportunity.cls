/**
 *  Author      :   Yusuf Ramadhan  (yusuf.ramadhan@saasten.com)
 *  Purposes    :   [fill Opportunity in Invoice__c through SOA or Quote]
 *  Test Class  :   [TA_AT_Invoice_AI_FillOpportunityTEST]
 * 
 *  Date        PIC         Brief of changes        Ticket
 *  26/06/24    Yusuf       Initial Create          https://saasten.odoo.com/web#id=532&cids=1&menu_id=132&action=217&active_id=10&model=project.task&view_type=form
 * 
 * 
 */
public with sharing class TA_AT_Invoice_AI_FillOpportunity implements TriggerAction.AfterInsert {
    public void afterInsert(List<Invoice__c> newList) {
        Set<Id> invoiceIds = new Set<Id>();
        for (Invoice__c invoice : newList) {
            invoiceIds.add(invoice.Id);
        }
        if (!invoiceIds.isEmpty()) {
            System.enqueueJob(new Queue_InvoiceUpdateOpportunity(invoiceIds));
        }
    }
}