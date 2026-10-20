@isTest
public class MonthlyProgrammaticTrafficHandlerTest {
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
    static void monthlyTest(){
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
       
        List<Programmatic_Traffic__c> progList = new List<Programmatic_Traffic__c>();
        
        for(Integer i=0; i<num; i++) {
            Programmatic_Traffic__c progObj = new Programmatic_Traffic__c(
              Channel__c = 'TADEX',                                                             // Channel
              Campaign__c = 'TADEX_TELKOMSEL_TTD_3300_DISPLAY_17012023-31012023_Testing-TADEX2',  // Campaign
              Site__c = '968348',                                                                 // Site
              Deal__c = 'PM-HYOJ-6184',                                                           // Deal
              Periode__c = Date.newInstance(2023, 1,1),                                            // Periode
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
}