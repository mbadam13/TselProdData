/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 10-20-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
@isTest
public class RabatConfigurationSettingServicesTest {

  
    @TestSetup
    static void makeData(){
      
        Trigger_Setting__c triggerSettingsRecValidationStartDateIsExist = new Trigger_Setting__c();
        triggerSettingsRecValidationStartDateIsExist.IsActive__c = true;
        triggerSettingsRecValidationStartDateIsExist.name = 'Validation:DataRabatisExist';
        triggerSettingsRecValidationStartDateIsExist.Error_Message__c = 'tidak bisa membuat data karena sudah ditentukan';
        triggerSettingsRecValidationStartDateIsExist.Object_Name__c = 'Rabat_Configuration_Setting__c';

        insert triggerSettingsRecValidationStartDateIsExist;

        Trigger_Setting__c triggerSettingsRecCantDelete = new Trigger_Setting__c();
        triggerSettingsRecCantDelete.IsActive__c = true;
        triggerSettingsRecCantDelete.name = 'Validation:_CantdeleteWhenRRCUsed';
        triggerSettingsRecCantDelete.Error_Message__c = 'tidak dapat dihapus karena digunakan pada Rabat Revenue Item';
        triggerSettingsRecCantDelete.Object_Name__c = 'Rabat_Configuration_Setting__c';

        insert triggerSettingsRecCantDelete;
    }
  

    @isTest
    static void testValidationCannotInsertRecordWhenStartDateIsExist() {   
        
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
        // Create additional settings that will violate the validation rule
        Rabat_Configuration_Setting__c rabat1 = new Rabat_Configuration_Setting__c(
          Account__c = acc.Id,                       // Account
          Start_Date__c = Date.valueOf('2028-01-01'),       // Start Date
          End_Date__c = Date.valueOf('2028-12-31'),         // End Date
          Spending_Amount_Greater_Than__c = 2500000000.00,  // Spending Amount Greater Than (>=)
          Spending_Amount_LessThan__c = 6000000000.00,      // Spending Amount LessThan (<)
          isActive__c = true,                              // isActive
          Group_Incentive__c = 6.00                        // Group Incentive
        );

        try {
          insert rabat1;  
        } catch (Exception e) {
          System.assertEquals(true, rabat1.hasErrors());
        }
        
        
        Rabat_Configuration_Setting__c rabat2 = new Rabat_Configuration_Setting__c(
          Account__c = acc.Id,                       // Account
          Start_Date__c = Date.valueOf('2028-01-01'),       // Start Date
          End_Date__c = Date.valueOf('2028-11-30'),         // End Date
          Spending_Amount_Greater_Than__c = 5500000000.00,  // Spending Amount Greater Than (>=)
          Spending_Amount_LessThan__c = 7000000000.00,      // Spending Amount LessThan (<)
          isActive__c = true,                              // isActive
          Group_Incentive__c = 5.00                        // Group Incentive
        );

        try {
          insert rabat2;  
        } catch (Exception e) {
          system.assertEquals(false, rabat2.hasErrors());
        }
        
        
        // Call the validation method and assert that it throws an error on the additional settings
        Test.startTest();
        RabatConfigurationSettingServices.validationCannotInsertRecordWhenStartDateIsExist(new List<Rabat_Configuration_Setting__c>{rabat1,rabat2});
        Test.stopTest();
    }
    
    @isTest
    static void validationCannotDeleteDatawhenisAlreadyUsedTest(){
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

        Brand__c brandRec = new Brand__c(
          Name = 'BTPN - Jenius',  // Brand Name
          User_Id__c = '9fjqepj'    // User Id
        );
        insert brandRec;
        // Create additional settings that will violate the validation rule
        Rabat_Configuration_Setting__c rabatConfSettinng = new Rabat_Configuration_Setting__c(
          Account__c = acc.Id,                       // Account
          Start_Date__c = Date.valueOf('2028-01-01'),       // Start Date
          End_Date__c = Date.valueOf('2028-12-31'),         // End Date
          Spending_Amount_Greater_Than__c = 2500000000.00,  // Spending Amount Greater Than (>=)
          Spending_Amount_LessThan__c = 6000000000.00,      // Spending Amount LessThan (<)
          isActive__c = true,                              // isActive
          Group_Incentive__c = 6.00                        // Group Incentive
        );
        insert rabatConfSettinng;

        Rabat_Revenue_Calculation__c rabatCalculation = new Rabat_Revenue_Calculation__c(
          Start_Date__c = Date.valueOf('2028-01-01'),// Start Date
          End_Date__c = Date.valueOf('2028-12-31'),    // End Date
          Account__c = acc.id                    // Account
        );
        insert rabatCalculation;

        Rabat_Revenue_Item__c rabatRevItem = new Rabat_Revenue_Item__c(
          Agency_Name__c = acc.id,                // Agency Name
          Brand__c = brandRec.id,                        // Brand
          Account__c = acc.id,                      // Account
          Rabat_Revenue_Calculation__c = rabatCalculation.id,    // Rabat Revenue Calculation
          Spending_Amount__c = 9889524600.00,            // Spending Amount
          Periode_Date__c = Date.valueOf('2028-03-10'),  // Periode Date
          Rabat_Configuration_Setting__c = rabatConfSettinng.id  // Rabat Configuration Setting
        );
        insert rabatRevItem;

        Test.startTest();
        try {
          delete rabatConfSettinng; 
        } catch (Exception e) {
          System.assertEquals(false, rabatConfSettinng.hasErrors()); 
        }
        RabatConfigurationSettingServices.validationCannotDeleteDatawhenisAlreadyUsed(new List<Rabat_Configuration_Setting__c>{rabatConfSettinng});
        Test.stopTest();
    }

}