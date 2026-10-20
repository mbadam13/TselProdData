@IsTest
public with sharing class invoiceSettlementController2ndTEST {
    @TestSetup
    static void makeData(){

        Date startDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);
        Date endDate = Date.newInstance(Date.today().year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));


        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Account acc = new Account(
            Name = 'Wira Pamungkas Pratama',          				// Account Name
            RecordTypeId = recordTypeAccId,                                  // Account Record Type
            Account_Type__c = 'Agency',                                  // Account Type
            Direct_Indirect__c = 'Direct',                               // Direct/Indirect
            Status__c = 'Approved by Settlement',                        // Status
            No_PKS__c = '123456',                                        // No PKS
            NPWP__c = '1',                                               // NPWP
            NPWP_Address__c = 'Jakarta',
            PKS_Tracker__c = 'Pending',
            Reason_by_Settlement__c = 'Reason' // Avoid VR: Account_check_npwp_v2     
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
            //Buying_Method__c = 'I/O',                           // Buying Method
            Rate_Card_Refference__c = 'Messaging',              // Rate Card Refference
            List_Price__c = 500.00,                             // List Price
            Product_Category__c = 'Advertising',                // Product Category
            Description = '500',                                // Product Description
            Business_Product__c = 'Digital Media'  // Avoid field depedency
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

        // -------------------------------- QUOTATION SETUP -------------------------------------
        Opportunity oppRecord1 = new Opportunity(
            RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
            Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Prepaid / 9/21/2024',  // Opportunity Name
            AccountId = acc.Id,                                                           // Account Name
            CloseDate = System.date.today()+7,                                                  // Close Date
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
            Penagihan_based_on__c = 'Prepaid',                                                      // Penagihan based on
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
            Quantity = 1234.00,              // Quantity
            Business_Product__c = 'Digital Media'
        );
        insert oli1;

        System.assertEquals('Digital Media', oli1.Business_Product__c);

        List<Opportunity> insertedOpportunities = [SELECT Id,Business_Product__c FROM Opportunity LIMIT 1];
        System.assertEquals('Digital Media', insertedOpportunities[0].Business_Product__c);

        //oppRecord1.StageName = 'Closed Won';
       // update oppRecord1;
        
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
            OpportunityId = insertedOpportunities[0].id,                      // Opportunity Name
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

        //System.assertEquals('Digital Media', order1.Business_Product__c);
        //System.assertEquals('Prepaid', order1.Penagihan__c);

        OrderItem orderItem1 = new OrderItem();
            orderItem1.OrderId = order1.id; 
            orderItem1.Product2Id = prod.Id;
            orderItem1.PricebookEntryId = pbEntry.id;
            orderItem1.Quantity = 10; 
            orderItem1.UnitPrice = 100.00; 
        insert orderItem1; 

        // -------------------------------- QUOTATION SETUP -------------------------------------
    }

    @isTest
    static void testGetCombinedRecords() {
        // Set start and end dates to the first and last day of the current month
        Date startDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);
        Date endDate = Date.newInstance(Date.today().year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));

        // Call the method with test data dates
        Test.startTest();
        List<invoiceSettlementController.InvoiceInSOAorQuoteRecord> records = invoiceSettlementController.getCombinedRecords(startDate, endDate);
        Test.stopTest();
    }

     
    @IsTest
    static void testImportWrongDataTypeInvocing(){
        // Fetch test data created in testSetup
        List<Quote> quotes = [SELECT Id, Name FROM Quote];

        // Prepare CSV content using fetched data
        String header = '"ID (DO NOT EDIT)";"SOA/Quotation";"Mitra";"Business Product";"SOA Start Date";"SOA End Date";"Telkomsel Revenue";"Hak Telkomsel";"Selisih Revenue (DO NOT EDIT)";"Tanggal Invoice";"No Invoice";"Invoice ID (DO NOT EDIT)"';
        String line1 = '"' + quotes[0].Id + '";"' + quotes[0].Name + '";"Wira Pamungkas Pratama";"Digital Media";"2023-04-01";"2023-04-30";"500000";"500000";"0";"04-2024-15";"INV12345";""';

        String csvContent = header + '\n' + line1;

        // Encode the CSV content
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf(csvContent));

        // Call the import method
        Test.startTest();
        String result = invoiceSettlementController.importDataFromCSV(base64Data);
        Test.stopTest();

        // Asserts to verify the outcomes
        System.assert(result.contains('Error'), 'The import should process unsuccessfully: ' + result);
    }

    @IsTest
    static void testImportWrongDataTypeInvocingDuplicate(){
        // Fetch test data created in testSetup
        List<Quote> quotes = [SELECT Id, Name FROM Quote];

        // Prepare CSV content using fetched data
        String header = '"ID (DO NOT EDIT)","SOA/Quotation","Mitra","Business Product","SOA Start Date","SOA End Date","Telkomsel Revenue","Hak Telkomsel","Selisih Revenue (DO NOT EDIT)","Tanggal Invoice","No Invoice","Invoice ID (DO NOT EDIT)"';
        String line1 = '"' + quotes[0].Id + '","' + quotes[0].Name + '","Wira Pamungkas Pratama","Digital Media","2023-04-01","2023-04-30","500000","500000","0","2024-04-15","INV12345",""';
        String line2 = '"' + quotes[0].Id + '","' + quotes[0].Name + '","Wira Pamungkas Pratama","Digital Media","2023-04-01","2023-04-30","500000","500000","0","2024-04-15","INV12345",""';

        String csvContent = header + '\n' + line1 + '\n' + line2;

        // Encode the CSV content
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf(csvContent));

        // Call the import method
        Test.startTest();
        String result = invoiceSettlementController.importDataFromCSV(base64Data);
        Test.stopTest();

        // Asserts to verify the outcomes
        System.assert(result.contains('Error'), 'The import should process unsuccessfully: ' + result);
    }

    
    @isTest
    static void testImportDataFromCSV() {
        // Fetch test data created in testSetup
        List<Quote> quotes = [SELECT Id, Name FROM Quote];
        //List<SOA__c> soas = [SELECT Id, Name FROM SOA__c];
        //System.assert(!quotes.isEmpty() && !soas.isEmpty(), 'Test data should not be empty');

        // Prepare CSV content using fetched data
        String header = '"ID (DO NOT EDIT)","SOA/Quotation","Mitra","Business Product","SOA Start Date","SOA End Date","Telkomsel Revenue","Hak Telkomsel","Selisih Revenue (DO NOT EDIT)","Tanggal Invoice","No Invoice","Invoice ID (DO NOT EDIT)"';
        String line1 = '"' + quotes[0].Id + '","' + quotes[0].Name + '","Wira Pamungkas Pratama","Digital Media","2023-04-01","2023-04-30","500000","500000","0","2024-04-15","INV12345",""';
        //String line2 = '"' + soas[0].Id + '","' + soas[0].Name + '","Wira Pamungkas Pratama","2023-05-01","2023-05-31","600000","600000","0","2024-05-15","INV12346",""';

        String csvContent = header + '\n' + line1;

        // Encode the CSV content
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf(csvContent));

        // Call the import method
        Test.startTest();
        String result = invoiceSettlementController.importDataFromCSV(base64Data);
        Test.stopTest();

        // Asserts to verify the outcomes
        System.assert(result.contains('Success'), 'The import should process successfully: ' + result);
    }


    
    @isTest
    static void testCanUserAccessButtons() {
        // Assuming 'Sales' profile should not access the buttons
        User testUser = createUserWithProfile('Sales');
        System.runAs(testUser) {
            Boolean canAccess = invoiceSettlementController.canUserAccessButtons();
            System.assert(!canAccess, 'Sales should not access the buttons');
        }
    
        
        // Assuming 'System Administrator' profile should access the buttons
        testUser = createUserWithProfile('System Administrator');
        System.runAs(testUser) {
            Boolean canAccess = invoiceSettlementController.canUserAccessButtons();
            System.assert(canAccess, 'Admin should access the buttons');
        }
    }
    
    static User createUserWithProfile(String profileName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        User newUser = new User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Tester', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
            UserName='standarduser@testorg.com' + DateTime.now().getTime()
        );
        insert newUser;
        return newUser;
    } 
}