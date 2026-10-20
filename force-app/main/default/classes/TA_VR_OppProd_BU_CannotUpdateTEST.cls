/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 14/02/2025
 * @last modified by  : Syaiful Syafani
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   14/02/2025   Syaiful Syafani   Initial Version
**/
@IsTest
public class TA_VR_OppProd_BU_CannotUpdateTEST {
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
                Description = '500'                                // Product Description
            );
            insert testProduct;

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
                PricebookEntryId = pricebookEntry.Id,
                Product2Id = testProduct.Id,
                Business_Product__c = 'Digital Media'
            );
            insert testOpportunityLineItem;

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
    static void UpdateGetUsagesOfProduct() {
        // Get the test OpportunityLineItem
        OpportunityLineItem opptyProdRec = [SELECT Id, Quantity FROM OpportunityLineItem LIMIT 1];
        
        // Call the method
        //List<Usage__c> result = OpportunityProductService.getUsagesOfProduct(testOpportunityLineItem.Id);
        
        Test.startTest();
        try {
            opptyProdRec.Quantity=2;
            Update opptyProdRec;

            // If the insert succeeds, that means the test failed as it should have thrown an error
            System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
        } catch (DmlException e) {
            // Check that the exception message contains the expected error message
            System.assert(e.getDmlMessage(0).contains('Produk ini tidak bisa diupdate karena sudah ada data usage. Jika ada kesulitan hubungi system administrator'), 'Unexpected error message: ' + e.getMessage());
        }
        Test.stopTest();
    }
}