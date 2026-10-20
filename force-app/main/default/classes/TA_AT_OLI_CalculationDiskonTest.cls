/**
 *  Author      :   Yusuf Ramadhan (yusuf.ramadhan@saasten.com)
 *  Project     :   TSEL-2411-ReOrg and Approval Enhancement
 * 
 *  Date            PIC         Ticket          Brief of changes
 *  03/03/2025      Yusuf       APE-006         Initial Created
 * 
 */
@IsTest
public with sharing class TA_AT_OLI_CalculationDiskonTest {
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
        MetadataTriggerHandler.bypass('TA_VR_Opp_BI_MustMatchLOB');
        MetadataTriggerHandler.bypass('TA_VR_Opp_BU_MustMatchLOB');

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
            Product2 tvProduct = new Product2(
                Name = 'TVC PLATINUM (Prime) 15" CNN Indonesia',// Product Name
                List_Price__c = 6500000.00,                       // Rate Card
                Business_Product__c = 'TV Media',                 // Business Product
                Product_Category__c = 'IPTV',                     // Product Category
                Family = 'TVC',                                   // Product Family
                PIC_Product_Type__c = 'IPTV',                     // PIC Product Type
                Product_Type__c = 'TVC',                          // Product Type
                Product_Channel__c = 'TVC PLATINUM',              // Product Inventory
                IsActive = false,                                 // Active
                Ads_Format__c = 'Video',                          // Ads Format
                Ads_Size__c = 'PRIME TIME 17.00 - 24.00',         // Ads Size
                Buying_Method__c = 'I/O',                         // Buying Method
                Tarif__c = 260000,                                // Tarif
                HJM__c = 104000,                                  // HJM
                Duration__c = 15                               // Duration
            );
            insert new List<Product2>{testProduct,tvProduct};
            
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

            PricebookEntry secondPricebookEntry = new PricebookEntry(
                Pricebook2Id = standardPricebook.Id,
                Product2Id = tvProduct.Id,
                UnitPrice = 200,
                IsActive = true
            );
            insert new List<PricebookEntry>{pricebookEntry,secondPricebookEntry};

            List<OpportunityLineItem> oliList = new List<OpportunityLineItem>{
                new OpportunityLineItem(
                    OpportunityId = testOpportunity.Id,
                    Quantity = 1,
                    UnitPrice = 100,
                    PricebookEntryId = secondPricebookEntry.Id,
                    Business_Product__c = 'TV Media',
                    Discount__c = 5 
                ),
                new OpportunityLineItem(
                    OpportunityId = testOpportunity.Id,
                    Quantity = 1,
                    UnitPrice = 100,
                    PricebookEntryId = secondPricebookEntry.Id,
                    Business_Product__c = 'TV Media',
                    Discount__c = 50
                ),
                new OpportunityLineItem(
                    OpportunityId = testOpportunity.Id,
                    Quantity = 1,
                    UnitPrice = 100,
                    PricebookEntryId = secondPricebookEntry.Id,
                    Business_Product__c = 'TV Media',
                    Discount__c = 60
                ),
                new OpportunityLineItem(
                    OpportunityId = testOpportunity.Id,
                    Quantity = 1,
                    UnitPrice = 100,
                    PricebookEntryId = secondPricebookEntry.Id,
                    Business_Product__c = 'TV Media',
                    Discount__c = 80
                ),
                new OpportunityLineItem(
                    OpportunityId = testOpportunity.Id,
                    Quantity = 1,
                    UnitPrice = 100,
                    PricebookEntryId = pricebookEntry.Id,
                    Business_Product__c = 'Digital Media',
                    Discount__c = 0 // Path 1
                ),
                new OpportunityLineItem(
                    OpportunityId = testOpportunity.Id,
                    Quantity = 1,
                    UnitPrice = 100,
                    PricebookEntryId = pricebookEntry.Id,
                    Business_Product__c = 'Digital Media',
                    Discount__c = 25 // Path 2
                ),
                new OpportunityLineItem(
                    OpportunityId = testOpportunity.Id,
                    Quantity = 1,
                    UnitPrice = 100,
                    PricebookEntryId = pricebookEntry.Id,
                    Business_Product__c = 'Digital Media',
                    Discount__c = 40 // Path 3
                ),
                new OpportunityLineItem(
                    OpportunityId = testOpportunity.Id,
                    Quantity = 1,
                    UnitPrice = 100,
                    PricebookEntryId = pricebookEntry.Id,
                    Business_Product__c = 'Digital Media',
                    Discount__c = 90 // Path 4
                )
            };
            insert oliList;

            // testOpportunity.StageName = 'Negotiation';
            // testOpportunity.Has_Adjustment_After_Close_Won__c = true;
            // testOpportunity.Proposal_Activity__c  = 1;
            // testOpportunity.Meeting_Activity__c  = 1;
            // testOpportunity.Penagihan_based_on_TV__c = 'Postpaid';
            // testOpportunity.Penagihan_based_on__c = 'Postpaid';

            // update testOpportunity;
        }
    }


    @IsTest
    static void testTVMediaDiscountCalculation() {
        Test.startTest();

        
        OpportunityLineItem tvOLI = [SELECT Id, Discount__c, App_Path_No__c FROM OpportunityLineItem WHERE Business_Product__c = 'TV Media' LIMIT 1];

        // Modify discount to trigger trigger logic
        tvOLI.Discount__c = 15;
        update tvOLI;

        // Validate Approval Path was updated
        OpportunityLineItem updatedOLI = [SELECT App_Path_No__c FROM OpportunityLineItem WHERE Id = :tvOLI.Id];
        System.assertNotEquals(null, updatedOLI.App_Path_No__c, 'TV Approval Path should be set');

        Test.stopTest();
    }

    @IsTest
    static void testDigitalMediaDiscountCalculation() {
        Test.startTest();

        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        testOpportunity.StageName = 'Negotation';
        testOpportunity.Has_Adjustment_After_Close_Won__c = true;
        update testOpportunity;
        
        OpportunityLineItem digitalOLI = [SELECT Id, Discount__c, App_Path_No_Digital__c, App_Path_No__c,OldApp_Path_No__c FROM OpportunityLineItem WHERE Business_Product__c = 'Digital Media' LIMIT 1];

        // Modify discount to trigger trigger logic
        digitalOLI.OldApp_Path_No__c = digitalOLI.App_Path_No__c;
        digitalOLI.Discount__c = 25;
        update digitalOLI;

        // Validate Approval Path was updated
        OpportunityLineItem updatedOLI = [SELECT App_Path_No_Digital__c FROM OpportunityLineItem WHERE Id = :digitalOLI.Id];
        System.assertNotEquals(null, updatedOLI.App_Path_No_Digital__c, 'Digital Approval Path should be set');

        Test.stopTest();
    }

    @IsTest
    static void testACWApprovalPathCalculation() {

        Test.startTest();

        Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
        testOpportunity.StageName = 'Negotation';
        testOpportunity.Has_Adjustment_After_Close_Won__c = true;
        update testOpportunity;

        OpportunityLineItem tvOLI = [SELECT Id, Opportunity.Has_Adjustment_After_Close_Won__c,App_Path_No__c,OldApp_Path_No__c FROM OpportunityLineItem WHERE Business_Product__c = 'TV Media' AND OpportunityId =:testOpportunity.Id LIMIT 1];

        // Update OLI to trigger ACW logic
        tvOLI.OldApp_Path_No__c = tvOLI.App_Path_No__c;
        tvOLI.Discount__c = 20;
        update tvOLI;

        // Verify ACW Approval Path is set
        OpportunityLineItem updatedOLI = [SELECT ACW_App_Path_No__c FROM OpportunityLineItem WHERE Id = :tvOLI.Id];
        System.assertNotEquals(null, updatedOLI.ACW_App_Path_No__c, 'ACW Approval Path should be set');

        Test.stopTest();
    }

    @IsTest
    static void testBulkProcessing() {
        Test.startTest();
        
        List<OpportunityLineItem> olisToUpdate = [SELECT Id, Discount__c FROM OpportunityLineItem LIMIT 10];
        for (OpportunityLineItem oli : olisToUpdate) {
            oli.Discount__c += 5; // Modify discount to trigger the trigger
        }
        
        update olisToUpdate;

        // List<OpportunityLineItem> updatedOLIs = [SELECT App_Path_No__c, App_Path_No_Digital__c FROM OpportunityLineItem WHERE Id IN :olisToUpdate];
        // for (OpportunityLineItem oli : updatedOLIs) {
        //     System.assertNotEquals(null, oli.App_Path_No__c, 'Approval Path should be set for bulk records');
        // }
        
        Test.stopTest();
    }

    @IsTest
    static void testTV_AllPaths() {
        List<OpportunityLineItem> tvOLIs = [SELECT Id, Discount__c, Discount_2__c FROM OpportunityLineItem WHERE Business_Product__c = 'TV Media'];
        System.assert(tvOLIs.size() >= 4, 'Ensure at least 4 TV OLIs for this test');

        tvOLIs[0].Discount__c = 5;  // Path 1: discount1 <= maxDisc
        tvOLIs[1].Discount__c = 40; tvOLIs[1].Discount__c = 25; // Path 2
        tvOLIs[2].Discount__c = 40; tvOLIs[2].Discount__c = 35; // Path 3
        tvOLIs[3].Discount__c = 40; tvOLIs[3].Discount__c = 50; // Path 4

        Test.startTest();
        update tvOLIs;
        Test.stopTest();

        List<OpportunityLineItem> updatedOLIs = [SELECT App_Path_No__c FROM OpportunityLineItem WHERE Id IN :tvOLIs];
        // System.assertEquals(1, updatedOLIs[0].App_Path_No__c);
        // System.assertEquals(2, updatedOLIs[1].App_Path_No__c);
        // System.assertEquals(3, updatedOLIs[2].App_Path_No__c);
        // System.assertEquals(4, updatedOLIs[3].App_Path_No__c);
    }

    @IsTest
    static void testDigital_AllPaths() {
        List<OpportunityLineItem> digitalOLIs = [SELECT Id, Discount__c FROM OpportunityLineItem WHERE Business_Product__c = 'Digital Media'];
        System.assert(digitalOLIs.size() >= 4, 'Ensure at least 4 Digital OLIs for this test');

        digitalOLIs[0].Discount__c = 0;   // Path 1
        digitalOLIs[1].Discount__c = 25;  // Path 2
        digitalOLIs[2].Discount__c = 50;  // Path 3
        digitalOLIs[3].Discount__c = 90;  // Path 4

        Test.startTest();
        update digitalOLIs;
        Test.stopTest();

        List<OpportunityLineItem> updatedOLIs = [SELECT App_Path_No_Digital__c FROM OpportunityLineItem WHERE Id IN :digitalOLIs];
        System.assertEquals(1, updatedOLIs[0].App_Path_No_Digital__c);
        System.assertEquals(2, updatedOLIs[1].App_Path_No_Digital__c);
        System.assertEquals(3, updatedOLIs[2].App_Path_No_Digital__c);
        System.assertEquals(4, updatedOLIs[3].App_Path_No_Digital__c);
    }



}