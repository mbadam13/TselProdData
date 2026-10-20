/**
 * @description       : 
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 08-08-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   07-04-2023   Novando Utoyo Agmawan   Initial Version
**/

@isTest()
public class MonthlyDiscountIMSCreate_Test {
    public static testMethod void testMethodD(){
        Id recordTypeId_AddtSet1 = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('Monthly Discount Inventory Media Seller').getRecordTypeId();

        List<Trigger_Setting__c> List_TriggerSettings = new List<Trigger_Setting__c>();

        Trigger_Setting__c TriggerSetting1 = new Trigger_Setting__c(
            Name = 'validation:_StartDateIsExist',
            Error_Message__c = 'tidak bisa euy',
            IsActive__c = true,
            Object_Name__c = 'Additional_setting__c'
        );
        List_TriggerSettings.Add(TriggerSetting1);

        Trigger_Setting__c TriggerSetting2 = new Trigger_Setting__c(
            Name = 'Validation:_CantdeleteWhenRecordUsed',
            Error_Message__c = 'tidak bisa euy',
            IsActive__c = true,
            Object_Name__c = 'Pubmatic_Billing__c'
        );
        List_TriggerSettings.Add(TriggerSetting2);

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

        Test.startTest();

        MonthlyDiscountIMSCreate_Batch MonthlyDiscountIMSCreate_Batch_Class = new MonthlyDiscountIMSCreate_Batch(date.newinstance(2023, 01, 01));
        
        Database.executebatch(MonthlyDiscountIMSCreate_Batch_Class,1);

        Datetime nextSchedule = system.now().addSeconds(5);

        String hour = String.valueOf( nextSchedule.hour());
        String min = String.valueOf( nextSchedule.minute()); 
        String ss = String.valueOf( nextSchedule.second());
        String sDay = string.valueof( nextSchedule.day() ); 
        String sYear = string.valueof( nextSchedule.year() );
        String sMonth = string.valueof( nextSchedule.month() );
        
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + sDay + ' ' + sMonth + ' ? ' + sYear;
        
        MonthlyDiscountIMSCreate_Schedule MonthlyDiscountIMSCreate_Schedule_Class = new MonthlyDiscountIMSCreate_Schedule();

        System.schedule('MonthlyDiscountIMSCreate_Schedule ' + AppUtils.getNewGUID() + '-' + String.valueOf(system.now()), nextFireTime, MonthlyDiscountIMSCreate_Schedule_Class);
        Test.stopTest();
    }

    public static testMethod void testMethodD_LstMnth(){
        Id recordTypeId_AddtSet1 = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('Monthly Discount Inventory Media Seller').getRecordTypeId();

        List<Trigger_Setting__c> List_TriggerSettings = new List<Trigger_Setting__c>();

        Trigger_Setting__c TriggerSetting1 = new Trigger_Setting__c(
            Name = 'validation:_StartDateIsExist',
            Error_Message__c = 'tidak bisa euy',
            IsActive__c = true,
            Object_Name__c = 'Additional_setting__c'
        );
        List_TriggerSettings.Add(TriggerSetting1);

        Trigger_Setting__c TriggerSetting2 = new Trigger_Setting__c(
            Name = 'Validation:_CantdeleteWhenRecordUsed',
            Error_Message__c = 'tidak bisa euy',
            IsActive__c = true,
            Object_Name__c = 'Pubmatic_Billing__c'
        );
        List_TriggerSettings.Add(TriggerSetting2);

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

        Test.startTest();
        MonthlyDiscountIMSCreate_LstMnth_Batch MonthlyDiscountIMSCreate_LstMnth_Batch_Class = new MonthlyDiscountIMSCreate_LstMnth_Batch(date.newinstance(2023, 01, 01));
        
        Database.executebatch(MonthlyDiscountIMSCreate_LstMnth_Batch_Class,1);


        Datetime nextSchedule = system.now().addSeconds(5);

        String hour = String.valueOf( nextSchedule.hour());
        String min = String.valueOf( nextSchedule.minute()); 
        String ss = String.valueOf( nextSchedule.second());
        String sDay = string.valueof( nextSchedule.day() ); 
        String sYear = string.valueof( nextSchedule.year() );
        String sMonth = string.valueof( nextSchedule.month() );
        
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' ' + sDay + ' ' + sMonth + ' ? ' + sYear;

        MonthlyDiscountIMSCreate_LstMnth_Schdlr MonthlyDiscountIMSCreate_LstMnth_Schdlr_Class = new MonthlyDiscountIMSCreate_LstMnth_Schdlr();

        System.schedule('MonthlyDiscountIMSCreate_LstMnth_Schdlr ' + AppUtils.getNewGUID() + '-' + String.valueOf(system.now()), nextFireTime, MonthlyDiscountIMSCreate_LstMnth_Schdlr_Class);
        Test.stopTest();
    }
}