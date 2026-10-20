/**
 * @description       : 
 * @author            : Doddy Prima
 * @group             : 
 * @last modified on  : 07-05-2024
 * @last modified by  : Doddy Prima
**/
trigger QuoteTrigger on Quote ( 
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    new MetadataTriggerHandler().run();
}