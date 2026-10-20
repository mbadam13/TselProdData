public with sharing class PubmaticBillingTriggerHandler {

    public static void updateBillingIDRfromBillingUSD(list<pubmatic_billing__c> newPubmaticBillingrRecordList, list<pubmatic_billing__c> oldPubmaticBillingrRecordList){
        System.debug(' in updateBillingIDRfromBillingUSD');
        System.debug('newPubmaticBillingrRecordList: ' + newPubmaticBillingrRecordList);
        System.debug('oldPubmaticBillingrRecordList: ' + oldPubmaticBillingrRecordList);

        for(pubmatic_billing__c newPubmaticBillingrRecordListRec :newPubmaticBillingrRecordList){
            if(newPubmaticBillingrRecordListRec.Billing_USD__c != null){
                newPubmaticBillingrRecordListRec.billing_IDR__c = newPubmaticBillingrRecordListRec.Billing_USD__c * newPubmaticBillingrRecordListRec.exchange_rate__c;  
            }       
        }
    }

    public void OnBeforeUpdate(List<pubmatic_billing__c> oldPubmaticBillingrRecordList, List<pubmatic_billing__c> newPubmaticBillingrRecordList, Map<Id, pubmatic_billing__c> oldPubmaticBillingrRecordMap, Map<Id, pubmatic_billing__c> newPubmaticBillingrRecordMap) {
        updateBillingIDRfromBillingUSD(newPubmaticBillingrRecordList,  oldPubmaticBillingrRecordList);
    }
}