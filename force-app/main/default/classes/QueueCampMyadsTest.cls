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
public class QueueCampMyadsTest 
{
     @isTest static void TestList()
     {
          Campaign_MyAds__c newCampMyAds = new Campaign_MyAds__c();
        newCampMyAds.Campaign_Name__c='ini campaign';
        newCampMyAds.Own_proposal__c=true;
        newCampMyAds.Start_Date__c=date.today();
        newCampMyAds.End_Date__c=system.today().adddays(10);
        newCampMyAds.Kode_Voucher__c='kodeads1';
        
        insert newCampMyAds;
        
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
        cdl.LinkedEntityId = newCampMyAds.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        newCampMyAds.Stage__c='Closed Won';
        update newCampMyAds;
        
        newCampMyAds.Stage__c='Completed';
        newCampMyAds.docToken__c=Label.docToken_Test;
        newCampMyAds.documentStatus__c='In Progress';
        update newCampMyAds;
          List<Campaign_MyAds__c> campList = [Select Id , Name,docToken__c from Campaign_MyAds__c where documentStatus__c='In Progress' limit 50];
          Test.startTest();
          //System.enqueueJob(campList);
          System.enqueueJob(new Schedule_CampMyadsDocQueuebleJob(campList));
          Test.stopTest();
      }
 }