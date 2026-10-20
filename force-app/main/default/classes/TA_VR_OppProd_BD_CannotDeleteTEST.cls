/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 11/02/2025
 * @last modified by  : Syaiful Syafani
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   02/02/2025   Syaiful Syafani   Initial Version
**/
@IsTest
public class TA_VR_OppProd_BD_CannotDeleteTEST {
    private static User createUser() {
        Profile proRec = [SELECT Id FROM Profile WHERE Name = 'SALES' LIMIT 1];
        UserRole roleRec = [SELECT Id, Name, PortalRole FROM UserRole WHERE Name='SALES DA' LIMIT 1];
        User userRec = new User(
            FirstName           = 'Admin',
            LastName            = 'TV Ads',
            NIK__c              = '312342',
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
                Description = '500'                                // Product Description
            );
            insert testProduct;

            //Product2 testProduct2 = new Product2(
            //    Name = 'BULK (SMS Premium)',                      // Product Name
            //    IsActive = true,                                    // Active
            //    Family = 'Messaging',                               // Product Family
            //    Product_Type__c = 'SMS',                            // Product Type
            //    ProductCode = 'SMS',                                // Product Code
            //    Ads_Format__c = 'Text',                             // Ads Format
            //    Ads_Detail__c = 'BULK (SMS Premium)_3telco_Icode',  // Ads Detail
            //    Ads_Size__c = 'Standard',                           // Ads Size
            //    Product_Channel__c = 'Mobile',                      // Product Channel
            //    Channel_Detail__c = 'Mobile',                       // Channel Detail
            //    Buying_Method__c = 'I/O',                           // Buying Method
            //    Rate_Card_Refference__c = 'Messaging',              // Rate Card Refference
            //    List_Price__c = 500.00,                             // List Price
            //    Business_Product__c = 'Digital Media',
            //    Product_Category__c = 'Advertising',                // Product Category
            //    Description = '500'                                // Product Description
            //);
            //insert testProduct2;
            
            // Create test Account
            Account testAccount = new Account(
                Name = 'Test Account'
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

            //Opportunity testOppty2 = new Opportunity(
            //    Name = 'Test',
            //    AccountId = testAccount.id,
            //    CloseDate = Date.today().addDays(30),
            //    StageName = 'Prospecting'
            //);
            //insert testOppty2;
            
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

            //PricebookEntry pricebookEntry2 = new PricebookEntry(
            //    Pricebook2Id = standardPricebook.Id,
            //    Product2Id = testProduct.Id,
            //    UnitPrice = 100,
            //    IsActive = true
            //);
            //insert pricebookEntry2;

            OpportunityLineItem testOpportunityLineItem = new OpportunityLineItem(
                OpportunityId = testOpportunity.Id,
                Quantity = 1,
                UnitPrice = 100,
                PricebookEntryId = pricebookEntry.Id,
                Product2Id = testProduct.Id
            );
            insert testOpportunityLineItem;

            OpportunityLineItem testOpportunityLineItem1 = new OpportunityLineItem(
                OpportunityId = testOpportunity.Id,
                Quantity = 1,
                UnitPrice = 100,
                PricebookEntryId = pricebookEntry.Id,
                Product2Id = testProduct.Id
            );
            insert testOpportunityLineItem1;

            //OpportunityLineItem testOpportunityLineItem2 = new OpportunityLineItem(
            //    OpportunityId = testOppty2.Id,
            //    Quantity = 1,
            //    UnitPrice = 100,
            //    PricebookEntryId = pricebookEntry2.Id
            //);
            //insert testOpportunityLineItem2;

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

            OrderItem testOrderItem2 = new OrderItem(
                OrderId = testOrder.Id,
                Quantity = 1,
                UnitPrice = 100,
                Opp_Product_Id__c = testOpportunityLineItem1.Id,
                PricebookEntryId = pricebookEntry.Id,
                Opportunity__c = testOpportunity.Id,
                Product2Id = testProduct.Id
            );
            insert testOrderItem2;

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
    static void DeleteUsagesOfProduct() {
        // Get the test OpportunityLineItem
        OpportunityLineItem testOpportunityLineItem = [SELECT Id FROM OpportunityLineItem WHERE Product2.Name = 'BULK (SMS Basic)' LIMIT 1];
        System.debug('=== delete(usage): '+ testOpportunityLineItem);
        
        // Call the method
        List<Usage__c> result = OpportunityProductService.getUsagesOfProduct(testOpportunityLineItem.Id);

        String assert = '';

        Test.startTest();
        try {
            delete testOpportunityLineItem;

            // If the insert succeeds, that means the test failed as it should have thrown an error
            System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
        } catch (DmlException e) {
            // Check that the exception message contains the expected error message
            System.assert(e.getDmlMessage(0).contains('Produk ini tidak bisa dihapus karena sudah ada data usage. Jika ada kesulitan hubungi system administrator'), 'Unexpected error message: ' + e.getMessage());
        }

        //System.assertEquals('Produk ini tidak bisa dihapus karena sudah ada data usage. Jika ada kesulitan hubungi system administrator', assert);
        Test.stopTest();
    }

    /*
    @isTest
    static void DeleteOpptyProduct(){
        // Get the test OpportunityLineItem
        OpportunityLineItem opptyProductRec = [SELECT Id, OpportunityId FROM OpportunityLineItem WHERE Product2.Name = 'BULK (SMS Premium)' LIMIT 1];
        System.debug('=== delete(OpptyProduct): '+ opptyProductRec);

        // Call the method
        List<OpportunityLineItem> listName = OpportunityProductService.getOpptyProduct(opptyProductRec.OpportunityId);

        String assert = '';

        Test.startTest();
        try {
            delete opptyProductRec;

            // If the insert succeeds, that means the test failed as it should have thrown an error
            //System.assert(true, 'Expected an exception to be thrown due to duplicate channel insertion.');
        } catch (Exception e) {
            // Check that the exception message contains the expected error message
            //System.assert(e.getDmlMessage(0).contains('Produk ini tidak bisa dihapus karena setidaknya opportunity memiliki satu product'), 'Unexpected error message: ' + e.getMessage());
            assert = e.getMessage();
        }

        System.assertEquals('Produk ini tidak bisa dihapus karena setidaknya opportunity memiliki satu product', assert);
        Test.stopTest();
    }
    */
}