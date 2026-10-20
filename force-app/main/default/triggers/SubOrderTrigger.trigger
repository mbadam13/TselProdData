/**
 * @description       : 
 * @author            : M B Adam
 * @group             : 
 * @last modified on  : 03-26-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger SubOrderTrigger on Sub_Order__c (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
    ) 
    {
    new MetadataTriggerHandler().run();

}