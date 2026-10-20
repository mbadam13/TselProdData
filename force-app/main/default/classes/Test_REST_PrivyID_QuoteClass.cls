@isTest(seeAlldata=true)
public class Test_REST_PrivyID_QuoteClass {
  public static testMethod void testMethod_Send_PrivyID_Quote() {
 
        //Create Quote
        //Test.startTest();
        
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
    
    Test.startTest();
     ApexPages.StandardController ssc = new ApexPages.StandardController(qt);
     REST_PrivyID_QuotationClass extension = new REST_PrivyID_QuotationClass(ssc);
     extension.UploadDocument();
     extension.back();
     Test.stopTest();
  }
}