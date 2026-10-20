public with sharing class DealIDFormComponentController {

    @AuraEnabled
    public static list<OpportunityLineItem> getOpportunityProduct(string opporutnityId){
        List<OpportunityLineItem> opptyLineItemList = [select id, name, Product2.name, Deal_ID__c from OpportunityLineItem where Product2.name like '%Tadex%' and Opportunityid =:opporutnityId ];
        return opptyLineItemList;
    }
}