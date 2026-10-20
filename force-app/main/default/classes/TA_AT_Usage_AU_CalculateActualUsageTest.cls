/**
 * @description       : Deactive flow "Opportunity_TRG_BU_ValidationClosedWon" when running test class or deploy
 * @author            : Syaiful Syafani
 * @group             :
 * @last modified on  : 10/12/2024
 * @last modified by  : Syaiful Syafani
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   09/12/2024   Syaiful Syafani   Initial Version
 **/
@IsTest
public with sharing class TA_AT_Usage_AU_CalculateActualUsageTest {
    private static User createUser() {
        Profile proRec = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1
        ];

        UserRole roleRec = [
            SELECT Id, Name, PortalRole
            FROM UserRole
            WHERE Name = 'SALES DA'
            LIMIT 1
        ];

        User userRec = new User(
            FirstName = 'Admin',
            LastName = 'TV Ads',
            NIK__c = '444999',
            Username = 'admintv@digiads.com.invalid',
            Alias = 'AdmTV',
            EmailEncodingKey = 'UTF-8',
            Email = 'admintv@digiads.com.invalid',
            ProfileId = proRec.Id,
            UserRoleId = roleRec.Id,
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert userRec;
        return userRec;
    }

    @TestSetup
    static void makeData() {
        User testUser = createUser();

        System.runAs(testUser) {
            Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                .get('Agency')
                .getRecordTypeId();
            Account accRec = new Account(
                Name = 'Wira Pamungkas Pratama #2', // Account Name
                RecordTypeId = recordTypeAccId, // Account Record Type
                Account_Type__c = 'Agency', // Account Type
                Direct_Indirect__c = 'Direct', // Direct/Indirect
                Status__c = 'Approved by Settlement', // Status
                No_PKS__c = '123456', // No PKS
                NPWP__c = '1234567890123456', // NPWP
                NPWP_Address__c = 'Jakarta',
                PKS_Tracker__c = 'Pending',
                Reason_by_Settlement__c = 'reason'
            );
            insert accRec;

            Contact contactRec = new Contact(
                AccountId = accRec.id, // Account Name
                Title = 'Planner', // Title
                Email = 'test@gmail.com', // Email
                Phone = '231313123123', // Phone
                LastName = 'user1',
                MobilePhone = '231313123123', // Mobile
                Active__c = true, // Active?
                Priority__c = 'Priority 1', // Priority
                Converted_from_Lead__c = false // Converted from Lead
            );
            insert contactRec;

            Contract contractRec = new Contract(
                StartDate = Date.valueOf('2019-09-01'), // Contract Start Date
                ContractTerm = 9999, // Contract Term (months)
                AccountId = accRec.Id,
                OwnerExpirationNotice = '120', // Owner Expiration Notice
                Status = 'Draft', // Status
                Terminate__c = false, // Terminate
                Archive__c = false, // Archive
                No_PKS__c = '123456', // No.PKS
                Contract_Signed__c = 'Circulation' // Contract Signed ?
            );
            insert contractRec;

            //update contract status
            contractRec.Status = 'Activated';
            update contractRec;

            Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
                .get('Agency Postpaid')
                .getRecordTypeId();

            accRec.ContractId__c = contractRec.Id;
            update accRec;

            IPTV_Channel__c IPTVChannelRec = new IPTV_Channel__c(
                Name = 'AllPlay.ent',
                Product_Inventory__c = 'TVC PLATINUM',
                Keyword__c = 'PLATINUM JAYA'
            );
            insert IPTVChannelRec;

            IPTV_Inventory__c IPTVInventoryRec = new IPTV_Inventory__c(
                Name = 'TEST Duplicate',
                IPTV_Channels__c = IPTVChannelRec.Id,
                Show_Time__c = 'PRIME TIME',
                Time__c = '17.00 - 24.00',
                keyword__c = 'all',
                OwnerId = testUser.Id,
                Product_Inventory__c = 'TVC PLATINUM',
                Inventories__c = 'TVC PLATINUM'
            );
            insert IPTVInventoryRec;

            IPTV_Spot_Limit__c IPTVSpotLimitRec = new IPTV_Spot_Limit__c(
                Name = 'SL / AllPlay.ent / REGULAR TIME / 1-31/1/2024',
                IPTV_Inventory__c = IPTVInventoryRec.Id,
                is_Active__c = true,
                Spot_Limit__c = 4320,
                Start_Date__c = system.today(),
                End_Date__c = system.today()
            );
            insert IPTVSpotLimitRec;

            IPTV_Spot_Daily_Status__c IPTVSportDailyStatusRec = new IPTV_Spot_Daily_Status__c(
                Name = 'SDS / AllPlay.ent / REGULAR TIME / 2024 - 1 - 1',
                Date__c = system.today(),
                IPTV_Spot_Limit__c = IPTVSpotLimitRec.Id,
                Inventory_Name__c = IPTVInventoryRec.Id
            );
            insert IPTVSportDailyStatusRec;

            Id pricebookId = Test.getStandardPricebookId();

            Product2 productRec = new Product2(
                Name = 'TVC PLATINUM (Prime) 15" CNN Indonesia', // Product Name
                IsActive = true, // Active
                Family = 'TVC', // Product Family
                Product_Type__c = 'TVC', // Product Type
                ProductCode = 'TVC', // Product Code
                Ads_Format__c = 'Video', // Ads Format
                Ads_Size__c = 'PRIME TIME 17.00 - 24.00', // Ads Size
                Product_Channel__c = 'TVC PLATINUM', // Product Channel
                Buying_Method__c = 'I/O', // Buying Method
                List_Price__c = 500.00, // List Price
                Business_Product__c = 'TV Media',
                Product_Category__c = 'IPTV', // Product Category
                Tarif__c = 250.00,
                Duration__c = 15,
                HJM__c = 10,
                Iptv_Inventory__c = IPTVInventoryRec.Id
            );
            insert productRec;
            System.debug('== productRec: ' + productRec);

            //Create your pricebook entry
            PricebookEntry pricebookEntryRec = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = productRec.Id,
                UnitPrice = 100.00,
                IsActive = true
            );
            insert pricebookEntryRec;

            Opportunity oppRec = new Opportunity(
                RecordTypeId = recordTypeOppId, // Opportunity Record Type
                Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024', // Opportunity Name
                AccountId = accRec.Id, // Account Name
                CloseDate = Date.valueOf('2024-09-21'), // Close Date
                Account_Type__c = 'Agency', // Account Type
                StageName = 'Proposal', // Stage
                Regional__c = 'HEAD OFFICE', // Regional  (Required)
                Probability = 100, // Probability (%)
                Agency_Name__c = accRec.Id, // Agency Name
                Campaign_Customize__c = false, // Campaign Customize
                Templated_Proposal__c = true, // Own Proposal?
                Approval_Remark__c = 'Approved', // Approval Remark
                Document_Version__c = 'Submit', // Document Version
                Approval_Status__c = 'Approved', // Approval Status
                Marketing_Package__c = false, // Marketing Package
                SME__c = false, // SME
                Type = 'Existing Business', // Type
                Penagihan_based_on_TV__c = 'Postpaid', // Penagihan based on
                Performance_Product__c = false, // Performance Product
                Programmatic_Product__c = false, // Programmatic Product
                Performance_Done__c = false, // Performance Done
                RFP_Status_sales__c = 'Completed', // RFP Status (sales)
                Check_PO__c = 'OK',
                Pricebook2Id = Test.getStandardPricebookId(),
                OwnerId = testUser.Id,
                Target_Start_Date__c = Date.valueOf('2024-09-21'),
                Target_Closed_Date__c = Date.valueOf('2024-09-29'),
                Remarks__c = 'Test'
               
            );
            insert oppRec;

            OpportunityLineItem oliRec = new OpportunityLineItem(
                OpportunityId = oppRec.Id, // Opportunity
                Product2Id = productRec.Id, // Product
                Discount__c = 0.00, // Discount (%)
                PricebookEntryId = pricebookEntryRec.Id,
                UnitPrice = 500.00, // Sales Price
                Quantity = 1234.00, // Quantity
                Business_Product__c = 'TV Media'
            );
            insert oliRec;
            
              ContentVersion uploadFile = new ContentVersion(
                Title = 'test file',
                PathOnClient = 'testfile.pdf',
                VersionData = Blob.valueOf('Test content for the file.')
            );
            insert uploadFile;

            ContentVersion uploadedFile = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: uploadFile.Id];

            ContentDocumentLink contentDocLink = new ContentDocumentLink(
                ContentDocumentId = uploadedFile.ContentDocumentId,
                LinkedEntityId = oppRec.Id,
                ShareType = 'V',
                Visibility = 'AllUsers'
            );
            insert contentDocLink;

            oppRec.StageName = 'Closed Won';
            update oppRec;

            Date startDate = Date.newInstance(
                Date.today().year(),
                Date.today().month(),
                1
            );
            Date endDate = Date.newInstance(
                Date.today().year(),
                Date.today().month(),
                Date.daysInMonth(Date.today().year(), Date.today().month())
            );

            Test.startTest();

            SOA__c soaRec = new SOA__c(
                Opportunity__c = oppRec.Id, // Opportunity
                SOA_Type__c = 'Opportunity', // SOA Type
                SOA_Start_Date__c = startDate, // SOA Start Date
                SOA_End_Date__c = endDate, // SOA End Date
                SOA_Sources__c = 'Opportunity' // SOA
            );
            insert soaRec;

            Order orderRec = new Order(
                Status = 'Draft', // Status
                SOA__c = soaRec.Id, // SOA
                EffectiveDate = Date.newInstance(2024, 12, 1), // Order Start Date
                EndDate = Date.newInstance(2024, 12, 31), // Order Type
                AccountId = accRec.Id,
                Pricebook2Id = Test.getStandardPricebookId()
            );
            insert orderRec;

            OrderItem orderItemRec = new OrderItem(
                OrderId = orderRec.id,
                Product2Id = productRec.Id,
                PricebookEntryId = pricebookEntryRec.id,
                Quantity = 10,
                UnitPrice = 100.00,
                Opportunity__c = oppRec.Id,
                Opportunity_Product__c = oliRec.Id
            );
            insert orderItemRec;

            Invoice__c invRec = new Invoice__c(
                Mitra__c = accRec.id, // Mitra
                No_Invoice__c = 'TS.123123.4123125', // No Invoice
                No_Master__c = '123123', // No Master
                Tanggal_Invoice__c = Date.newInstance(2024, 12, 1), // Tanggal Invoice
                No_Individual__c = '3123123', // No Individual
                Jangka_Waktu_PKS__c = '1 Januari 2024 - 31 Desember 2025', // Jangka Waktu PKS
                Hak_Telkomsel__c = 150000 // Hak Telkomsel
            );
            insert invRec;

            soaRec.invoice__c = invRec.id;
            update soaRec;

            // insert soaRecord;
            Quote quoteRec = new Quote(
                Name = 'TSEL / Q02250 / dev1/9/25/2023', // Quotation Name
                OpportunityId = oppRec.id, // Opportunity Name
                ContactId = contactRec.id, // Contact Name
                Status = 'Final', // Status
                Start_Date__c = startDate, // Start Date
                End_Date__c = endDate, // End Date
                Invoice__c = invRec.id // Invoice
            );
            insert quoteRec;

            Media_Order__c moRec = new Media_Order__c(
                Name = 'TSEL/TMS0000003/Admin TV Ads/7/2024', // No MO
                Order_Item_ID__c = '0000013121', // Order Item ID
                Product_Name__c = 'TVC PLATINUM (Regular) 120" AllPlay.ent', // Product Name
                House_Number__c = 'CRHD2102053', // House Number
                Brand__c = 'Mie Sedaap Soto', // Brand
                Versi__c = '15', // Versi
                Channel__c = 'AllPlay.ent', // Channel
                Product_Inventory__c = 'TVC PLATINUM', // Product Inventory
                Showtimes__c = 'REGULAR TIME', // Showtimes
                Time__c = '00.00 - 17.00', // Time
                Duration__c = 120, // Duration
                Start_Date__c = System.date.today(), // Start Date
                End_Date__c = System.date.today() + 30, // End Date
                Quantity__c = 10, // Quantity
                Net__c = 5000000.00, // Net
                Amount__c = 0.00, // Amount
                Order_Product__c = orderItemRec.Id, // Order Product
                Order__c = orderRec.Id // Order
            );
            insert moRec;

            Media_Order_Item__c moiRec = new Media_Order_Item__c(
                Name = 'TSEL/TMS0000003/Admin TV Ads/7/2024/1', // No MO Item
                Media_Order__c = moRec.Id, // Media Order
                Order_Product__c = orderItemRec.Id, // Order Product
                Product_Name__c = 'TVC PLATINUM (Regular) 120" AllPlay.ent', // Product Name
                House_Number__c = 'CRHD2102053', // House Number
                Versi__c = '15', // Versi
                Duration__c = 120, // Duration
                Date__c = System.date.today(), // Date
                Time__c = '00.00 - 17.00', // Time
                Net__c = 5000000.00, // Net
                Amount__c = 0.00,
                Inventory_Name__c = IPTVInventoryRec.Id, // Amount
                Channel__c = 'AllPlay.ent' // Channel
            );
            insert moiRec;

            // update order item -> add campaign id
            OrderItemRec.Campaign_ID__c = 'testId123';
            update orderItemRec;

            String CampainId = orderItemRec.Campaign_ID__c;

            // create usage
            Usage__c usageRec = new Usage__c(
                NIK__c = '81312',
                Campaign_ID__c = CampainId,
                Date__c = date.today(),
                amount__c = 1000,
                Media_Order_Item__c = moiRec.Id,
                Bucket_Detail__c = OrderItemRec.Id
            );
            insert usageRec;
        }
    }

    @IsTest
    static void updateUsage() {
        Usage__c usageRec = [
            SELECT Id, amount__c
            FROM Usage__c
            WHERE NIK__c = '81312'
        ];

        usageRec.amount__c = 120;

        Test.startTest();
        update usageRec;
        Test.stopTest();
    }
}