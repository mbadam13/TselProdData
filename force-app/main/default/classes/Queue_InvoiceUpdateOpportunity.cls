/**
 *  Author      :   Yusuf Ramadhan  (yusuf.ramadhan@saasten.com)
 *  Purposes    :   [Querying assosiate recs SOA/Quote then get the Opportunity and fill Opportunity in Invoice__c]
 *  Test Class  :   [Queue_InvoiceUpdateOpportunityTEST]
 * 
 *  Date        PIC         Brief of changes        Ticket
 *  26/06/24    Yusuf       Initial Create          https://saasten.odoo.com/web#id=532&cids=1&menu_id=132&action=217&active_id=10&model=project.task&view_type=form
 * 
 * 
 */
public with sharing class Queue_InvoiceUpdateOpportunity implements Queueable {
    private Set<Id> invoiceIds;

    public Queue_InvoiceUpdateOpportunity(Set<Id> invoiceIds) {
        this.invoiceIds = invoiceIds;
    }

    public void execute(QueueableContext context) {
        Map<Id, Invoice__c> invoicesToUpdate = new Map<Id, Invoice__c>();

        // Query SOA__c records
        List<SOA__c> soaRecords = [
            SELECT 
                Invoice__c, 
                Opportunity__c 
            FROM 
                SOA__c 
            WHERE 
                Invoice__c IN :invoiceIds AND 
                Opportunity__c != null
        ];

        for (SOA__c soa : soaRecords) {
            invoicesToUpdate.put(soa.Invoice__c, new Invoice__c(
                Id = soa.Invoice__c,
                Opportunity__c = soa.Opportunity__c
            ));
        }

        // Query Quote records
        List<Quote> quoteRecords = [
            SELECT 
                Invoice__c, 
                OpportunityId 
            FROM 
                Quote 
            WHERE 
                Invoice__c IN :invoiceIds AND 
                OpportunityId != null
        ];

        for (Quote quote : quoteRecords) {
            invoicesToUpdate.put(quote.Invoice__c, new Invoice__c(
                Id = quote.Invoice__c,
                Opportunity__c = quote.OpportunityId
            ));
        }

        if (!invoicesToUpdate.isEmpty()) {
            update invoicesToUpdate.values();
        }
    }
}