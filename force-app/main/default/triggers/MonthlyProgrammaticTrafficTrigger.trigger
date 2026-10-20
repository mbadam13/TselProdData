/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 09-04-2023
 * @last modified by  : Diky Nurosid
**/
trigger MonthlyProgrammaticTrafficTrigger on monthly_programmatic_traffic__c (after insert,after update) {
    if(trigger.isAfter){
        if(trigger.isInsert){
            MonthlyProgrammaticTrafficTriggerHandler.afterInsert(trigger.new);
        }
    } 
    
    if(trigger.isAfter && trigger.isUpdate){
        MonthlyProgrammaticTrafficTriggerHandler.afterUpdate(Trigger.new, Trigger.Old);
    }
}