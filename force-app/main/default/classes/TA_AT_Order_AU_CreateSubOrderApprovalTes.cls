/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-16-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class TA_AT_Order_AU_CreateSubOrderApprovalTes {

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
    static void makeData(){
        User testUser = createUser();
        
        System.runAs(testUser) {
            MetadataTriggerHandler.bypass('TA_AT_CreateOpptyTeamMember_AI');
            Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            Account acc = new Account(
                Name = 'Wira Pamungkas Pratama #2', 
                Legal_Name__c ='Testing', // Account Name
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
                Penagihan_based_on__c = 'Postpaid',
                Penagihan_based_on_TV__c='Postpaid',// Penagihan based on
                Performance_Product__c = false,                                                          // Performance Product
                Programmatic_Product__c = false,                                                         // Programmatic Product
                Performance_Done__c = false,                                                             // Performance Done
                RFP_Status_sales__c = 'Completed',                                                       // RFP Status (sales)
                Check_PO__c = 'OK',
                Pricebook2Id = Test.getStandardPricebookId(),
                OwnerId = testUser.Id,
                Proposal_Activity__c = 1,
                Meeting_Activity__c  = 1,
                Remarks__c = 'test',
                Target_Start_Date__c = Date.valueOf('2024-09-1'),
                Target_Closed_Date__c = Date.valueOf('2024-09-21')
            );
            insert oppRecord;
            
            OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = oppRecord.Id,// Opportunity
                Product2Id = prod.Id,     // Product
                Discount__c = 0,               // Discount (%)
                PricebookEntryId = pbEntry.Id,
                UnitPrice = 500,                 // Sales Price
                Quantity = 10,              // Quantity
                Business_Product__c = 'TV Media'
            );
            insert oli;

            ContentVersion uploadFile = new ContentVersion(
                Title = 'Test File',
                PathOnClient = 'TestFile.txt',
                VersionData = Blob.valueOf('This is a test file content.'),
                Origin = 'H'
            );
            insert uploadFile;

            ContentVersion fileUploaded = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: uploadFile.Id LIMIT 1];

            ContentDocumentLink contentDoc = new ContentDocumentLink(
                ContentDocumentId = fileUploaded.ContentDocumentId,
                LinkedEntityId = oppRecord.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            );
            insert contentDoc;

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
                Pricebook2Id = Test.getStandardPricebookId(),
                File_Upload_MO__c = true,
                Approval_Status__c = '',
                OpportunityId = oppRecord.Id,
                All_House_Numbers_Filled__c = true
            );
            insert order;

            OrderItem orderItem = new OrderItem(
                OrderId = order.id,
                Product2Id = prod.Id,
                PricebookEntryId = pbEntry.id,
                Quantity = 10,
                UnitPrice = 100.00,
                Opportunity__c = oppRecord.Id,
                Opportunity_Product__c = oli.Id
            );
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

            Usage__c usgRec = new Usage__c(
                Date__c = Date.today(),
                Bucket_Detail__c = orderItem.Id,
                Amount__c = 10
            );
            insert usgRec;

            oppRecord.StageName = 'Closed Won';
            update oppRecord;
        }
    }

    
    @isTest
    static void testHandleSubOrderApprovals() {
        Test.startTest();
        
        // Ambil Order dan Sub Order yang sudah dibuat di setupTestData
        Order testOrder = [SELECT Id FROM Order WHERE Status='Draft' LIMIT 1];
        Order anUpdateOrder = new Order();
        anUpdateOrder.Id = testOrder.Id;
        anUpdateOrder.Approval_Status__c='Submit';
        Update anUpdateOrder;
        
       
        Set<Id> orderIds = new Set<Id>();
        orderIds.add(testOrder.Id);
       
        
         Sub_Order__c subOrder = new Sub_Order__c();
                    //subOrder.Manager_Approval__c = managerId;
                    subOrder.Approval_Status__c = 'Submit';
                    subOrder.Order__c = testOrder.Id;
                    subOrder.Is_Active__c = true;
    
          Insert subOrder;
        
          Sub_Order__c subOrder2 = new Sub_Order__c();
                    //subOrder.Manager_Approval__c = managerId;
                    subOrder.Approval_Status__c = 'Submit';
                    subOrder.Order__c = testOrder.Id;
                    subOrder.Is_Active__c = true;
    
          Insert subOrder2;
        // Jalankan method generateSubOrders
        SubOrderService.generateSubOrders(new List<Id>{testOrder.Id});
        
         SubOrderService.handleSubOrderApprovals(new List<Id>(orderIds));
        Test.stopTest();
    }
    
}