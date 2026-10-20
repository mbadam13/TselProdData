/**
 * @description       : 
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 07-10-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   07-05-2023   Novando Utoyo Agmawan   Initial Version
**/

@isTest()
public class MonthlyDiscountIMSServices_Test {
    public static testMethod void testMethodD(){
        Id recordTypeId_Acc1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Media Seller').getRecordTypeId();

        Id recordTypeId_AddSetting1 = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('Revenue Calculation for Discount Inventory').getRecordTypeId();

        Id recordTypeId_AddtSet2 = Schema.SObjectType.Additional_Setting__c.getRecordTypeInfosByName().get('Monthly Discount Inventory Media Seller').getRecordTypeId();

        List<Trigger_Setting__c> List_TriggerSettings = new List<Trigger_Setting__c>();

        Trigger_Setting__c TriggerSetting1 = new Trigger_Setting__c(
            Name = 'UsageTrafficMediaSellerTrigger',
            Error_Message__c = null,
            IsActive__c = true,
            Object_Name__c = 'Usage_Traffic_Media_Seller__cc'
        );
        List_TriggerSettings.Add(TriggerSetting1);

        Trigger_Setting__c TriggerSetting2 = new Trigger_Setting__c(
            Name = 'MonthlySpecialPriceAllocationTrigger',
            Error_Message__c = null,
            IsActive__c = true,
            Object_Name__c = 'Monthly_Special_Price_Allocation__c'
        );
        List_TriggerSettings.Add(TriggerSetting2);

        Trigger_Setting__c TriggerSetting3 = new Trigger_Setting__c(
            Name = 'MonthlyDiscountIMSTrigger',
            Error_Message__c = null,
            IsActive__c = true,
            Object_Name__c = 'Monthly_Discount_Inventory_Media_Seller__c'
        );
        List_TriggerSettings.Add(TriggerSetting3);

        Trigger_Setting__c TriggerSetting4 = new Trigger_Setting__c(
            Name = 'validation:_StartDateIsExist',
            Error_Message__c = 'tidak bisa euy',
            IsActive__c = true,
            Object_Name__c = 'Additional_setting__c'
        );
        List_TriggerSettings.Add(TriggerSetting4);

        Trigger_Setting__c TriggerSetting5 = new Trigger_Setting__c(
            Name = 'Validation:_CantdeleteWhenRecordUsed',
            Error_Message__c = 'tidak bisa euy',
            IsActive__c = true,
            Object_Name__c = 'Pubmatic_Billing__c'
        );
        List_TriggerSettings.Add(TriggerSetting5);

        Insert List_TriggerSettings;
        
        Product2 prod1 = new Product2();
        prod1.Name = 'BULK (SMS)';
        prod1.ProductCode = 'Messaging';
        prod1.Product_Type__c = 'SMS';
        prod1.Buying_Method__c = 'I/O';
        prod1.Family = 'SMS';
        prod1.IsActive = true;
        prod1.Product_Name_MS__c = 'BULK (SMS)';
        prod1.Product_Category__c = 'Tadex';
        Insert prod1;

        PricebookEntry pbe_std_1 = new PricebookEntry();
		pbe_std_1.IsActive = true;
		pbe_std_1.Product2Id = prod1.Id;
		pbe_std_1.Pricebook2Id = Test.getStandardPricebookId();
        pbe_std_1.UnitPrice = 500;
        Insert pbe_std_1;

        Kategori_Industri__c KategoriIndustri = new Kategori_Industri__c();
        KategoriIndustri.Name = 'Others'; 
        KategoriIndustri.prefix_ms__c = 'oth' ;
        insert KategoriIndustri;
        
        Account acc = new Account ();
        acc.Name='IMS';
        acc.Account_Type__c='Media Seller';
        acc.Legal_Name__c='IMS';
        acc.Category__c='others';
        acc.Kategori_Industri__c= KategoriIndustri.Id;
        acc.prefix_ms__c='ims';
        acc.RecordTypeId = recordTypeId_Acc1;
        acc.Active__c = true;
        insert acc;

        SID_Tools__c sid_rec = new SID_Tools__c();
        sid_rec.Sender_ID__c = 'jatis';
        sid_rec.Media_Seller__c = acc.Id;
        sid_rec.Type_Sender__c = 'Premium';
        sid_rec.Type_SMS__c = 'SMS Bulk';
        sid_rec.SID__c = 'jatis123xyz';
        sid_rec.Sub_Reseller__c = FALSE;
        sid_rec.Company__c = 'PT Coba Testing';
        insert sid_rec;
        
        Usage_Traffic_Media_Seller__c utms_rec = new Usage_Traffic_Media_Seller__c();
        utms_rec.Date__c = system.today();
        utms_rec.Unique_ID__c = '12300123';
        utms_rec.Media_seller__c = acc.Id;
		utms_rec.Sub_Media_Seller__c = acc.Id;
		utms_rec.Traffic_Type__c = 'Bulk';
        utms_rec.Product__c = prod1.Id;
        utms_rec.Product_Code__c = 'SMS';
		utms_rec.Amount__c = 4500;
        insert utms_rec;

        Usage_Traffic_Media_Seller__c utms_rec2 = new Usage_Traffic_Media_Seller__c();
        utms_rec2.Date__c = system.today();
        utms_rec2.Unique_ID__c = '12300124';
        utms_rec2.Media_seller__c = acc.Id;
		utms_rec2.Sub_Media_Seller__c = acc.Id;
		utms_rec2.Traffic_Type__c = 'Bulk';
        //utms_rec2.Product__c = prod1.Id;
        utms_rec2.Product_Code__c = 'SMS';
		utms_rec2.Amount__c = 4500;
        insert utms_rec2;

        list<Traffics_SID__c> lstTrafficSID = new list<Traffics_SID__c>();

        Traffics_SID__c TrafficsSID1 = new Traffics_SID__c(
            Event_Date__c = system.today(),
            CP_Name__c = 'ussd-i-dws-ims-oth',
            Traffic__c = 126,
            Product__c = prod1.Id,
            Product_Name__c = 'USSD Bulk',
            Sales_Price__c = 300,
            Usage_Traffic_Media_Seller__c = utms_rec.Id,         
            Traffic_SID_Unique_ID__c = '20230305ussd-i-dws-ims-1',
            Temp_Amount__c = 17199,
            Discount__c = 1,
            Discount_Amount__c = 1
        );
        lstTrafficSID.add(TrafficsSID1);

        insert lstTrafficSID;

        Traffic_Non_Bulk__c TrafficsNB1 = new Traffic_Non_Bulk__c(
            Date__c = system.today(),
            Campaign_Name_Text__c = 'Test',
            message_success__c = 1000,
            CP_Name__c = 'dws',
            Campaign_Type__c = 'SMS BROADCAST',
            user_id__c = acc.id,
            Brand__c = 'All Client',
            Discount__c = 1,
            Discount_Amount__c = 1,
            Usage_Traffic_Media_Seller__c = utms_rec.Id
        );
        insert TrafficsNB1;

        Monthly_Special_Price_Allocation__c MonthlySPAllocation1 = new Monthly_Special_Price_Allocation__c(
            Media_Seller__c = acc.Id,
            Start_Date__c = System.today(),
            End_Date__c = System.today(),
            Usage__c = 1,
            Invoice__c = 1,
            Minimum_Guarantee__c = 1,
            Target_Commitment__c = 1,
            Special_Price__c = 1,
            Bulk_Alocation_Percentage__c = 1,
            Non_Bulk_Allocation_Percentage__c = 1
        );
        Insert MonthlySPAllocation1;

        Additional_Setting__c AdditionalSetting1 = new Additional_Setting__c(
            Applies_to_Category__c = 'Specific',
            Object_Name__c = 'Revenue_Calculation_for_Discount_Inventory__c',
            Type__c = 'Revenue Calculation',
            Account__c = acc.id,
            Start_Date__c = System.today(),
            End_Date__c = System.today(),
            RecordTypeId = recordTypeId_AddSetting1,
            Active__c = true 
        );
        insert AdditionalSetting1;

        Additional_Setting__c AdditionalSetting2 = new Additional_Setting__c(
            Start_Date__c = System.today(),
            End_Date__c = System.today(),
            Applies_to_Category__c = 'Specific',
            Object_Name__c = 'Monthly_Discount_Inventory_Seller__c',
            Type__c = 'Discount',
            Account__c = acc.Id,
            Product_Services_and_Code__c = 'Bulk SMS',
            Brand__c = 'All Client',
            Tiering_Type__c = 'Amount',
            Greater_Than_Equal__c = 0, 
            Less_Than__c = 2,
            Value_Type__c = 'Amount', 
            Value__c = 225, 
            RecordTypeId = recordTypeId_AddtSet2, 
            Active__c = true,
            Product__c = prod1.Id,
            Group_Incentive__c = null
        );
        insert AdditionalSetting2;

        Additional_Setting__c AdditionalSetting3 = new Additional_Setting__c(
            Start_Date__c = System.today().addMonths(1),
            End_Date__c = System.today().addMonths(1),
            Applies_to_Category__c = 'Specific',
            Object_Name__c = 'Monthly_Discount_Inventory_Seller__c',
            Type__c = 'Discount',
            Account__c = acc.Id,
            Product_Services_and_Code__c = 'Bulk SMS',
            Brand__c = 'All Client',
            Tiering_Type__c = 'Amount',
            Greater_Than_Equal__c = 0, 
            Less_Than__c = 2,
            Value_Type__c = 'Amount', 
            Value__c = 225, 
            RecordTypeId = recordTypeId_AddtSet2, 
            Active__c = true,
            Product__c = prod1.Id,
            Group_Incentive__c = null
        );
        insert AdditionalSetting3;

        Monthly_Discount_Inventory_Media_Seller__c MonthlyDiscountInventoryMediaSeller_New = new Monthly_Discount_Inventory_Media_Seller__c(
            Media_Seller__c = acc.id,
            Start_Date__c = System.today(),
            End_Date__c = System.today(),
            Product_Name__c = prod1.Id,
            Product_Services_and_Code__c = 'Bulk SMS',
            Discount_Type__c = 'Amount',
            Brand__c = 'All Client',
            Additional_Setting__c = AdditionalSetting1.Id,
            Current_Revenue_from_traffic__c = 1
        );
        insert MonthlyDiscountInventoryMediaSeller_New;

        Monthly_Discount_Inventory_Media_Seller__c MonthlyDiscountInventoryMediaSeller_New2 = new Monthly_Discount_Inventory_Media_Seller__c(
            Media_Seller__c = acc.id,
            Start_Date__c = System.today().addMonths(1),
            End_Date__c = System.today().addMonths(1),
            Product_Name__c = prod1.Id,
            Product_Services_and_Code__c = 'Bulk SMS',
            Discount_Type__c = 'Amount',
            Brand__c = 'All Client',
            Additional_Setting__c = AdditionalSetting1.Id,
            Current_Revenue_from_traffic__c = 1
        );
        insert MonthlyDiscountInventoryMediaSeller_New2;

        Test.startTest();

        String MediaSeller = acc.id;
        String Product = prod1.Id;
        String ProductServicesAndCode = 'Bulk SMS';
        String Brand = 'All Client';
        Date StartDate = System.today();
        Date EndDate = System.today();

        Set<String> Set_MonthlyDiscountInventoryMediaSellerIds = new Set<String>();
        Set_MonthlyDiscountInventoryMediaSellerIds.add(MonthlyDiscountInventoryMediaSeller_New.Id);

        MonthlyDiscountIMSServices.getKategoriIndustriByPrefix();

        MonthlyDiscountIMSServices.getRevenueFromTrafficValue(MediaSeller, Product, ProductServicesAndCode, Brand, StartDate);

        MonthlyDiscountIMSServices.getRevenueFromTrafficValue(MediaSeller, null, ProductServicesAndCode, Brand, StartDate);

        MonthlyDiscountIMSServices.getCurrentRevenueFromTraffic(MediaSeller, Product, ProductServicesAndCode, Brand, StartDate, EndDate);

        MonthlyDiscountIMSServices.getCurrentRevenueFromTraffic(MediaSeller, null, ProductServicesAndCode, Brand, StartDate, EndDate);

        MonthlyDiscountIMSServices.setValueDiscount(Set_MonthlyDiscountInventoryMediaSellerIds);

        MonthlyDiscountIMSServices.setValueDiscountUpdate(MonthlyDiscountInventoryMediaSeller_New);

        Test.stopTest();
    }
}