/**
 *  Author      :   Yusuf Ramadhan (yusuf.ramadhan@saasten.com)
 *  Classes     :   invoiceSettlementController
 * 
 * 
 *  Date        PIC         Ref         Brief of changes
 *  29/04/24    Yusuf       TSEL-2312   Initial Create
 *  29/04/24    Yusuf       TSEL-2312   Complete the class
 *  15/05/24    Yusuf       TSEL-2312   Negative Test Provided
 * 
 * 
 */
@isTest
private class invoiceSettlementControllerTEST {

    @TestSetup
    static void makeData(){
        MetadataTriggerHandler.bypass('TA_AT_Quote_AU_RelateOrderTVtoQuote');


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
            
        Opportunity oppRecord = new Opportunity(
            RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
            Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',  // Opportunity Name
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
            Penagihan_based_on__c = 'Postpaid',                                                      // Penagihan based on
            Performance_Product__c = false,                                                          // Performance Product
            Programmatic_Product__c = false,                                                         // Programmatic Product
            Performance_Done__c = false,                                                             // Performance Done
            RFP_Status_sales__c = 'Completed',                                                       // RFP Status (sales)
            Check_PO__c = 'OK',
            Pricebook2Id = Test.getStandardPricebookId()            
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

        //Test.startTest();
       
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


        // -------------------------------- QUOTATION SETUP -------------------------------------
        /*Opportunity oppRecord1 = new Opportunity(
            RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
            Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',  // Opportunity Name
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
            OpportunityId = oppRecord1.id,                      // Opportunity Name
            ContactId = contactRec.id,                          // Contact Name
            Status = 'Final',                                 // Status
            Start_Date__c = startDate,       // Start Date
            End_Date__c = endDate,         // End Date
            Invoice__c = invRec1.id                         // Invoice
        );

        insert quoteRec; */

        /*Order order1 = new Order(
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
        insert orderItem1; */

        // -------------------------------- QUOTATION SETUP -------------------------------------
     
    }

    /*
    @isTest
    static void SOAImplementation() {
        List<SOA__c> soaCreated = [SELECT Id FROM SOA__c];
        System.assert(soaCreated.size() > 0);
    } */

    @isTest
    static void testGetCombinedRecords() {
        // Set start and end dates to the first and last day of the current month
        Date startDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);
        Date endDate = Date.newInstance(Date.today().year(), Date.today().month(), Date.daysInMonth(Date.today().year(), Date.today().month()));

        // Call the method with test data dates
        Test.startTest();
        List<invoiceSettlementController.InvoiceInSOAorQuoteRecord> records = invoiceSettlementController.getCombinedRecords(startDate, endDate);
        Test.stopTest();

        // Asserts to check if records are retrieved correctly
       // System.assertNotEquals(0, records.size(), 'Records should be retrieved');
        for (invoiceSettlementController.InvoiceInSOAorQuoteRecord record : records) {
            System.assertNotEquals(null, record.RecordName, 'Record Name should not be null');
            System.assert(record.startDate >= startDate && record.endDate <= endDate, 'Record dates should be within the specified range');
        }
    }

      
    @IsTest
    static void testImportWrongDataTypeSOAQuote(){
         // Fetch test data created in testSetup
         //List<Quote> quotes = [SELECT Id, Name FROM Quote];
         List<SOA__c> soas = [SELECT Id, Name FROM SOA__c];
         //System.assert(!quotes.isEmpty() && !soas.isEmpty(), 'Test data should not be empty');
 
         // Prepare CSV content using fetched data
         String header = '"ID (DO NOT EDIT)","SOA/Quotation","Mitra","Business Product","SOA Start Date","SOA End Date","Telkomsel Revenue","Hak Telkomsel","Selisih Revenue (DO NOT EDIT)","Tanggal Invoice","No Invoice","Invoice ID (DO NOT EDIT)"';
         //String line1 = '"' + quotes[0].Id + '","' + quotes[0].Name + '","Wira Pamungkas Pratama","04-2023-01","2023-04-30","x","500000","0","2024-04-15","INV12345",""';
         String line2 = '"' + soas[0].Id + '","' + soas[0].Name + '","Wira Pamungkas Pratama","Digital Media","05-2023-01","2023-05-31","x","600000","0","2024-05-15","INV12346",""';
         String line3 = '"' + soas[0].Id + '","' + soas[0].Name + '","Wira Pamungkas Pratama","Digital Media","2023-05-01","2023-05-31","x","6o0000","0","2024-05-15","INV12346",""';
         String line4 = '"' + soas[0].Id + '","' + soas[0].Name + '","Wira Pamungkas Pratama","Digital Media","2023-05-01","2023-05-31","x","60000","0","2024-05-15","INV12346",""';
 
         String csvContent = header + '\n' + line2 + '\n' + line3 + '\n' + line4;
 
         // Encode the CSV content
         String base64Data = EncodingUtil.base64Encode(Blob.valueOf(csvContent)); //Error
 
         // Call the import method
         Test.startTest();
         String result = invoiceSettlementController.importDataFromCSV(base64Data);
         Test.stopTest();
 
         // Asserts to verify the outcomes
         System.assert(result.contains('Error'), 'The import should process unsuccessfully: ' + result);
    }

    @IsTest
    static void testImportSOA(){
         // Fetch test data created in testSetup
         //List<Quote> quotes = [SELECT Id, Name FROM Quote];
         List<SOA__c> soas = [SELECT Id, Name FROM SOA__c];
         //System.assert(!quotes.isEmpty() && !soas.isEmpty(), 'Test data should not be empty');
 
         // Prepare CSV content using fetched data
         String header = '"ID (DO NOT EDIT)","SOA/Quotation","Mitra","Business Product","SOA Start Date","SOA End Date","Telkomsel Revenue","Hak Telkomsel","Selisih Revenue (DO NOT EDIT)","Tanggal Invoice","No Invoice","Invoice ID (DO NOT EDIT)"';
         //String line1 = '"' + quotes[0].Id + '","' + quotes[0].Name + '","Wira Pamungkas Pratama","04-2023-01","2023-04-30","x","500000","0","2024-04-15","INV12345",""';
        //  String line2 = '"' + soas[0].Id + '","' + soas[0].Name + '","Wira Pamungkas Pratama","Digital Media","05-2023-01","2023-05-31","x","600000","0","2024-05-15","INV12346",""';
        //  String line3 = '"' + soas[0].Id + '","' + soas[0].Name + '","Wira Pamungkas Pratama","Digital Media","2023-05-01","2023-05-31","x","6o0000","0","2024-05-15","INV12346",""';
         String line4 = '"' + soas[0].Id + '","' + soas[0].Name + '","Wira Pamungkas Pratama","Digital Media","2023-05-01","2023-05-31","","60000","0","2024-05-15","INV12346",""';
 
         String csvContent = header + '\n' + line4;
 
         // Encode the CSV content
         String base64Data = EncodingUtil.base64Encode(Blob.valueOf(csvContent)); //valid
 
         // Call the import method
         Test.startTest();
         String result = invoiceSettlementController.importDataFromCSV(base64Data);
         Test.stopTest();
 
         // Asserts to verify the outcomes
         //System.assert(result.contains('Error'), 'The import should process unsuccessfully: ' + result);
    }


    @IsTest
    static void testIsValidDate() {
        // Test with a null input
        System.assert(!invoiceSettlementController.isValidDate(null), 'Null should return false');
        
        // Test with an empty string
        System.assert(!invoiceSettlementController.isValidDate(''), 'Empty string should return false');
        
        // Test with a valid date string
        System.assert(invoiceSettlementController.isValidDate('2023-01-01'), 'Valid date string should return true');
        
        // Test with an invalid date string
        System.assert(!invoiceSettlementController.isValidDate('2023-02-30'), 'Invalid date string should return false');
        
        // Test with non-date string
        System.assert(!invoiceSettlementController.isValidDate('hello'), 'Non-date string should return false');
    }

    @IsTest
    static void testIsValidDecimal() {
        // Test with a null input
        System.assert(!invoiceSettlementController.isValidDecimal(null), 'Null should return false');
        
        // Test with an empty string
        System.assert(!invoiceSettlementController.isValidDecimal(''), 'Empty string should return false');
        
        // Test with a valid decimal string
        System.assert(invoiceSettlementController.isValidDecimal('123.456'), 'Valid decimal string should return true');
        
        // Test with a valid negative decimal
        System.assert(invoiceSettlementController.isValidDecimal('-987.654'), 'Valid negative decimal should return true');
        
        // Test with an invalid decimal string (non-numeric)
        System.assert(!invoiceSettlementController.isValidDecimal('abc123'), 'Non-numeric string should return false');
        
        // Test with a complex string containing numbers
        System.assert(!invoiceSettlementController.isValidDecimal('123.456.789'), 'Complex non-decimal string should return false');
    }

    @IsTest
    static void testErrorToExport() {
        // Setup 
        Quote aQuoteUpdate = new Quote();
        //aQuoteUpdate.Id = 'asdasdasd';

        // Execute - Attempt to insert the incomplete Account and catch the DmlException
        String result = '';
        try {
            update aQuoteUpdate; // This should fail
        } catch (DmlException dmlEx) {
            // Test the method that formats the DmlException into a CSV string
            result = invoiceSettlementController.errorToExport(dmlEx);
        }

        // Verify - Check that the output string is formatted as expected
        System.assertNotEquals('', result, 'Result should not be empty');
        System.assert(result.startsWith('Error:'), 'Error message should start with "Error:"');
        System.assert(result.contains('Record ID,Error Message\n'), 'Header should be present in the error message');
    }

    
    

}