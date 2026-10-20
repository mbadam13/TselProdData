/**
 * @description       : 
 * @Test Class        : MonthlyDiscountIMSTrigger_Test
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 06-26-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   06-22-2023   Novando Utoyo Agmawan   Initial Version
**/


trigger MonthlyDiscountIMSTrigger on Monthly_Discount_Inventory_Media_Seller__c (after insert, before update) {
    Trigger_Setting__c MonthlyDiscountIMSTriggerAcitvation = Trigger_Setting__c.getInstance('MonthlyDiscountIMSTrigger');
    
    if (MonthlyDiscountIMSTriggerAcitvation.IsActive__c == true){
        if(trigger.isafter){
            system.debug('====== MonthlyDiscountIMSTrigger trigger.isafter ======');

            if(trigger.isinsert){
                system.debug('====== MonthlyDiscountIMSTrigger trigger.isinsert ======');

                MonthlyDiscountIMSTriggerHandler.afterInsertHandler(Trigger.new);
            }
        }
        if(trigger.isBefore){
            system.debug('====== MonthlyDiscountIMSTrigger trigger.isBefore ======');
            if(trigger.isUpdate){
                system.debug('====== MonthlyDiscountIMSTrigger trigger.isUpdate ======');
                
                MonthlyDiscountIMSTriggerHandler.afterUpdateHandler(Trigger.new, Trigger.oldMap);
            }
        }
    }
}