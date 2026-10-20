/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 11/02/2025
 * @last modified by  : Syaiful Syafani
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   11/02/2025   Syaiful Syafani   Initial Version
**/
@isTest
public with sharing class Test_Trigger_Usage_After_Insert_V2 {
    private static User createUser(){
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
    static void makeData(){
        User sales = createUser();

        System.runAs(sales){
            // ===== create account =====
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

            // ===== create contact =====
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

            // ===== create contract =====
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
            );
            insert contract;

            contract.Status = 'Activated';
            update contract;

            acc.ContractId__c = contract.Id;
            update acc;

            // ===== create product =====
            Id pricebookId = Test.getStandardPricebookId();
            Product2 prod = new Product2(
                Name = 'BULK (SMS Premium)',                        // Product Name
                Business_Product__c = 'Digital Media',              // Business Product
                Product_Category__c = 'Advertising',                // Product Category
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
                Description = '500'                                 // Product Description
            );
            insert prod;

            PricebookEntry pbEntry = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = prod.Id,
                UnitPrice = 100.00,
                IsActive = true
                );
            insert pbEntry;

            // ===== create opportunity ======
            Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Agency Postpaid').getRecordTypeId();
            Opportunity opp = new Opportunity(
                RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
                Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2023',  // Opportunity Name
                AccountId = acc.Id,                                                           // Account Name
                CloseDate = Date.valueOf('2023-09-21'),                                                  // Close Date
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
                Type = 'Existing Business',                                                              // Type
                Penagihan_based_on__c = 'Postpaid',                                                      // Penagihan based on
                Performance_Product__c = false,                                                          // Performance Product
                Programmatic_Product__c = false,                                                         // Programmatic Product
                Performance_Done__c = false,                                                             // Performance Done
                RFP_Status_sales__c = 'Completed',                                                       // RFP Status (sales)
                Check_PO__c = 'OK',
                Pricebook2Id = Test.getStandardPricebookId()
            );
            insert opp;

            OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = opp.Id,       // Opportunity
                Product2Id = prod.Id,               // Product
                Discount__c = 0.00,                 // Discount (%)
                PricebookEntryId = pbEntry.Id,
                UnitPrice = 500.00,                 // Sales Price
                Quantity = 100.00                    // Quantity
            );
            insert oli;

            opp.StageName = 'Closed Won';
            update opp;

            Date today = Date.today();
            Date startDate = Date.newInstance(today.year(), today.month(), 1);
            Date endDate = Date.newInstance(today.year(), today.month(), Date.daysInMonth(today.year(), today.month()));

            // ===== after closed won =====
            SOA__c soa = new SOA__c(
                Opportunity__c = opp.Id,                // Opportunity
                SOA_Type__c = 'Opportunity',            // SOA Type
                SOA_Start_Date__c = startDate,          // SOA Start Date
                SOA_End_Date__c = endDate,              // SOA End Date
                SOA_Sources__c = 'Opportunity'          // SOA
            );
            insert soa;

            Order order = new Order(
                Status = 'Draft',                                             
                SOA__c = soa.Id,                                              
                EffectiveDate = Date.newInstance(today.year(), today.month(), today.day()),                              // Order Start Date
                EndDate = endDate,                                                      
                AccountId = acc.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                File_Upload_MO__c = true,
                Approval_Status__c = '',
                OpportunityId = opp.Id
            );
            insert order;

            OrderItem orderItem = new OrderItem(
                OrderId = order.id,
                Product2Id = prod.Id,
                PricebookEntryId = pbEntry.id,
                Quantity = 100.00,
                UnitPrice = 500.00,
                Opportunity_Product__c = oli.Id,
                Opportunity__c = opp.Id
            );
            insert orderItem;

            Invoice__c invoice = new Invoice__c(
                Mitra__c = acc.id,                                   
                No_Invoice__c = 'TS.123123.4123125',                 
                No_Master__c = '123123',                             
                Tanggal_Invoice__c = today,            
                No_Individual__c = '3123123',                        
                Jangka_Waktu_PKS__c = '1 Januari 2024 - 31 Desember 2025',
                Hak_Telkomsel__c = 150000                                 
            );
            insert invoice;

            soa.Invoice__c = invoice.Id;
            update soa;
        }
    }

    @isTest
    static void insertUsage(){
        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'BULK (SMS Premium)' LIMIT 1];
        OrderItem item = [SELECT Campaign_ID__c FROM OrderItem WHERE Product2Id = :product.Id LIMIT 1];
        System.debug('== campaignId at OrderItem: '+ item);
        Date today = Date.today();

        Usage__c usg = new Usage__c(
            Date__c = today,
            Campaign_ID__c = item.Campaign_ID__c,
            Amount__c = 100
        );
        Test.startTest();
        insert usg;
        Test.stopTest();
    }
}