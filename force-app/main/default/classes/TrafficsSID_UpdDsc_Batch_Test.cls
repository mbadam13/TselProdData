/**
 * @description       : 
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 07-04-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   07-04-2023   Novando Utoyo Agmawan   Initial Version
**/

@isTest()
public class TrafficsSID_UpdDsc_Batch_Test {
    public static testMethod void testMethodD(){
        Id recordTypeId_Acc1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Media Seller').getRecordTypeId();

        List<Trigger_Setting__c> List_TriggerSettings = new List<Trigger_Setting__c>();

        Trigger_Setting__c TriggerSetting1 = new Trigger_Setting__c(
            Name = 'UsageTrafficMediaSellerTrigger',
            Error_Message__c = null,
            IsActive__c = true,
            Object_Name__c = 'Usage_Traffic_Media_Seller__cc'
        );
        List_TriggerSettings.Add(TriggerSetting1);

        Insert List_TriggerSettings;

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
        //utms_rec.Product__c = prodList[0].Id;
		utms_rec.Amount__c = 4500;
        insert utms_rec;

        list<Traffics_SID__c> lstTrafficSID = new list<Traffics_SID__c>();

        Traffics_SID__c TrafficsSID1 = new Traffics_SID__c(
            Event_Date__c = system.today(),
            CP_Name__c = 'ussd-i-dws-ims-oth',
            Traffic__c = 126,
            //Product__c = prodList[0].Id,
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

        Test.startTest();

        TrafficsSID_UpdDsc_Batch TrafficsSID_UpdDsc_Batch_Class = new TrafficsSID_UpdDsc_Batch(system.today());
        Database.executebatch(TrafficsSID_UpdDsc_Batch_Class,170);

        Test.stopTest();
    }
}