/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 06-22-2024
 * @last modified by  : Syaiful Syafani
**/
trigger IPTVInventoryTrigger on IPTV_Inventory__c (
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