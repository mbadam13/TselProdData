@isTest(seeAlldata=true)
public class Test_ONB_Check_Sender_Before_Insert {
     public static testMethod void Test_ONB_Check_Sender_Before_Insert() {
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
         ONB.Order_Start_Date__c=system.today();
         ONB.Order_End_Date__c=system.today();
         ONB.Kategori_Industri__c=Label.Kategori_Industri;
         ONB.Campaign_Type__c='TARGETED';
         ONB.Agency__c=acc.id;
         insert ONB;

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
        cdl.LinkedEntityId = ONB.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        ONB.Status__c='Validate';
        update ONB;
         
         Test.stopTest();
     }
}