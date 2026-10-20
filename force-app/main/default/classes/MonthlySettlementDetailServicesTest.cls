@isTest
public with sharing class MonthlySettlementDetailServicesTest {

    @TestSetup
    static void makeData(){
        Trigger_Setting__c triggerSettingsRecValidationStartDateIsExist = new Trigger_Setting__c();
        triggerSettingsRecValidationStartDateIsExist.IsActive__c = false;
        triggerSettingsRecValidationStartDateIsExist.name = 'validation:_StartDateIsExist';
        triggerSettingsRecValidationStartDateIsExist.Error_Message__c = 'Tidak bisa membuat additional setting karena sudah tersedia, silahkan buat ditanggal berbeda';
        triggerSettingsRecValidationStartDateIsExist.Object_Name__c = 'Additional_setting__c';

        insert triggerSettingsRecValidationStartDateIsExist;

        Trigger_Setting__c triggerSettingsRecValidationDealIDMustBeFilled = new Trigger_Setting__c();
        triggerSettingsRecValidationDealIDMustBeFilled.IsActive__c = false;       
        triggerSettingsRecValidationDealIDMustBeFilled.name = 'Validation:_Deal_ID_Must_be_filled';
        triggerSettingsRecValidationDealIDMustBeFilled.Error_Message__c = 'Tidak bisa membuat additional setting karena sudah tersedia, silahkan buat ditanggal berbeda';
        triggerSettingsRecValidationDealIDMustBeFilled.Object_Name__c = 'Opportunity';

        insert triggerSettingsRecValidationDealIDMustBeFilled;
        
        list<profile> profileAdmin = [select id from profile where name like '%Admin%' limit 1];
        User salesAdminUser = new User(
            //UserRoleId = 'undefined',                                                  // Role
            Alias = 'sadmin',    
            ProfileId = profileAdmin[0].id,                                                         // Alias
            Email = 'adminTEst@TSEL.co.id',                                                   // Emails
            Username = 'adminTEst@TSEL.co.id.TEST',                                                // Username
            IsActive = true,                                                             // Active
            CommunityNickname = 'salesadminTEST',   // Nickname
            lastName  = 'salesadminTEST',
            UserPermissionsMarketingUser = false,                                        // Marketing User
            UserPermissionsOfflineUser = false,                                          // Offline User
            Department = 'Telkomsel',                                        // Department
            TimeZoneSidKey = 'Asia/Jakarta',        // Time Zone
            LocaleSidKey = 'in_ID',                                     // Locale
            LanguageLocaleKey = 'en_US',                                               // Language
            MobilePhone = '+6281381238123',                                             // Mobile
            EmailEncodingKey = 'ISO-8859-1',  // Email Encoding
            NIK__c = '123456789'                                                 // Employee ID
        );
        insert salesAdminUser;
    }

    @isTest 
    static void testUpsertMonthlySettlement() {
        // Set up test data
        String uniqueKey = '1234';
        Date monthlySettlementDate = Date.today();

        // Call the method being tested
        String result = MonthlySettlementDetailServices.upsertMonthlySettlement(uniqueKey, monthlySettlementDate);

        // Verify that a Monthly Settlement record was created or updated
        Monthly_Settlement__c monthlySettlement = [SELECT Id, Unique_Key__c, Date__c FROM Monthly_Settlement__c WHERE Unique_Key__c = :uniqueKey];
        System.assertNotEquals(null, monthlySettlement.Id);
        System.assertEquals(uniqueKey, monthlySettlement.Unique_Key__c);
        System.assertEquals(monthlySettlementDate, monthlySettlement.Date__c);

        // Verify that the method returned the ID of the new Monthly Settlement record
        System.assertEquals(monthlySettlement.Id, result);
    }

    @isTest
    static void testGetRevenueDSPFee() {
        // create test data
        List<DSP_Fee__c> dspFeeList = new List<DSP_Fee__c>();
        for (Integer i = 0; i < 5; i++) {
            DSP_Fee__c dspFee = new DSP_Fee__c();
            dspFee.Deal_Id__c = 'Test Deal ' + i;
            dspFee.Date__c = Date.newInstance(2023, 3, 1);
            dspFee.Amount__c = 100.00;
            dspFeeList.add(dspFee);
        }
        insert dspFeeList;
        

        test.startTest();
        MonthlySettlementDetailServices.getRevenueDSPFee(Date.newInstance(2023, 3, 1));
        test.stopTest();
    }

    @isTest
    static void testGetRevenuefromPublisherShare(){

        Additional_Setting__c additionalSettingRec = new Additional_Setting__c(
            Start_Date__c = date.newInstance(2028, 01, 01),
            Type__c = 'VAT',                             // Type
            End_Date__c = date.newInstance(2028, 06, 01),
            Object_Name__c = 'traffic__c',                  // Object Name
            Value__c = 1.11                           // Value
        );
        insert additionalSettingRec;

        Account accountRecord = new Account(
            Name = 'PT. Dinamo Media NTq',                                                                                                             // Account Name
            Site_Domain__c = 'dinamomediant.com',                                                                                                        // Site Domain
            Account_Type__c = 'Publisher',                                                                                                               // Account Type
            Nomor_Verifikasi_Dewan_Pers__c = '456/DP-Terverifikasi/K/XI/2020',                                                                           // Nomor Verifikasi Dewan Pers
            AccountSource = 'TADEX Form',                                                                                                                // Account Source
            Nomor_Induk_Berusaha__c = '123450017862',                                                                                                    // Nomor Induk Berusaha
            Publisher_Status__c = 'Ad Tag Shared',                                                                                                       // Publisher Status
            Nama_Penjabat__c = 'Joice',                                                                                                                  // Nama Penjabat
            Jabatan_Penjabat__c = 'Manager',                                                                                                             // Jabatan Penjabat
            Contract_Bypass_Approval__c = 'Approved',                                                                                                    // Contract Bypass Approval
            Status__c = 'Approved by Settlement',                                                                                                        // Status
            Tipe_Platform__c = 'Web;Mobile',                                                                                                             // Tipe Platform
            Total_Ad_Request_Bulan__c = 973,                                                                                                     // Total Ad Request/Bulan
            Tipe_Display_Ads__c = 'Desktop Display 300x250;Desktop Display 728x90;Desktop Display 320x50;Mobile Display 300x250;Mobile Display 320x50',  // Tipe Display Ads
            Content__c = 'General',                                                                                                                     // Content
            Nama_Pemilik__c = 'Tika',                                                                                                                    // Nama Pemilik
            Nomor_Rekening__c = '098907890079',                                                                                                          // Nomor Rekening
            Chatter_Name__c = 'Siska',                                                                                                                   // Chatter Name
            Chatter_Email__c = 'siska@dmnt.com',                                                                                                         // Chatter Email
            Chatter_Group_Id__c = '0F9p0000000NWljCAG'                                                                                                  // Chatter Group Id
                                                                                                               // Account Record Type
        );
        insert accountRecord;

        Sites__c siteRecord = new Sites__c(
            Site_ID__c = '801823',                               // Site ID
            siteUrl__c = 'TADEX|MobileWeb|Abc|Abc.com|Outstream',  // siteUrl
            Platform__c = 'Mobile',                                // Platform
            Status__c = 'New'                                     // Status
        );
        insert siteRecord;

        Demand_Source_Information__c DSIRecord = new Demand_Source_Information__c(
            Demand_Source__c = 'Programmatic PMP with Client\'s DSP',// Demand Source
            Share__c = 17                                          // Share
        );
        insert DSIRecord;

        Business_Model_Category__c BMCRecord = new Business_Model_Category__c(
            BMC_Name__c = 'Tadex Client',                           // BMC Name
            Demand_Source_Information__c = DSIRecord.Id,
            BMC_Text__c = 'TADEX_',                                   // BMC Text
            Percentage__c = 17.00,                                  // Percentage
            Demand_Source__c = 'Programmatic PMP with Client\'s DSP'  // Demand Source
        );
        insert BMCRecord;

        list<traffic__c> newTrafficList = new list <traffic__c>();
        for(Integer i = 0; i < 5; i++){
            traffic__c newTrafficRec = new traffic__c();
            newTrafficRec.Deal_ID__c = 'PM-DAOB-0603-001';                          // Deal ID
            newTrafficRec.Deal__c = 'TADEX_NESTLE_TTD_0000_DISPLAY_08042021';       // Deal
            newTrafficRec.Total_Telkomsel_Share__c = 17;                          // Total Telkomsel Share
            newTrafficRec.Date__c = date.newInstance(2028, 06, 01);
            newTrafficRec.Demand_Source__c = 'Programmatic PMP with Clients DSP';  // Demand Source
            newTrafficRec.Deal_Source__c = 'Publisher';                             // Deal Source
            newTrafficRec.Paid_Impressions__c = 3401;                            // Paid Impressions
            newTrafficRec.Revenue_USD__c = 2.72;                                  // Revenue (USD)
            newTrafficRec.PMP_Fees__c = 0.27;                                     // PMP Fees
            newTrafficRec.Fee__c = 10;                                            // Fee (%)
            newTrafficRec.Net_Revenue__c = 2.45;                                  // Net Revenue
            newTrafficRec.Additional_Setting__c = additionalSettingRec.id;                      // Additional Setting
            newTrafficRec.Sites__c = siteRecord.id;
            newTrafficRec.Business_Model_Category__c = BMCRecord.id;
            newTrafficList.add(newTrafficRec);
        }
        insert newTrafficList;

        test.startTest();
        MonthlySettlementDetailServices.getRevenueFromPublisherShare(date.newInstance(2028, 06, 01));
        test.stopTest();
    }

    @isTest
    static void testGetRevenueFromAdvertiser(){

        LOB__c LOBRecord = new LOB__c(
            name = 'FMCG'
        );
        insert LOBRecord;

        Account accountRecord = new Account(
            Name = 'PT. Dinamo Media NTq',                                                                                                             // Account Name
            Site_Domain__c = 'dinamomediant.com',                                                                                                        // Site Domain
            Account_Type__c = 'Publisher',                                                                                                               // Account Type
            Nomor_Verifikasi_Dewan_Pers__c = '456/DP-Terverifikasi/K/XI/2020',                                                                           // Nomor Verifikasi Dewan Pers
            AccountSource = 'TADEX Form',                                                                                                                // Account Source
            Nomor_Induk_Berusaha__c = '123450017862',                                                                                                    // Nomor Induk Berusaha
            Publisher_Status__c = 'Ad Tag Shared',                                                                                                       // Publisher Status
            Nama_Penjabat__c = 'Joice',                                                                                                                  // Nama Penjabat
            Jabatan_Penjabat__c = 'Manager',                                                                                                             // Jabatan Penjabat
            Contract_Bypass_Approval__c = 'Approved',                                                                                                    // Contract Bypass Approval
            Status__c = 'Approved by Settlement',                                                                                                        // Status
            Tipe_Platform__c = 'Web;Mobile',                                                                                                             // Tipe Platform
            Total_Ad_Request_Bulan__c = 973,                                                                                                     // Total Ad Request/Bulan
            Tipe_Display_Ads__c = 'Desktop Display 300x250;Desktop Display 728x90;Desktop Display 320x50;Mobile Display 300x250;Mobile Display 320x50',  // Tipe Display Ads
            Content__c = 'General',                                                                                                                     // Content
            Nama_Pemilik__c = 'Tika',                                                                                                                    // Nama Pemilik
            Nomor_Rekening__c = '098907890079',                                                                                                          // Nomor Rekening
            Chatter_Name__c = 'Siska',                                                                                                                   // Chatter Name
            Chatter_Email__c = 'siska@dmnt.com',                                                                                                         // Chatter Email
            Chatter_Group_Id__c = '0F9p0000000NWljCAG'                                                                                                  // Chatter Group Id
                                                                                                               // Account Record Type
        );
        insert accountRecord;

        Contact contactRecord = new Contact(
            LastName = 'murad UAT',
            AccountId = accountRecord.id
        );
        insert contactRecord;

        Brand__c brandRecord = new Brand__c(
            Name = 'Detik Brand UAT',       // Brand Name
            PIC_Advertiser__c = contactRecord.id
        );
        insert brandRecord;

        Contract newContract = new Contract();
        newContract.StartDate = date.today();
        newContract.ContractTerm = 1;
        newContract.AccountId = accountRecord.id;
        insert newContract;

        newContract.Status = 'Activated';
        update newContract;


        // Create a test product
        Product2 prod = new Product2(
            Name = 'Tadex Display', 
            IsActive = true, 
            ProductCode = 'TP001', 
            Description = 'Test Product Description',
            Product_Category__c = 'Tadex'
        );
        insert prod;

        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebookREC = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebookREC;
        
        PricebookEntry pbEntrySTDREC = new PricebookEntry(
            Product2Id = prod.id,  // Product
            IsActive = true,                   // Active
            Pricebook2Id = standardPricebookREC.id,  // Price Book
            UnitPrice = 52.500,                // List Price
            UseStandardPrice = false          // Use Standard Price
        );
        insert pbEntrySTDREC;

        Opportunity opportunityRecord = new Opportunity(
            Name = 'Test Opportunity', 
            accountid = accountRecord.id,
            brand__c = brandRecord.id,
            StageName = 'Prospect', 
            CloseDate = Date.today().addDays(30), 
            Amount = 50000,
            Approval_Status__c = 'Approved',
            Regional__c = 'BALINUSRA'
        );
        insert opportunityRecord;

        opportunityRecord.Approval_Status__c='Approved';
        opportunityRecord.Check_PO__c='OK';

        update opportunityRecord;

        OpportunityLineItem oli_prod1 = new OpportunityLineItem();
        oli_prod1.OpportunityId = opportunityRecord.Id;
        oli_prod1.Product2Id = prod.id;
        oli_prod1.UnitPrice = 500;
        oli_prod1.PricebookEntryId = pbEntrySTDREC.id;
        oli_prod1.Quantity = 100;
        //oli_prod1.deal_id__c = 'PM_ASDQWE_123';
        
        insert oli_prod1;
        System.debug('oli_prod1: ' + oli_prod1);

        opportunityRecord.StageName = 'Closed Won';
        update opportunityRecord;
        
        Order odr = new Order();
            odr.Pricebook2id = standardPricebookREC.id;
            odr.OpportunityId = opportunityRecord.Id;
            odr.EffectiveDate = system.today();
            odr.EndDate = system.today().adddays(10);
            odr.status = 'Draft';
            odr.AccountId = accountRecord.id; 
        insert odr;
        
        OrderItem orderItem = new OrderItem(
            Product2Id = prod.id,
            OrderId = odr.id,
            PricebookEntryId = pbEntrySTDREC.id,
            Opportunity__c = opportunityRecord.id,
            Opportunity_Product__c = oli_prod1.id,
            campaign_id__c = '123456789',
            deal_id__c = 'PM_ASDQWE_123',
            UnitPrice = pbEntrySTDREC.UnitPrice, //00kp0000006d0gnAAA
            Quantity = 1

        );
        insert orderItem;
        System.debug('orderItem.290: ' + orderItem.Opportunity_Product__c);

        usage__c usg = new usage__c();
            usg.NIK__c = '123456789';
            usg.Campaign_ID__c = 'null_100385_1';
            usg.Date__c = date.today();
            usg.amount__c = 1000;
            USG.Bucket_Detail__c = orderItem.id;
        insert usg;
        System.debug('usg: ' + usg);

        MonthlySettlementDetailServices.getRevenueAdvertiser(date.today());
    }
}