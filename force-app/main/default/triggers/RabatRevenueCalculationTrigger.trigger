/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 10-03-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
trigger RabatRevenueCalculationTrigger on Rabat_Revenue_Calculation__c (after insert) {

    if(trigger.isAfter){
        if(trigger.isInsert){
            RabatRevenueCalculationTriggerHandler.afterinsertRabatRevenueCalculation(Trigger.new);
        }
    }
}