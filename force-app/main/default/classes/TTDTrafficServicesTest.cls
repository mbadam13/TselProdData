/**
* @description       : 
* @author            : Diky Nurosid
* @group             : 
* @last modified on  : 10-21-2023
* @last modified by  : Ahmat Zulkifli Murad
**/
@isTest
public class TTDTrafficServicesTest {
    
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
    static void TTDTrafficServicesTest(){
         Test.startTest();
        Date today =  System.today(); //Give your date
        Date firstDate = today.toStartOfMonth();
        integer num = 10;
        
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
        List<TTD_Traffic__c> ttdupdateList = new List<TTD_Traffic__c>();
        
        for(Integer i=0; i<num; i++) {
            TTD_Traffic__c ttdObj = new TTD_Traffic__c();
            ttdObj.Date__c = Date.newInstance(2023, 1,1);                                                
            ttdObj.Advertiser__c = 'JAGO'+i+ ' (bpu1mr1'+i+')';                                                       
            ttdObj.Partner__c = 'Accuen Indonesia (conk3h1)';                                          
            ttdObj.Campaign__c = 'LFS_AWR_SA_TheTradeDesk_20230405_JagoRamadhan_Reach_CROSS 2023 (fqa7lmo)';
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
}