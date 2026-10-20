/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 10-23-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
trigger ClientTrafficTrigger on Client_Traffic__c (before insert, after insert){//, after update) {

    if(trigger.isInsert){

        if(trigger.isBefore){
            ClientTrafficHandler.beforeInsert(Trigger.new);
        } 
        if(trigger.isAfter){
            ClientTrafficHandler.afterInsert(Trigger.new);
        }
    }

    /*
    if(trigger.isUpdate){

        if(trigger.isAfter){
            ClientTrafficHandler.afterUpdate(Trigger.new,Trigger.old);
        }
    }
    */
}