/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-30-2024
 * @last modified by  : Syaiful Syafani
**/
trigger LeadTrigger on Lead (
    before insert,
    after insert,
    before update,
    after update,
    before delete,
    after delete,
    after undelete
){
    new MetadataTriggerHandler().run();
}