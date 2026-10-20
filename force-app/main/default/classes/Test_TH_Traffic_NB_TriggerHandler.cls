/**
 * @description       : 
 * @author            :
 * @group             : 
 * @last modified on  : 07-06-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   07-04-2023   Novando Utoyo Agmawan   Initial Version
**/

@isTest
public class Test_TH_Traffic_NB_TriggerHandler {

   @TestSetup
   static void makeData() {
      // Create use case setting
      Use_Case_Setting__c useCase = new Use_Case_Setting__c();
      useCase.Name = 'OTP';
      useCase.Code__c = 'otp'; 
      insert useCase; 
      
      //create media seller account
      Id recordTypeId_AddtSet1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Media Seller').getRecordTypeId();
      Account acc = new Account();
      acc.RecordTypeId = recordTypeId_AddtSet1;
      acc.Name = 'DWS1';
      acc.Account_Type__c = 'Media_Seller';
      acc.Legal_Name__c = 'DWS1';
      acc.prefix_ms__c = 'DWS1';
      acc.Active__c = true;
      insert acc;
   
      system.debug('Account: ' + json.serialize(acc));

      //create special price whitelist
      Special_Price_Whitelist__c specialPriceRec = new Special_Price_Whitelist__c(
      Active__c = true,                                            // Active?
      CP_Name_SID__c = 'sms-r-dws-dws-ban_rdwsbanbrisblrja1po78y',  // CP Name + SID
      Brand__c = 'BRI'                                             // Brand
      );
      insert specialPriceRec;

      //create onof trigger Trigger_Setting__c MonthlyDiscountIMSTriggerAcitvation = Trigger_Setting__c.getInstance('MonthlyDiscountIMSTrigger');
      Trigger_Setting__c MonthlyDiscountIMSTriggerAcitvation = new Trigger_Setting__c();
      MonthlyDiscountIMSTriggerAcitvation.name = 'MonthlyDiscountIMSTrigger';
      MonthlyDiscountIMSTriggerAcitvation.Object_Name__c = 'Monthly_Discount_Inventory_Media_Seller__c'; 
      MonthlyDiscountIMSTriggerAcitvation.IsActive__c = true;

      insert MonthlyDiscountIMSTriggerAcitvation;

      //create monthlydiscountinv for traffic
      Monthly_Discount_Inventory_Media_Seller__c monthDiscountInventoryMedSelBulkSMS = new Monthly_Discount_Inventory_Media_Seller__c(
         Media_Seller__c = acc.id,                                                                                // Media Seller
         Start_Date__c = Date.newInstance(2023, 01, 01),                                                                     // Start Date
         //Product_Name__c = 'undefined',                                                                                  // Product Name
         End_Date__c = Date.newInstance(2023, 12, 31),                                                                       // End Date
         Product_Services_and_Code__c = 'Bulk IVR;Bulk SMS;Bulk MMS;Bulk USSD;Non Bulk IVR;Non Bulk SMS;Non Bulk MMS;Non Bulk NSP;Non Bulk Symphony;Non Bulk USSD',                                                                           // Product Services and Code
         //Additional_Setting__c = 'undefined',                                                                            // Additional Setting
         Discount_Type__c = 'Percentage',                                                                                    // Discount Type
         Value__c = 35,                                                                                            // Value
         Brand__c = 'All Client',                                                                                        // Brand
         Revenue_From_Traffic__c = 0.00,                                                                                 // Revenue From Traffic
         Current_Revenue_from_traffic__c = 837886396981.90,                                                              // Current Revenue from traffic
         Unique_ID__c = '2023-01-01 00:00:00-2023-01-31 00:00:00-0011s00001jLQR4AAO-null-Bulk IVR;Bulk SMS;Bulk MMS;Bulk USSD;Non Bulk IVR;Non Bulk SMS;Non Bulk MMS;Non Bulk NSP;Non Bulk Symphony;Non Bulk USSD-All Client'  // Unique ID
         );
   
      insert monthDiscountInventoryMedSelBulkSMS;


      //create media seller mapping
      Media_Seller_Mapping_Settings__c medSellMappingSettings = new Media_Seller_Mapping_Settings__c();
      medSellMappingSettings.name = 'DWS1';
      medSellMappingSettings.Key__c = 'dws';
      medSellMappingSettings.Media_Seller_SFID__c = acc.id;

      insert medSellMappingSettings;

      // creteate media seller product setting pnv
      Media_Seller_Product_Settings__c medSelProductSettings = new Media_Seller_Product_Settings__c();
      medSelProductSettings.name = '1';
      medSelProductSettings.is_Active__c = true ;
      medSelProductSettings.Product_Code__c = '	SMS';
      medSelProductSettings.Product_Name__c = '	LBA ON Location';
      medSelProductSettings.Product_Services__c = 'Non Bulk';
      medSelProductSettings.Product_SFID__c = '01t2u0000004Asd';

      insert medSelProductSettings;

   }

   @isTest
   public static void trafficNonBulkLBA(){
      account accid = [select id from account where name = 'dws1' limit 1];
      Traffic_Non_Bulk__c tnbLBA = new Traffic_Non_Bulk__c(
      CP_Name__c = 'Dws Mdm Oth',                                                                                                                                   // CP Name
      campaign_id__c = '332978',                                                                                                                                      // campaign_id
      Campaign_Type__c = 'LBA ON Location',                                                                                                                           // Campaign Type
      Demand_ID__c = '458360',                                                                                                                                        // Demand ID
      Date__c = Date.newInstance(2023, 01, 01),                                                                                                                     // Date
      start_date__c = Date.newInstance(2023, 01, 01),                                                                                                                     // start_date
      end_date__c = Date.newInstance(2023, 01, 11),                                                                                                                       // end_date
      message_success__c = 2000, 
      total_messages__c = 2000,                                                                                                                                  // Traffic
      Broadcast__c = 2000,                                                                                                                                         // Broadcast
      Failed__c = 0,                                                                                                                                                // Failed
      //Usage_Traffic_Media_Seller__c = 'undefined',                                                                                                                    // Usage Traffic Media Seller
      //Product__c = 'undefined',                                                                                                                                       // Product
      //Discount__c = 35.00,                                                                                                                                            // Discount
      List_Price__c = 430.00,                                                                                                                                         // List Price
      Traffic_Non_Bulk_Unique_ID__c = '202301-2-332978-458362',                                                                                                       // Traffic Non Bulk Unique ID                                                                                                        // Created Ad
      Pesan__c = '5 Cara HEMAT! Hanya di SUPER INDO.Ayam BROILER Rp 3,250/100gr, TROPICAL Minyak Goreng Refill 2L Rp 34.700/pch (max.4pch). Berlaku 20 - 22 Jan23',  // Pesan
      Campaign_Name_Text__c = 'SUPER INDO_21Jan23',                                                                                                                   //Campaign Name Text
      Advance_Profiling_Price__c = 300,                                                                                                                               // Advance Profiling Price
      Product_Services__c = 'Non Bulk',                                                                                                                               // Product Services
      Brand__c = 'All Client',                                                                                                                                        // Brand
      Product_Code__c = 'SMS',
      user_id__c = accid.id                                                                                                                                        // Product Code
      );

      test.startTest();
      insert tnbLBA;
      test.stopTest();
   }

   /*
   //oldWay
   public static testMethod void Test_TH_Traffic_NB_TriggerHandler() {
      Test.startTest();
      /*
      Account acc = new Account ();
      acc.Name='IMS';
      acc.Account_Type__c='Media_Seller';
      acc.Legal_Name__c='IMS';
      acc.ParentId=Label.parentid;
      acc.Category__c='others';
      acc.Kategori_Industri__c=Label.Kategori_Industri;
      acc.prefix_ms__c='ims';
      insert acc;
      
      Order_Non_Bulk__c ONB = new Order_Non_Bulk__c();
      ONB.Campaign_Name__c='Ini Testing ONB';
      ONB.Channel__c='SMS';
      ONB.Order_Start_Date__c=system.today();
      ONB.Order_End_Date__c=system.today();
      ONB.Kategori_Industri__c=Label.Kategori_Industri;
      ONB.Campaign_Type__c='TARGETED';
      ONB.Agency__c=acc.id;
      insert ONB;
      
      Order_Product_Non_Bulk__c OPNB = new Order_Product_Non_Bulk__c();
      OPNB.Product__c=Label.Product_NB;
      OPNB.Order_Non_Bulk_Number__c=ONB.id;
      OPNB.Quantity__c=1000;
      Insert OPNB;
      
      Campaign_Order__c newCO = new Campaign_Order__c();
      newCO.Masking_Sender_Brand__c = 'Testing';
      newCO.Profiling_Lokasi__c= 'Testing';
      newCO.Gender__c='All';
      newCO.Umur__c='>24tahun';
      newCO.ARPU__c='>10000';
      newCO.Religion__c='All';
      newCO.Channel__c='SMS Targeted';
      newCO.Start_Campaign__c = system.now();
      newCO.End_Campaign__c = system.now();
      newCO.Order_Non_Bulk__c=ONB.id;
      
      insert newCO;
      
      
      Traffic_Non_Bulk__c TNB_01 = new Traffic_Non_Bulk__c();
      TNB_01.Date__c= Date.newInstance(2023, 01, 01);
      TNB_01.Campaign_Name_Text__c='Test';
      TNB_01.message_success__c=1000;
      TNB_01.CP_Name__c='dws';
      TNB_01.Campaign_Type__c='SMS BROADCAST';
      
      insert TNB_01;
      
      
      Traffic_Non_Bulk__c TNB_02 = new Traffic_Non_Bulk__c();
      TNB_02.Date__c= Date.newInstance(2023, 01, 01);
      TNB_02.Campaign_Name_Text__c='Test02';
      TNB_02.message_success__c=1000;
      TNB_02.CP_Name__c='mustika';
      TNB_02.Campaign_Type__c='LBA ON Location';
      
      insert TNB_02;

      TNB_02.Campaign_Name_Text__c='Test03';
      update TNB_02;

      Test.stopTest();
   }
   */
}