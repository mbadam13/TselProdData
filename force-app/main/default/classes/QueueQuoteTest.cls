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
public class QueueQuoteTest 
{
     @isTest static void TestList()
     {
        Account acc = new Account();
        acc.Name = 'Acc ABC';
        insert acc; 
        system.debug('>>> acc = ' + acc);
        
        Contact con = new Contact();
        con.lastName = 'Con ABC';
        con.AccountId = acc.Id;
        insert con; 
        system.debug('>>> con = ' + con);
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.AccountId = acc.Id;
        opp.Account_Type__c = 'Advertiser';
        opp.CloseDate = system.today();
        opp.StageName = 'Prospecting';
        insert opp; 
        Quote qt = new Quote();
        qt.Name = 'Test Quote';
        qt.ContactId = con.Id;
        qt.Start_Date__c = system.today();
        qt.End_Date__c = system.today().addDays(10);
        qt.OpportunityId = opp.Id;
        insert qt;
        
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
        cdl.LinkedEntityId = qt.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;

        qt.docToken__c=Label.docToken_Test;
        qt.documentStatus__c='In Progress';
        update qt;
          List<Quote> quoteList = [Select Id , Name,docToken__c from quote where documentStatus__c='In Progress' limit 50];
          Test.startTest();
          //System.enqueueJob(campList);
          System.enqueueJob(new Schedule_QuoteDocQueuebleJob(quoteList));
          Test.stopTest();
      }
 }