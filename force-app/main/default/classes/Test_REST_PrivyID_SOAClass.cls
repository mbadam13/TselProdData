@isTest(seeAlldata=true)
public class Test_REST_PrivyID_SOAClass {
  public static testMethod void testMethod_Send_PrivyID_SOA() {
 
    //Create SOA
        //Test.startTest();
        
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

        List<SOA__c> lnewsoa=[SELECT id,name FROM SOA__c where id=:newSOA.id LIMIT 1];
        
     
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
    
    Test.startTest();
     ApexPages.StandardController ssc = new ApexPages.StandardController(newSOA);
     REST_PrivyID_SOAClass extension = new REST_PrivyID_SOAClass(ssc);
     extension.UploadDocument();
     extension.back();
     Test.stopTest();
  }
}