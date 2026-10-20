/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 09-02-2024
 * @last modified by  : Syaiful Syafani
**/
@isTest
public with sharing class TA_VR_RFP_BU_OwnerValidation_Test {
    private static String generateUsername(){
        String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        Integer usernameLength = 8; // Panjang username acak
        String domain = 'example.com.invalid'; // Domain email, bisa diubah sesuai kebutuhan

        String username = '';

        // Membuat username acak
        for (Integer i = 0; i < usernameLength; i++) {
            Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            username += chars.substring(randomIndex, randomIndex + 1);
        }

        // Menggabungkan username dengan domain untuk membuat email lengkap
        String usernameUnique = username + '@' + domain;
        return usernameUnique;

    }

    private static String generateNIK(){
        Integer generateNIK = 100000 + (Integer)(Math.random() * 900000);
        
        String nikUnique = String.valueOf(generateNIK);
        return nikUnique;
    }

    private static User createSalesUser() {
        Profile proRec = [SELECT Id FROM Profile WHERE Name = 'SALES' LIMIT 1];
        UserRole roleRec = [SELECT Id, Name, PortalRole FROM UserRole WHERE Name='SALES DA' LIMIT 1];

        User userRec = new User(
            FirstName           = 'Admin',
            LastName            = 'TV Ads',
            NIK__c              = generateNIK(),
            Username            = generateUsername(),
            Alias               = 'AdmTV',
            EmailEncodingKey    = 'UTF-8',
            Email               = 'admintvs@digiads.com.invalid',
            ProfileId           = proRec.Id,
            UserRoleId          = roleRec.Id,
            LocaleSidKey        = 'en_US',
            LanguageLocaleKey   = 'en_US',
            TimeZoneSidKey      = 'America/Los_Angeles'
        );
        insert userRec;
        return userRec;
    }

    private static User createMarketingUser() {
        Profile proRec = [SELECT Id FROM Profile WHERE Name = 'Marketing Manager' LIMIT 1];
        UserRole roleRec = [SELECT Id, Name, PortalRole FROM UserRole WHERE Name='SALES PLANNER' LIMIT 1];

        User userRec = new User(
            FirstName           = 'Marketing',
            LastName            = 'Manager',
            NIK__c              = generateNIK(),
            Username            = generateUsername(),
            Alias               = 'AdmTV',
            EmailEncodingKey    = 'UTF-8',
            Email               = 'marketingmanager@digiads.com.invalid',
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
        User SalesUser = createSalesUser(); // running as a sales
        User MarketingUser = createMarketingUser(); // running as a sales

        // recordTypeId
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser').getRecordTypeId();
        Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Advertiser').getRecordTypeId();
        Id recordTypeRfpId = Schema.SObjectType.Request_for_Proposal__c.getRecordTypeInfosByName().get('Direct Sales Proposal').getRecordTypeId();

        System.runAs(SalesUser){
            Account acc = new Account(
                Name = 'Wira Pamungkas Pratama #2',          				// Account Name
                RecordTypeId = recordTypeAccId,                             // Account Record Type
                Account_Type__c = 'Advertiser',                             // Account Type
                Direct_Indirect__c = 'Direct',                               // Direct/Indirect
                Status__c = 'Approved by Settlement',                        // Status
                No_PKS__c = '123456',                                        // No PKS
                NPWP__c = '1234567890123456',                                               // NPWP
                NPWP_Address__c = 'Jakarta',
                PKS_Tracker__c = 'Pending',
                Reason_by_Settlement__c = 'reason'
            );
            TriggerBase.bypass('Account');
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
                StartDate = Date.today(),// Contract Start Date
                ContractTerm = 9999,                  // Contract Term (months)
                AccountId = acc.Id,
                OwnerExpirationNotice = '120',      // Owner Expiration Notice
                Status = 'Draft',                    // Status
                Terminate__c = false,                    // Terminate
                Archive__c = false,                      // Archive
                No_PKS__c = '123456',                    // No.PKS
                Contract_Signed__c = 'Signed',     // Contract Signed ?
                IsSubmitApproval__c = true
            // Opportunity__c = oppRecord.Id
            );
            insert contract;
            
            contract.Status = 'Activated';
            update contract;

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

            Date endDate = Date.today().addDays(15);

            Opportunity oppRecord = new Opportunity(
                RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
                Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',  // Opportunity Name
                AccountId = acc.Id,                                                           // Account Name
                CloseDate = endDate,                                                  // Close Date
                Account_Type__c = 'Advertiser',                                                              // Account Type
                StageName = 'Request for Proposal',                                                                // Stage
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
                OwnerId = SalesUser.Id
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

            TriggerBase.bypass('Request_for_Proposal__c');
            MetadataTriggerHandler.bypass('TA_VR_RFP_BU_OwnerValidation');
            // rfp assigned
            Request_for_Proposal__c rfpRec2 = new Request_for_Proposal__c(
                Opportunity_Name__c = oppRecord.Id,
                Request_for_Proposal_Status__c = 'Request Assign',
                Date__c = Date.today(),
                Product__c = '2',
                Buying_Method__c = 'I/O Based',
                PIC_Client__c = contactRec.Id,
                Deadline__c = endDate,
                Project__c = '1',
                Background__c = '1',
                Campaign_Objective__c = '1',
                KPI__c = '1',
                Key_Message__c = '1',
                Start_Period__c = Date.today(),
                End_Period__c = endDate,
                Target_Audiance__c = '1',
                Campaign_Investment__c = 1,
                Campaign_Media_Preferred_Inventory__c = '1',
                Opportunity_Owner__c = oppRecord.OwnerId,
                RecordTypeId = recordTypeRfpId,
                OwnerId = MarketingUser.Id
            );
            insert rfpRec2;

            // rfp progress
            Request_for_Proposal__c rfpRec3 = new Request_for_Proposal__c(
                Opportunity_Name__c = oppRecord.Id,
                Request_for_Proposal_Status__c = 'Progress',
                Date__c = Date.today(),
                Product__c = '3',
                Buying_Method__c = 'I/O Based',
                PIC_Client__c = contactRec.Id,
                Deadline__c = endDate,
                Project__c = '1',
                Background__c = '1',
                Campaign_Objective__c = '1',
                KPI__c = '1',
                Key_Message__c = '1',
                Start_Period__c = Date.today(),
                End_Period__c = endDate,
                Target_Audiance__c = '1',
                Campaign_Investment__c = 1,
                Campaign_Media_Preferred_Inventory__c = '1',
                Opportunity_Owner__c = oppRecord.OwnerId,
                RecordTypeId = recordTypeRfpId,
                OwnerId = MarketingUser.Id
            );
            insert rfpRec3;

            // rfp ask revision
            Request_for_Proposal__c rfpRec4 = new Request_for_Proposal__c(
                Opportunity_Name__c = oppRecord.Id,
                Request_for_Proposal_Status__c = 'Ask Revision',
                Date__c = Date.today(),
                Product__c = '4',
                Buying_Method__c = 'I/O Based',
                PIC_Client__c = contactRec.Id,
                Deadline__c = endDate,
                Project__c = '1',
                Background__c = '1',
                Campaign_Objective__c = '1',
                KPI__c = '1',
                Key_Message__c = '1',
                Start_Period__c = Date.today(),
                End_Period__c = endDate,
                Target_Audiance__c = '1',
                Campaign_Investment__c = 1,
                Campaign_Media_Preferred_Inventory__c = '1',
                Opportunity_Owner__c = oppRecord.OwnerId,
                RecordTypeId = recordTypeRfpId,
                OwnerId = SalesUser.Id
            );
            insert rfpRec4;

            // rfp ask revision
            Request_for_Proposal__c rfpRec5 = new Request_for_Proposal__c(
                Opportunity_Name__c = oppRecord.Id,
                Request_for_Proposal_Status__c = 'In_Revision',
                Date__c = Date.today(),
                Product__c = '5',
                Buying_Method__c = 'I/O Based',
                PIC_Client__c = contactRec.Id,
                Deadline__c = endDate,
                Project__c = '1',
                Background__c = '1',
                Campaign_Objective__c = '1',
                KPI__c = '1',
                Key_Message__c = '1',
                Start_Period__c = Date.today(),
                End_Period__c = endDate,
                Target_Audiance__c = '1',
                Campaign_Investment__c = 1,
                Campaign_Media_Preferred_Inventory__c = '1',
                Opportunity_Owner__c = oppRecord.OwnerId,
                RecordTypeId = recordTypeRfpId,
                OwnerId = MarketingUser.Id
            );
            insert rfpRec5;
            MetadataTriggerHandler.clearBypass('TA_VR_RFP_BU_OwnerValidation');
            TriggerBase.clearBypass('Request_for_Proposal__c');

            System.debug('--rfpRec2: '+ rfpRec2.Request_for_Proposal_Status__c);
            System.debug('--rfpRec3: '+ rfpRec3.Request_for_Proposal_Status__c);
            System.debug('--rfpRec4: '+ rfpRec4.Request_for_Proposal_Status__c);
            System.debug('--rfpRec5: '+ rfpRec5.Request_for_Proposal_Status__c);
        }
    }


    // ===== VALIDATION USER NOT EQUALS "SYSTEM ADMINISTRATOR" =====
    @isTest
    static void updateRFPFromAssignedtoCompleted(){   
        User runningAsMarketing = createMarketingUser(); // running as marketing

        System.runAs(runningAsMarketing){
            Request_for_Proposal__c rfpRec = [SELECT Id, Request_for_Proposal_Status__c FROM Request_for_Proposal__c WHERE Request_for_Proposal_Status__c = 'Request Assign' AND Product__c = '2'];
            System.debug('--rfpRec: '+ rfpRec);

            Test.startTest();
            try {
                rfpRec.Request_for_Proposal_Status__c = 'Completed';
                update rfpRec;
    
                // If the insert succeeds, that means the test failed as it should have thrown an error
                System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
            } catch (DmlException e) {
                // Check that the exception message contains the expected error message
                System.assert(e.getDmlMessage(0).contains('Only System Admin can move stage from Assigned to Completed!'), 'Unexpected error message: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void updateRFPFromAssignedtoInRevision(){   
        User runningAsMarketing = createMarketingUser(); // running as marketing

        System.runAs(runningAsMarketing){
            Request_for_Proposal__c rfpRec = [SELECT Id, Request_for_Proposal_Status__c FROM Request_for_Proposal__c WHERE Request_for_Proposal_Status__c = 'Request Assign' AND Product__c = '2'];
            System.debug('--rfpRec: '+ rfpRec);

            Test.startTest();
            try {
                rfpRec.Request_for_Proposal_Status__c = 'In_Revision';
                update rfpRec;
    
                // If the insert succeeds, that means the test failed as it should have thrown an error
                System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
            } catch (DmlException e) {
                // Check that the exception message contains the expected error message
                System.assert(e.getDmlMessage(0).contains('Only System Admin can move stage from Request Assign to In Revision!'), 'Unexpected error message: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void updateRFPFromAssignedtoAskRevision(){   
        User runningAsMarketing = createMarketingUser(); // running as marketing

        System.runAs(runningAsMarketing){ 
            Request_for_Proposal__c rfpRec = [SELECT Id FROM Request_for_Proposal__c WHERE Request_for_Proposal_Status__c = 'Request Assign' AND Product__c = '2'];
            System.debug('--rfpRec: '+ rfpRec);

            Test.startTest();
            try {
                rfpRec.Request_for_Proposal_Status__c = 'Ask Revision';
                update rfpRec;
    
                // If the insert succeeds, that means the test failed as it should have thrown an error
                System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
            } catch (DmlException e) {
                // Check that the exception message contains the expected error message
                System.assert(e.getDmlMessage(0).contains('Only System Admin can move stage from Request Assign to Ask Revision!'), 'Unexpected error message: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void updateRFPFromAssignedtoSendProposal(){   
        User runningAsMarketing = createMarketingUser(); // running as marketing

        System.runAs(runningAsMarketing){
            Request_for_Proposal__c rfpRec = [SELECT Id FROM Request_for_Proposal__c WHERE Request_for_Proposal_Status__c = 'Request Assign' AND Product__c = '2'];
            System.debug('--rfpRec: '+ rfpRec);

            Test.startTest();
            try {
                rfpRec.Request_for_Proposal_Status__c = 'Send Proposal';
                update rfpRec;
    
                // If the insert succeeds, that means the test failed as it should have thrown an error
                System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
            } catch (DmlException e) {
                // Check that the exception message contains the expected error message
                System.assert(e.getDmlMessage(0).contains('Only System Admin can move stage to Send Proposal!'), 'Unexpected error message: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void updateRFPFromAssignedtoClosed(){   
        User runningAsMarketing = createMarketingUser(); // running as marketing

        System.runAs(runningAsMarketing){
            Request_for_Proposal__c rfpRec = [SELECT Id FROM Request_for_Proposal__c WHERE Request_for_Proposal_Status__c = 'Request Assign' AND Product__c = '2'];
            System.debug('--rfpRec: '+ rfpRec);

            Test.startTest();
            try {
                rfpRec.Request_for_Proposal_Status__c = 'Closed';
                update rfpRec;
    
                // If the insert succeeds, that means the test failed as it should have thrown an error
                System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
            } catch (DmlException e) {
                // Check that the exception message contains the expected error message
                System.assert(e.getDmlMessage(0).contains('Only System Admin can move stage to Closed!'), 'Unexpected error message: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void updateRFPFromProgresstoAskRevision(){
        User runningAsMarketing = createMarketingUser(); // running as marketing

        System.runAs(runningAsMarketing){
            Request_for_Proposal__c rfpRec = [SELECT Id, Request_for_Proposal_Status__c FROM Request_for_Proposal__c WHERE Request_for_Proposal_Status__c = 'Progress' AND Product__c = '3'];

            Test.startTest();
            try {
                rfpRec.Request_for_Proposal_Status__c = 'Ask Revision';
                update rfpRec;
    
                // If the insert succeeds, that means the test failed as it should have thrown an error
                System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
            } catch (DmlException e) {
                // Check that the exception message contains the expected error message
                System.assert(e.getDmlMessage(0).contains('Only System Admin can move stage from Progress to Ask Revision!'), 'Unexpected error message: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void updateRFPFromAskRevisiontoCompleted(){
        User runningAsMarketing = createMarketingUser(); // running as marketing

        System.runAs(runningAsMarketing){
            Request_for_Proposal__c rfpRec = [SELECT Id, Request_for_Proposal_Status__c FROM Request_for_Proposal__c WHERE Request_for_Proposal_Status__c = 'Ask Revision' AND Product__c = '4'];

            Test.startTest();
            try {
                rfpRec.Request_for_Proposal_Status__c = 'Completed';
                update rfpRec;
    
                // If the insert succeeds, that means the test failed as it should have thrown an error
                System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
            } catch (DmlException e) {
                // Check that the exception message contains the expected error message
                System.assert(e.getDmlMessage(0).contains('Only System Admin can move stage from Ask Revision to Completed!'), 'Unexpected error message: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void updateRFPFromCompletedtoAssigned(){
        User runningAsMarketing = createMarketingUser(); // running as marketing
        Id recordTypeRfpId = Schema.SObjectType.Request_for_Proposal__c.getRecordTypeInfosByName().get('Direct Sales Proposal').getRecordTypeId();

        System.runAs(runningAsMarketing){
            Opportunity oppRec = [SELECT Id, OwnerId FROM Opportunity WHERE StageName = 'Request for Proposal'];
            Contact conRec = [SELECT Id FROM Contact WHERE Email = 'test@gmail.com'];
            Date endDate = Date.today().addDays(15);
            
            // rfp completed
            Request_for_Proposal__c rfpRec5 = new Request_for_Proposal__c(
                Opportunity_Name__c = oppRec.Id,
                Request_for_Proposal_Status__c = 'Progress',
                Date__c = Date.today(),
                Product__c = '5',
                Buying_Method__c = 'I/O Based',
                PIC_Client__c = conRec.Id,
                Deadline__c = endDate,
                Project__c = '1',
                Background__c = '1',
                Campaign_Objective__c = '1',
                KPI__c = '1',
                Key_Message__c = '1',
                Start_Period__c = Date.today(),
                End_Period__c = endDate,
                Target_Audiance__c = '1',
                Campaign_Investment__c = 1,
                Campaign_Media_Preferred_Inventory__c = '1',
                Opportunity_Owner__c = oppRec.OwnerId,
                RecordTypeId = recordTypeRfpId,
                OwnerId = runningAsMarketing.Id
            );
            MetadataTriggerHandler.bypass('TA_VR_RFP_BU_OwnerValidation');
            insert rfpRec5;
            MetadataTriggerHandler.clearBypass('TA_VR_RFP_BU_OwnerValidation');

            rfpRec5.Request_for_Proposal_Status__c = 'Completed';
            update rfpRec5;

            Test.startTest();
            try {
                rfpRec5.Request_for_Proposal_Status__c = 'Request Assign';
                update rfpRec5;
    
                // If the insert succeeds, that means the test failed as it should have thrown an error
                System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
            } catch (DmlException e) {
                // Check that the exception message contains the expected error message
                System.assert(e.getDmlMessage(0).contains('Only System Admin can move stage from Completed to Assigned!'), 'Unexpected error message: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void updateRFPFromCompletedtoProgress(){
        User runningAsMarketing = createMarketingUser(); // running as marketing
        Id recordTypeRfpId = Schema.SObjectType.Request_for_Proposal__c.getRecordTypeInfosByName().get('Direct Sales Proposal').getRecordTypeId();

        System.runAs(runningAsMarketing){
            Opportunity oppRec = [SELECT Id, OwnerId FROM Opportunity WHERE StageName = 'Request for Proposal'];
            Contact conRec = [SELECT Id FROM Contact WHERE Email = 'test@gmail.com'];
            Date endDate = Date.today().addDays(15);
            
            // rfp completed
            Request_for_Proposal__c rfpRec5 = new Request_for_Proposal__c(
                Opportunity_Name__c = oppRec.Id,
                Request_for_Proposal_Status__c = 'Progress',
                Date__c = Date.today(),
                Product__c = '5',
                Buying_Method__c = 'I/O Based',
                PIC_Client__c = conRec.Id,
                Deadline__c = endDate,
                Project__c = '1',
                Background__c = '1',
                Campaign_Objective__c = '1',
                KPI__c = '1',
                Key_Message__c = '1',
                Start_Period__c = Date.today(),
                End_Period__c = endDate,
                Target_Audiance__c = '1',
                Campaign_Investment__c = 1,
                Campaign_Media_Preferred_Inventory__c = '1',
                Opportunity_Owner__c = oppRec.OwnerId,
                RecordTypeId = recordTypeRfpId,
                OwnerId = runningAsMarketing.Id
            );
            MetadataTriggerHandler.bypass('TA_VR_RFP_BU_OwnerValidation');
            insert rfpRec5;
            MetadataTriggerHandler.clearBypass('TA_VR_RFP_BU_OwnerValidation');

            rfpRec5.Request_for_Proposal_Status__c = 'Completed';
            update rfpRec5;

            Test.startTest();
            try {
                rfpRec5.Request_for_Proposal_Status__c = 'Progress';
                update rfpRec5;
    
                // If the insert succeeds, that means the test failed as it should have thrown an error
                System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
            } catch (DmlException e) {
                // Check that the exception message contains the expected error message
                System.assert(e.getDmlMessage(0).contains('Only System Admin can move stage from Completed to Progress!'), 'Unexpected error message: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void updateRFPFromAskRevisiontoProgress(){
        User runningAsMarketing = createMarketingUser(); // running as marketing

        System.runAs(runningAsMarketing){
            Request_for_Proposal__c rfpRec = [SELECT Id, Request_for_Proposal_Status__c FROM Request_for_Proposal__c WHERE Request_for_Proposal_Status__c = 'Ask Revision' AND Product__c = '4'];

            Test.startTest();
            try {
                rfpRec.Request_for_Proposal_Status__c = 'Progress';
                update rfpRec;
    
                // If the insert succeeds, that means the test failed as it should have thrown an error
                System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
            } catch (DmlException e) {
                // Check that the exception message contains the expected error message
                System.assert(e.getDmlMessage(0).contains('Only System Admin can move stage from Ask Revision to Progress!'), 'Unexpected error message: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void updateRFPFromInRevisiontoAskRevision(){
        User runningAsMarketing = createMarketingUser(); // running as marketing

        System.runAs(runningAsMarketing){
            Request_for_Proposal__c rfpRec = [SELECT Id, Request_for_Proposal_Status__c FROM Request_for_Proposal__c WHERE Request_for_Proposal_Status__c = 'In_Revision' AND Product__c = '5'];

            Test.startTest();
            try {
                rfpRec.Request_for_Proposal_Status__c = 'Ask Revision';
                update rfpRec;
    
                // If the insert succeeds, that means the test failed as it should have thrown an error
                System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
            } catch (DmlException e) {
                // Check that the exception message contains the expected error message
                System.assert(e.getDmlMessage(0).contains('Only System Admin can move stage from In_Revision to Ask Revision!'), 'Unexpected error message: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void updateRFPToOtherStageFromSendProposal(){
        User runningAsMarketing = createMarketingUser(); // running as marketing
        Id recordTypeRfpId = Schema.SObjectType.Request_for_Proposal__c.getRecordTypeInfosByName().get('Direct Sales Proposal').getRecordTypeId();

        System.runAs(runningAsMarketing){
            Opportunity oppRec = [SELECT Id, OwnerId FROM Opportunity WHERE StageName = 'Request for Proposal'];
            Contact conRec = [SELECT Id FROM Contact WHERE Email = 'test@gmail.com'];
            Date endDate = Date.today().addDays(15);
            
            // rfp completed
            Request_for_Proposal__c rfpRec5 = new Request_for_Proposal__c(
                Opportunity_Name__c = oppRec.Id,
                Request_for_Proposal_Status__c = 'Send Proposal',
                Date__c = Date.today(),
                Product__c = '5',
                Buying_Method__c = 'I/O Based',
                PIC_Client__c = conRec.Id,
                Deadline__c = endDate,
                Project__c = '1',
                Background__c = '1',
                Campaign_Objective__c = '1',
                KPI__c = '1',
                Key_Message__c = '1',
                Start_Period__c = Date.today(),
                End_Period__c = endDate,
                Target_Audiance__c = '1',
                Campaign_Investment__c = 1,
                Campaign_Media_Preferred_Inventory__c = '1',
                Opportunity_Owner__c = oppRec.OwnerId,
                RecordTypeId = recordTypeRfpId,
                OwnerId = runningAsMarketing.Id
            );
            MetadataTriggerHandler.bypass('TA_VR_RFP_BU_OwnerValidation');
            insert rfpRec5;
            MetadataTriggerHandler.clearBypass('TA_VR_RFP_BU_OwnerValidation');

            Test.startTest();
            try {
                rfpRec5.Request_for_Proposal_Status__c = 'Completed';
                update rfpRec5;
    
                // If the insert succeeds, that means the test failed as it should have thrown an error
                System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
            } catch (DmlException e) {
                // Check that the exception message contains the expected error message
                System.assert(e.getDmlMessage(0).contains('Only System Admin can move stage from Send Proposal to other Stage!'), 'Unexpected error message: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void updateRFPToOtherStageFromClosed(){
        User runningAsMarketing = createMarketingUser(); // running as marketing
        Id recordTypeRfpId = Schema.SObjectType.Request_for_Proposal__c.getRecordTypeInfosByName().get('Direct Sales Proposal').getRecordTypeId();

        System.runAs(runningAsMarketing){
            Opportunity oppRec = [SELECT Id, OwnerId FROM Opportunity WHERE StageName = 'Request for Proposal'];
            Contact conRec = [SELECT Id FROM Contact WHERE Email = 'test@gmail.com'];
            Date endDate = Date.today().addDays(15);
            
            // rfp completed
            Request_for_Proposal__c rfpRec5 = new Request_for_Proposal__c(
                Opportunity_Name__c = oppRec.Id,
                Request_for_Proposal_Status__c = 'Closed',
                Date__c = Date.today(),
                Product__c = '5',
                Buying_Method__c = 'I/O Based',
                PIC_Client__c = conRec.Id,
                Deadline__c = endDate,
                Project__c = '1',
                Background__c = '1',
                Campaign_Objective__c = '1',
                KPI__c = '1',
                Key_Message__c = '1',
                Start_Period__c = Date.today(),
                End_Period__c = endDate,
                Target_Audiance__c = '1',
                Campaign_Investment__c = 1,
                Campaign_Media_Preferred_Inventory__c = '1',
                Opportunity_Owner__c = oppRec.OwnerId,
                RecordTypeId = recordTypeRfpId,
                OwnerId = runningAsMarketing.Id
            );
            MetadataTriggerHandler.bypass('TA_VR_RFP_BU_OwnerValidation');
            insert rfpRec5;
            MetadataTriggerHandler.clearBypass('TA_VR_RFP_BU_OwnerValidation');

            Test.startTest();
            try {
                rfpRec5.Request_for_Proposal_Status__c = 'Completed';
                update rfpRec5;
    
                // If the insert succeeds, that means the test failed as it should have thrown an error
                System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
            } catch (DmlException e) {
                // Check that the exception message contains the expected error message
                System.assert(e.getDmlMessage(0).contains('Only System Admin can move stage from Closed to other Stage!'), 'Unexpected error message: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void updateRFPinStatusSendProposal(){
        User runningAsMarketing = createMarketingUser(); // running as marketing
        Id recordTypeRfpId = Schema.SObjectType.Request_for_Proposal__c.getRecordTypeInfosByName().get('Direct Sales Proposal').getRecordTypeId();
        
        System.runAs(runningAsMarketing){
            Opportunity oppRec = [SELECT Id, OwnerId FROM Opportunity WHERE StageName = 'Request for Proposal'];
            Contact conRec = [SELECT Id FROM Contact WHERE Email = 'test@gmail.com'];
            Date endDate = Date.today().addDays(15);
            
            // rfp completed
            Request_for_Proposal__c rfpRec5 = new Request_for_Proposal__c(
                Opportunity_Name__c = oppRec.Id,
                Request_for_Proposal_Status__c = 'Send Proposal',
                Date__c = Date.today(),
                Product__c = '5',
                Buying_Method__c = 'I/O Based',
                PIC_Client__c = conRec.Id,
                Deadline__c = endDate,
                Project__c = '1',
                Background__c = '1',
                Campaign_Objective__c = '1',
                KPI__c = '1',
                Key_Message__c = '1',
                Start_Period__c = Date.today(),
                End_Period__c = endDate,
                Target_Audiance__c = '1',
                Campaign_Investment__c = 1,
                Campaign_Media_Preferred_Inventory__c = '1',
                Opportunity_Owner__c = oppRec.OwnerId,
                RecordTypeId = recordTypeRfpId,
                OwnerId = oppRec.OwnerId
            );
            MetadataTriggerHandler.bypass('TA_VR_RFP_BU_OwnerValidation');
            insert rfpRec5;
            MetadataTriggerHandler.clearBypass('TA_VR_RFP_BU_OwnerValidation');
    
            Test.startTest();
            try {
                rfpRec5.Product__c = '1';
                update rfpRec5;
    
                // If the insert succeeds, that means the test failed as it should have thrown an error
                System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
            } catch (DmlException e) {
                // Check that the exception message contains the expected error message
                System.assert(e.getDmlMessage(0).contains('Only System Admin can Edit at stage Send Proposal!'), 'Unexpected error message: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void updateRFPinStatusClosed(){
        User runningAsMarketing = createMarketingUser(); // running as marketing
        Id recordTypeRfpId = Schema.SObjectType.Request_for_Proposal__c.getRecordTypeInfosByName().get('Direct Sales Proposal').getRecordTypeId();
        
        System.runAs(runningAsMarketing){
            Opportunity oppRec = [SELECT Id, OwnerId FROM Opportunity WHERE StageName = 'Request for Proposal'];
            Contact conRec = [SELECT Id FROM Contact WHERE Email = 'test@gmail.com'];
            Date endDate = Date.today().addDays(15);
            
            // rfp completed
            Request_for_Proposal__c rfpRec5 = new Request_for_Proposal__c(
                Opportunity_Name__c = oppRec.Id,
                Request_for_Proposal_Status__c = 'Closed',
                Date__c = Date.today(),
                Product__c = '5',
                Buying_Method__c = 'I/O Based',
                PIC_Client__c = conRec.Id,
                Deadline__c = endDate,
                Project__c = '1',
                Background__c = '1',
                Campaign_Objective__c = '1',
                KPI__c = '1',
                Key_Message__c = '1',
                Start_Period__c = Date.today(),
                End_Period__c = endDate,
                Target_Audiance__c = '1',
                Campaign_Investment__c = 1,
                Campaign_Media_Preferred_Inventory__c = '1',
                Opportunity_Owner__c = oppRec.OwnerId,
                RecordTypeId = recordTypeRfpId,
                OwnerId = oppRec.OwnerId
            );
            MetadataTriggerHandler.bypass('TA_VR_RFP_BU_OwnerValidation');
            insert rfpRec5;
            MetadataTriggerHandler.clearBypass('TA_VR_RFP_BU_OwnerValidation');
    
            Test.startTest();
            try {
                rfpRec5.Product__c = '1';
                update rfpRec5;
    
                // If the insert succeeds, that means the test failed as it should have thrown an error
                System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
            } catch (DmlException e) {
                // Check that the exception message contains the expected error message
                System.assert(e.getDmlMessage(0).contains('Only System Admin can Edit at stage Closed!'), 'Unexpected error message: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }


    // ===== VALIDATION USER NOT EQUALS "SALES" =====
    @isTest
    static void updateRFPFromCompletedtoAskRevision(){
        User runningAsMarketing = createMarketingUser(); // running as marketing
        Id recordTypeRfpId = Schema.SObjectType.Request_for_Proposal__c.getRecordTypeInfosByName().get('Direct Sales Proposal').getRecordTypeId();

        System.runAs(runningAsMarketing){
            Opportunity oppRec = [SELECT Id, OwnerId FROM Opportunity WHERE StageName = 'Request for Proposal'];
            Contact conRec = [SELECT Id FROM Contact WHERE Email = 'test@gmail.com'];
            Date endDate = Date.today().addDays(15);
            
            // rfp completed
            Request_for_Proposal__c rfpRec5 = new Request_for_Proposal__c(
                Opportunity_Name__c = oppRec.Id,
                Request_for_Proposal_Status__c = 'Completed',
                Date__c = Date.today(),
                Product__c = '5',
                Buying_Method__c = 'I/O Based',
                PIC_Client__c = conRec.Id,
                Deadline__c = endDate,
                Project__c = '1',
                Background__c = '1',
                Campaign_Objective__c = '1',
                KPI__c = '1',
                Key_Message__c = '1',
                Start_Period__c = Date.today(),
                End_Period__c = endDate,
                Target_Audiance__c = '1',
                Campaign_Investment__c = 1,
                Campaign_Media_Preferred_Inventory__c = '1',
                Opportunity_Owner__c = oppRec.OwnerId,
                RecordTypeId = recordTypeRfpId,
                OwnerId = runningAsMarketing.Id
            );
            MetadataTriggerHandler.bypass('TA_VR_RFP_BU_OwnerValidation');
            insert rfpRec5;
            MetadataTriggerHandler.clearBypass('TA_VR_RFP_BU_OwnerValidation');

            Test.startTest();
            try {
                rfpRec5.Request_for_Proposal_Status__c = 'Ask Revision';
                update rfpRec5;
    
                // If the insert succeeds, that means the test failed as it should have thrown an error
                System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
            } catch (DmlException e) {
                // Check that the exception message contains the expected error message
                System.assert(e.getDmlMessage(0).contains('Only Sales can move stage from Completed to Ask Revision!'), 'Unexpected error message: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void updateRFPFromAskRevisiontoInRevision(){
        User runningAsMarketing = createMarketingUser(); // running as marketing

        System.runAs(runningAsMarketing){
            Request_for_Proposal__c rfpRec = [SELECT Id, Request_for_Proposal_Status__c FROM Request_for_Proposal__c WHERE Request_for_Proposal_Status__c = 'Ask Revision' AND Product__c = '4'];

            Test.startTest();
            try {
                rfpRec.Request_for_Proposal_Status__c = 'In_Revision';
                update rfpRec;
    
                // If the insert succeeds, that means the test failed as it should have thrown an error
                System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
            } catch (DmlException e) {
                // Check that the exception message contains the expected error message
                System.assert(e.getDmlMessage(0).contains('Only Sales can move stage from Ask Revision to In Revision!'), 'Unexpected error message: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    @isTest
    static void updateRFPinStatusCompleted(){
        Id recordTypeRfpId = Schema.SObjectType.Request_for_Proposal__c.getRecordTypeInfosByName().get('Direct Sales Proposal').getRecordTypeId();
        Opportunity oppRec = [SELECT Id, OwnerId FROM Opportunity WHERE StageName = 'Request for Proposal'];
        Contact conRec = [SELECT Id FROM Contact WHERE Email = 'test@gmail.com'];
        Date endDate = Date.today().addDays(15);
        
        // rfp completed
        Request_for_Proposal__c rfpRec5 = new Request_for_Proposal__c(
            Opportunity_Name__c = oppRec.Id,
            Request_for_Proposal_Status__c = 'Completed',
            Date__c = Date.today(),
            Product__c = '5',
            Buying_Method__c = 'I/O Based',
            PIC_Client__c = conRec.Id,
            Deadline__c = endDate,
            Project__c = '1',
            Background__c = '1',
            Campaign_Objective__c = '1',
            KPI__c = '1',
            Key_Message__c = '1',
            Start_Period__c = Date.today(),
            End_Period__c = endDate,
            Target_Audiance__c = '1',
            Campaign_Investment__c = 1,
            Campaign_Media_Preferred_Inventory__c = '1',
            Opportunity_Owner__c = oppRec.OwnerId,
            RecordTypeId = recordTypeRfpId,
            OwnerId = oppRec.OwnerId
        );
        MetadataTriggerHandler.bypass('TA_VR_RFP_BU_OwnerValidation');
        insert rfpRec5;
        MetadataTriggerHandler.clearBypass('TA_VR_RFP_BU_OwnerValidation');

        Test.startTest();
        try {
            rfpRec5.Product__c = '1';
            update rfpRec5;

            // If the insert succeeds, that means the test failed as it should have thrown an error
            System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
        } catch (DmlException e) {
            // Check that the exception message contains the expected error message
            System.assert(e.getDmlMessage(0).contains('Only Sales can Edit at stage Completed!'), 'Unexpected error message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void updateRFPinStatusAskRevision(){
        Id recordTypeRfpId = Schema.SObjectType.Request_for_Proposal__c.getRecordTypeInfosByName().get('Direct Sales Proposal').getRecordTypeId();
        Opportunity oppRec = [SELECT Id, OwnerId FROM Opportunity WHERE StageName = 'Request for Proposal'];
        Contact conRec = [SELECT Id FROM Contact WHERE Email = 'test@gmail.com'];
        Date endDate = Date.today().addDays(15);
        
        // rfp completed
        Request_for_Proposal__c rfpRec5 = new Request_for_Proposal__c(
            Opportunity_Name__c = oppRec.Id,
            Request_for_Proposal_Status__c = 'Ask Revision',
            Date__c = Date.today(),
            Product__c = '5',
            Buying_Method__c = 'I/O Based',
            PIC_Client__c = conRec.Id,
            Deadline__c = endDate,
            Project__c = '1',
            Background__c = '1',
            Campaign_Objective__c = '1',
            KPI__c = '1',
            Key_Message__c = '1',
            Start_Period__c = Date.today(),
            End_Period__c = endDate,
            Target_Audiance__c = '1',
            Campaign_Investment__c = 1,
            Campaign_Media_Preferred_Inventory__c = '1',
            Opportunity_Owner__c = oppRec.OwnerId,
            RecordTypeId = recordTypeRfpId,
            OwnerId = oppRec.OwnerId
        );
        MetadataTriggerHandler.bypass('TA_VR_RFP_BU_OwnerValidation');
        insert rfpRec5;
        MetadataTriggerHandler.clearBypass('TA_VR_RFP_BU_OwnerValidation');

        Test.startTest();
        try {
            rfpRec5.Product__c = '1';
            update rfpRec5;

            // If the insert succeeds, that means the test failed as it should have thrown an error
            System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
        } catch (DmlException e) {
            // Check that the exception message contains the expected error message
            System.assert(e.getDmlMessage(0).contains('Only Sales can Edit at stage Ask Revision!'), 'Unexpected error message: ' + e.getMessage());
        }
        Test.stopTest();
    }


    // ===== VALIDATION USER NOT EQUALS "MARKETING" =====
    @isTest
    static void updateRFPFromAssignedToProgress(){
        Request_for_Proposal__c rfpRec = [SELECT Id, Request_for_Proposal_Status__c FROM Request_for_Proposal__c WHERE Request_for_Proposal_Status__c = 'Request Assign' AND Product__c = '2'];

        Test.startTest();
        try {
            rfpRec.Request_for_Proposal_Status__c = 'Progress';
            update rfpRec;

            // If the insert succeeds, that means the test failed as it should have thrown an error
            System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
        } catch (DmlException e) {
            // Check that the exception message contains the expected error message
            System.assert(e.getDmlMessage(0).contains('Only Marketing can move stage from Assigned to Progress!'), 'Unexpected error message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void updateRFPFromProgresstoCompleted(){
        Request_for_Proposal__c rfpRec = [SELECT Id, Request_for_Proposal_Status__c FROM Request_for_Proposal__c WHERE Request_for_Proposal_Status__c = 'Progress' AND Product__c = '3'];

        Test.startTest();
        try {
            rfpRec.Request_for_Proposal_Status__c = 'Completed';
            update rfpRec;

            // If the insert succeeds, that means the test failed as it should have thrown an error
            System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
        } catch (DmlException e) {
            // Check that the exception message contains the expected error message
            System.assert(e.getDmlMessage(0).contains('Only Marketing can move stage from Progress to Completed!'), 'Unexpected error message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void updateRFPFromInRevisiontoCompleted(){
        Request_for_Proposal__c rfpRec = [SELECT Id, Request_for_Proposal_Status__c FROM Request_for_Proposal__c WHERE Request_for_Proposal_Status__c = 'In_Revision' AND Product__c = '5'];

        Test.startTest();
        try {
            rfpRec.Request_for_Proposal_Status__c = 'Completed';
            update rfpRec;

            // If the insert succeeds, that means the test failed as it should have thrown an error
            System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
        } catch (DmlException e) {
            // Check that the exception message contains the expected error message
            System.assert(e.getDmlMessage(0).contains('Only Marketing can move stage from In Revision to Completed!'), 'Unexpected error message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void updateRFPFromAskRevisiontoAssigned(){
        Request_for_Proposal__c rfpRec = [SELECT Id, Request_for_Proposal_Status__c FROM Request_for_Proposal__c WHERE Request_for_Proposal_Status__c = 'Ask Revision' AND Product__c = '4'];

        Test.startTest();
        try {
            rfpRec.Request_for_Proposal_Status__c = 'Request Assign';
            update rfpRec;

            // If the insert succeeds, that means the test failed as it should have thrown an error
            System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
        } catch (DmlException e) {
            // Check that the exception message contains the expected error message
            System.assert(e.getDmlMessage(0).contains('Only Marketing can move stage from In Ask Revision to Assigned!'), 'Unexpected error message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void updateRFPinStatusAssigned(){
        Request_for_Proposal__c rfpRec = [SELECT Id, Product__c FROM Request_for_Proposal__c WHERE Request_for_Proposal_Status__c = 'Request Assign' AND Product__c = '2'];

        Test.startTest();
        try {
            rfpRec.Product__c = '1';
            update rfpRec;

            // If the insert succeeds, that means the test failed as it should have thrown an error
            System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
        } catch (DmlException e) {
            // Check that the exception message contains the expected error message
            System.assert(e.getDmlMessage(0).contains('Only Marketing can Edit at stage Assigned!'), 'Unexpected error message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void updateRFPinStatusProgress(){
        Id recordTypeRfpId = Schema.SObjectType.Request_for_Proposal__c.getRecordTypeInfosByName().get('Direct Sales Proposal').getRecordTypeId();
        Opportunity oppRec = [SELECT Id, OwnerId FROM Opportunity WHERE StageName = 'Request for Proposal'];
        Contact conRec = [SELECT Id FROM Contact WHERE Email = 'test@gmail.com'];
        Date endDate = Date.today().addDays(15);
        
        // rfp completed
        Request_for_Proposal__c rfpRec5 = new Request_for_Proposal__c(
            Opportunity_Name__c = oppRec.Id,
            Request_for_Proposal_Status__c = 'Progress',
            Date__c = Date.today(),
            Product__c = '5',
            Buying_Method__c = 'I/O Based',
            PIC_Client__c = conRec.Id,
            Deadline__c = endDate,
            Project__c = '1',
            Background__c = '1',
            Campaign_Objective__c = '1',
            KPI__c = '1',
            Key_Message__c = '1',
            Start_Period__c = Date.today(),
            End_Period__c = endDate,
            Target_Audiance__c = '1',
            Campaign_Investment__c = 1,
            Campaign_Media_Preferred_Inventory__c = '1',
            Opportunity_Owner__c = oppRec.OwnerId,
            RecordTypeId = recordTypeRfpId,
            OwnerId = oppRec.OwnerId
        );
        MetadataTriggerHandler.bypass('TA_VR_RFP_BU_OwnerValidation');
        insert rfpRec5;
        MetadataTriggerHandler.clearBypass('TA_VR_RFP_BU_OwnerValidation');

        Test.startTest();
        try {
            rfpRec5.Product__c = '1';
            update rfpRec5;

            // If the insert succeeds, that means the test failed as it should have thrown an error
            System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
        } catch (DmlException e) {
            // Check that the exception message contains the expected error message
            System.assert(e.getDmlMessage(0).contains('Only Marketing can Edit at stage Progress!'), 'Unexpected error message: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void updateRFPinStatusInRevision(){
        Id recordTypeRfpId = Schema.SObjectType.Request_for_Proposal__c.getRecordTypeInfosByName().get('Direct Sales Proposal').getRecordTypeId();
        Opportunity oppRec = [SELECT Id, OwnerId FROM Opportunity WHERE StageName = 'Request for Proposal'];
        Contact conRec = [SELECT Id FROM Contact WHERE Email = 'test@gmail.com'];
        Date endDate = Date.today().addDays(15);
        
        // rfp completed
        Request_for_Proposal__c rfpRec5 = new Request_for_Proposal__c(
            Opportunity_Name__c = oppRec.Id,
            Request_for_Proposal_Status__c = 'In_Revision',
            Date__c = Date.today(),
            Product__c = '5',
            Buying_Method__c = 'I/O Based',
            PIC_Client__c = conRec.Id,
            Deadline__c = endDate,
            Project__c = '1',
            Background__c = '1',
            Campaign_Objective__c = '1',
            KPI__c = '1',
            Key_Message__c = '1',
            Start_Period__c = Date.today(),
            End_Period__c = endDate,
            Target_Audiance__c = '1',
            Campaign_Investment__c = 1,
            Campaign_Media_Preferred_Inventory__c = '1',
            Opportunity_Owner__c = oppRec.OwnerId,
            RecordTypeId = recordTypeRfpId,
            OwnerId = oppRec.OwnerId
        );
        MetadataTriggerHandler.bypass('TA_VR_RFP_BU_OwnerValidation');
        insert rfpRec5;
        MetadataTriggerHandler.clearBypass('TA_VR_RFP_BU_OwnerValidation');

        Test.startTest();
        try {
            rfpRec5.Product__c = '1';
            update rfpRec5;

            // If the insert succeeds, that means the test failed as it should have thrown an error
            System.assert(false, 'Expected an exception to be thrown due to duplicate channel insertion.');
        } catch (DmlException e) {
            // Check that the exception message contains the expected error message
            System.assert(e.getDmlMessage(0).contains('Only Marketing can Edit at stage In Revision!'), 'Unexpected error message: ' + e.getMessage());
        }
        Test.stopTest();
    }
}