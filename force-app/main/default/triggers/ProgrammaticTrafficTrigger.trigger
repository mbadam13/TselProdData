/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 10-23-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
trigger ProgrammaticTrafficTrigger on Programmatic_Traffic__c (before insert, after insert){//, after update) {
    if(trigger.isInsert){

        if(trigger.isBefore){
            ProgrammaticTrafficHandler.beforeInsert(Trigger.new);
        }

        if(trigger.isAfter){
            ProgrammaticTrafficHandler.afterInsert(Trigger.new);
        }      
    }
/*
    if(trigger.isUpdate){
        if(trigger.isUpdate){
            ProgrammaticTrafficHandler.afterUpdate(Trigger.new, Trigger.old);
        }
    }
*/
}