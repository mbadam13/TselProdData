/**
* @description       : 
* @author            : Debora E P
* @group             : 
* @last modified on  : 10-19-2023
* @last modified by  : Ahmat Zulkifli Murad
* update Test Class
**/
// Created By Debora E P
// 13 October 2020

@isTest
public class Test_Trigger_OrderProduct {
    
    @TestSetup
    static void makeData(){
        Trigger_Setting__c triggerSettingsRecValidationStartDateIsExist = new Trigger_Setting__c();
        triggerSettingsRecValidationStartDateIsExist.IsActive__c = true;
        triggerSettingsRecValidationStartDateIsExist.name = 'validation:_StartDateIsExist';
        triggerSettingsRecValidationStartDateIsExist.Error_Message__c = 'Tidak bisa membuat additional setting karena sudah tersedia, silahkan buat ditanggal berbeda';
        triggerSettingsRecValidationStartDateIsExist.Object_Name__c = 'Additional_setting__c';
        
        insert triggerSettingsRecValidationStartDateIsExist;
        
        Trigger_Setting__c triggerSettingsRecValidationDataExchangesRateisExist = new Trigger_Setting__c();
        triggerSettingsRecValidationDataExchangesRateisExist.IsActive__c = true;
        triggerSettingsRecValidationDataExchangesRateisExist.name = 'Validation:_ExcRateisExist';
        triggerSettingsRecValidationDataExchangesRateisExist.Error_Message__c = 'tidak bisa membuat data karena sudah ada dalam periode yang ditentukan';
        triggerSettingsRecValidationDataExchangesRateisExist.Object_Name__c = 'ExchangeRates__c';
        
        insert triggerSettingsRecValidationDataExchangesRateisExist;  
    }
    
    
    static testMethod void testOrderProduct_BeforeUpdate() {
        Brand__c brand = new Brand__c(
            Name = 'GDPN - Djarum Super',// Brand Name
            User_Id__c = '8ld9xgb'        // User Id
        );
        insert brand;
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
        
        contract.Status = 'Activated';
        update contract;
        Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Agency Postpaid').getRecordTypeId();
        
        Opportunity oppRecord = new Opportunity(
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
        acc.ContractId__c = contract.Id;
        update acc;
      
        
        SOA__c soaRecord = new SOA__c(
            Opportunity__c = oppRecord.Id,              // Opportunity
            SOA_Type__c = 'Opportunity',                     // SOA Type
            SOA_Start_Date__c = Date.valueOf('2023-10-01'),  // SOA Start Date
            SOA_End_Date__c = Date.valueOf('2023-10-31'),    // SOA End Date
            SOA_Sources__c = 'Opportunity'                  // SOA
        );
        insert soaRecord;
        Id recordTypeId = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('VAT').getRecordTypeId();
        Additional_Setting__c VAT = new Additional_Setting__c(
            recordTypeId = recordTypeId,
            Active__c = true,                         // Active?
            Start_Date__c = Date.newInstance(2023, 1,1),  // Start Date
            End_Date__c = Date.newInstance(2023, 12,31),    // End Date
            Applies_to_Category__c = 'General',          // Applies to Category
            Type__c = 'VAT',                             // Type
            Value_Type__c = 'Percentage',                // Value Type
            Value__c = 1.11,                           // Value
            Object_Name__c = 'VAT'
        );
        insert VAT;
          // Call the method with the test data
        List<SOA__c> soaList = new List<SOA__c>{soaRecord};
        SoaService.createOrderforOppty(soaList);
        
        Test.startTest();
        Order orderRec =[SELECT Id,SOA__c FROM Order WHERE SOA__c =: soaRecord.Id LIMIT 1];
        OrderItem orderProduct = [SELECT Id FROM OrderItem WHERE OrderId =:orderRec.Id LIMIT 1];
        
        Usage__c usg = new Usage__c();
        usg.NIK__c='81312';
        usg.Campaign_ID__c='2023_B00008685_S02797_476_5';
        usg.Date__c=date.today();
        usg.amount__c=1000;
        usg.Bucket_Detail__c = orderProduct.Id;
        insert usg;
        try {
            orderProduct.Quantity = 1111.00;
        	update orderProduct;
        } catch(Exception e) {
            // Tangkap kesalahan dan ambil tindakan yang sesuai
            System.debug('Kesalahan: ' + e.getMessage());
             Test.stopTest(); // Stop test execution
             System.assert(false,e.getMessage()); // Assertion failure
        }
 
        
    }
    
    @IsTest
    static void testOrderProduct_AfterUpdate(){
        
        Date today =  System.today(); //Give your date
        Date firstDate = today.toStartOfMonth();
        integer num = 20;
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('DSP Client').getRecordTypeId();
        Account accountObj = new Account(
            Name = 'The UK Trade Desk Ltd',// Account Name
            RecordTypeId = recordTypeAccId,                       // Account Record Type
            PKS_Tracker__c = 'Pending'                       // PKS Tracker
        );
        insert accountObj;
        
        Brand__c brand = new Brand__c(
            Name = 'GDPN - Djarum Super',// Brand Name
            User_Id__c = '8ld9xgb'        // User Id
        );
        insert brand;
        
        SOA__c SOA = new SOA__c(
            SOA_Type__c = 'TTD',                             // SOA Type
            SOA_Start_Date__c = Date.newInstance(2023, 12,01),
            SOA_End_Date__c = Date.newInstance(2023, 12,31),    // SOA End Date
            SOA_Sources__c = 'TTD',                          // SOA
            Account__c = accountObj.Id                  // Account
        );
        insert SOA;
        
        Order order = new Order(
            Status = 'Draft',                                                    // Status
            SOA__c = SOA.Id,                                              // SOA
            EffectiveDate = Date.newInstance(2023, 12,01),                              // Order Start Date
            EndDate = Date.newInstance(2023, 12,31),                                    // Order End Date
            Brand__c = brand.Id,                                            // Brand
            Order_Type__c = 'TTD',                                                   // Order Type
            AccountId = accountObj.Id,
            Monthly_Traffic_Unique_Id__c = '2023/12/GDPN - Djarum Super (8ld9xgb)',  // Monthly Traffic Unique Id
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert order;
        
        Product2 newProduct = new Product2(Name='DMP TTD', Description='Sample Product',IsActive=true,Product_Category__c='Advertising');
        insert newProduct;
        
        PricebookEntry pbe_ttd = new PricebookEntry();
        pbe_ttd.IsActive = true;
        pbe_ttd.Product2Id = newProduct.Id;
        pbe_ttd.Pricebook2Id = Test.getStandardPricebookId();
        pbe_ttd.UnitPrice = 0;
        insert pbe_ttd;
        
        DSP_TTD_Product_Settings__c ttdSetting = new DSP_TTD_Product_Settings__c();
        ttdSetting.Name = 'DMP TTD';
        ttdSetting.Product_Id__c = newProduct.Id;
        insert ttdSetting;
        
        integer noOfDays = Date.daysInMonth(firstDate.year(), 12);
        Date endDate = Date.newInstance( firstDate.year(), 12, noOfDays);
        ExchangeRates__c exchangeRateObj = new ExchangeRates__c(
            Start_Date__c = Date.newInstance(2023, 1,1),// Start Date
            End_Date__c = Date.newInstance(2023, 12,31),    // End Date
            CurrencyType__c = 'USD',                     // Currency Type
            ConversionRate__c = 15096             // Conversion Rate
        );
        insert exchangeRateObj;
        Id recordTypeId = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('VAT').getRecordTypeId();
        Additional_Setting__c VAT = new Additional_Setting__c(
            recordTypeId = recordTypeId,
            Active__c = true,                         // Active?
            Start_Date__c = Date.newInstance(2023, 1,1),  // Start Date
            End_Date__c = Date.newInstance(2023, 12,31),    // End Date
            Applies_to_Category__c = 'General',          // Applies to Category
            Type__c = 'VAT',                             // Type
            Value_Type__c = 'Percentage',                // Value Type
            Value__c = 1.11,                           // Value
            Object_Name__c = 'VAT'
        );
        insert VAT;
        list <PricebookEntry> pricebookEntries = [
            SELECT Id, 
            Name, 
            Pricebook2Id, 
            Product2Id
            FROM PricebookEntry
            WHERE name ='DMP TTD'
            LIMIT 1
        ];
        System.debug('pricebook: '+ pricebookEntries);
        List<TTD_Traffic__c> ttdList = new List<TTD_Traffic__c>();
        OrderItem orderProduct = new OrderItem(
            OrderId = order.Id,                                           // Order
            Product2Id = newProduct.Id,                                          // Product
            ServiceDate = Date.newInstance(2023, 12,01),                                // Start Date
            ListPrice = 0.00,                                                        // List Price
            EndDate = Date.newInstance(2023, 12,31),                                    // End Date
            UnitPrice = 1619.72,                                                     // Unit Price
            Monthly_Traffic_Unique_Id__c = '2023/12/GDPN - Djarum Super (8ld9xgb)',  // Monthly Traffic Unique Id
            Quantity = 2.56,                                                       // Quantity
            Usage_Actual__c = 2.558214,                                            // Usage Actual
            Campaign_ID__c = '2023_B00008685_S02797_476_5',                          // Campaign ID
            Camp_ID__c = 'S02797_476_5',                                             // Camp ID
            VAT_Related__c = VAT.Id,                                      // VAT Related
            Total_Data_Cost_In_USD__c = 0.305364000000,                              // Total Data Cost In USD
            Exchange_Rates_Related__c = exchangeRateObj.Id,                           // Exchange Rates Related
            PricebookEntryId =pbe_ttd.Id
            //  Discount_Related__c = 'a1P1s00000360cF'                                 // Discount Related
        );
        insert orderProduct;
        
        MonthlyTTDTraffic__c monthlyTTD = new MonthlyTTDTraffic__c(
            Date__c = Date.newInstance(2023, 12,01),                  // Date
            Advertiser__c = 'GDPN - Djarum Super (8ld9xgb)',         // Advertiser
            Account__c = accountObj.ID,                          // Account
            Brand__c = brand.Id,                            // Brand
            //   Sales__c = '0052v00000fzOlk',                            // Sales
            UniqueKey__c = '2023/12/GDPN - Djarum Super (8ld9xgb)',  // Unique Key
            SOA__c = SOA.Id,                              // SOA
            ImpressionCount__c = 2558.21,                         // ImpressionCount
            TotalDataCostInUSD__c = 0.305364,                      // Total Data Cost In USD
            VATRelated__c = VAT.Id,                       // VAT Related
            Product__c = newProduct.Id,                          // Product
            Sales_NIK__c = '88140',                                  // Sales NIK
            ExchangeRatesRelated__c = exchangeRateObj.Id             // Exchange Rates Related
            //  Discount_Related__c = 'a1P1s00000360cF'                 // Discount Related
        );
        insert monthlyTTD;
        
        for(Integer i=0; i<num; i++) {
            TTD_Traffic__c ttdObj = new TTD_Traffic__c();
            ttdObj.Date__c = Date.newInstance(2023, 1,1);                                                
            ttdObj.Advertiser__c = 'GDPN - Djarum Super (8ld9xgb)';                                                                                                             
            ttdObj.Partner__c = 'PT Alpha Merah Kreasi - GDP N (on8q175)';                                          
            ttdObj.Campaign__c = 'DJARUM SUPER_DISPLAY_Premium Banner Audience Segmenting_MAR2023 (oolncif)';
            ttdObj.AdGroup__c = 'Male_18-24_TV Streamer (tnk8h84)';                              
            ttdObj.TargetingDataId__c = '286626877';                                                         
            ttdObj.ThirdPartyDataProviderName__c = 'Telkomsel';                                         
            ttdObj.BrandName__c = 'Telkomsel';                                                             
            ttdObj.FullPath__c = 'Telkomsel > Interest-based > TV Streamer';                  
            ttdObj.ThirdPartyDataBrandId__c = 'dr852telkomsel';                                              
            ttdObj.SegmentId__c = 'TSEL_3_47';                                                          
            ttdObj.ImpressionCount__c = 23156.78;
            ttdObj.Account__c = accountObj.Id;
            ttdObj.Brand__c = brand.Id;
            ttdObj.Monthly_TTD_Traffic_Unique_ID__c =  '2023/12/GDPN - Djarum Super (8ld9xgb)';                                                     
            ttdObj.TotalDataCostInUSD__c = 0.39;
            ttdObj.SalesNIK__c = '87151';
            ttdObj.MonthlyTTDTraffic__c = monthlyTTd.Id;
            ttdObj.Monthly_TTD_Traffic_Unique_ID__c = monthlyTTd.UniqueKey__c;
            ttdObj.isUsage__c = false;
            ttdList.add(ttdObj);
        }                                                                     
        insert ttdList;
        
        for(TTD_Traffic__c ttdListRec :ttdList){
            ttdListRec.isUsage__c = false;
        }
        
        update ttdList;
        
        Test.startTest();
        OrderServices.UpdateOrderItemforTTD(new Set<Id> {monthlyTTD.Id});
        test.stopTest();
    }

}