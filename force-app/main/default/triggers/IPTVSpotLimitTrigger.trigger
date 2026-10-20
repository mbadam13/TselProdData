/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 06-21-2024
 * @last modified by  : Syaiful Syafani
**/
trigger IPTVSpotLimitTrigger on IPTV_Spot_Limit__c (
    before insert,
    after insert,
    before update,
    after update,
    before delete,
    after delete,
    after undelete
) {
    new MetadataTriggerHandler().run();
}