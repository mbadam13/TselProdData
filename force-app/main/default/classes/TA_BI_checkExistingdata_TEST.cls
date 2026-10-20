/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-16-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public  class TA_BI_checkExistingdata_TEST {
    @isTest
    static void checkduplicateIPTVchanel() {
        // Setup test data

        // Create an IPTV Channel record
        IPTV_Channel__c IPTVChannel1 = new IPTV_Channel__c(
            Name = 'AllPlay.ent', 
            Product_Inventory__c = 'TVC PLATINUM', 
            Keyword__c = 'PLATINUM'     
        );
        insert IPTVChannel1;

        // Attempt to insert a duplicate IPTV Channel record
        IPTV_Channel__c IPTVChannel2 = new IPTV_Channel__c(
            Name = 'AllPlay.ent', 
            Product_Inventory__c = 'TVC PLATINUM', 
            Keyword__c = 'PLATINUM'     
        );
        

        
        IPTV_Inventory__c IPTVInventory1 = new IPTV_Inventory__c(
            Name = 'AllPlay.ent REGULAR TIME', 
            IPTV_Channels__c = IPTVChannel1.Id, 
            Show_Time__c = 'REGULAR TIME', 
            Time__c = '00.00 - 17.00', 
            keyword__c = 'all'
        );
        insert IPTVInventory1;

        
        IPTV_Inventory__c IPTVInventory2 = new IPTV_Inventory__c(
            Name = 'AllPlay.ent REGULAR TIME', 
            IPTV_Channels__c = IPTVChannel1.Id, 
            Show_Time__c = 'REGULAR TIME', 
            Time__c = '00.00 - 17.00', 
            keyword__c = 'all'
        );
        

        Test.startTest();
        try {
            insert IPTVChannel2;
           
            // If the insert succeeds, that means the test failed as it should have thrown an error
            System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
        } catch (DmlException e) {
            // Check that the exception message contains the expected error message
            System.assert(e.getDmlMessage(0).contains('Anda Tidak bisa Memasukan data Chanel ini karena ada data yang sama. Jika ada kesulitan hubungi system administrator'), 'Unexpected error message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void checkduplicateIPTVInventory() {
        // Setup test data

        // Create an IPTV Channel record
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

        
        IPTV_Inventory__c IPTVInventory2 = new IPTV_Inventory__c(
            Name = 'AllPlay.ent REGULAR TIME', 
            IPTV_Channels__c = IPTVChannel1.Id, 
            Show_Time__c = 'REGULAR TIME', 
            Time__c = '00.00 - 17.00', 
            keyword__c = 'all'
        );
        

        Test.startTest();
        try {
           
            insert IPTVInventory2;
            // If the insert succeeds, that means the test failed as it should have thrown an error
            System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
        } catch (DmlException e) {
            // Check that the exception message contains the expected error message
            System.assert(e.getDmlMessage(0).contains('Anda Tidak bisa Memasukan data IPTV Inventories ini karena sudah ada data yang sama. Jika ada kesulitan hubungi system administrator'), 'Unexpected error message: ' + e.getMessage());
        }
        Test.stopTest();
    }
}