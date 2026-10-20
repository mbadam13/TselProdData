/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 10-13-2023
 * @last modified by  : Diky Nurosid
**/
public with sharing class TTDTrafficTriggerHandler {

    public static void beforeInsert(List<TTD_Traffic__c> TtdList){
        
        TTDTrafficServices.userMappingWithNik(TtdList);
    }

    public static void afterInsert(List<TTD_Traffic__c> TtdList){
        
        TTDTrafficServices.createMonthlyTTDTraffic(TtdList);
    }
/*
    public static void afterUpdate(List<TTD_Traffic__c> newTtdList, List<TTD_Traffic__c> oldTtdList){
        Map<Id,TTD_Traffic__c> oldMap = new Map<Id,TTD_Traffic__c>(oldTtdList);
        List<TTD_Traffic__c> newTtdUpdateList = new List<TTD_Traffic__c>();
        for(TTD_Traffic__c ttdRec: newTtdList){

            if(
                ttdRec.ImpressionCount__c != oldMap.get(ttdRec.Id).ImpressionCount__c || 
                ttdRec.TotalDataCostInUSD__c != oldMap.get(ttdRec.Id).TotalDataCostInUSD__c
            ){
                newTtdUpdateList.add(ttdRec);
            }
        }
        if(!newTtdUpdateList.isEmpty()){
         //   TTDTrafficServices.updateMonthlyTraffic(newTtdUpdateList,oldTtdList);
        }
    }
*/   
}