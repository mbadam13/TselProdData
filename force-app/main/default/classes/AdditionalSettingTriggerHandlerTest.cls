/**
 * @description       : 
 * @author            :
 * @group             : 
 * @last modified on  : 10-20-2023
 * @last modified by  : Ahmat Zulkifli Murad
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   07-07-2023   Novando Utoyo Agmawan   Initial Version
**/

@isTest
public with sharing class AdditionalSettingTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        Trigger_Setting__c triggerSettingsRecValidationStartDateIsExist = new Trigger_Setting__c();
        triggerSettingsRecValidationStartDateIsExist.IsActive__c = true;
        triggerSettingsRecValidationStartDateIsExist.name = 'validation:_StartDateIsExist';
        triggerSettingsRecValidationStartDateIsExist.Error_Message__c = 'Tidak bisa membuat additional setting karena sudah tersedia, silahkan buat ditanggal berbeda';
        triggerSettingsRecValidationStartDateIsExist.Object_Name__c = 'Additional_setting__c';

        insert triggerSettingsRecValidationStartDateIsExist;

        Trigger_Setting__c triggerSettingsRecCantDelete = new Trigger_Setting__c();
        triggerSettingsRecCantDelete.IsActive__c = true;
        triggerSettingsRecCantDelete.name = 'Validation:_CantdeleteWhenRecordUsed';
        triggerSettingsRecCantDelete.Error_Message__c = 'Additonal Setting Tidak bisa dihapus karena sudah digunakan pada Record Traffic';
        triggerSettingsRecCantDelete.Object_Name__c = 'traffic__c';

        insert triggerSettingsRecCantDelete;

        Trigger_Setting__c triggerSettingsRecCantDelete1 = new Trigger_Setting__c();
        triggerSettingsRecCantDelete1.IsActive__c = true;
        triggerSettingsRecCantDelete1.name = 'Validation:_CantdeleteWhenRecordUsed';
        triggerSettingsRecCantDelete1.Error_Message__c = 'Additonal Setting Tidak bisa dihapus karena sudah digunakan pada Record Pubmatic Billing';
        triggerSettingsRecCantDelete1.Object_Name__c = 'pubmatic_billing__c';

        insert triggerSettingsRecCantDelete1;
    }

    @isTest
    static void testValidationCannotInsertRecordWhenStartDateIsExistVAT() {       
        // Create additional settings that will violate the validation rule
        Id recordTypeId_AddtSet1 = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('VAT').getRecordTypeId();

        Additional_Setting__c additionalSettingVAT = new Additional_Setting__c(
            recordtypeid = recordTypeId_AddtSet1,
            Start_Date__c = date.newInstance(2023, 01, 01),
            End_Date__c = date.newInstance(2023, 12, 31),
            Applies_to_Category__c = 'General',         // Applies to Category
            Object_Name__c = 'VAT',         // Object Name
            Type__c = 'VAT',                             // Type
            Active__c = true,                           // Active?
            Value_Type__c = 'Percentage',                // Value Type
            Value__c = 1.11 
            
        );

        Additional_Setting__c additionalSettingVAT1 = new Additional_Setting__c(
            recordtypeid = recordTypeId_AddtSet1,
            Start_Date__c = date.newInstance(2023, 01, 01),
            End_Date__c = date.newInstance(2023, 12, 31),
            Applies_to_Category__c = 'General',         // Applies to Category
            Object_Name__c = 'VAT',         // Object Name
            Type__c = 'VAT',                             // Type
            Active__c = true,                           // Active?
            Value_Type__c = 'Percentage',                // Value Type
            Value__c = 1.11 
            
        );

        try {
            insert additionalSettingVAT; 
            test.startTest();
            insert additionalSettingVAT1;    
            test.stopTest();
        } catch (Exception e) {            
            System.assertEquals(false, additionalSettingVAT1.hasErrors());   
        }
    }

    @isTest
    static void testValidationCannotInsertRecordWhenStartDateIsExistDisc() {       
        // Create additional settings that will violate the validation rule
        Id recordTypeId_AddtSet2 = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('Discount').getRecordTypeId();

        Additional_Setting__c additionalSettingDisc = new Additional_Setting__c(
            recordtypeid = recordTypeId_AddtSet2,
            Start_Date__c = date.newInstance(2023, 01, 01),
            End_Date__c = date.newInstance(2023, 12, 31),
            Applies_to_Category__c = 'Specific',         // Applies to Category
            Object_Name__c = 'monthlyTTDTraffic__c',         // Object Name
            Type__c = 'Discount',                             // Type
            Active__c = true,                           // Active?
            Value_Type__c = 'Percentage',                // Value Type
            Value__c = 1.11          
        );

        Additional_Setting__c additionalSettingDisc1 = new Additional_Setting__c(
            recordtypeid = recordTypeId_AddtSet2,
            Start_Date__c = date.newInstance(2023, 01, 01),
            End_Date__c = date.newInstance(2023, 12, 31),
            Applies_to_Category__c = 'Specific',         // Applies to Category
            Object_Name__c = 'monthlyTTDTraffic__c',         // Object Name
            Type__c = 'Discount',                             // Type
            Active__c = true,                           // Active?
            Value_Type__c = 'Percentage',                // Value Type
            Value__c = 1.11          
        );

        try {
            insert additionalSettingDisc;
            test.startTest();
            insert additionalSettingDisc1;
            test.stopTest();
        } catch (Exception e) {            
            System.assertEquals(false, additionalSettingDisc1.hasErrors());
        }
    }

    @isTest
    static void testValidationCannotInsertRecordWhenStartDateIsExistElse() {       
        // Create additional settings that will violate the validation rule
        Id recordTypeId_AddtSet2 = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('Revenue Calculation for Discount Inventory').getRecordTypeId();
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();

        Account acc = new Account(
            Name = 'Wira Pamungkas Pratama',          				// Account Name
            RecordTypeId = recordTypeAccId,                                  // Account Record Type
            Account_Type__c = 'Agency',                                  // Account Type
            Direct_Indirect__c = 'Direct',                               // Direct/Indirect
            Status__c = 'Approved by Settlement',                        // Status
            No_PKS__c = '123456',                                        // No PKS
            NPWP__c = '1',                                               // NPWP
            PKS_Tracker__c = 'Pending'      
        );
        insert acc;
        
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

        Additional_Setting__c additionalSettingElse = new Additional_Setting__c(
            recordtypeid = recordTypeId_AddtSet2,
            account__c = acc.id,
            Start_Date__c = date.newInstance(2023, 01, 01),
            End_Date__c = date.newInstance(2023, 12, 31),
            Applies_to_Category__c = 'Specific',         // Applies to Category
            Object_Name__c = 'Revenue_Calculation_for_Discount_Inventory__c',         // Object Name
            Type__c = 'Revenue Calculation',                             // Type
            Active__c = true                         // Active?
            //Value_Type__c = 'Percentage',                // Value Type
            //Value__c = 1.11          
        );
        insert additionalSettingElse;

        Additional_Setting__c additionalSettingElse1 = new Additional_Setting__c(
            recordtypeid = recordTypeId_AddtSet2,
            account__c = acc.id,
            Start_Date__c = date.newInstance(2023, 02, 01),
            End_Date__c = date.newInstance(2023, 12, 31),
            Applies_to_Category__c = 'Specific',         // Applies to Category
            Object_Name__c = 'Revenue_Calculation_for_Discount_Inventory__c',         // Object Name
            Type__c = 'Revenue Calculation',                             // Type
            Active__c = true                         // Active?
            //Value_Type__c = 'Percentage',                // Value Type
            //Value__c = 1.11            
        );

        try {
            test.startTest();
            
            insert additionalSettingElse1;
            List<Additional_Setting__c> addSettingList = new List<Additional_Setting__c>{additionalSettingElse1};
            AdditionalSettingTriggerHandler.validationCannotInsertRecordWhenStartDateIsExist(addSettingList);
            test.stopTest();
        } catch (Exception e) {            
            System.assertEquals(false, additionalSettingElse1.hasErrors());
        }
    }

    @istest
    static void testValidationCannotdeleteWhenRecordUsedInTrafficRecord() {
        // Create a test Additional_Setting__c record
        Id recordTypeId_AddtSet1 = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('VAT').getRecordTypeId();
        Additional_Setting__c additionalSetting1 = new Additional_Setting__c(
            recordtypeid = recordTypeId_AddtSet1,
            Start_Date__c = date.newInstance(2059, 05, 01),
            End_Date__c = date.newInstance(2059, 07, 01),
            Applies_to_Category__c = 'General',         // Applies to Category
            Object_Name__c = 'VAT',
            Type__c = 'VAT',                             // Type
            //Value_Type__c = 'Percentage',                // Value Type
            //Value__c = 1.11,
            Active__c = true  
        );
        insert additionalSetting1;

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
            newTrafficRec.Sites__c = siteRecord.id;
            newTrafficRec.Business_Model_Category__c = BMCRecord.id;
            newTrafficRec.Additional_Setting__c = additionalSetting1.id;
            newTrafficList.add(newTrafficRec);
        }
        insert newTrafficList;

        System.debug('newTrafficList: ' + newTrafficList);
        // Call the validation method with the oldAdditionalSettingList parameter containing the test Additional_Setting__c record
        List<Additional_Setting__c> settingList = new List<Additional_Setting__c>{additionalSetting1};
        Test.startTest();
       // delete additionalSetting1;
        AdditionalSettingTriggerHandler.validationCannotdeleteWhenRecordUsedInTrafficRecord(settingList);
        Test.stopTest();
        
        // Assert that the Additional_Setting__c record has an error message
        System.assertEquals(true, additionalSetting1.hasErrors());
    }

    @istest
    static void testValidationCannotdeleteWhenRecordUsedBeforeInsert() {
        // Create a test Additional_Setting__c record
        Id recordTypeId_AddtSet1 = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('VAT').getRecordTypeId();
        Additional_Setting__c additionalSetting1 = new Additional_Setting__c(
            recordtypeid = recordTypeId_AddtSet1,
            Start_Date__c = date.newInstance(2028, 05, 01),
            End_Date__c = date.newInstance(2028, 07, 01),
            Applies_to_Category__c = 'General',         // Applies to Category
            Object_Name__c = 'VAT',
            Type__c = 'VAT',                             // Type
            //Value_Type__c = 'Percentage',                // Value Type
            //Value__c = 1.11,
            Active__c = true  
        );
        insert additionalSetting1;


        // Call the validation method with the oldAdditionalSettingList parameter containing the test Additional_Setting__c record
        Test.startTest();
        delete additionalSetting1;
        Test.stopTest();
    }
    
/*
    @istest
    static void testValidationCannotdeleteWhenRecordUsedInPubmaticBillingRecord() {
        // Create a test Additional_Setting__c record
        Id recordTypeId_AddtSet1 = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('Traffic').getRecordTypeId();
        Additional_Setting__c additionalSetting1 = new Additional_Setting__c(
            recordtypeid = recordTypeId_AddtSet1,
            Start_Date__c = date.newInstance(2028, 05, 01),
            End_Date__c = date.newInstance(2028, 07, 01),
            Applies_to_Category__c = 'Specific',         // Applies to Category
            Object_Name__c = 'Traffic__c',
            Type__c = 'VAT',                             // Type
            Value_Type__c = 'Percentage',                // Value Type
            Value__c = 1.11,
            Active__c = true  
        );
        insert additionalSetting1;

        Monthly_Settlement__c monthlySettlment = new Monthly_Settlement__c(
            Date__c = date.newInstance(2028, 05, 01),// Date
            Unique_Key__c = 'MS_202805'           // Unique Key
        );
        insert monthlySettlment;

        Pubmatic_Billing__c pubmaticBilling = new Pubmatic_Billing__c(
            //Publisher__c = 'undefined',            // Publisher
            //Site__c = 'undefined',                   // Site
            Monthly_Settlement__c = monthlySettlment.id,     // Monthly Settlement
            Date__c = date.newInstance(2028, 05, 01),    // Date
            Sum_of_Revenue_USD__c = 224751,      // Sum of Revenue (USD)
            Exchange_Rate__c = 14300.00,          // Exchange Rate
            Sum_of_Paid_Impressions__c = 214794,  // Sum of Paid Impressions
            Additional_Setting__c = additionalSetting1.id,     // Additional Setting
            Sum_of_Net_Revenue_USD__c = 20112,  // Sum of Net Revenue (USD)
            Billing_USD__c = 123,             // Billing USD
            Billing_IDR__c = 1758900,         // Billing IDR
            Unique_Key__c = 'PB_202302_867235'      // Unique Key
        );
        insert pubmaticBilling;

        // Call the validation method with the oldAdditionalSettingList parameter containing the test Additional_Setting__c record
        List<Additional_Setting__c> settingList = new List<Additional_Setting__c>{additionalSetting1};
        Test.startTest();
       // delete additionalSetting1;
        AdditionalSettingTriggerHandler.validationCannotdeleteWhenRecordUsedInPubmaticBillingRecord(settingList);
        Test.stopTest();
        
        // Assert that the Additional_Setting__c record has an error message
        System.assertEquals(true, additionalSetting1.hasErrors());
    }

    @istest
    static void testValidationCannotdeleteWhenRecordUsedBeforeInsert() {
        // Create a test Additional_Setting__c record
        Id recordTypeId_AddtSet1 = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('Traffic').getRecordTypeId();
        Additional_Setting__c additionalSetting1 = new Additional_Setting__c(
            recordtypeid = recordTypeId_AddtSet1,
            Start_Date__c = date.newInstance(2028, 05, 01),
            End_Date__c = date.newInstance(2028, 07, 01),
            Applies_to_Category__c = 'Specific',         // Applies to Category
            Object_Name__c = 'Traffic__c',
            Type__c = 'VAT',                             // Type
            Value_Type__c = 'Percentage',                // Value Type
            Value__c = 1.11,
            Active__c = true  
        );
        insert additionalSetting1;


        // Call the validation method with the oldAdditionalSettingList parameter containing the test Additional_Setting__c record
        Test.startTest();
        delete additionalSetting1;
        Test.stopTest();
    }
*/
}