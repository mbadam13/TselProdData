/**
 *  Author      :   Yusuf Ramadhan (yusuf.ramadhan@saasten.com)
 *  Purpose     :   Identify App Path No based on Product Code
 *  Test Class  :   TA_AT_OLI_CalculationDiskonTest
 *  Project     :   TSEL-2411-ReOrg and Approval Enhancement
 * 
 *  Date            PIC         Ticket          Brief of changes
 *  25/12/2025      Yusuf       APE-006         Initial Created
 *  26/02/2025      Yusuf       APE-006         Connecting to Service Class
 *  03/03/2025      Yusuf       APE-006         Call ACW Approval Path Logic
 * 
 */
public with sharing class TA_AT_OLI_AU_CalculationDiskon implements TriggerAction.AfterUpdate {
    /**
     * WHEN:  Price or discount is changing
     * GIVEN: Business Product either TV or Media
     * THEN: calculate the approval path no
     */
    public void afterUpdate(List<OpportunityLineItem> newList, List<OpportunityLineItem> oldList){
        Map<Id, OpportunityLineItem> oldMap = new Map<Id, OpportunityLineItem>(oldList);
        OpportunityProductService.processDiscountApproval(newList, oldMap);
    }
   
}