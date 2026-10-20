/**
 * @description       : 
 * @test Class         
 * @author            : M B Adam 
 * @group             : 
 * @last modified on  : 07-16-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest()
public  class deleteRelatedRec_Test {
    
    public static testMethod void deleteIPTVInvRec(){
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
         delete IPTVInventory1;
         ///delete IPTVSpotLimit1;
        
        Test.stopTest();
    }
    
     public static testMethod void deleteIPTVSpotRec(){
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
         
         delete IPTVSpotLimit1;
        
        Test.stopTest();
    }
}