/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-23-2024
 * @last modified by  : Syaiful Syafani
**/
@isTest
public with sharing class TA_AT_IPTVInv_BU_UpdateInventories_Test {
    @isTest
    static void testUpdateInventory(){
        // == create channel ==
        IPTV_Channel__c channelRec = new IPTV_Channel__c(
            Name                    = 'AFN',
            Keyword__c              = 'TVC PLATINUM'
        );
        Insert channelRec;

        // == create inventory ==
        IPTV_Inventory__c invRec = new IPTV_Inventory__c(
            Name                    = 'AFN PRIME TIME',
            IPTV_Channels__c        = channelRec.Id,
            Show_Time__c            = 'PRIME TIME',
            Time__c                 = '17.00 - 24.00',
            keyword__c              = 'all',
            Type__c                 = 'IPTV',
            Product_Inventory__c    = 'TVC PLATINUM;TVC ROS'
        );
        Insert invRec;

        // === update inventory ===
        invRec.Product_Inventory__c = 'TVC PLATINUM;TVC GOLD';
        Test.startTest();
            Update invRec;
        Test.stopTest();
    }
}