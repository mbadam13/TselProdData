/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TA_AT_Opp_AU_FillApproverByLOBTest {

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

            // Create test Product
            Product2 testProduct = new Product2(
                Name = 'BULK (SMS Basic)',                      // Product Name
                IsActive = true,                                    // Active
                Family = 'Messaging',                               // Product Family
                Product_Type__c = 'SMS',                            // Product Type
                ProductCode = 'SMS',                                // Product Code
                Ads_Format__c = 'Text',                             // Ads Format
                Ads_Detail__c = 'BULK (SMS Premium)_3telco_Icode',  // Ads Detail
                Ads_Size__c = 'Standard',                           // Ads Size
                Product_Channel__c = 'Mobile',                      // Product Channel
                Channel_Detail__c = 'Mobile',                       // Channel Detail
                Buying_Method__c = 'I/O',                           // Buying Method
                Rate_Card_Refference__c = 'Messaging',              // Rate Card Refference
                List_Price__c = 500.00,                             // List Price
                Business_Product__c = 'Digital Media',
                Product_Category__c = 'Advertising',                // Product Category
                Description = '500',                                // Product Description
                PIC_Product_Type__c = 'IPTV'
            );
            insert testProduct;
            
            // Create test Opportunity
            Opportunity testOpportunity = new Opportunity(
                Name = 'Test Opportunity',
                Account_Type__c = 'Advertiser',
                AccountId = accRec.id,
                CloseDate = Date.today().addDays(30),
                StageName = 'Prospecting',
                OwnerId = salesA.Id,
                Brand__c = brandRec.Id
            );
            insert testOpportunity;
            
            // Create test OpportunityLineItem
            Pricebook2 standardPricebook = new Pricebook2(
                Id = Test.getStandardPricebookId(),
                IsActive = true
            );
            System.debug('=== Pricebook : '+standardPricebook);
            PricebookEntry pricebookEntry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = testProduct.Id,
                UnitPrice = 100,
                IsActive = true
            );
            insert pricebookEntry;

            OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(
                OpportunityId = testOpportunity.Id,
                Quantity = 1,
                UnitPrice = 100,
                PricebookEntryId = pricebookEntry.Id
            );
            insert testOpportunityLineItem;

            // Create test Order
            Order testOrder = new Order(
                AccountId = testOpportunity.AccountId,
                Status = 'Draft',
                EffectiveDate = Date.today(),
                Pricebook2id = standardPricebook.Id
            );
            insert testOrder;

            // Create test OrderItem
            OrderItem testOrderItem = new OrderItem(
                OrderId = testOrder.Id,
                Quantity = 1,
                UnitPrice = 100,
                Opp_Product_Id__c = testOpportunityLineItem.Id,
                PricebookEntryId = pricebookEntry.Id,
                Opportunity__c = testOpportunity.Id,
                Product2Id = testProduct.Id
            );
            insert testOrderItem;

            // Create test Usage
            Usage__c testUsage = new Usage__c(
                //Name = 'Test Usage',
                Date__c = Date.today(),
                Bucket_Detail__c = testOrderItem.Id
            );
            insert testUsage;
        }
    }

    @isTest
    private static void test_updateOpptywithLOB() {
        // Test data setup
        User userRec = [SELECT Id FROM User WHERE Alias = 'SA' LIMIT 1];        
        User userRecNonAllowed = [SELECT Id FROM User WHERE Alias = 'SB' LIMIT 1];
        Account accRec = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Brand__c brandRec = [SELECT Id FROM Brand__c WHERE Name = 'MRT' LIMIT 1];
        LOB_Group__c lobGroup = [SELECT Id,Senior_Officer__c FROM LOB_Group__c LIMIT 1];

        Opportunity opptyRec = new Opportunity(
            Name = 'Test Opportunity',
            Account_Type__c = 'Advertiser',
            AccountId = accRec.id,
            CloseDate = Date.today().addDays(30),
            StageName = 'Prospecting',
            OwnerId = userRec.Id,
            Brand__c = brandRec.Id
        );
        

        // Actual test
        Test.startTest();
        MetadataTriggerHandler.bypass('TA_VR_Opp_BI_MustMatchLOB');
        MetadataTriggerHandler.bypass('TA_VR_Opp_BU_MustMatchLOB');
        insert opptyRec;
    
        lobGroup.Senior_Officer__c = userRecNonAllowed.Id;
        update lobGroup;        
        
        opptyRec.OwnerId = userRecNonAllowed.Id;
        update opptyRec;
        Test.stopTest();
    
        // Asserts
    }
}