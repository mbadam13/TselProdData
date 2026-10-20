/**
 * @description       : Test Class For IPTV Spot Limit
 * @author            : M B Adam 
 * @group             : 
 * @last modified on  : 07-16-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * 
 * V.1.0         M B Adam         initial version 
**/
@isTest()
public  class IPTVSpotlimitService_Test {
    public static testMethod void testMethodIPTV(){
        IPTV_Channel__c IPTVChannel1 = new IPTV_Channel__c(
            Name = 'AllPlay.ent', 
            Product_Inventory__c = 'TVC PLATINUM', 
            Keyword__c = 'PLATINUM'     
        );
        insert IPTVChannel1;

        IPTV_Inventory__c IPTVInventory1 = new IPTV_Inventory__c(
            Name = 'AllPlay.ent REGULAR TIME', 
            IPTV_Channels__c = IPTVChannel1.Id, 
            Show_Time__c = 'REGULAR TIME', 
            Time__c = '00.00 - 17.00', 
            keyword__c = 'all'
        );
        insert IPTVInventory1;

        IPTV_Spot_Limit__c IPTVSpotLimit1 = new IPTV_Spot_Limit__c(
            Name = 'SL / AllPlay.ent / REGULAR TIME / 1-31/1/2024',
            IPTV_Inventory__c = IPTVInventory1.Id,
            is_Active__c = true,
            Spot_Limit__c = 4320,
            Start_Date__c = system.today(),
            End_Date__c = system.today()
            );
        insert IPTVSpotLimit1;

        IPTV_Spot_Daily_Status__c IptvSDS1 = new IPTV_Spot_Daily_Status__c(
            Name = 'SDS / AllPlay.ent / REGULAR TIME / 2024 - 1 - 1',
            Date__c = system.today(),
            IPTV_Spot_Limit__c = IPTVSpotLimit1.Id,
            Inventory_Name__c = IPTVInventory1.Id
        );
        insert IptvSDS1;

        Test.startTest();  
        IPTVInventory1.Current_Spotlimit__c = IPTVSpotLimit1.Id;
        update IPTVInventory1;

        Set<String> Set_IptvInventoriIds = new Set<String>();
        
        Set_IptvInventoriIds.Add(IPTVInventory1.Id);
        
        List<IPTV_Spot_Limit__c> spotLimits = new List<IPTV_Spot_Limit__c>();
        spotLimits.add(IPTVSpotLimit1);
        
        IPTVSpotlimitservice.createYearlyRecords(2024,3400,IPTVInventory1.Id);
        IPTVSpotlimitservice.createCustomDateRangeRecords(system.today(),system.today()+15,3400,IPTVInventory1.Id);
        IPTVSpotlimitservice.createDailySpotLimitRecords(spotLimits);
        IPTVSpotlimitservice.getMOItemOnIPTVDailyStatus(IPTVSpotLimit1.Id);
        IPTVInvService.getMOItem(IPTVInventory1.Id);
        
        Test.stopTest();
    }
}