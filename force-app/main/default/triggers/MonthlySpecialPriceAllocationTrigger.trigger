/**
 * @description       : 
 * @Test Class        : MonthlySPAllocationTrigger_Test
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 06-22-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   06-22-2023   Novando Utoyo Agmawan   Initial Version
**/

trigger MonthlySpecialPriceAllocationTrigger on Monthly_Special_Price_Allocation__c (after insert, after update) {
    Trigger_Setting__c MonthlySpecialPriceAllocationTriggerAcitvation = Trigger_Setting__c.getInstance('MonthlySpecialPriceAllocationTrigger');

    if (MonthlySpecialPriceAllocationTriggerAcitvation.IsActive__c == true){
        if(trigger.isafter){
            if(trigger.isinsert){
                MonthlySPAllocationTriggerHandler.afterInsertHandler(Trigger.new);
            }
            
            if(trigger.isUpdate){
                MonthlySPAllocationTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
            }
        }
    }
}