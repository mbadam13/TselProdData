/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-15-2024
 * @last modified by  : Syaiful Syafani
**/
@isTest
public with sharing class TA_AT_IPTVSpotLimit_BI_SetName_Test {
    @isTest
    static void testCreateSpotLimit(){
        // create channel
        IPTV_Channel__c channelRec = new IPTV_Channel__c(
            Name                    = 'AFN',
            Keyword__c              = 'TVC PLATINUM',
            Product_Inventory__c    = 'PLATINUM'
        );
        Insert channelRec;

        // create inventory
        IPTV_Inventory__c invRec = new IPTV_Inventory__c(
            Name                = 'AFN PRIME TIME',
            IPTV_Channels__c    = channelRec.Id,
            Show_Time__c        = 'PRIME TIME',
            Time__c             = '17.00 - 24.00',
            keyword__c          = 'all'
        );
        Insert invRec;

        // create spot limit
        IPTV_Spot_Limit__c spotLimitRec = new IPTV_Spot_Limit__c(
            Name                = 'SL/AFN/PRIME TIME',
            Spot_Limit__c       = 480,
            Start_Date__c       = Date.newInstance(2024, 1, 1),
            End_Date__c         = Date.newInstance(2024, 2, 28),
            IPTV_Inventory__c   = invRec.Id,
            is_Active__c        = true
        );
        Test.startTest();
        Insert spotLimitRec;
        Test.stopTest();
    }
    
      static void testCreateIPTVInv(){
        // create channel
        IPTV_Channel__c channelRec = new IPTV_Channel__c(
            Name                    = 'AFN',
            Keyword__c              = 'TVC PLATINUM',
            Product_Inventory__c    = 'PLATINUM'
        );
        Insert channelRec;

        // create inventory
        IPTV_Inventory__c invRec = new IPTV_Inventory__c(
            Name                = 'AFN PRIME TIME',
            IPTV_Channels__c    = channelRec.Id,
            Show_Time__c        = 'PRIME TIME',
            Time__c             = '17.00 - 24.00',
            keyword__c          = 'all'
        );
        

       
        Test.startTest();
        Insert invRec;
        Test.stopTest();
    }
}