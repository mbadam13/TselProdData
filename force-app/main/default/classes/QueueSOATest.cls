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
public class QueueSOATest 
{
     @isTest static void TestList()
     {
        LIST<user> u=[SELECT id from user where username='dev1@telkomsel.co.id' LIMIT 1];
        
        Account acc = new Account ();
        acc.Name='Suka Selalu Aka';
        insert acc;

        Contact cont = new Contact();
        cont.lastName ='Doddy';
        cont.accountid = acc.id;
        insert cont;
        
        Opportunity opp = new Opportunity();
        opp.name = 'TEst';
        opp.StageName ='Prospecting';
        opp.accountid = acc.id;

        Pricebook2 PB=[SELECT id from PriceBook2 limit 1];
        opp.Pricebook2id=PB.id;
        opp.CloseDate=system.today().adddays(10);
        opp.Approval_Status__c='Approved';
        opp.Check_PO__c='OK';
        Upsert opp;
        
        
        //SOA
        SOA__c newSOA = new SOA__c();
        newSOA.SOA_Start_Date__c= date.today();
        newSOA.SOA_End_Date__c= date.today();
        newSOA.Opportunity__c=opp.id;

        Upsert newSOA;
        
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
        cdl.LinkedEntityId = newSOA.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;

        newSOA.docToken__c=Label.docToken_Test;
        newSOA.documentStatus__c='In Progress';
        update newSOA;
          List<SOA__c> soaList = [Select Id , Name,docToken__c from SOA__c where documentStatus__c='In Progress' limit 50];
          Test.startTest();
          //System.enqueueJob(campList);
          System.enqueueJob(new Schedule_SOADocQueuebleJob(soaList));
          Test.stopTest();
      }
 }