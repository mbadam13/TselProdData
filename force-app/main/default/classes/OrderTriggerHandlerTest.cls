/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 04-30-2024
 * @last modified by  : Ahmat Zulkifli Murad
**/
@isTest
public class OrderTriggerHandlerTest {

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
    
    @IsTest
    static void OrderTTDCreationTest(){
        Test.startTest();
        Date today =  System.today(); //Give your date
        Date firstDate = today.toStartOfMonth();
        integer num = 20;
        
        Product2 newProduct = new Product2(
          Name = 'DMP TTD', 
          Description = 'Sample Product',
          IsActive = true,
          Product_Category__c = 'Advertising'
        );
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
            Start_Date__c = Date.newInstance(2024, 1,1),// Start Date
            End_Date__c = Date.newInstance(2024, 12,31),    // End Date
            CurrencyType__c = 'USD',                     // Currency Type
            ConversionRate__c = 15096             // Conversion Rate
        );
        insert exchangeRateObj;
         Id recordTypeId = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('VAT').getRecordTypeId();
        Additional_Setting__c VAT = new Additional_Setting__c(
          recordTypeId = recordTypeId,
          Active__c = true,                         // Active?
          Start_Date__c = Date.newInstance(2024, 1,1),  // Start Date
          End_Date__c = Date.newInstance(2024, 12,31),    // End Date
          Applies_to_Category__c = 'General',          // Applies to Category
          Type__c = 'VAT',                             // Type
          Value_Type__c = 'Decimal',                // Value Type
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
        List<TTD_Traffic__c> ttdupdateList = new List<TTD_Traffic__c>();
        
        for(Integer i=0; i<num; i++) {
            TTD_Traffic__c ttdObj = new TTD_Traffic__c();
            ttdObj.Date__c = Date.newInstance(2024, 1,1);                                                
            ttdObj.Advertiser__c = 'JAGO'+i+ ' (bpu1mr1'+i+')';                                                       
            ttdObj.Partner__c = 'Accuen Indonesia (conk3h1)';                                          
            ttdObj.Campaign__c = 'LFS_AWR_SA_TheTradeDesk_20240405_JagoRamadhan_Reach_CROSS 2024 (fqa7lmo)';
            ttdObj.AdGroup__c = 'All Jago Targeting - Display & GIF (q8s46y6)';                              
            ttdObj.TargetingDataId__c = '286626370';                                                         
            ttdObj.ThirdPartyDataProviderName__c = 'Telkomsel';                                         
            ttdObj.BrandName__c = 'Telkomsel';                                                             
            ttdObj.FullPath__c = 'Telkomsel > Interest-based > Online Banking User';                  
            ttdObj.ThirdPartyDataBrandId__c = 'dr852telkomsel';                                              
            ttdObj.SegmentId__c = 'TSEL_3_31';                                                          
            ttdObj.ImpressionCount__c = 23156.78;                                                        
            ttdObj.TotalDataCostInUSD__c = 0.39;
            ttdObj.SalesNIK__c = '87151';
            ttdList.add(ttdObj);
        }                                                                     
        insert ttdList;
      
        Test.stopTest();
        
    }
    @IsTest
    static void orderItemTTDUpdateTesting(){
        
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
          SOA_Start_Date__c = Date.newInstance(2024, 12,01),
          SOA_End_Date__c = Date.newInstance(2024, 12,31),    // SOA End Date
          SOA_Sources__c = 'TTD',                          // SOA
          Account__c = accountObj.Id                  // Account
        );
        insert SOA;

        Order order = new Order(
          Status = 'Draft',                                                    // Status
          SOA__c = SOA.Id,                                              // SOA
          EffectiveDate = Date.newInstance(2024, 12,01),                              // Order Start Date
          EndDate = Date.newInstance(2024, 12,31),                                    // Order End Date
          Brand__c = brand.Id,                                            // Brand
          Order_Type__c = 'TTD',                                                   // Order Type
          AccountId = accountObj.Id,
          Monthly_Traffic_Unique_Id__c = '2024/12/GDPN - Djarum Super (8ld9xgb)',  // Monthly Traffic Unique Id
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
            Start_Date__c = Date.newInstance(2024, 1,1),// Start Date
            End_Date__c = Date.newInstance(2024, 12,31),    // End Date
            CurrencyType__c = 'USD',                     // Currency Type
            ConversionRate__c = 15096             // Conversion Rate
        );
        insert exchangeRateObj;
         Id recordTypeId = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('VAT').getRecordTypeId();
        Additional_Setting__c VAT = new Additional_Setting__c(
          recordTypeId = recordTypeId,
          Active__c = true,                         // Active?
          Start_Date__c = Date.newInstance(2024, 1,1),  // Start Date
          End_Date__c = Date.newInstance(2024, 12,31),    // End Date
          Applies_to_Category__c = 'General',          // Applies to Category
          Type__c = 'VAT',                             // Type
          Value_Type__c = 'Decimal',                // Value Type
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
          ServiceDate = Date.newInstance(2024, 12,01),                                // Start Date
          ListPrice = 0.00,                                                        // List Price
          EndDate = Date.newInstance(2024, 12,31),                                    // End Date
          UnitPrice = 1619.72,                                                     // Unit Price
          Monthly_Traffic_Unique_Id__c = '2024/12/GDPN - Djarum Super (8ld9xgb)',  // Monthly Traffic Unique Id
          Quantity = 2.56,                                                       // Quantity
          Usage_Actual__c = 2.558214,                                            // Usage Actual
          Campaign_ID__c = '2024_B00008685_S02797_476_5',                          // Campaign ID
          Camp_ID__c = 'S02797_476_5',                                             // Camp ID
          VAT_Related__c = VAT.Id,                                      // VAT Related
          Total_Data_Cost_In_USD__c = 0.305364000000,                              // Total Data Cost In USD
          Exchange_Rates_Related__c = exchangeRateObj.Id,                           // Exchange Rates Related
          PricebookEntryId =pbe_ttd.Id
        //  Discount_Related__c = 'a1P1s00000360cF'                                 // Discount Related
        );
        insert orderProduct;

        MonthlyTTDTraffic__c monthlyTTD = new MonthlyTTDTraffic__c(
          Date__c = Date.newInstance(2024, 12,01),                  // Date
          Advertiser__c = 'GDPN - Djarum Super (8ld9xgb)',         // Advertiser
          Account__c = accountObj.ID,                          // Account
          Brand__c = brand.Id,                            // Brand
       //   Sales__c = '0052v00000fzOlk',                            // Sales
          UniqueKey__c = '2024/12/GDPN - Djarum Super (8ld9xgb)',  // Unique Key
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
            ttdObj.Date__c = Date.newInstance(2024, 1,1);                                                
            ttdObj.Advertiser__c = 'GDPN - Djarum Super (8ld9xgb)';                                                                                                             
            ttdObj.Partner__c = 'PT Alpha Merah Kreasi - GDP N (on8q175)';                                          
            ttdObj.Campaign__c = 'DJARUM SUPER_DISPLAY_Premium Banner Audience Segmenting_MAR2024 (oolncif)';
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
            ttdObj.Monthly_TTD_Traffic_Unique_ID__c =  '2024/12/GDPN - Djarum Super (8ld9xgb)';                                                     
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
    
    @IsTest
    static void orderClientCreateTesting(){
         Test.startTest();
        Date today =  System.today(); //Give your date
        Date firstDate = today.toStartOfMonth();
        integer num = 10;
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser').getRecordTypeId();
       	Brand__c brand = new Brand__c(Name = 'BCA');
        insert brand;
                
        Account acc = new Account(
          RecordTypeId = recordTypeAccId,
          Name = 'Portal Bursa Digital',// Account Name
          Legal_Name__c = 'Portal Bursa Digital',          // Legal Name
          PKS_Tracker__c = 'Pending',                      // PKS Tracker
          Converted_from_Lead__c = false,                  // Converted from Lead
          User_ID__c = 'REG-DS-000000020022',              // User ID
          Account_Type__c = 'Advertiser'                  // Account Type
        );
        insert acc;
        Product2 prodLBASMS = new Product2(
          Name = 'LBA SMS',                     // Product Name
          IsActive = true,                        // Active
          Family = 'Messaging',                   // Product Family
          Product_Type__c = 'SMS',                // Product Type
          ProductCode = 'SMS',                    // Product Code
          Ads_Format__c = 'Text',                 // Ads Format
          Ads_Detail__c = 'LBA Basic',            // Ads Detail
          Ads_Size__c = 'Standard',               // Ads Size
          Product_Channel__c = 'Mobile',          // Product Channel
          Channel_Detail__c = 'Mobile',           // Channel Detail
          Buying_Method__c = 'I/O',               // Buying Method
          Pricing_Model__c = 'CPU',               // Pricing Model
          Rate_Card_Refference__c = 'Messaging',  // Rate Card Refference
          MS_Type__c = 'Non Bulk',                // MS Type
          List_Price__c = 430.00,                 // List Price
          Grouping__c = 'Media Seller',           // Grouping
          Product_Name_MS__c = 'SMS LBA',         // Product Name MS
          Product_Category__c = 'Advertising',    // Product Category
          Description = '430'                    // Product Description
        );
        insert prodLBASMS;
        
        PricebookEntry pbE = new PricebookEntry(
          Product2Id = prodLBASMS.Id,  // Product
          IsActive = false,                  // Active
          Pricebook2Id = Test.getStandardPricebookId(),  // Price Book
          UnitPrice = 15.00                 // List Price
        );
        insert pbE;
        
        integer noOfDays = Date.daysInMonth(firstDate.year(), 12);
        Date endDate = Date.newInstance( firstDate.year(), 12, noOfDays);
        ExchangeRates__c exchangeRateObj = new ExchangeRates__c(
            Start_Date__c = Date.newInstance(2024, 1,1),// Start Date
            End_Date__c = Date.newInstance(2024, 12,31),    // End Date
            CurrencyType__c = 'USD',                     // Currency Type
            ConversionRate__c = 15096             // Conversion Rate
        );
        insert exchangeRateObj;
         Id recordTypeId = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('VAT').getRecordTypeId();
        Additional_Setting__c VAT = new Additional_Setting__c(
          recordTypeId = recordTypeId,
          Active__c = true,                         // Active?
          Start_Date__c = Date.newInstance(2024, 1,1),  // Start Date
          End_Date__c = Date.newInstance(2024, 12,31),    // End Date
          Applies_to_Category__c = 'General',          // Applies to Category
          Type__c = 'VAT',                             // Type
          Value_Type__c = 'Decimal',                // Value Type
          Value__c = 1.11,                           // Value
          Object_Name__c = 'VAT'
        );
        insert VAT;
       
        List<Client_Traffic__c> clientList = new List<Client_Traffic__c>();
        
        for(Integer i=1; i<num; i++) {
            Client_Traffic__c clientObj = new Client_Traffic__c(
              
              Campaign_ID__c = '1043871',                           // Campaign ID
              ID_Iklan__c = '1043871',                              // ID Iklan
              tgl_Tayang__c = Date.newInstance(2024, i,1),           // tgl Tayang
              Judul_Pesan_Iklan__c = 'IS BCA 3 MAR - ANDROID 500',  // Judul Pesan Iklan
              Operator_Seluler__c = 'TELKOMSEL',                    // Operator Seluler
              Kategori_Iklan__c = 'LBA',                            // Kategori Iklan
              Tipe_Kanal__c = 'SMS',                                // Tipe Kanal
              Product_Name__c = 'SMS LBA',                          // Product Name
              Detil_Status__c = 'Sukses: 499 Gagal: 1',             // Detil Status
              Brand__c = 'BCA',                                     // Brand
              ID__c = 'REG-DS-000000020022',                        // ID
              Sales_NIK__c = '87152'                               // Sales NIK
            );
            clientList.add(clientObj);
        }                                                                     
        insert clientList;
    }

    @isTest
    static void orderClientUpdateTesting(){
     Date today =  System.today(); //Give your date
     Date firstDate = today.toStartOfMonth();
     integer num = 3;
     Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser').getRecordTypeId();
      Brand__c brand = new Brand__c(Name = 'BCA');
     insert brand;
             
     Account acc = new Account(
       RecordTypeId = recordTypeAccId,
       Name = 'Portal Bursa Digital',// Account Name
       Legal_Name__c = 'Portal Bursa Digital',          // Legal Name
       PKS_Tracker__c = 'Pending',                      // PKS Tracker
       Converted_from_Lead__c = false,                  // Converted from Lead
       User_ID__c = 'REG-DS-000000020022',              // User ID
       Account_Type__c = 'Advertiser'                  // Account Type
     );
     insert acc;
     Product2 prodLBASMS = new Product2(
       Name = 'LBA SMS',                     // Product Name
       IsActive = true,                        // Active
       Family = 'Messaging',                   // Product Family
       Product_Type__c = 'SMS',                // Product Type
       ProductCode = 'SMS',                    // Product Code
       Ads_Format__c = 'Text',                 // Ads Format
       Ads_Detail__c = 'LBA Basic',            // Ads Detail
       Ads_Size__c = 'Standard',               // Ads Size
       Product_Channel__c = 'Mobile',          // Product Channel
       Channel_Detail__c = 'Mobile',           // Channel Detail
       Buying_Method__c = 'I/O',               // Buying Method
       Pricing_Model__c = 'CPU',               // Pricing Model
       Rate_Card_Refference__c = 'Messaging',  // Rate Card Refference
       MS_Type__c = 'Non Bulk',                // MS Type
       List_Price__c = 430.00,                 // List Price
       Grouping__c = 'Media Seller',           // Grouping
       Product_Name_MS__c = 'SMS LBA',         // Product Name MS
       Product_Category__c = 'Advertising',    // Product Category
       Description = '430'                    // Product Description
     );
     insert prodLBASMS;
     
     PricebookEntry pbE = new PricebookEntry(
       Product2Id = prodLBASMS.Id,  // Product
       IsActive = false,                  // Active
       Pricebook2Id = Test.getStandardPricebookId(),  // Price Book
       UnitPrice = 15.00                 // List Price
     );
     insert pbE;
     
     integer noOfDays = Date.daysInMonth(firstDate.year(), 12);
     Date endDate = Date.newInstance( firstDate.year(), 12, noOfDays);
     ExchangeRates__c exchangeRateObj = new ExchangeRates__c(
         Start_Date__c = Date.newInstance(2024, 1,1),// Start Date
         End_Date__c = Date.newInstance(2024, 12,31),    // End Date
         CurrencyType__c = 'USD',                     // Currency Type
         ConversionRate__c = 15096             // Conversion Rate
     );
     insert exchangeRateObj;
      Id recordTypeId = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('VAT').getRecordTypeId();
     Additional_Setting__c VAT = new Additional_Setting__c(
       recordTypeId = recordTypeId,
       Active__c = true,                         // Active?
       Start_Date__c = Date.newInstance(2024, 1,1),  // Start Date
       End_Date__c = Date.newInstance(2024, 12,31),    // End Date
       Applies_to_Category__c = 'General',          // Applies to Category
       Type__c = 'VAT',                             // Type
       Value_Type__c = 'Decimal',                // Value Type
       Value__c = 1.11,                           // Value
       Object_Name__c = 'VAT'
     );
     insert VAT;
    
     List<Client_Traffic__c> clientList = new List<Client_Traffic__c>();
     
     for(Integer i=1; i<num; i++) {
         Client_Traffic__c clientObj = new Client_Traffic__c(
           
           Campaign_ID__c = '1043871',                           // Campaign ID
           ID_Iklan__c = '1043871',                              // ID Iklan
           tgl_Tayang__c = Date.newInstance(2024, i,1),           // tgl Tayang
           Judul_Pesan_Iklan__c = 'IS BCA 3 MAR - ANDROID 500',  // Judul Pesan Iklan
           Operator_Seluler__c = 'TELKOMSEL',                    // Operator Seluler
           Kategori_Iklan__c = 'LBA',                            // Kategori Iklan
           Tipe_Kanal__c = 'SMS',                                // Tipe Kanal
           Product_Name__c = 'SMS LBA',                          // Product Name
           Detil_Status__c = 'Sukses: 499 Gagal: 1',             // Detil Status
           Brand__c = 'BCA',                                     // Brand
           ID__c = 'REG-DS-000000020022',                        // ID
           Sales_NIK__c = '87152'                               // Sales NIK
         );
         clientList.add(clientObj);
     }                 
     
     ClientTrafficServices.evaluateClientTraffic(clientList);
     insert clientList;

     set<id> clientTrafficIds = new Set<id>();
     for(Client_Traffic__c clientListRec :clientList){
      clientTrafficIds.add(clientListRec.id);
     }

     ClientTrafficServices.createMonthlyClientTraffic(clientTrafficIds);

     System.debug('clientList: ' + json.serialize(clientList));
    
      set<string> monthClientTrafficIds = new Set<string>();
      for(Client_Traffic__c clientListRec :clientList){
        monthClientTrafficIds.add(clientListRec.Monthly_Client_Traffic_Unique_ID__c);
      }

      set<string> newMonthlyClientTrafficIds = new set<string>();
      List<Monthly_Client_Traffic__c> monthClientTraffList = [
        SELECT id, unique_id__c from Monthly_Client_Traffic__c where unique_id__c IN:monthClientTrafficIds
      ];
      
      for(Monthly_Client_Traffic__c monthClientTraffListRec :monthClientTraffList){
        newMonthlyClientTrafficIds.Add(monthClientTraffListRec.unique_id__c);
      }
      System.debug('newMonthlyClientTrafficIds: ' + newMonthlyClientTrafficIds);
      
     test.startTest();
     OrderServices.UpdateOrderItemforClient(newMonthlyClientTrafficIds);
     test.stopTest();
    }
    
    @IsTest
    static void orderProgCreationTest(){
        Test.startTest();
        Date today =  System.today(); //Give your date
        Date firstDate = today.toStartOfMonth();
        integer num = 10;
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser').getRecordTypeId();
        Account acc = new Account(
          Name = 'Pubmatic Inc.',// Account Name
          RecordTypeId = recordTypeAccId,               // Account Record Type
          Legal_Name__c = 'Pubmatic Inc.',          // Legal Name
          PKS_Tracker__c = 'Pending',               // PKS Tracker
          Converted_from_Lead__c = false,           // Converted from Lead
          User_ID__c = 'Pubmatic',                  // User ID
          Account_Type__c = 'Advertiser'           // Account Type
        );
        insert acc;
        
        Product2 productCPM = new Product2(
          Name = 'Tadex Banner Image Medium (300x250) CPM',       // Product Name
          IsActive = false,                                         // Active
          Family = 'Display',                                       // Product Family
          Product_Type__c = 'Banner',                               // Product Type
          ProductCode = 'Banner',                                   // Product Code
          Ads_Format__c = 'Image',                                  // Ads Format
          Ads_Size__c = 'Medium',                                   // Ads Size
          Product_Channel__c = 'Off Deck',                          // Product Channel
          Channel_Detail__c = 'Off Deck',                           // Channel Detail
          Buying_Method__c = 'Programmatic',                        // Buying Method
          Pricing_Model__c = 'CPM',                                 // Pricing Model
          Product_Group__c = 'Offdeck',                             // Product Group
          List_Price__c = 15.00,                                    // List Price
          Grouping__c = 'Direct Sales',                             // Grouping
          Product_Name_MS__c = 'Tadex Banner Image (300x250) CPM',  // Product Name MS
          Product_Category__c = 'Tadex',                            // Product Category
          Description = '15'                                       // Product Description
        );
        insert productCPM;
        
        PricebookEntry pbE = new PricebookEntry(
          Product2Id = productCPM.Id,  // Product
          IsActive = false,                  // Active
          Pricebook2Id = Test.getStandardPricebookId(),  // Price Book
          UnitPrice = 15.00                 // List Price
        );
        insert pbE;
        
        integer noOfDays = Date.daysInMonth(firstDate.year(), 12);
        Date endDate = Date.newInstance( firstDate.year(), 12, noOfDays);
        ExchangeRates__c exchangeRateObj = new ExchangeRates__c(
            Start_Date__c = Date.newInstance(2024, 1,1),// Start Date
            End_Date__c = Date.newInstance(2024, 12,31),    // End Date
            CurrencyType__c = 'USD',                     // Currency Type
            ConversionRate__c = 15096             // Conversion Rate
        );
        insert exchangeRateObj;
         Id recordTypeId = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('VAT').getRecordTypeId();
        Additional_Setting__c VAT = new Additional_Setting__c(
          recordTypeId = recordTypeId,
          Active__c = true,                         // Active?
          Start_Date__c = Date.newInstance(2024, 1,1),  // Start Date
          End_Date__c = Date.newInstance(2024, 12,31),    // End Date
          Applies_to_Category__c = 'General',          // Applies to Category
          Type__c = 'VAT',                             // Type
          Value_Type__c = 'Decimal',                // Value Type
          Value__c = 1.11,                           // Value
          Object_Name__c = 'VAT'
        );
        insert VAT;
       
        List<Programmatic_Traffic__c> progList = new List<Programmatic_Traffic__c>();
        
        for(Integer i=0; i<num; i++) {
            Programmatic_Traffic__c progObj = new Programmatic_Traffic__c(
              Channel__c = 'TADEX',                                                             // Channel
              Campaign__c = 'TADEX_TELKOMSEL_TTD_3300_DISPLAY_17012024-31012024_Testing-TADEX2',  // Campaign
              Site__c = '968348',                                                                 // Site
              Deal__c = 'PM-HYOJ-6184',                                                           // Deal
              Periode__c = Date.newInstance(2024, 1,1),                                            // Periode
              Paid_Impression__c = 48,                                                          // Paid Impression
              Revenue__c = 0.03456,                                                             // Revenue
              Brand__c = 'TADEX2',                                                                // Brand
              Inventory__c = 'Tadex Banner Image (300x250) CPM',                                  // Inventory
              Mitra__c = 'Pubmatic',                                                              // Mitra
              Sales_NIK__c = '87151'                                                             // Sales NIK
            );
           // insert sobj;
            progList.add(progObj);
        }                                                                     
        insert progList;
      
        Test.stopTest();        
    } 

    @istest
    static void orderProgUpdateTest(){
        Date today =  System.today(); //Give your date
        Date firstDate = today.toStartOfMonth();
        integer num = 10;
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser').getRecordTypeId();
        Account acc = new Account(
          Name = 'Pubmatic Inc.',// Account Name
          RecordTypeId = recordTypeAccId,               // Account Record Type
          Legal_Name__c = 'Pubmatic Inc.',          // Legal Name
          PKS_Tracker__c = 'Pending',               // PKS Tracker
          Converted_from_Lead__c = false,           // Converted from Lead
          User_ID__c = 'Pubmatic',                  // User ID
          Account_Type__c = 'Advertiser'           // Account Type
        );
        insert acc;
        
        Product2 productCPM = new Product2(
          Name = 'Tadex Banner Image Medium (300x250) CPM',       // Product Name
          IsActive = false,                                         // Active
          Family = 'Display',                                       // Product Family
          Product_Type__c = 'Banner',                               // Product Type
          ProductCode = 'Banner',                                   // Product Code
          Ads_Format__c = 'Image',                                  // Ads Format
          Ads_Size__c = 'Medium',                                   // Ads Size
          Product_Channel__c = 'Off Deck',                          // Product Channel
          Channel_Detail__c = 'Off Deck',                           // Channel Detail
          Buying_Method__c = 'Programmatic',                        // Buying Method
          Pricing_Model__c = 'CPM',                                 // Pricing Model
          Product_Group__c = 'Offdeck',                             // Product Group
          List_Price__c = 15.00,                                    // List Price
          Grouping__c = 'Direct Sales',                             // Grouping
          Product_Name_MS__c = 'Tadex Banner Image (300x250) CPM',  // Product Name MS
          Product_Category__c = 'Tadex',                            // Product Category
          Description = '15'                                       // Product Description
        );
        insert productCPM;
        
        PricebookEntry pbE = new PricebookEntry(
          Product2Id = productCPM.Id,  // Product
          IsActive = false,                  // Active
          Pricebook2Id = Test.getStandardPricebookId(),  // Price Book
          UnitPrice = 15.00                 // List Price
        );
        insert pbE;
        
        integer noOfDays = Date.daysInMonth(firstDate.year(), 12);
        Date endDate = Date.newInstance( firstDate.year(), 12, noOfDays);
        ExchangeRates__c exchangeRateObj = new ExchangeRates__c(
            Start_Date__c = Date.newInstance(2024, 1,1),// Start Date
            End_Date__c = Date.newInstance(2024, 12,31),    // End Date
            CurrencyType__c = 'USD',                     // Currency Type
            ConversionRate__c = 15096             // Conversion Rate
        );
        insert exchangeRateObj;
         Id recordTypeId = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('VAT').getRecordTypeId();
        Additional_Setting__c VAT = new Additional_Setting__c(
          recordTypeId = recordTypeId,
          Active__c = true,                         // Active?
          Start_Date__c = Date.newInstance(2024, 1,1),  // Start Date
          End_Date__c = Date.newInstance(2024, 12,31),    // End Date
          Applies_to_Category__c = 'General',          // Applies to Category
          Type__c = 'VAT',                             // Type
          Value_Type__c = 'Decimal',                // Value Type
          Value__c = 1.11,                           // Value
          Object_Name__c = 'VAT'
        );
        insert VAT;
       
        List<Programmatic_Traffic__c> progList = new List<Programmatic_Traffic__c>();
        
        for(Integer i=0; i<num; i++) {
            Programmatic_Traffic__c progObj = new Programmatic_Traffic__c(
              Channel__c = 'TADEX',                                                             // Channel
              Campaign__c = 'TADEX_TELKOMSEL_TTD_3300_DISPLAY_17012024-31012024_Testing-TADEX2',  // Campaign
              Site__c = '968348',                                                                 // Site
              Deal__c = 'PM-HYOJ-6184',                                                           // Deal
              Periode__c = Date.newInstance(2024, 1,1),                                            // Periode
              Paid_Impression__c = 48,                                                          // Paid Impression
              Revenue__c = 0.03456,                                                             // Revenue
              Brand__c = 'TADEX2',                                                                // Brand
              Inventory__c = 'Tadex Banner Image (300x250) CPM',                                  // Inventory
              Mitra__c = 'Pubmatic',                                                              // Mitra
              Sales_NIK__c = '87151' 
                                                                      // Sales NIK
            );
            progList.add(progObj);
        }                

        ProgrammaticTrafficServices.evaluateProgrammaticTraffic(progList);                                                     
        insert progList;

        System.debug('progList: ' + json.serialize(progList));
        set<string> monthlyProgTrafficIds = new set<string>();
        for(Programmatic_Traffic__c progListRec :progList){
          monthlyProgTrafficIds.add(progListRec.Monthly_Prog_Traffic_Unique_id__c);
          progListRec.isUsage__c = false;
        }

        update progList;

        Test.startTest();
        OrderServices.UpdateOrderItemforProg(monthlyProgTrafficIds);
        Test.stopTest();  
    }

    @isTest
    static void updateactualUsage(){
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

        // for quoteation
        Opportunity oppRecord1 = new Opportunity(
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
            Pricebook2Id = Test.getStandardPricebookId()            
        );
        insert oppRecord1;
        
        OpportunityLineItem oli1 = new OpportunityLineItem(
            OpportunityId = oppRecord1.Id,// Opportunity
            Product2Id = prod.Id,     // Product
            Discount__c = 0.00,               // Discount (%)
            PricebookEntryId = pbEntry.Id,
            UnitPrice = 500.00,                 // Sales Price
            Quantity = 1234.00              // Quantity
        );
        insert oli1;

        oppRecord1.StageName = 'Closed Won';
        update oppRecord1;
        
        // Test.startTest();
       
        Invoice__c invRec1 = new Invoice__c(
            Mitra__c = acc.id,                                   // Mitra
            No_Invoice__c = 'TS.123123.4121233125',                        // No Invoice
            No_Master__c = '123123',                                    // No Master
            Tanggal_Invoice__c = Date.newInstance(2024, 12,01),            // Tanggal Invoice
            No_Individual__c = '3123123',                               // No Individual
            Jangka_Waktu_PKS__c = '1 Januari 2024 - 31 Desember 2025',  // Jangka Waktu PKS
            Hak_Telkomsel__c = 150000                                 // Hak Telkomsel
            // VAT_Related__c = 'undefined'                               // VAT Related
        );
        insert invRec1;

        // insert soaRecord;
        Quote quoteRec = new Quote(
            Name = 'TSEL / Q02250 / dev1/9/25/2024',        // Quotation Name
            OpportunityId = oppRecord1.id,                      // Opportunity Name
            ContactId = contactRec.id,                          // Contact Name
            Status = 'Final',                                 // Status
            Start_Date__c = Date.newInstance(2024, 1,01),       // Start Date
            End_Date__c = Date.newInstance(2029, 12,01),         // End Date
            Invoice__c = invRec1.id                         // Invoice
        );

        insert quoteRec; 

        Order order1 = new Order(
          Status = 'Draft',                                                    // Status
          quoteid = quoteRec.Id,                                              // SOA
          EffectiveDate = Date.newInstance(2024, 12,01),                              // Order Start Date
          EndDate = Date.newInstance(2024, 12,31),                                                      // Order Type
          AccountId = acc.Id,
          Pricebook2Id = Test.getStandardPricebookId()
        );
        insert order1;

        OrderItem orderItem1 = new OrderItem();
            orderItem1.OrderId = order1.id; 
            orderItem1.Product2Id = prod.Id;
            orderItem1.PricebookEntryId = pbEntry.id;
            orderItem1.Quantity = 10; 
            orderItem1.UnitPrice = 100.00; 
        insert orderItem1;

        test.startTest();
        orderItem1.Usage_Actual__c = orderItem1.Quantity;
        update orderItem1;
        
        test.stopTest();
    }

    @isTest
    static void MapOrderwithSOAnotMapping(){
        Date today =  System.today(); //Give your date
        Date firstDate = today.toStartOfMonth();
        integer num = 10;
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser').getRecordTypeId();
        Account acc = new Account(
          Name = 'Pubmatic Inc.',// Account Name
          RecordTypeId = recordTypeAccId,               // Account Record Type
          Legal_Name__c = 'Pubmatic Inc.',          // Legal Name
          PKS_Tracker__c = 'Pending',               // PKS Tracker
          Converted_from_Lead__c = false,           // Converted from Lead
          User_ID__c = 'Pubmatic',                  // User ID
          Account_Type__c = 'Advertiser'           // Account Type
        );
        insert acc;
        
        Product2 productCPM = new Product2(
          Name = 'Tadex Banner Image Medium (300x250) CPM',       // Product Name
          IsActive = false,                                         // Active
          Family = 'Display',                                       // Product Family
          Product_Type__c = 'Banner',                               // Product Type
          ProductCode = 'Banner',                                   // Product Code
          Ads_Format__c = 'Image',                                  // Ads Format
          Ads_Size__c = 'Medium',                                   // Ads Size
          Product_Channel__c = 'Off Deck',                          // Product Channel
          Channel_Detail__c = 'Off Deck',                           // Channel Detail
          Buying_Method__c = 'Programmatic',                        // Buying Method
          Pricing_Model__c = 'CPM',                                 // Pricing Model
          Product_Group__c = 'Offdeck',                             // Product Group
          List_Price__c = 15.00,                                    // List Price
          Grouping__c = 'Direct Sales',                             // Grouping
          Product_Name_MS__c = 'Tadex Banner Image (300x250) CPM',  // Product Name MS
          Product_Category__c = 'Tadex',                            // Product Category
          Description = '15'                                       // Product Description
        );
        insert productCPM;
        
        PricebookEntry pbE = new PricebookEntry(
          Product2Id = productCPM.Id,  // Product
          IsActive = false,                  // Active
          Pricebook2Id = Test.getStandardPricebookId(),  // Price Book
          UnitPrice = 15.00                 // List Price
        );
        insert pbE;
        
        integer noOfDays = Date.daysInMonth(firstDate.year(), 12);
        Date endDate = Date.newInstance( firstDate.year(), 12, noOfDays);
        ExchangeRates__c exchangeRateObj = new ExchangeRates__c(
            Start_Date__c = Date.newInstance(2024, 1,1),// Start Date
            End_Date__c = Date.newInstance(2024, 12,31),    // End Date
            CurrencyType__c = 'USD',                     // Currency Type
            ConversionRate__c = 15096             // Conversion Rate
        );
        insert exchangeRateObj;
         Id recordTypeId = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('VAT').getRecordTypeId();
        Additional_Setting__c VAT = new Additional_Setting__c(
          recordTypeId = recordTypeId,
          Active__c = true,                         // Active?
          Start_Date__c = Date.newInstance(2024, 1,1),  // Start Date
          End_Date__c = Date.newInstance(2024, 12,31),    // End Date
          Applies_to_Category__c = 'General',          // Applies to Category
          Type__c = 'VAT',                             // Type
          Value_Type__c = 'Decimal',                // Value Type
          Value__c = 1.11,                           // Value
          Object_Name__c = 'VAT'
        );
        insert VAT;
       
        List<Programmatic_Traffic__c> progList = new List<Programmatic_Traffic__c>();
        
        for(Integer i=0; i<num; i++) {
            Programmatic_Traffic__c progObj = new Programmatic_Traffic__c(
              Channel__c = 'TADEX',                                                             // Channel
              Campaign__c = 'TADEX_TELKOMSEL_TTD_3300_DISPLAY_17012024-31012024_Testing-TADEX2',  // Campaign
              Site__c = '968348',                                                                 // Site
              Deal__c = 'PM-HYOJ-6184',                                                           // Deal
              Periode__c = Date.newInstance(2024, 1,1),                                            // Periode
              Paid_Impression__c = 48,                                                          // Paid Impression
              Revenue__c = 0.03456,                                                             // Revenue
              Brand__c = 'TADEX2',                                                                // Brand
              Inventory__c = 'Tadex Banner Image (300x250) CPM',                                  // Inventory
              Mitra__c = 'Pubmatic',                                                              // Mitra
              Sales_NIK__c = '87151'                                                             // Sales NIK
            );
           
            progList.add(progObj);
        }                                                                     
        insert progList;

        set<String> monthlyProgTrafficIds = new set<String>();
        set<Date> soaDates = new set<Date>();
        for(Programmatic_Traffic__c progListRec :progList){
          date soaStartDate = Date.newInstance(progListRec.periode__c.year(), progListRec.periode__c.month(), 1);

          monthlyProgTrafficIds.add(progListRec.Monthly_Prog_Traffic_Unique_id__c);
          soaDates.add(soaStartDate);
        }

        MonthlyClientTrafficServices.createSOAforMonthlyClientTraffic(soaDates);
        System.debug('monthlyProgTrafficIds: ' + monthlyProgTrafficIds);
        
        list<order> orderMapWithSOAList = [
          SELECT 
          id,
          EffectiveDate,
          soa__c,
          soa__r.SOA_start_date__c
          FROM order where monthly_traffic_unique_id__c IN:monthlyProgTrafficIds
        ];

        set<Id> orderMapWithSOAIds = new Set<Id>();
        set<Id> SOAIds = new Set<Id>();
        for(order orderMapWithSOAListRec :orderMapWithSOAList){
          orderMapWithSOAIds.add(orderMapWithSOAListRec.id);
          orderMapWithSOAListRec.soa__c = null;
          soaDates.add(orderMapWithSOAListRec.soa__r.SOA_start_date__c);
        }

        System.debug('orderMapWithSOAListBefore: ' + json.serialize(orderMapWithSOAList));
        update orderMapWithSOAList;
        System.debug('orderMapWithSOAListAfter: ' + json.serialize(orderMapWithSOAList));

        Test.startTest();
        OrderServices.MapOrderwithSOAnotMapping(orderMapWithSOAIds, 'Programmatic');
        Test.stopTest();   
    }
    
}