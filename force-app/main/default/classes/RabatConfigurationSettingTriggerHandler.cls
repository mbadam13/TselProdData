/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * test class         : RabatConfigurationTriggerHandlerTest
 * @last modified on  : 10-20-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
public with sharing class RabatConfigurationSettingTriggerHandler {
    public static void BeforeInsertRabatConfigurationSettingTriggerHandler(list<Rabat_Configuration_Setting__c> newRabatConfigurationSettingTriggerList) {
        RabatConfigurationSettingServices.validationCannotInsertRecordWhenStartDateIsExist(newRabatConfigurationSettingTriggerList);
    }

    public static void BeforeDeleteRabatConfigurationSettingTriggerHandler(list<Rabat_Configuration_Setting__c> oldRabatConfigurationSettingTriggerList){
        RabatConfigurationSettingServices.validationCannotDeleteDatawhenisAlreadyUsed(oldRabatConfigurationSettingTriggerList);
    }
}