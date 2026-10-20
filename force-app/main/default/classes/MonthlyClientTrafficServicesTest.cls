@isTest
public class MonthlyClientTrafficServicesTest {
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
    static void ClientTrafficServicesTesting(){
         Test.startTest();
        Date today =  System.today(); //Give your date
        Date firstDate = today.toStartOfMonth();
        integer num = 10;
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser').getRecordTypeId();
       
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
       
        List<Client_Traffic__c> clientList = new List<Client_Traffic__c>();
        
        for(Integer i=1; i<num; i++) {
            Client_Traffic__c clientObj = new Client_Traffic__c(
              
              Campaign_ID__c = '1043871',                           // Campaign ID
              ID_Iklan__c = '1043871',                              // ID Iklan
              tgl_Tayang__c = Date.newInstance(2023, i,1),           // tgl Tayang
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
      
        Test.stopTest(); 
    }
    
    @IsTest
    static void ClientTrafficServicesBrandTesting(){
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
       
        List<Client_Traffic__c> clientList = new List<Client_Traffic__c>();
        
        for(Integer i=1; i<num; i++) {
            Client_Traffic__c clientObj = new Client_Traffic__c(
              
              Campaign_ID__c = '1043871',                           // Campaign ID
              ID_Iklan__c = '1043871',                              // ID Iklan
              tgl_Tayang__c = Date.newInstance(2023, i,1),           // tgl Tayang
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
      
        Test.stopTest(); 
    }
}