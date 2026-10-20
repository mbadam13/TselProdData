/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 10-03-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
public with sharing class RabatRevenueCalculationTriggerHandler {
    public static void afterinsertRabatRevenueCalculation(list<Rabat_Revenue_Calculation__c> newRabatRevenueCalculationList){
        set<id> newRabatRevenueCalculationIds = new set<id>();
        
        for(Rabat_Revenue_Calculation__c newRabatRevenueCalculationListRec :newRabatRevenueCalculationList){
            newRabatRevenueCalculationIds.add(newRabatRevenueCalculationListRec.id);
        }

        if(newRabatRevenueCalculationIds != null){
            RabatRevenueCalculationServices.createRabatRevenueItems(newRabatRevenueCalculationIds);
        }
    }
}