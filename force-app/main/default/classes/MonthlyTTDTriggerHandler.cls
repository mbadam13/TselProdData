/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 09-16-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
public with sharing class MonthlyTTDTriggerHandler {

    public static void afterInsert(list<MonthlyTTDTraffic__c> newMonthlyTTDTrafficList){
        system.debug('=== MonthlyTTDTriggerHandler beforeInsert ===');
        try {
        Set<Id> newMonthlyTTDIds = new Set<Id>();
        for (MonthlyTTDTraffic__c newMonthlyRec : newMonthlyTTDTrafficList) {
            if(newMonthlyRec.SOA__c == null){
                newMonthlyTTDIds.add(newMonthlyRec.Id);
            }
        }
        if(!newMonthlyTTDIds.isEmpty()){
             MonthlyTTDServices.createSOA(newMonthlyTTDIds);
        }
       
          
        } catch (Exception e) {
            string errMessage = 'Error on MonthlyTTDTriggerHandler beforeInsert function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }  
    }


    public static void afterUpdate(List<MonthlyTTDTraffic__c> newMonthlyList,List<MonthlyTTDTraffic__c> oldMonthlyList){
        Map<Id,MonthlyTTDTraffic__c> oldMap = new Map<Id,MonthlyTTDTraffic__c>(oldMonthlyList);
        List<MonthlyTTDTraffic__c> newList = new List<MonthlyTTDTraffic__c>();
        Set<Id> monthlyIds = new Set<Id>();


        for (MonthlyTTDTraffic__c newMonthlyRec : newMonthlyList) {
            if(
                newMonthlyRec.SOA__c != oldMap.get(newMonthlyRec.id).SOA__c && 
                oldMap.get(newMonthlyRec.id).SOA__c == null
            ){
                newList.add(newMonthlyRec);
            }
            
            if(
                oldMap.get(newMonthlyRec.id).Traffic__c != newMonthlyRec.Traffic__c || 
                oldMap.get(newMonthlyRec.id).Price__c != newMonthlyRec.Price__c
            ){
                System.debug('MASUK KONDISI UPDATE TRAFFIC');
                monthlyIds.add(newMonthlyRec.Id);
            }
        }

        if(!newList.isEmpty()){
            MonthlyTTDServices.createOrderforMonthlyTTD(newList);
        }

        if(!monthlyIds.isEmpty()){
            //MonthlyTTDServices.updateOrderItem(monthlyIds);
            OrderServices.UpdateOrderItemforTTD(monthlyIds);
        }
    }

  
}