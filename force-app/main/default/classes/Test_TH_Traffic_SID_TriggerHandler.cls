/**
 * @description       : 
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 07-04-2023
 * @last modified by  : Ahmat Murad
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   07-04-2023   Novando Utoyo Agmawan   Initial Version
**/

@isTest
public class Test_TH_Traffic_SID_TriggerHandler {

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
      acc.User_ID__c = 'DWS1';
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

      // creteate media seller product setting pnv
      Media_Seller_Product_Settings__c medSelProductSettings = new Media_Seller_Product_Settings__c();
      medSelProductSettings.name = '1';
      medSelProductSettings.is_Active__c = true ;
      medSelProductSettings.Product_Code__c = '	PNV';
      medSelProductSettings.Product_Name__c = '	PNV OTP';
      medSelProductSettings.Product_Services__c = 'PNV';
      medSelProductSettings.Product_SFID__c = '01t2u0000004Asd';

      insert medSelProductSettings;


      //create onof trigger Trigger_Setting__c MonthlyDiscountIMSTriggerAcitvation = Trigger_Setting__c.getInstance('MonthlyDiscountIMSTrigger');
      Trigger_Setting__c MonthlyDiscountIMSTriggerAcitvation = new Trigger_Setting__c();
      MonthlyDiscountIMSTriggerAcitvation.name = 'MonthlyDiscountIMSTrigger';
      MonthlyDiscountIMSTriggerAcitvation.Object_Name__c = 'Monthly_Discount_Inventory_Media_Seller__c'; 
      MonthlyDiscountIMSTriggerAcitvation.IsActive__c = true;

      insert MonthlyDiscountIMSTriggerAcitvation;

      //create monthlydiscountinv for pnv
      Monthly_Discount_Inventory_Media_Seller__c monthDiscountInventoryMedSelPNV = new Monthly_Discount_Inventory_Media_Seller__c(
      Media_Seller__c = acc.id,                                                                                // Media Seller
      Start_Date__c = Date.newInstance(2023, 01, 01),                                                                     // Start Date
      //Product_Name__c = 'undefined',                                                                                  // Product Name
      End_Date__c = Date.newInstance(2023, 12, 31),                                                                       // End Date
      Product_Services_and_Code__c = 'PNV',                                                                           // Product Services and Code
      //Additional_Setting__c = 'undefined',                                                                            // Additional Setting
      Discount_Type__c = 'Amount',                                                                                    // Discount Type
      Value__c = 225,                                                                                            // Value
      Brand__c = 'All Client',                                                                                        // Brand
      Revenue_From_Traffic__c = 0.00,                                                                                 // Revenue From Traffic
      Current_Revenue_from_traffic__c = 837886396981.90,                                                              // Current Revenue from traffic
      Unique_ID__c = '2023-07-01 00:00:00-2023-07-31 00:00:00-0011s00001jLQQpAAO-01t2u0000004AsdAAE-PNV-All Client'  // Unique ID
      );

      insert monthDiscountInventoryMedSelPNV;

      //create monthlydiscountinv for traffic
      Monthly_Discount_Inventory_Media_Seller__c monthDiscountInventoryMedSelBulkSMS = new Monthly_Discount_Inventory_Media_Seller__c(
         Media_Seller__c = acc.id,                                                                                // Media Seller
         Start_Date__c = Date.newInstance(2023, 01, 01),                                                                     // Start Date
         //Product_Name__c = 'undefined',                                                                                  // Product Name
         End_Date__c = Date.newInstance(2023, 12, 31),                                                                       // End Date
         Product_Services_and_Code__c = 'Bulk SMS',                                                                           // Product Services and Code
         //Additional_Setting__c = 'undefined',                                                                            // Additional Setting
         Discount_Type__c = 'Amount',                                                                                    // Discount Type
         Value__c = 225,                                                                                            // Value
         Brand__c = 'All Client',                                                                                        // Brand
         Revenue_From_Traffic__c = 0.00,                                                                                 // Revenue From Traffic
         Current_Revenue_from_traffic__c = 837886396981.90,                                                              // Current Revenue from traffic
         Unique_ID__c = '2023-07-01 00:00:00-2023-07-31 00:00:00-0011s00001jLQQpAAO-01t2u0000004AsdAAE-PNV-All Client'  // Unique ID
         );
   
         insert monthDiscountInventoryMedSelBulkSMS;

               //create monthlydiscountinv for traffic
      Monthly_Discount_Inventory_Media_Seller__c monthDiscountInventoryMedSelNonBulk = new Monthly_Discount_Inventory_Media_Seller__c(
         Media_Seller__c = acc.id,                                                                                // Media Seller
         Start_Date__c = Date.newInstance(2023, 01, 01),                                                                     // Start Date
         //Product_Name__c = 'undefined',                                                                                  // Product Name
         End_Date__c = Date.newInstance(2023, 12, 31),                                                                       // End Date
         Product_Services_and_Code__c = 'Non Bulk USSD',                                                                           // Product Services and Code
         //Additional_Setting__c = 'undefined',                                                                            // Additional Setting
         Discount_Type__c = 'Amount',                                                                                    // Discount Type
         Value__c = 225,                                                                                            // Value
         Brand__c = 'All Client',                                                                                        // Brand
         Revenue_From_Traffic__c = 0.00,                                                                                 // Revenue From Traffic
         Current_Revenue_from_traffic__c = 837886396981.90,                                                              // Current Revenue from traffic
         Unique_ID__c = '2023-07-01 00:00:00-2023-07-31 00:00:00-0011s00001jLQQpAAO-01t2u0000004AsdAAE-Non Bulk USSD-All Client'  // Unique ID
         );
   
         insert monthDiscountInventoryMedSelNonBulk;

      // create sid for exclude revenue
      Id recTypeSID = Schema.SObjectType.SID_Tools__c.getRecordTypeInfosByName().get('SID').getRecordTypeId();
      SID_Tools__c sidExlc = new SID_Tools__c(
         //Kategori_Industri__c = 'undefined',  // Kategori Industri
         Media_Seller__c = acc.id,       // Media Seller
         Type_Sender__c = 'Premium',		//Type sender
         Type_SMS__c = 'SMS Bulk',            // Type
         Status__c = 'Draft',                 // Stages Status (Batch)
         Sender_ID__c = 'SID',                // Sender ID
         SID__c = 'SID',                      // SID
         Data_Migration__c = false,           // Data Migration
         Is_Manual_SID__c = true,            // Is Manual SID
         CP_Name_Existing__c = 'SID'         // CP Name Existing
      );

      insert sidExlc;

      //create media seller mapping
      Media_Seller_Mapping_Settings__c medSellMappingSettings = new Media_Seller_Mapping_Settings__c();
      medSellMappingSettings.name = 'DWS1';
      medSellMappingSettings.Key__c = 'dws';
      medSellMappingSettings.Media_Seller_SFID__c = acc.id;

      insert medSellMappingSettings;

   }
   
   @isTest
   public static void testMethod1() {
      Account acc = [SELECT Id FROM Account WHERE Name = 'DWS1' LIMIT 1];
   
      Blacklist__c BL = new Blacklist__c();
      BL.Name = 'Cobacoba';
      insert BL;
   
      Master_Brand__c MB = new Master_Brand__c();
      MB.Media_Seller__c = acc.Id;
      MB.Name = 'Brand New';
      MB.Line_Of_Business__c = 'RETAIL - MEDIA SHOPPING';
      insert MB;
   
      Id recTypeSID = Schema.SObjectType.SID_Tools__c.getRecordTypeInfosByName().get('PNV').getRecordTypeId();
      SID_Tools__c sidRec = new SID_Tools__c(
         app_name__c = 'testAppName',
         use_case__c = 'OTP',
         RecordTypeId = recTypeSID,
         Media_Seller__c = acc.Id,           // Media Seller
         Type_SMS__c = 'PNV',                     // Type
         SID__c = 'pnv-dws-tokped'               // SID
      );
      insert sidRec;
   
      ContentVersion cv_pnv = new ContentVersion();
      cv_pnv.Title = 'PNVDoc';
      cv_pnv.PathOnClient = 'PNVDoc.pdf';
      cv_pnv.VersionData = Blob.valueOf('Test Content PNV');
      cv_pnv.IsMajorVersion = true;
      insert cv_pnv;    
   
      Traffics_SID__c TID = new Traffics_SID__c();
      TID.Event_Date__c = Date.newInstance(2023, 01, 01);
      //TID.CP_Name__c = sidRec.CP_Name__c;
      TID.Traffic__c = 1000;
      TID.SID__c = sidRec.Id;
      //TID.Product__c = Label.Product_Bulk;
      TID.Media_Seller__c = acc.Id;
      TID.Product_Name__c = 'PNV OTP';
      TID.Traffic_SID_Unique_ID__c = '123';
      TID.CP_Name__c = 'pnv-dws-tokped';
      TID.Brand__c = 'All Client';
   
      test.startTest();
      Insert TID;
      test.stopTest(); 
   }
   
   @isTest
   public static void excludeRevenueTest() {
      Account acc = [SELECT Id FROM Account WHERE Name = 'DWS1' LIMIT 1];
      SID_Tools__c sidExc = [SELECT Id, CP_Name__c FROM SID_Tools__c WHERE SID__c = 'SID' LIMIT 1];
  
      // Create setting for ExcludeRevenue
      Media_Seller_Exclude_Revenue__c medSelExcludeRevSettings = new Media_Seller_Exclude_Revenue__c();
      medSelExcludeRevSettings.Name = 'SID';
      insert medSelExcludeRevSettings;
  
      Traffics_SID__c TID = new Traffics_SID__c();
      TID.Event_Date__c = Date.newInstance(2023, 01, 01);
      TID.CP_Name__c = 'SID';
      TID.Traffic__c = 1000;
      TID.SID__c = sidExc.Id;
      TID.Media_Seller__c = acc.Id;
      TID.Product_Name__c = 'SMS Bulk Regular';
      TID.Traffic_SID_Unique_ID__c = '123';
      TID.CP_Name__c = 'ussd-i-dws-ims-oth';
      TID.Brand__c = 'All Client';

      test.startTest();
      insert TID;
      test.stopTest();
      /*
  
      Test.startTest();
      try {
          insert TID;
          // The above line should throw an exception since the revenue is excluded
          // If the execution reaches this point, fail the test
          System.assert(false, 'Expected exception was not thrown');
      } catch (DmlException e) {
          // Verify the expected error message in the exception
          System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Expected error message not found');
      }
      Test.stopTest();*/    
   }

   @isTest
   public static void productContainsUSSD(){
      Account acc = [SELECT Id FROM Account WHERE Name = 'DWS1' LIMIT 1];
      SID_Tools__c sidExc = [SELECT Id, CP_Name__c FROM SID_Tools__c WHERE SID__c = 'SID' LIMIT 1];
  
      Traffics_SID__c TID = new Traffics_SID__c();
      TID.Event_Date__c = Date.newInstance(2023, 01, 01);
      TID.CP_Name__c = 'ussd-i-dws-ims-oth';
      TID.Traffic__c = 1000;
      TID.SID__c = sidExc.Id;
      TID.Media_Seller__c = acc.Id;
      TID.Product_Name__c = 'USSD Bulk';
      TID.Traffic_SID_Unique_ID__c = '123';
      TID.CP_Name__c = 'ussd-i-dws-ims-oth';
      TID.product_services__c = 'Non Bulk';
      TID.Product_code__c = 'USSD';

      test.startTest();
      insert TID;
      test.stopTest();
   }


   
   /*
   //oldWay
   @isTest
   public static testMethod void testMethod_TH_Traffic_SID() {
      Test.startTest();
      
      Account acc = new Account ();
      acc.Name='Test123';
      acc.Account_Type__c='Media_Seller';
      acc.Legal_Name__c='IMS123';
      acc.ParentId=Label.parentid;
      acc.Category_del__c='others';
      acc.Kategori_Industri__c=Label.Kategori_Industri;
      acc.prefix_ms__c='ims';
      insert acc;
      
      Blacklist__c BL = new Blacklist__c();
      BL.Name='Cobacoba';
      insert BL;
      
      
      Master_Brand__c MB = new Master_Brand__c();
      MB.Media_Seller__c=Label.parentid;
      MB.Name='Brand New';
      MB.Line_Of_Business__c='RETAIL - MEDIA SHOPPING';
      insert MB;
      
      RecordType recType = [ SELECT Id, Name, DeveloperName, IsActive, SobjectType FROM RecordType WHERE Name = 'PNV' AND SobjectType = 'SID_Tools__c'];
      system.debug('Name Recordtype = ' + recType);  
      
      SID_Tools__c PNV   = new SID_Tools__c();
      PNV.RecordTypeId   = recType.Id;
      system.debug('Record Type   = ' + recType.Id);
      
      PNV.Legal_Name__c   = 'Test PNV 123';
      PNV.App_Name__c   = 'Test PNV 123';
      PNV.Indico__c   = 'Yes';
      //PNV.Registration_Number__c   = 123;
      PNV.Address__c   = 'Jakarta';
      PNV.URL__c   = 'ABC.com';
      PNV.Privacy_Policy_URL__c   = 'ABC.com';
      PNV.Terms_Conditions_URL__c   = 'ABC.com'; 
      PNV.IP_s_to_be_whitelisted__c   ='ABC.com';
      PNV.Media_Seller__c   = Label.MediaSeller_DWS;
      PNV.Anticipated_Launch_Date__c   = Date.today();
      PNV.Anticipated_Monthly_Transaction_Volume__c   = 123;
      PNV.Use_Case__c   = 'OTP';
      PNV.PNV_Attachment__c   = 1;
      Insert PNV;
      System.debug('>>> PNV = ' + PNV);
      
      ContentVersion cv_pnv = new ContentVersion();
      cv_pnv.Title = 'PNVDoc';
      cv_pnv.PathOnClient = 'PNVDoc.pdf';
      cv_pnv.VersionData = Blob.valueOf('Test Content PNV');
      cv_pnv.IsMajorVersion = true;
      Insert cv_pnv;
      
      
      // SID_Tools__c SIT = new SID_Tools__c();
      // SIT.Sender_ID__c='jatis';
      // SIT.Media_Seller__c=Label.parentid;
      // SIT.OwnerId=Label.Owner_MS;
      // SIT.Type_Sender__c='Premium';
      // SIT.Kategori_Pesan__c='Premium OTP';
      // SIT.Brand__c=MB.id;
      // SIT.Type_SMS__c='SMS Bulk';
      // SIT.SID__c ='jatis123xyz';
      // SIT.Sub_Reseller__c=FALSE;
      // SIT.Company__c='PT Coba Testing';
      // insert SIT;
      
      
      Traffics_SID__c TID = new Traffics_SID__c();
      TID.Event_Date__c= Date.newInstance(2023, 01, 01);
      TID.CP_Name__c=PNV.CP_Name__c;
      TID.Traffic__c=1000;
      TID.SID__c= PNV.id;
      TID.Product__c=Label.Product_Bulk;
      TID.Media_Seller__c=Label.parentid;
      TID.Product_Name__c='SMS Bulk Regular';
      TID.Traffic_SID_Unique_ID__c = '123';
      TID.CP_Name__c = 'ussd-i-dws-ims-oth';
      TID.Brand__c = 'All Client';
      insert TID;
      
      Test.stopTest();
   }
   */
}