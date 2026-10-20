@IsTest
public with sharing class MediaOrderItemExpControllerTEST {
    @TestSetup
    static void makeData(){
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Account acc = new Account(
            Name = 'Wira Pamungkas Pratama #2',          				// Account Name
            RecordTypeId = recordTypeAccId,                                  // Account Record Type
            Account_Type__c = 'Agency',                                  // Account Type
            Direct_Indirect__c = 'Direct',                               // Direct/Indirect
            Status__c = 'Approved by Settlement',                        // Status
            No_PKS__c = '123456',                                        // No PKS
            NPWP__c = '1234567890123456',                                               // NPWP
            NPWP_Address__c = 'Jakarta',
            PKS_Tracker__c = 'Pending',
            Reason_by_Settlement__c = 'reason'      
        );
        insert acc;

        Contact contactRec = new Contact(
            AccountId = acc.id,                 // Account Name
            Title = 'Planner',                         // Title
            Email = 'test@gmail.com',  // Email
            Phone = '231313123123',                   // Phone
            LastName = 'user1',
            MobilePhone = '231313123123',             // Mobile
            Active__c = true,                         // Active?
            Priority__c = 'Priority 1',                // Priority
            Converted_from_Lead__c = false            // Converted from Lead
        );
        insert contactRec;
        
        Contract contract = new Contract(
            StartDate = Date.valueOf('2019-09-01'),// Contract Start Date
            ContractTerm = 9999,                  // Contract Term (months)
            AccountId = acc.Id,
            OwnerExpirationNotice = '120',      // Owner Expiration Notice
            Status = 'Draft',                    // Status
            Terminate__c = false,                    // Terminate
            Archive__c = false,                      // Archive
            No_PKS__c = '123456',                    // No.PKS
            Contract_Signed__c = 'Circulation'     // Contract Signed ?
           // Opportunity__c = oppRecord.Id
        );
        insert contract;
        
        contract.Status = 'Activated';
        update contract;
        Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Agency Postpaid').getRecordTypeId();

        acc.ContractId__c = contract.Id;
        update acc;

        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = new Product2(
            Name = 'BULK (SMS Premium)',                      // Product Name
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
        insert prod;
            
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
            );
        insert pbEntry;

        User userRec = [SELECT Id, Username FROM User WHERE NIK__c != null LIMIT 1];
            
        Opportunity oppRecord = new Opportunity(
            RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
            Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',  // Opportunity Name
            AccountId = acc.Id,                                                           // Account Name
            CloseDate = Date.valueOf('2024-09-21'),                                                  // Close Date
            Account_Type__c = 'Agency',                                                              // Account Type
            StageName = 'Proposal',                                                                // Stage
            Regional__c = 'HEAD OFFICE',                                                             // Regional  (Required)
            Probability = 100,                                                                       // Probability (%)
            Agency_Name__c = acc.Id,                                                      // Agency Name
            Campaign_Customize__c = false,                                                           // Campaign Customize
            Templated_Proposal__c = true,                                                            // Own Proposal?
            Approval_Remark__c = 'Approved',                                                         // Approval Remark
            Document_Version__c = 'Submit',                                                          // Document Version
            Approval_Status__c = 'Approved',                                                         // Approval Status
            Marketing_Package__c = false,                                                            // Marketing Package
            SME__c = false,                                                                          // SME
            // Brand__c = 'a011s00000Dk5rF',                                                            // Brand
            Type = 'Existing Business',                                                              // Type
            Penagihan_based_on__c = 'Postpaid',                                                      // Penagihan based on
            Performance_Product__c = false,                                                          // Performance Product
            Programmatic_Product__c = false,                                                         // Programmatic Product
            Performance_Done__c = false,                                                             // Performance Done
            RFP_Status_sales__c = 'Completed',                                                       // RFP Status (sales)
            Check_PO__c = 'OK',
            Pricebook2Id = Test.getStandardPricebookId(),
            OwnerId = userRec.Id            
        );
        insert oppRecord;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = oppRecord.Id,// Opportunity
            Product2Id = prod.Id,     // Product
            Discount__c = 0.00,               // Discount (%)
            PricebookEntryId = pbEntry.Id,
            UnitPrice = 500.00,                 // Sales Price
            Quantity = 1234.00              // Quantity
        );
        insert oli;

        oppRecord.StageName = 'Closed Won';
        update oppRecord;
        
        Date startDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);
        Date endDate = Date.newInstance(Date.today().year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));

        Test.startTest();
       
        SOA__c soaRecord = new SOA__c(
            Opportunity__c = oppRecord.Id,              // Opportunity
            SOA_Type__c = 'Opportunity',                     // SOA Type
            SOA_Start_Date__c = startDate,  // SOA Start Date
            SOA_End_Date__c = endDate,    // SOA End Date
            SOA_Sources__c = 'Opportunity'                  // SOA
        );
        insert soaRecord;

        Order order = new Order(
          Status = 'Draft',                                                    // Status
          SOA__c = soaRecord.Id,                                              // SOA
          EffectiveDate = Date.newInstance(2024, 12,01),                              // Order Start Date
          EndDate = Date.newInstance(2024, 12,31),                                                      // Order Type
          AccountId = acc.Id,
          Pricebook2Id = Test.getStandardPricebookId()
        );
        insert order;

        OrderItem orderItem = new OrderItem();
            orderItem.OrderId = order.id; 
            orderItem.Product2Id = prod.Id;
            orderItem.PricebookEntryId = pbEntry.id;
            orderItem.Quantity = 10; 
            orderItem.UnitPrice = 100.00; 
        insert orderItem;

        Invoice__c invRec = new Invoice__c(
            Mitra__c = acc.id,                                   // Mitra
            No_Invoice__c = 'TS.123123.4123125',                        // No Invoice
            No_Master__c = '123123',                                    // No Master
            Tanggal_Invoice__c = Date.newInstance(2024, 12,01),            // Tanggal Invoice
            No_Individual__c = '3123123',                               // No Individual
            Jangka_Waktu_PKS__c = '1 Januari 2024 - 31 Desember 2025',  // Jangka Waktu PKS
            Hak_Telkomsel__c = 150000                                 // Hak Telkomsel
            // VAT_Related__c = 'undefined'                               // VAT Related
        );
        insert invRec;

        soaRecord.invoice__c = invRec.id;
        update soaRecord;

        // for quoteation
        Opportunity oppRecord1 = new Opportunity(
            RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
            Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',  // Opportunity Name
            AccountId = acc.Id,                                                           // Account Name
            CloseDate = Date.valueOf('2024-09-21'),                                                  // Close Date
            Account_Type__c = 'Agency',                                                              // Account Type
            StageName = 'Proposal',                                                                // Stage
            Regional__c = 'HEAD OFFICE',                                                             // Regional  (Required)
            Probability = 100,                                                                       // Probability (%)
            Agency_Name__c = acc.Id,                                                      // Agency Name
            Campaign_Customize__c = false,                                                           // Campaign Customize
            Templated_Proposal__c = true,                                                            // Own Proposal?
            Approval_Remark__c = 'Approved',                                                         // Approval Remark
            Document_Version__c = 'Submit',                                                          // Document Version
            Approval_Status__c = 'Approved',                                                         // Approval Status
            Marketing_Package__c = false,                                                            // Marketing Package
            SME__c = false,                                                                          // SME
            // Brand__c = 'a011s00000Dk5rF',                                                            // Brand
            Type = 'Existing Business',                                                              // Type
            Penagihan_based_on__c = 'Postpaid',                                                      // Penagihan based on
            Performance_Product__c = false,                                                          // Performance Product
            Programmatic_Product__c = false,                                                         // Programmatic Product
            Performance_Done__c = false,                                                             // Performance Done
            RFP_Status_sales__c = 'Completed',                                                       // RFP Status (sales)
            Check_PO__c = 'OK',
            Pricebook2Id = Test.getStandardPricebookId()            
        );
        insert oppRecord1;
        
        OpportunityLineItem oli1 = new OpportunityLineItem(
            OpportunityId = oppRecord1.Id,// Opportunity
            Product2Id = prod.Id,     // Product
            Discount__c = 0.00,               // Discount (%)
            PricebookEntryId = pbEntry.Id,
            UnitPrice = 500.00,                 // Sales Price
            Quantity = 1234.00              // Quantity
        );
        insert oli1;

        oppRecord1.StageName = 'Closed Won';
        update oppRecord1;
        
        // Test.startTest();
       
        Invoice__c invRec1 = new Invoice__c(
            Mitra__c = acc.id,                                   // Mitra
            No_Invoice__c = 'TS.123123.4121233125',                        // No Invoice
            No_Master__c = '123123',                                    // No Master
            Tanggal_Invoice__c = Date.newInstance(2024, 12,01),            // Tanggal Invoice
            No_Individual__c = '3123123',                               // No Individual
            Jangka_Waktu_PKS__c = '1 Januari 2024 - 31 Desember 2025',  // Jangka Waktu PKS
            Hak_Telkomsel__c = 150000                                 // Hak Telkomsel
            // VAT_Related__c = 'undefined'                               // VAT Related
        );
        insert invRec1;

        // insert soaRecord;
        Quote quoteRec = new Quote(
            Name = 'TSEL / Q02250 / dev1/9/25/2023',        // Quotation Name
            OpportunityId = oppRecord1.id,                      // Opportunity Name
            ContactId = contactRec.id,                          // Contact Name
            Status = 'Final',                                 // Status
            Start_Date__c = startDate,       // Start Date
            End_Date__c = endDate,         // End Date
            Invoice__c = invRec1.id                         // Invoice
        );

        insert quoteRec; 

        Order order1 = new Order(
          Status = 'Draft',                                                    // Status
          quoteid = quoteRec.Id,                                              // SOA
          EffectiveDate = Date.newInstance(2024, 12,01),                              // Order Start Date
          EndDate = Date.newInstance(2024, 12,31),                                                      // Order Type
          AccountId = acc.Id,
          Pricebook2Id = Test.getStandardPricebookId()
        );
        insert order1;

        OrderItem orderItem1 = new OrderItem();
            orderItem1.OrderId = order1.id; 
            orderItem1.Product2Id = prod.Id;
            orderItem1.PricebookEntryId = pbEntry.id;
            orderItem1.Quantity = 10; 
            orderItem1.UnitPrice = 100.00; 
        insert orderItem1;

        Media_Order__c aMediaOrder = new Media_Order__c(
            Name = 'TSEL/TMS0000003/Admin TV Ads/7/2024',               // No MO
            Order_Item_ID__c = '0000013121',                              // Order Item ID
            Product_Name__c = 'TVC PLATINUM (Regular) 120" AllPlay.ent',  // Product Name
            House_Number__c = 'CRHD2102053',                              // House Number
            Brand__c = 'Mie Sedaap Soto',                                 // Brand
            Versi__c = '15',                                              // Versi
            Channel__c = 'AllPlay.ent',                                   // Channel
            Product_Inventory__c = 'TVC PLATINUM',                        // Product Inventory
            Showtimes__c = 'REGULAR TIME',                                // Showtimes
            Time__c = '00.00 - 17.00',                                    // Time
            Duration__c = 120,                                          // Duration
            Start_Date__c = System.date.today(),                   // Start Date
            End_Date__c = System.date.today()+30,                     // End Date
            Quantity__c = 1,                                            // Quantity
            Net__c = 5000000.00,                                          // Net
            Amount__c = 0.00,                                             // Amount
            Order_Product__c = orderItem1.Id,                               // Order Product
            Order__c = order1.Id                                       // Order
            );
        insert aMediaOrder;


        List<Media_Order_Item__c> mediaOrderItems = new List<Media_Order_Item__c>();
        for (Integer i = 0; i < 9; i++) {
            Media_Order_Item__c aMOI = new Media_Order_Item__c(
            Name = 'TSEL/TMS0000003/Admin TV Ads/7/2024/'+i,             // No MO Item
            Media_Order__c = aMediaOrder.Id,                                 // Media Order
            Order_Product__c = orderItem1.Id,                               // Order Product
            //Order_Item_ID__c = orderItem1.Name,                              // Order Item ID
            Product_Name__c = 'TVC PLATINUM (Regular) 120" AllPlay.ent',  // Product Name
            House_Number__c = 'CRHD2102053',                              // House Number
            Versi__c = '15',                                              // Versi
            Duration__c = 120,                                          // Duration
            Date__c = System.date.today(),                         // Date
            Time__c = '00.00 - 17.00',                                    // Time
            Net__c = 5000000.00,                                          // Net
            Amount__c = 0.00,                                             // Amount
            //IPTV_Spot_Daily_Status__c = 'undefined',                      // IPTV Spot Daily Status
            //Inventory_Name__c = 'undefined',                              // Inventory Name
            Channel__c = 'AllPlay.ent'                                   // Channel
            );
            mediaOrderItems.add(aMOI);
        }
        insert mediaOrderItems;
        
    }

    @isTest
    private static void test_MediaOrderItemExpController() {
        // Test data setup
        Id mediaOrderId = [SELECT Id FROM Media_Order__c LIMIT 1].Id;
        // Run Test
        Test.startTest();
        String contentCSV = MediaOrderItemExpController.getMediaOrderItems(mediaOrderId);
        Test.stopTest();
    
        // Asserts
        System.assertEquals(true, String.isNotBlank(contentCSV));
    }

    @isTest
    private static void test_MediaOrderItemOrderExp() {
        // Test data setup
        Id orderId = [SELECT Id FROM Order LIMIT 1].Id;
        // Run Test
        Test.startTest();
        String contentCSV = MediaOrderItemExpController.getMediaOrderItemsByOrderId(orderId);
        Test.stopTest();
    
        // Asserts
        System.assertEquals(true, String.isNotBlank(contentCSV));
    }
}