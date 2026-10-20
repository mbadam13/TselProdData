/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 27/03/2025
 * @last modified by  : Syaiful Syafani
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   27/03/2025   Syaiful Syafani   Initial Version
 * 2.0   14/05/2025	  M B Adam	        Update Apex Class
**/
@IsTest
public class OpportunityServiceTest {
    
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
                Name = 'Wira Pamungkas Pratama #2',          				// Account Name
                Legal_Name__c = 'Wira Pamungkas Pratama #2',
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
                PIC_Product_Type__c = 'Messaging',
                Product_Category__c = 'Advertising',                // Product Category
                Description = '500'                                // Product Description
                );
            insert prod;

            Product2 prod2 = new Product2(
                Name = 'BULK (SMS Interactive)',                      // Product Name
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
                PIC_Product_Type__c = 'Messaging',
                Product_Category__c = 'Advertising',                // Product Category
                Description = '500'                                // Product Description
                );
            insert prod2;

            Id pricebookId = Test.getStandardPricebookId();

            PricebookEntry pbEntry = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = prod.Id,
                UnitPrice = 100.00,
                IsActive = true
            );
            insert pbEntry;

            PricebookEntry pbEntry2 = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = prod2.Id,
                UnitPrice = 100.00,
                IsActive = true
            );
            insert pbEntry2;

            Opportunity oppRecord = new Opportunity(
                RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
                Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',  // Opportunity Name
                AccountId = acc.Id,                                                           // Account Name
                CloseDate = Date.valueOf('2024-09-21'),                                                  // Close Date
                Account_Type__c = 'Agency',                                                              // Account Type
                StageName = 'Proposal',                                                                // Stage
                Regional__c = 'HEAD OFFICE',                                                             // Regional  (Required)
                Probability = 100,                                                                      // Probability (%)
                Agency_Name__c = acc.Id,                                                      // Agency Name
                Amount = 150000000,
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
                OwnerId = testUser.Id            
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

            OrderItem orderItem = new OrderItem(
                OrderId = order.id,
                Product2Id = prod.Id,
                PricebookEntryId = pbEntry.id,
                Quantity = 10,
                UnitPrice = 100.00 
            );
            insert orderItem;

            Adjustment_Log__c AdjLogObjChange = new Adjustment_Log__c(
                Version__c = 3,                        // Version
                Opportunity__c = oppRecord.id,              // Opportunity
                Action__c = 'Change',                      // Action
                //Opp_Product_Id__c = '00kIm000003HykOIAS',  // Opp Product Id
                Product__c = prod.Id,                  // Product
                Product_Id_Number__c = '4',              // Product Id Number
                Old_Quantity__c = 90,                 // Old Quantity
                New_Sales_Price__c = 200,               // New Sales Price
                New_Quantity__c = 50,                 // New Quantity
                Opp_Product_Sequence_No__c = 1,          // Opp Product Sequence No
                Opportunity_Product__c = oli.Id      // Opportunity Product
            );
            insert AdjLogObjChange;

            Usage__c testUsage = new Usage__c(
                //Name = 'Test Usage',
                Date__c = Date.today(),
                Bucket_Detail__c = orderItem.Id
            );
            insert testUsage;
        }
    }
    
    @isTest
    static void TestOpptyData(){
        User userRec = [SELECT Id FROM User WHERE Username = 'admintv@digiads.com.invalid' LIMIT 1];        
        Opportunity OppRecData  = [SELECT Id, OwnerId FROM Opportunity WHERE OwnerId =: userRec.Id LIMIT 1];
        Order OrderRecData  = [SELECT Id, Status FROM Order WHERE Status ='Draft' LIMIT 1];

        OppRecData.Proposal_Activity__c = 1;
        OppRecData.Meeting_Activity__c  = 1;
       
        OppRecData.StageName = 'Negotiation';
        System.debug('Data Order Record' + OppRecData);
        
        Test.startTest();       
            update OppRecData;
            
            List<OpportunityLineItem> oliRec  = [SELECT Id,OpportunityId,Product_Name__c,Product2Id,Quantity
                                        FROM OpportunityLineItem WHERE OpportunityId =: OppRecData.Id];
            
            System.debug('oliRec ::'+ oliRec);        
            oliRec[0].Quantity = 400;
            
            update oliRec;
                OppRecData.Check_PO__c = 'OK';
                OppRecData.isSubmitCheckPOApproval__c = true;
                OppRecData.Approval_Status__c = 'Approved';
            //update OppRecData;
                OppRecData.StageName = 'Closed Won';
            update OppRecData;
        Test.stopTest();
    }
}