/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 12/02/2025
 * @last modified by  : Syaiful Syafani
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   12/02/2025   Syaiful Syafani   Initial Version
**/
@isTest
public class TA_AT_OrderItem_AU_AllHouseNumberTest {
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
        User sales = createUser();
        System.runAs(sales) {
            MetadataTriggerHandler.bypass('TA_AT_CreateOpptyTeamMember_AI');
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
                Penagihan_based_on__c = 'Postpaid',                                                      // Penagihan based on
                Performance_Product__c = false,                                                          // Performance Product
                Programmatic_Product__c = false,                                                         // Programmatic Product
                Performance_Done__c = false,                                                             // Performance Done
                RFP_Status_sales__c = 'Completed',                                                       // RFP Status (sales)
                Check_PO__c = 'OK',
                Pricebook2Id = Test.getStandardPricebookId(),
                OwnerId = sales.Id            
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

            // upload file oppty
            ContentVersion uploadFile = new ContentVersion(
                Title = 'Sample-PNG',
                PathOnClient = 'testfile.pdf',
                VersionData = Blob.valueOf('this is a test file'),
                IsMajorVersion = true
            );
            Insert uploadFile;

            ContentVersion contentVersionRec = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: uploadFile.Id];

            ContentDocumentLink uploadFileLink = new ContentDocumentLink(
                ContentDocumentId = contentVersionRec.ContentDocumentId,
                LinkedEntityId = oppRecord.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            );
            insert uploadFileLink;

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

            House_Number__c houseNumber = new House_Number__c(
                Name = 'CRHTO0101923',
                Brand__c = 'Toyota',
                Versi__c = 'Toyota Avanza'
            );
            insert houseNumber;

            Order order = new Order(
                Status = 'Draft',                                                    // Status
                SOA__c = soaRecord.Id,                                              // SOA
                EffectiveDate = Date.newInstance(2024, 12,01),                              // Order Start Date
                EndDate = Date.newInstance(2024, 12,31),                                                      // Order Type
                AccountId = acc.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                File_Upload_MO__c = false,
                Approval_Status__c = '',
                OpportunityId = oppRecord.Id
            );
            insert order;

            OrderItem orderItem = new OrderItem(
                OrderId = order.id, 
                Product2Id = prod.Id,
                PricebookEntryId = pbEntry.id,
                Quantity = 10,
                UnitPrice = 100.00
            );
            insert orderItem;
        }
    }

    @isTest
    static void checkHouseNumber(){
        OrderItem orderItemRec = [SELECT Id, House_Number__c FROM OrderItem LIMIT 1];
        House_Number__c houseNumberRec = [SELECT Id FROM House_Number__c LIMIT 1];

        orderItemRec.House_Number__c = houseNumberRec.Id;
        Test.startTest();
        update orderItemRec;
        Test.stopTest();
    }
}