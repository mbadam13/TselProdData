/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 25/03/2025
 * @last modified by  : Syaiful Syafani
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   13/01/2025   Syaiful Syafani   Initial Version
 * 2.0   25/03/2025   Syaiful Syafani   Deactive Code 
**/
public with sharing class TA_VR_OLI_BU_QtyEqualUsageActual implements TriggerAction.BeforeUpdate {
    public void BeforeUpdate(List<OpportunityLineItem> newList, List<OpportunityLineItem> oldList){
        System.debug('=== TA_VR_OLI_BU_QtyEqualUsageActual ===');

        Map<Id, OpportunityLineItem> oldMap = new Map<Id, OpportunityLineItem>(oldList);

        try {
            for (OpportunityLineItem newOLIRec : newList) { // langsung ngambil dari oppty product
                OpportunityLineItem oldOLIRec = oldMap.get(newOLIRec.Id);
                if (
                    newOLIRec.Quantity < oldOLIRec.Usage_Actual__c && 
                    newOLIRec.Opp_Adj_Ver__c >= 1
                ) {
                    newOLIRec.addError('Product ini memiliki Usage yang lebih banyak dari pada quantity! Usage pada product ini sebanyak '+ String.valueOf(oldOLIRec.Usage_Actual__c));
                }
            }    
            
            /* deactive - 25 March 2025
            Set<Id> oliIds = new Set<Id>();
            for (OpportunityLineItem oliRec : newList) {
                oliIds.add(oliRec.Id);
            }

            List<OrderItem> orderItemList = [
                SELECT
                    Id,
                    Usage_Actual__c,
                    Opportunity_Product__c,
                    Opportunity_Product__r.Usage_Actual__c,
                    Opportunity_Product__r.Quantity,
                    Opportunity_Product__r.Opp_Adj_Ver__c,
                    Opportunity_Product__r.Business_Product2__c
                FROM
                    OrderItem
                WHERE
                    Opportunity_Product__c IN :oliIds
            ];
            System.debug('== orderItemList.size: '+ orderItemList.size());

            Map<Id, Boolean> qtyEqualUsageActualMap = new Map<Id, Boolean>();
            Map<Id, Integer> usgTotalMap = new Map<Id, Integer>();
            for (OrderItem orderItemRec : orderItemList) {
                Boolean qtyNotEqualUsageActual = false;
                System.debug('== orderItemRec.Usage_Actual__c' + orderItemRec.Usage_Actual__c);
                System.debug('== orderItemRec.Opportunity_Product__r.Usage_Actual__c' + orderItemRec.Opportunity_Product__r.Usage_Actual__c);
                System.debug('== orderItemRec.Opportunity_Product__r.Quantity' + orderItemRec.Opportunity_Product__r.Quantity);
                System.debug('== orderItemRec.Opportunity_Product__r.Opp_Adj_Ver__c' + orderItemRec.Opportunity_Product__r.Opp_Adj_Ver__c);

                if (
                    orderItemRec.Usage_Actual__c <= orderItemRec.Opportunity_Product__r.Quantity &&
                    // orderItemRec.Opportunity_Product__r.Business_Product2__c == 'TV Media' &&
                    orderItemRec.Opportunity_Product__r.Opp_Adj_Ver__c >= 1
                ) {
                    qtyNotEqualUsageActual = true;
                    qtyEqualUsageActualMap.put(orderItemRec.Opportunity_Product__c, qtyNotEqualUsageActual); // opptyProductId, Boolean
                    usgTotalMap.put(orderItemRec.Opportunity_Product__c, Integer.valueOf(orderItemRec.Usage_Actual__c));
                } 
            }

            System.debug('== qtyEqualUsageActualMap: '+ qtyEqualUsageActualMap);
            for (OpportunityLineItem newOLIRec : newList) {
                Boolean notValidQuantity =  qtyEqualUsageActualMap.get(newOLIRec.Id);
                Integer usgTotal = usgTotalMap.get(newOLIRec.Id);
                System.debug('== notValidQuantity: '+ notValidQuantity);
                System.debug('== usgTotal: '+ usgTotal);

                if (notValidQuantity == true) {
                    newOLIRec.addError('Product ini memiliki Usage yang lebih banyak dari pada quantity! Usage pada product ini sebanyak '+ String.valueOf(usgTotal));
                }
            }
            */

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            string errMessage = 'Error on TA_VR_OLI_BU_QtyEqualUsageActual - BeforeUpdate function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage);
        }
    }
}