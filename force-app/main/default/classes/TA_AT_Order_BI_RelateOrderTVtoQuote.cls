/**
 * @description       : 
 * @author            : Doddy Prima
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : Doddy Prima
**/
public with sharing class TA_AT_Order_BI_RelateOrderTVtoQuote implements TriggerAction.BeforeInsert {

    public void BeforeInsert(List<Order> orderNewList) {
        System.debug('=== TA_AT_Order_BI_RelateOrderTVtoQuote ===');

        String errMessage;
        String notes;
        String message;
        Integer lineNumber;

        // Collect Opportunity IDs from the Quotes being processed
        Set<Id> opportunityIds = new Set<Id>();
        for (Order orderNEWRec : orderNewList) {
            if (orderNEWRec.OpportunityId != null) {
                opportunityIds.add(orderNEWRec.OpportunityId);
            }
        }

        // get quote list to store to the map
        List<Quote> quoteList = [
            SELECT 
                Id, OpportunityId
            FROM quote
            WHERE OpportunityId in : opportunityIds
                AND Status = 'Final'
            ORDER BY CreatedDate DESC
        ];

        // store quote to the map
        Map <ID, ID> opptyQuoteMap = New Map <ID, ID>();
        for (Quote quoteRec : quoteList) {
            if (quoteRec.OpportunityId != null) {
                opportunityIds.add(quoteRec.OpportunityId);

                ID quoteID = opptyQuoteMap.get( quoteRec.OpportunityId );

                if (quoteID == null) {
                    opptyQuoteMap.put( quoteRec.OpportunityId, quoteRec.Id );
                }

            }
        }

        
        // MAIN ITERATE --------------------------
        for (Order orderNEWRec : orderNewList) {

            // If the Opportunity ID is not null, then attempt to relate it to a Quote
            if ( orderNEWRec.OpportunityId != null && orderNEWRec.QuoteId == null ) {
                orderNEWRec.QuoteId = opptyQuoteMap.get( orderNEWRec.OpportunityId );
            }

        }

        

    }
}