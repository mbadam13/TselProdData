/**
 * @description       : 
 * @author            : Doddy Prima
 * @group             : 
 * @last modified on  : 07-26-2024
 * @last modified by  : Doddy Prima
**/
public with sharing class TA_AT_Quote_AU_RelateOrderTVtoQuote implements TriggerAction.AfterUpdate {

    public void afterUpdate(List<Quote> quoteNewList, List<Quote> quoteOldList) {
        System.debug('=== TA_AT_Quote_AU_RelateOrderTVtoQuote ===');
        
        String errMessage;
        String notes;
        String message;
    
        Map<Id,Quote> oldMap = new Map<Id,Quote>(quoteOldList);

        // Collect Opportunity IDs from the Quotes being processed
        Set<Id> opportunityIds = new Set<Id>();
        for (Quote quoteNEWRec : quoteNewList) {
            if (quoteNEWRec.OpportunityId != null) {
                opportunityIds.add(quoteNEWRec.OpportunityId);
            }
        }

        // Query the Opportunities
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([
            SELECT 
                Id, StageName, Approval_Status__c, Penagihan_based_on__c, Business_Product__c,
                Penagihan_based_on_tv__c
            FROM Opportunity
            WHERE Id IN :opportunityIds
        ]);

        List<Order> orderNeedToRelateList = [
            SELECT id, OpportunityId, QuoteId
            FROM Order
            WHERE OpportunityId IN :opportunityIds
        ];


        // MAIN ITERATE --------------------------
        for(Quote quoteNEWRec : quoteNewList){
            Quote quoteOLDRec = oldMap.get(quoteNEWRec.Id);
            Opportunity oppRelREC = opportunityMap.get( quoteNEWRec.OpportunityId );

            // when status move to FINAL
            if ( oppRelREC.Business_Product__c              == 'TV Media' 
                    && oppRelREC.StageName                  == 'Closed Won' 
                    && oppRelREC.Penagihan_based_on_tv__c   == 'Postpaid'
                    && quoteNEWRec.Status                   == 'Final' 
                    && quoteOLDRec.Status                   <> 'Final') {
                
                System.debug('=== QuoteNumber : ' + quoteNEWRec.QuoteNumber);
                

                for ( Order orderNeedToRelateREC : orderNeedToRelateList) {
                    // set QuoteID in order (to realate)
                    System.debug('=== Relate Order to this quote ===');
                    if ( orderNeedToRelateREC.OpportunityId ==  quoteNEWRec.OpportunityId ) {
                        orderNeedToRelateREC.QuoteId = quoteNEWRec.id;
                    }
                }

            }
        }

        if (orderNeedToRelateList.size() > 0 ) {

            try {
                // update orders need to relate
                update orderNeedToRelateList;
                System.debug('=== Order has been updated ===');

            } catch (Exception e) {
                errMessage = 'Error on TA_AT_Quote_AU_RelateOrderTVtoQuote::' + e.getmessage() + ' - ' + e.getStacktraceString() + e.getLineNumber() ;
                system.debug('=== error message : ' + errMessage);
                AppUtils.putError(errMessage );
            }
        }
    }


}