/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-29-2024
 * @last modified by  : Syaiful Syafani
**/
@isTest
public with sharing class QuoteTriggerTEST {
    @TestSetup
    static void makeData(){
        // === RecordType or Id ===
        Id recordTypeAccId  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser').getRecordTypeId();
        Id recordTypeOppId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Advertiser').getRecordTypeId();
        Id pricebookId      = Test.getStandardPricebookId();

        // === date ===
        Date startDate = Date.newInstance(2024, 1, 1);
        Date endDate   = Date.newInstance(2025, 12, 31);

        // === Create User ===
        Profile proRec = [SELECT Id FROM Profile WHERE Name = 'SALES' LIMIT 1];
        User userRec = new User(
            FirstName           = 'Admin',
            LastName            = 'TV',
            NIK__c              = '123',
            Username            = 'admintv@digiads.com.invalid',
            Alias               = 'AdmTV',
            EmailEncodingKey    = 'UTF-8',
            Email               = 'admintv@digiads.com.invalid',
            ProfileId           = proRec.Id,
            LocaleSidKey        = 'en_US',
            LanguageLocaleKey   = 'en_US',
            TimeZoneSidKey      = 'America/Los_Angeles'
        );
        insert userRec;

        // === Create Account ===
        Account acc = new Account(
            Name                    = 'Wira Pamungkas Pratama',     // Account Name
            RecordTypeId            = recordTypeAccId,              // Account Record Type
            Account_Type__c         = 'Agency',                     // Account Type
            Direct_Indirect__c      = 'Direct',                     // Direct/Indirect
            Status__c               = 'Approved by Settlement',     // Status
            No_PKS__c               = '123456',                     // No PKS
            NPWP__c                 = '111111',                     // NPWP
            NPWP_Address__c         = 'Podomoro',                   // NPWP Address
            Reason_by_Settlement__c = 'Approved',                   // Reason by Settlement
            PKS_Tracker__c          = 'Pending'
        );
        insert acc;

        // === Create Contact ===
        Contact contactRec = new Contact(
            AccountId               = acc.id,               // Account Name
            Title                   = 'Planner',            // Title
            Email                   = 'test@gmail.com',     // Email
            Phone                   = '231313123123',       // Phone
            LastName                = 'user1',              // Last Name
            MobilePhone             = '231313123123',       // Mobile
            Active__c               = true,                 // Active?
            Priority__c             = 'Priority 1',         // Priority
            Converted_from_Lead__c  = false                 // Converted from Lead
        );
        insert contactRec;
        
        // === Create Contract ===
        Contract contract = new Contract(
            StartDate               = Date.valueOf('2019-09-01'),   // Contract Start Date
            ContractTerm            = 9999,                         // Contract Term (months)
            AccountId               = acc.Id,                       // Account Name
            OwnerExpirationNotice   = '120',                        // Owner Expiration Notice
            Status                  = 'Draft',                      // Status
            Terminate__c            = false,                        // Terminate
            Archive__c              = false,                        // Archive
            No_PKS__c               = '123456',                     // No.PKS
            Contract_Signed__c      = 'Circulation'                 // Contract Signed ?
        );
        insert contract;
        
        // === Update Record ===
        acc.ContractId__c = contract.Id;
        update acc;

        contract.Status = 'Activated';
        update contract;

        // === Create Channel ===
        IPTV_Channel__c channelRec = new IPTV_Channel__c(
            Name                    = 'AFN',
            Keyword__c              = 'TVC PLATINUM'
        );
        Insert channelRec;

        // === Create Inventory ===
        IPTV_Inventory__c invRec = new IPTV_Inventory__c(
            Name                    = 'AFN PRIME TIME',
            IPTV_Channels__c        = channelRec.Id,
            Show_Time__c            = 'PRIME TIME',
            Time__c                 = '17.00 - 24.00',
            keyword__c              = 'all',
            Type__c                 = 'IPTV',
            Product_Inventory__c    = 'TVC PLATINUM;TVC ROS'
        );
        Insert invRec;

        // === Product TV Media ===
        Product2 prodTV = new Product2(
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
            List_Price__c       = 1300000,                      // Rate Card
            IPTV_Inventory__c   = invRec.Id,                    // IPTV Inventory
            Duration__c         = 10,                           // Duration
            IsActive            = true                          // Active
        );
        insert prodTV;
            
        // === Pricebook Entry TV Media ===
        PricebookEntry pbEntryTV = new PricebookEntry(
            Pricebook2Id    = pricebookId,
            Product2Id      = prodTV.Id,
            UnitPrice       = 100.00,
            IsActive        = true
            );
        insert pbEntryTV;

        // === Opportunity TV Media ===
        Opportunity oppTVRec = new Opportunity(
            RecordTypeId            = recordTypeOppId,              // Opportunity Record Type
            Name                    = 'TSEL',                       // Opportunity Name
            AccountId               = acc.Id,                       // Account Name
            CloseDate               = Date.valueOf('2024-09-21'),   // Close Date
            Account_Type__c         = 'Advertiser',                 // Account Type
            StageName               = 'Proposal / PO Sign',         // Stage
            Regional__c             = 'HEAD OFFICE',                // Regional  (Required)
            Probability             = 100,                          // Probability (%)
            Agency_Name__c          = acc.Id,                       // Agency Name
            Campaign_Customize__c   = false,                        // Campaign Customize
            Templated_Proposal__c   = true,                         // Own Proposal?
            Approval_Remark__c      = 'Approved',                   // Approval Remark
            Document_Version__c     = 'Submit',                     // Document Version
            Approval_Status__c      = 'Approved',                   // Approval Status
            Marketing_Package__c    = false,                        // Marketing Package
            SME__c                  = false,                        // SME
            Type                    = 'Existing Business',          // Type
            Penagihan_based_on__c   = 'Postpaid',                   // Penagihan based on
            Performance_Product__c  = false,                        // Performance Product
            Programmatic_Product__c = false,                        // Programmatic Product
            Performance_Done__c     = false,                        // Performance Done
            RFP_Status_sales__c     = 'Completed',                  // RFP Status (sales)
            Check_PO__c             = 'OK',                         // Check PO
            Pricebook2Id            = Test.getStandardPricebookId(),
            OwnerId                 = userRec.Id           
        );
        insert oppTVRec;

        // === create oppty product ===
        OpportunityLineItem oliTVRec = new OpportunityLineItem(
            OpportunityId       = oppTVRec.Id,     // Opportunity
            Product2Id          = prodTV.Id,       // Product
            Discount__c         = 0.00,                 // Discount (%)
            PricebookEntryId    = pbEntryTV.Id, 
            UnitPrice           = 500.00,               // Sales Price
            Quantity            = 100.00                // Quantity
        );
        insert oliTVRec;

        oppTVRec.StageName = 'Closed Won';
        update oppTVRec;

        // === create soa ===
        SOA__c soaRecord = new SOA__c(
            Opportunity__c = oppTVRec.Id,       // Opportunity
            SOA_Type__c = 'Opportunity',        // SOA Type
            SOA_Start_Date__c = startDate,      // SOA Start Date
            SOA_End_Date__c = endDate,          // SOA End Date
            SOA_Sources__c = 'Opportunity'      // SOA
        );
        insert soaRecord;

        // === create invoice ===
        Invoice__c invoiceRec = new Invoice__c(
            Mitra__c            = acc.id,                                   // Mitra
            No_Invoice__c       = 'TS.123123.4121233125',                   // No Invoice
            No_Master__c        = '123123',                                 // No Master
            Tanggal_Invoice__c  = Date.newInstance(2024, 12,01),            // Tanggal Invoice
            No_Individual__c    = '3123123',                                // No Individual
            Jangka_Waktu_PKS__c = '1 Januari 2024 - 31 Desember 2025',      // Jangka Waktu PKS
            Hak_Telkomsel__c    = 150000                                    // Hak Telkomsel
            // VAT_Related__c = 'undefined'                                 // VAT Related
        );
        insert invoiceRec;
    }

    @isTest
    static void testCreateOrder(){
        // === get oppty record ===
        Opportunity oppRec  = [SELECT Id, AccountId FROM Opportunity WHERE Business_Product__c = 'TV Media'];
        Contact conRec      = [SELECT Id FROM Contact WHERE Email = 'test@gmail.com'];
        Invoice__c invRec   = [SELECT Id FROM Invoice__c WHERE No_Invoice__c = 'TS.123123.4121233125'];

        // === date ===
        Date startDate  = Date.newInstance(2024, 1, 1);
        Date endDate    = Date.newInstance(2025, 12, 31);

        // === create quote ===
        Quote quoteRec = new Quote(
            Name            = 'TSEL / Q02250 / dev1/9/25/2023',     // Quotation Name
            OpportunityId   = oppRec.id,                            // Opportunity Name
            ContactId       = conRec.id,                            // Contact Name
            Status          = 'Final',                              // Status
            Start_Date__c   = startDate,                            // Start Date
            End_Date__c     = endDate,                              // End Date
            Invoice__c      = invRec.id                             // Invoice
        );

        // === execute ===
        Test.startTest();
            insert quoteRec; 
        Test.stopTest();
    }
}