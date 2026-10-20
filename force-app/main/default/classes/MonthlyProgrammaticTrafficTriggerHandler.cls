/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 10-16-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
public with sharing class MonthlyProgrammaticTrafficTriggerHandler {
    
    public static void afterInsert(List<Monthly_Programmatic_Traffic__c> newMonthlyProgrammaticTraffic){

        set<date> monthlyProgrammaticTrafficforCreateSOAbyDates = new set<date>();
        set<id> monthlyProgrammaticTrafficforCreateOrders = new set<id>();

        for(Monthly_Programmatic_Traffic__c newMonthlyProgrammaticTrafficRec :newMonthlyProgrammaticTraffic){
            
            monthlyProgrammaticTrafficforCreateSOAbyDates.add(newMonthlyProgrammaticTrafficRec.periode__c);
            monthlyProgrammaticTrafficforCreateOrders.add(newMonthlyProgrammaticTrafficRec.id);
            
        }

        if(!monthlyProgrammaticTrafficforCreateSOAbyDates.isEmpty()){
            MonthlyProgrammaticTrafficServices.createSOAforMonthlyProgrammaticTraffic(monthlyProgrammaticTrafficforCreateSOAbyDates);
        }
    }

    public static void afterUpdate(list<Monthly_Programmatic_Traffic__c> newMonthlyProgTrafficList, list<Monthly_Programmatic_Traffic__c> oldMonthlyProgTrafficList){
        map<id, Monthly_Programmatic_Traffic__c> oldMonthlyProgTrafficMap = new map <id, Monthly_Programmatic_Traffic__c>(oldMonthlyProgTrafficList);
        set<string> monthlyProgTrafficIds = new set<string>();
        set<string> monthlyProgrammaticTrafficIds = new set<string>();

        for(Monthly_Programmatic_Traffic__c newMonthlyProgTrafficListRec :newMonthlyProgTrafficList){
            Monthly_Programmatic_Traffic__c oldMonthlyProgTrafficMapRec = oldMonthlyProgTrafficMap.get(newMonthlyProgTrafficListRec.id);

            if(
                (newMonthlyProgTrafficListRec.Paid_Impression__c != oldMonthlyProgTrafficMapRec.Paid_Impression__c) ||
                (newMonthlyProgTrafficListRec.Revenue__c != oldMonthlyProgTrafficMapRec.Revenue__c)
            ){
                monthlyProgTrafficIds.add(newMonthlyProgTrafficListRec.unique_id__c);
            }

            if(
                (oldMonthlyProgTrafficMapRec.soa__c != newMonthlyProgTrafficListRec.soa__c) &&
                oldMonthlyProgTrafficMapRec.soa__c == null
            ){
                monthlyProgrammaticTrafficIds.add(newMonthlyProgTrafficListRec.unique_id__c);
            }
            
        }

        if(!monthlyProgrammaticTrafficIds.isEmpty()){
            MonthlyProgrammaticTrafficServices.createOrderforMonthlyProgrammaticTraffic(monthlyProgrammaticTrafficIds);
        }

        if(!monthlyProgTrafficIds.isEmpty()){
            system.debug('in monthlyprogrammatictriggerhandler.afterUpdate');
            OrderServices.UpdateOrderItemforProg(monthlyProgTrafficIds);
        }

        /*
        if(!monthlyProgrammaticTrafficIds.isEmpty()){
            system.debug('in monthlyprogrammatictriggerhandler.afterUpdate');
            MonthlyProgrammaticTrafficServices.MapOrderwithSOAnotMapping(monthlyProgrammaticTrafficIds);
        }
        */        
    }
}