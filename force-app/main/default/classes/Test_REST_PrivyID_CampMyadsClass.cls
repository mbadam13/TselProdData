@isTest(seeAlldata=true)
public class Test_REST_PrivyID_CampMyadsClass {
  public static testMethod void testMethod_Send_PrivyID_CampMyads() {
        //Test.startTest();
        
        Campaign_MyAds__c newCampMyAds = new Campaign_MyAds__c();
        newCampMyAds.Campaign_Type__c = 'Program';
        newCampMyAds.Campaign_Name__c='ini campaign';
        newCampMyAds.Voucher__c='Tanpa Kode Voucher';
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

    Test.startTest();
     ApexPages.StandardController ssc = new ApexPages.StandardController(newCampMyAds);
     REST_PrivyID_SendPrivyidCampMyAds extension = new REST_PrivyID_SendPrivyidCampMyAds(ssc);
     extension.UploadDocument();
     extension.back();
     Test.stopTest();
  }
}