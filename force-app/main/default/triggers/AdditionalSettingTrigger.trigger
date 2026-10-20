/**
 * @description       : 
 * @Test Class        : AdditionalSettingTriggerHandlerTest
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 10-09-2023
 * @last modified by  : Ahmat Zulkifli Murad
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   06-19-2023   Novando Utoyo Agmawan   Initial Version
**/

trigger AdditionalSettingTrigger on Additional_Setting__c (before insert, before delete, before update) {
    AdditionalSettingTriggerHandler AdditionalSettingTriggerHandlerClass = new AdditionalSettingTriggerHandler(); 
    
    if(Trigger.isInsert && Trigger.isBefore) {
        System.debug('Trigger.new: ' + Trigger.new);
        AdditionalSettingTriggerHandlerClass.OnBeforeInsert(Trigger.new);  
    }

    if(Trigger.isUpdate && Trigger.isBefore) {
        System.debug('Trigger.new: ' + Trigger.new);
        AdditionalSettingTriggerHandlerClass.OnBeforeUpdate(Trigger.new);  
    }

    if(Trigger.isDelete && Trigger.isBefore){
        System.debug('Trigger.old: ' + Trigger.old);
        System.debug('Trigger.oldMap: ' + Trigger.oldMap);

        AdditionalSettingTriggerHandlerClass.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    
}