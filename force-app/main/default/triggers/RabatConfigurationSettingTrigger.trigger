/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 10-05-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
trigger RabatConfigurationSettingTrigger on Rabat_Configuration_Setting__c (Before insert, Before Delete ) {
    
    if(trigger.isInsert){
        if(trigger.isBefore){
            RabatConfigurationSettingTriggerHandler.BeforeInsertRabatConfigurationSettingTriggerHandler(Trigger.new);
        }
    }

    if(trigger.isDelete){
        if(trigger.isBefore){
            RabatConfigurationSettingTriggerHandler.BeforeDeleteRabatConfigurationSettingTriggerHandler(Trigger.old);
        }
    }
}