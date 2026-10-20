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
@isTest
public class QueueSIDTest 
{
     @isTest static void TestList()
     {
        Account acc = new Account ();
        acc.Name='IMS';
        acc.Account_Type__c='Media_Seller';
        acc.Legal_Name__c='IMS';
        acc.ParentId=Label.parentid;
        acc.Category__c='others';
        acc.Kategori_Industri__c=Label.Kategori_Industri;
        acc.prefix_ms__c='ims';
        insert acc;
        
        Blacklist__c BL = new Blacklist__c();
        BL.Name='digiads';
        insert BL;
        
        Master_Brand__c MB = new Master_Brand__c();
        MB.Media_Seller__c=acc.id;
        MB.Name='Brand New';
        MB.Line_Of_Business__c='RETAIL - MEDIA SHOPPING';
        insert MB;
 
        SID_Tools__c SIT = new SID_Tools__c();
        SIT.Sender_ID__c='jatis';
        SIT.Media_Seller__c=Label.parentid;
        SIT.OwnerId=Label.Owner_MS;
        SIT.Type_Sender__c='Premium';
        SIT.Kategori_Pesan__c='SMS Bulk';
        SIT.Brand__c=MB.id;
        SIT.Type_SMS__c='SMS Bulk';
        SIT.SID__c ='jatis123xyz';
        SIT.Sub_Reseller__c=FALSE;
        SIT.Company__c='PT Coba Testing';
        insert SIT;
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'PrivyID';
        cv.PathOnClient = 'PrivyID.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        system.debug('isi condocid'+ conDocId);
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = SIT.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;

        SIT.docToken__c=Label.docToken_Test;
        SIT.documentStatus__c='In Progress';
        update SIT;
          List<SID_Tools__c> campList = [Select Id , Name,docToken__c from SID_Tools__c where documentStatus__c='In Progress' limit 50];
          Test.startTest();
          //System.enqueueJob(campList);
          System.enqueueJob(new Schedule_SIDDocQueuebleJob(campList));
          Test.stopTest();
      }
 }