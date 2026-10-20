/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-13-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-13-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest(seealldata=true)

public class Test_GenerateSIDController{
    
    static testMethod void testMethod_Generate_SID() {
        Test.startTest();
        list<SID_Tools__c> SelectedSIDs = new  list<SID_Tools__c>();
                
        Account acc = new Account ();
        acc.Name='IMS';
        acc.Account_Type__c='Media_Seller';
        acc.Legal_Name__c='IMS';
        acc.ParentId=Label.parentid;
        acc.Category__c='others';
        acc.Kategori_Industri__c=Label.Kategori_Industri;
        acc.prefix_ms__c='ims';
        insert acc;
        System.debug('berhasil insert account');
        
        Blacklist__c BL = new Blacklist__c();
        BL.Name='doddy';
        insert BL;
        System.debug('berhasil insert blacklist');
        
        Master_Brand__c MB = new Master_Brand__c();
        MB.Media_Seller__c=acc.id;
        MB.Name='Brand New';
        MB.Line_Of_Business__c='RETAIL - MEDIA SHOPPING';
        insert MB;
        System.debug('berhasil insert master brand');
 
        SID_Tools__c SIT = new SID_Tools__c();
        SIT.Sender_ID__c='jatis';
        SIT.Media_Seller__c=Label.parentid;
        SIT.OwnerId=Label.Owner_MS;
        SIT.Type_Sender__c='Premium';
        SIT.Kategori_Pesan__c='Premium Ads';
        SIT.Brand__c=MB.id;
        SIT.Type_SMS__c='SMS Bulk';
        SIT.SID__c ='jatis123xyz';
        SIT.Sub_Reseller__c=FALSE;
        SIT.Company__c='PT Coba Testing';
        insert SIT;
        System.debug('berhasil insert SID Tools');
  
        //buat panggil GenerateSID
        ApexPages.StandardController ssc = new ApexPages.StandardController(SIT);
        GenerateSID_PDFController gsc = new GenerateSID_PDFController(ssc);

        Test.stopTest();
    }
}