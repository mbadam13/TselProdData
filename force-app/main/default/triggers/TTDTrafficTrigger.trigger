/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 10-13-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
trigger TTDTrafficTrigger on TTD_Traffic__c (before insert, after insert){//, after update) {

    if(trigger.isInsert){

        if(trigger.isBefore){
            TTDTrafficTriggerHandler.beforeInsert(Trigger.new);
        }
        if(trigger.isAfter){
            TTDTrafficTriggerHandler.afterInsert(Trigger.new);
        } 
    }

    if(trigger.isUpdate){

        if(trigger.isAfter){
       //     TTDTrafficTriggerHandler.afterUpdate(Trigger.new,Trigger.old);
        } 
    }

}