/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 10-18-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
public with sharing class MonthlyClientTrafficTriggerHandler {

    public static void afterInsert(list<Monthly_Client_Traffic__c> newMonthlyClientTrafficList){

        set<date> newMonthlyClientTrafficDates = new set<date>(); // for create SOA
        set<Id> newMonthlyClientTrafficIds = new set<Id>(); // for create SOA
        if(!newMonthlyClientTrafficList.isEmpty()){
            for(Monthly_Client_Traffic__c newMonthlyClientTrafficListRec :newMonthlyClientTrafficList){
                
                newMonthlyClientTrafficDates.add(newMonthlyClientTrafficListRec.Start_Date__c);
                newMonthlyClientTrafficIds.add(newMonthlyClientTrafficListRec.id);
            }
        }

        if(!newMonthlyClientTrafficDates.isEmpty()){
            system.debug('CreateSOAforMonthlyClientTraffic');
            MonthlyClientTrafficServices.createSOAforMonthlyClientTraffic(newMonthlyClientTrafficDates);
        }

        /*
        if(!newMonthlyClientTrafficIds.isEmpty()){
            system.debug('createOrderforMonthlyclientTraffic');
            MonthlyClientTrafficServices.createOrderforMonthlyclientTraffic(newMonthlyClientTrafficIds);
        }
        */
    }

    public static void afterUpdate(list<Monthly_Client_Traffic__c> newMonthlyClientTrafficList, list<Monthly_Client_Traffic__c> OldMonthlyClientTrafficList){
        map<id, Monthly_Client_Traffic__c> oldMonthlyClientTrafficMap = new map <id, Monthly_Client_Traffic__c>(OldMonthlyClientTrafficList);
        set<string> MonthlyClientTrafficIdsforUpdateTraffic = new set<string>();
        List<Monthly_Client_Traffic__c> newList = new List<Monthly_Client_Traffic__c>();

        for(Monthly_Client_Traffic__c newMonthlyClientTrafficListRec :newMonthlyClientTrafficList){
            Monthly_Client_Traffic__c oldMonthlyClientTrafficMapRec = oldMonthlyClientTrafficMap.get(newMonthlyClientTrafficListRec.id);

            if(
                oldMonthlyClientTrafficMapRec.SOA__c != newMonthlyClientTrafficListRec.SOA__c && 
                oldMonthlyClientTrafficMapRec.soa__c == null
            ){
                newList.add(oldMonthlyClientTrafficMapRec);
            }

            if(
                (newMonthlyClientTrafficListRec.order_quantity__c != oldMonthlyClientTrafficMapRec.order_quantity__c) ||
                (newMonthlyClientTrafficListRec.Traffic__c != oldMonthlyClientTrafficMapRec.Traffic__c)
            ){
                MonthlyClientTrafficIdsforUpdateTraffic.add(newMonthlyClientTrafficListRec.unique_id__c);
            }
        }

        set<id> MonthlyClientTrafficIds = new set<id>();
        if(!newList.isEmpty()){
            for(Monthly_Client_Traffic__c newListRec :newList){
                MonthlyClientTrafficIds.add(newListRec.id);
            }
        }

        if(!MonthlyClientTrafficIds.isEmpty()
        ){
            MonthlyClientTrafficServices.createOrderforMonthlyclientTraffic(MonthlyClientTrafficIds);
        }  

        if(!MonthlyClientTrafficIdsforUpdateTraffic.isEmpty()){
            OrderServices.UpdateOrderItemforClient(MonthlyClientTrafficIdsforUpdateTraffic);
        }
    }
}