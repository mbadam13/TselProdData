/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-23-2024
 * @last modified by  : Syaiful Syafani
**/
@isTest
public with sharing class TA_AT_IPTVInv_BI_SetName_Test {
    @isTest
    static void testInsertInventory(){
        IPTV_Channel__c channelRec = new IPTV_Channel__c(
            Name        = 'AFN',
            Keyword__c  = 'PLATINUM'
        );
        Insert channelRec;

        IPTV_Inventory__c inventoryRec = new IPTV_Inventory__c(
            Name                    = 'AFN PRIME TIME',
            IPTV_Channels__c        = channelRec.Id,
            Show_Time__c            = 'PRIME TIME',
            Time__c                 = '17.00 - 24.00',
            keyword__c              = 'all'
        );
        
        Test.startTest();
            Insert inventoryRec;
        Test.stopTest();
    }
}