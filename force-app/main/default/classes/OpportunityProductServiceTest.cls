/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 27/03/2025
 * @last modified by  : Syaiful Syafani
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   02/02/2025   Syaiful Syafani   Initial Version
**/
@isTest
public class OpportunityProductServiceTest {
    private static User createUser() {
        Profile proRec = [SELECT Id FROM Profile WHERE Name = 'SALES' LIMIT 1];
        UserRole roleRec = [SELECT Id, Name, PortalRole FROM UserRole WHERE Name='SALES DA' LIMIT 1];
        User userRec = new User(
            FirstName           = 'Admin',
            LastName            = 'TV Ads',
            NIK__c              = '444999',
            Username            = 'admintv@digiads.com.invalid',
            Alias               = 'AdmTV',
            EmailEncodingKey    = 'UTF-8',
            Email               = 'admintv@digiads.com.invalid',
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
        
        User testUser = createUser();        
        System.runAs(testUser) {
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
                PIC_Product_Type__c = 'Messaging'
            );
            insert testProduct;
            
            
             Product2 testProduct2 = new Product2(
              Name                = 'TVC PRIME TIME 30" AXN',     // Product Name
                Business_Product__c = 'TV Media',                   // Business Product
                Product_Category__c = 'IPTV',                       // Product Category
                Family              = 'TVC',                        // Product Family
                Product_Type__c     = 'TVC',                        // Product Type
                Product_Channel__c  = 'TVC PLATINUM',               // Product Channel
                Ads_Format__c       = 'Video',                      // Ads Format
                Ads_Size__c         = 'PRIME TIME 17.00 - 24.00	',  // Ads Size
                Channel_Detail__c   = 'My Telkomsel',               // Channel Detail
                Tarif__c            = 120000,                       // Tarif
                HJM__c              = 20,                           // HJM
                List_Price__c       = 1300000,  
                PIC_Product_Type__c = 'IPTV',// Rate Card
                //IPTV_Inventory__c   = invRec.Id,                    // IPTV Inventory
                Duration__c         = 10,                           // Duration
                IsActive            = true                          // Active
            );
            insert testProduct2;
            
            // Create test Account
            Account testAccount = new Account(
                Name = 'Test Account',
                Legal_Name__c = 'Test Account'
            );
            insert testAccount;

            // Create test Opportunity
            Opportunity testOpportunity = new Opportunity(
                Name = 'Test Opportunity',
                AccountId = testAccount.id,
                CloseDate = Date.today().addDays(30),
                StageName = 'Prospecting'
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
            
              PricebookEntry pricebookEntry2 = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = testProduct2.Id,
                UnitPrice = 100,
                IsActive = true
            );
            insert pricebookEntry2;

            OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(
                OpportunityId = testOpportunity.Id,
                Quantity = 1,
                UnitPrice = 100,
                PricebookEntryId = pricebookEntry.Id
            );
            insert testOpportunityLineItem;
            
            OpportunityLineItem testOpportunityLineItem2 = new OpportunityLineItem(
                OpportunityId = testOpportunity.Id,
                Quantity = 1,
                UnitPrice = 100,
                PricebookEntryId = pricebookEntry2.Id
            );
            insert testOpportunityLineItem2;

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
    static void testGetUsagesOfProduct() {
        // Get the test OpportunityLineItem
        OpportunityLineItem testOpportunityLineItem = [SELECT Id, Business_Product__c, App_Path_No_Digital__c, OldApp_Path_No__c FROM OpportunityLineItem LIMIT 1];
         
        
        Test.startTest();
            // Call the method
            List<Usage__c> result = OpportunityProductService.getUsagesOfProduct(testOpportunityLineItem.Id);
        // Call the utility method
         Integer approvalPath = OpportunityProductService.calculateACWApprovalPath(testOpportunityLineItem);
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetOpptyProduct() {
        // Get the test OpportunityLineItem
        OpportunityLineItem testOpportunityLineItem = [SELECT Id, OpportunityId FROM OpportunityLineItem LIMIT 1];
        
        
        Test.startTest();
            // Call the method
            List<OpportunityLineItem> result = OpportunityProductService.getOpptyProduct(testOpportunityLineItem.OpportunityId);
        Test.stopTest();
    }
}