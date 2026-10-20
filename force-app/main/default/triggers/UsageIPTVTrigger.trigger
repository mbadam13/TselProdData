/**
 * @description       : 
 * @author            : M B Adam
 * @group             : 
 * @last modified on  : 07-10-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger UsageIPTVTrigger on Usage_IPTV__c (
    before insert,
    after insert, 
    before update, 
    after update, 
    before delete, 
    after delete, 
    after undelete
    ) 
{
    new MetadataTriggerHandler().run();
}