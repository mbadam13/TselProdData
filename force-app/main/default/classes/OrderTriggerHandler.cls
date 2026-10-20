/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 04-17-2024
 * @last modified by  : Ahmat Zulkifli Murad
**/
public with sharing class OrderTriggerHandler {
   
    public static void afterInsert(List<Order> orderList){
        list<order> orderTTDList = new list<order>();
        list<order> orderClientList = new list<order>();
        list<order> orderProgList = new list<order>();
        set<id> orderMapWithSOAProgrammaticIds = new set<id> ();
        set<id> orderMapWithSOAClientIds = new set<id> ();
        set<id> orderMapWithSOATTDIds = new set<id> ();

        for(order orderListRec :orderList){
            if(orderListRec.order_type__c == 'TTD'){
                orderTTDList.add(orderListRec);

                if(orderListRec.soa__c == null){
                    orderMapWithSOATTDIds.add(orderListRec.id);    
                }
            }
            if(orderListRec.order_type__c == 'Client'){
                orderClientList.add(orderListRec);

                if(orderListRec.soa__c == null){
                    orderMapWithSOAClientIds.add(orderListRec.id);    
                }
            }
            if(orderListRec.order_type__c == 'Programmatic'){
                orderProgList.add(orderListRec);

                if(orderListRec.soa__c == null){
                    orderMapWithSOAProgrammaticIds.add(orderListRec.id);    
                }
                
            }
        }
        
        if(!orderMapWithSOAProgrammaticIds.isEmpty()){
            OrderServices.MapOrderwithSOAnotMapping(orderMapWithSOAProgrammaticIds, 'Programmatic');
        }

        if(!orderMapWithSOAClientIds.isEmpty()){
            OrderServices.MapOrderwithSOAnotMapping(orderMapWithSOAClientIds, 'Client');
        }

        if(!orderMapWithSOATTDIds.isEmpty()){
            OrderServices.MapOrderwithSOAnotMapping(orderMapWithSOATTDIds, 'TTD');
        }

        if(!orderTTDList.isEmpty()){
            System.debug('masuk createOrderItemforTTD');
            OrderServices.createOrderItemforTTD(orderTTDList);
        }

        if(!orderClientList.isEmpty()){
            OrderServices.createOrderItemforClient(orderClientList);
        }

        if(!orderProgList.isEmpty()){
            OrderServices.createOrderItemforProgrammatic(orderProgList);
        }
    }

    public static void afterUpdate(List<Order> oldOrderList, List<Order> newOrderList){
        map<id, order> oldOrderRecordMap = new Map<id, Order>(oldOrderList);
        Set<String> orderRecordIdsforCalculateFinalRevenueInSOAorQuote= new Set<String>();
        for(order newOrderListRec :newOrderList){
            order oldOrderRecord = oldOrderRecordMap.get(newOrderListRec.id);
            if(oldOrderRecord.Final_Sum_Revenue_Telkomsel__c != newOrderListRec.Final_Sum_Revenue_Telkomsel__c){
                orderRecordIdsforCalculateFinalRevenueInSOAorQuote.add(newOrderListRec.id);
            }
        }

        if(!orderRecordIdsforCalculateFinalRevenueInSOAorQuote.isEmpty()){
            CalculateSOAorQuoteFinalRev_Batch batchJob = new CalculateSOAorQuoteFinalRev_Batch(orderRecordIdsforCalculateFinalRevenueInSOAorQuote);
            Database.executeBatch(batchJob, 100);
        }
    }
}