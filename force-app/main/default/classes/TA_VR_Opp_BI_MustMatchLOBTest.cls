/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 06/03/2025
 * @last modified by  : Syaiful Syafani
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   06/03/2025   Syaiful Syafani   Initial Version
**/
@isTest
public with sharing class TA_VR_Opp_BI_MustMatchLOBTest {
    private static User salesA() {
        Profile proRec = [SELECT Id FROM Profile WHERE Name = 'SALES' LIMIT 1];
        UserRole roleRec = [SELECT Id, Name, PortalRole FROM UserRole WHERE Name='Sales Government & VAS' LIMIT 1];
        User userRec = new User(
            FirstName           = 'Sales',
            LastName            = 'A',
            NIK__c              = '22233442',
            Username            = 'salesa@digiads.com.invalid',
            Alias               = 'SA',
            EmailEncodingKey    = 'UTF-8',
            Email               = 'salesa@digiads.com.invalid',
            ProfileId           = proRec.Id,
            UserRoleId          = roleRec.Id,
            LocaleSidKey        = 'en_US',
            LanguageLocaleKey   = 'en_US',
            TimeZoneSidKey      = 'America/Los_Angeles'
        );
        insert userRec;
        return userRec;
    }

    private static User salesB() {
        Profile proRec = [SELECT Id FROM Profile WHERE Name = 'SALES' LIMIT 1];
        UserRole roleRec = [SELECT Id, Name, PortalRole FROM UserRole WHERE Name='Sales Government & VAS' LIMIT 1];
        User userRec = new User(
            FirstName           = 'Sales',
            LastName            = 'B',
            NIK__c              = '5554443',
            Username            = 'salesb@digiads.com.invalid',
            Alias               = 'SB',
            EmailEncodingKey    = 'UTF-8',
            Email               = 'salesb@digiads.com.invalid',
            ProfileId           = proRec.Id,
            UserRoleId          = roleRec.Id,
            LocaleSidKey        = 'en_US',
            LanguageLocaleKey   = 'en_US',
            TimeZoneSidKey      = 'America/Los_Angeles'
        );
        insert userRec;
        return userRec;
    }

    @TestSetup
    static void setupTestData() {
        User salesA = salesA();
        User salesB = salesB();

        System.runAs(salesA){
            // create account
            Account accRec = new Account(
                Name = 'Test Account',
                Legal_Name__c = 'Test Account',
                Account_Type__c = 'Advertiser'
            );
            insert accRec;

            // create contact
            Contact conRec = new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                Active__c = true,
                AccountId = accRec.Id
            );
            insert conRec;

            LOB_Group__c lobGroupRec = new LOB_Group__c(
                Name = 'Government & VAS',
                Active__c = true,
                Senior_Officer__c = salesA.Id
            );
            insert lobGroupRec;

            // create lob
            LOB__c lobRec = new LOB__c(
                Name = 'GOVERNMENT & PUBLIC SERVICE',
                LOB_Unique_ID__c = 'GOVERNMENT & PUBLIC SERVICE',
                Active__c = true,
                LOB_Group__c = lobGroupRec.Id
            );
            insert lobRec;

            LOB__c lobRecB = new LOB__c(
                Name = 'EDUCATION & EDUTECH',
                LOB_Unique_ID__c = 'EDUCATION & EDUTECH',
                Active__c = true,
                LOB_Group__c = lobGroupRec.Id
            );
            insert lobRecB;

            // create brand
            Brand__c brandRec = new Brand__c(
                Name = 'MRT',
                PIC_Advertiser__c = conRec.Id,
                Brand_Category__c = lobRec.Id,
                Advertiser__c = accRec.Id
            );
            insert brandRec;

            // create lob sales mapping
            LOB_Sales_Mapping__c lobSalesMappingRec = new LOB_Sales_Mapping__c(
                Sales__c = salesA.Id,
                LOB__c = lobRec.Id
            );
            insert lobSalesMappingRec;

            LOB_Sales_Mapping__c lobSalesMappingRecB = new LOB_Sales_Mapping__c(
                Sales__c = salesB.Id,
                LOB__c = lobRecB.Id
            );
            insert lobSalesMappingRecB;
        }
    }

    @isTest
    static void InsertOpportunity(){
        User userRec = [SELECT Id FROM User WHERE Alias = 'SB' LIMIT 1];
        Account accRec = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Brand__c brandRec = [SELECT Id FROM Brand__c WHERE Name = 'MRT' LIMIT 1];

        Opportunity opptyRec = new Opportunity(
            Name = 'Test Opportunity',
            Account_Type__c = 'Advertiser',
            AccountId = accRec.id,
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting',
            OwnerId = userRec.Id,
            Brand__c = brandRec.Id
        );

        Test.startTest();
            Database.SaveResult sr = Database.insert(opptyRec, false);
            System.assertEquals('Cannot create oppty because Owner not access with this brand LOB.', sr.getErrors()[0].getMessage());
        Test.stopTest();
    }
}