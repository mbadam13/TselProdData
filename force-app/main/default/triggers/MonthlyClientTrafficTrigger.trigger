/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 08-27-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
trigger MonthlyClientTrafficTrigger on Monthly_Client_Traffic__c (after insert, after update) {
    if(trigger.isAfter){
        if(trigger.isInsert){
            MonthlyClientTrafficTriggerHandler.afterInsert(Trigger.new);
        }
    }

    if(trigger.isAfter){
        if(trigger.isUpdate){
            MonthlyClientTrafficTriggerHandler.afterUpdate(Trigger.new, Trigger.old);
        }
    }
}