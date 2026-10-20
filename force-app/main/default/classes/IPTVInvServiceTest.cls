@isTest()
public class IPTVInvServiceTest {
  public static testMethod void testMethodIPTV(){
        IPTV_Channel__c IPTVChannel1 = new IPTV_Channel__c(
            Name = 'AllPlay.ent', 
            Product_Inventory__c = 'TVC PLATINUM', 
            Keyword__c = 'PLATINUM'     
        );
        insert IPTVChannel1;

        IPTV_Inventory__c IPTVInventory1 = new IPTV_Inventory__c(
           
            Name                    = 'AFN PRIME TIME',
            IPTV_Channels__c        = IPTVChannel1.Id,
            Show_Time__c            = 'PRIME TIME',
            Time__c                 = '17.00 - 24.00',
            keyword__c              = 'all',
            Type__c                 = 'IPTV',
            Product_Inventory__c    = 'TVC PLATINUM;TVC ROS'
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