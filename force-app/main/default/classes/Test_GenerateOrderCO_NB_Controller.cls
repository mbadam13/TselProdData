/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-12-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-12-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
@isTest(seeAlldata=true)
public class Test_GenerateOrderCO_NB_Controller{
     public static testMethod void testMethod_GenerateOrderCO_NB() {
        Test.startTest();
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
         ONB.Sender__c='senderonb';
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
         
         //buat panggil EditOrderCO
            
             //buat panggil GenerateOrderCO
            ApexPages.StandardController ssc = new ApexPages.StandardController(ONB);
            GenerateOrderCO_NB_Controller gsc = new GenerateOrderCO_NB_Controller(ssc);
            Test.stopTest();
            
     }
}