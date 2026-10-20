/**
 * @description       : 
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 07-10-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   07-04-2023   Novando Utoyo Agmawan   Initial Version
**/

@isTest()
public class MonthlyDiscountIMSTriggerHandler_Test {
    public static testMethod void testMethodD(){
        Id recordTypeId_AddtSet1 = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('Monthly Discount Inventory Media Seller').getRecordTypeId();

        List<Trigger_Setting__c> List_TriggerSettings = new List<Trigger_Setting__c>();

        Trigger_Setting__c TriggerSetting1 = new Trigger_Setting__c(
            Name = 'MonthlyDiscountIMSTrigger',
            Error_Message__c = null,
            IsActive__c = true,
            Object_Name__c = 'Monthly_Discount_Inventory_Media_Seller__c'
        );
        List_TriggerSettings.Add(TriggerSetting1);

        Trigger_Setting__c TriggerSetting2 = new Trigger_Setting__c(
            Name = 'validation:_StartDateIsExist',
            Error_Message__c = 'tidak bisa euy',
            IsActive__c = true,
            Object_Name__c = 'Additional_setting__c'
        );
        List_TriggerSettings.Add(TriggerSetting2);

        Trigger_Setting__c TriggerSetting3 = new Trigger_Setting__c(
            Name = 'Validation:_CantdeleteWhenRecordUsed',
            Error_Message__c = 'tidak bisa euy',
            IsActive__c = true,
            Object_Name__c = 'Pubmatic_Billing__c'
        );
        List_TriggerSettings.Add(TriggerSetting3);

        Insert List_TriggerSettings;

        Kategori_Industri__c KategoriIndustri = new Kategori_Industri__c();
        KategoriIndustri.Name = 'Others'; 
        KategoriIndustri.prefix_ms__c = 'oth' ;
        insert KategoriIndustri;
        
        Account acc = new Account ();
        acc.Name='IMS';
        acc.Account_Type__c='Media_Seller';
        acc.Legal_Name__c='IMS';
        acc.Category__c='others';
        acc.Kategori_Industri__c= KategoriIndustri.Id;
        acc.prefix_ms__c='ims';
        insert acc;

        Additional_Setting__c AdditionalSetting1 = new Additional_Setting__c(
            Start_Date__c = Date.newInstance(2023, 01, 01),
            End_Date__c = Date.newInstance(2023, 01, 01),
            Applies_to_Category__c = 'Specific',
            Object_Name__c = 'Monthly_Discount_Inventory_Seller__c',
            Type__c = 'Discount',
            Account__c = acc.Id,
            Product_Services_and_Code__c = 'Bulk SMS',
            Brand__c = 'All Client',
            Tiering_Type__c = 'Amount',
            Greater_Than_Equal__c = 0, 
            Less_Than__c = 750000000,
            Value_Type__c = 'Amount', 
            Value__c = 225, 
            RecordTypeId = recordTypeId_AddtSet1, 
            Active__c = true,
            Product__c = null,
            Group_Incentive__c = null
        );
        insert AdditionalSetting1;

        Monthly_Discount_Inventory_Media_Seller__c MonthlyDiscountInventoryMediaSeller_New = new Monthly_Discount_Inventory_Media_Seller__c(
            Media_Seller__c = acc.id,
            Start_Date__c = Date.newInstance(2023, 01, 01),
            End_Date__c = Date.newInstance(2023, 01, 01),
            Product_Name__c = null,
            Product_Services_and_Code__c = 'Bulk SMS',
            Discount_Type__c = 'Amount',
            Brand__c = 'All Client',
            Additional_Setting__c = AdditionalSetting1.Id
        );
        insert MonthlyDiscountInventoryMediaSeller_New;

        Test.startTest();

        Test.stopTest();
    }
}