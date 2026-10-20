@isTest
public class Test_ContentDocLinkTrigger {
    
    static testmethod void CRUD1(){
        Kategori_Industri__c KategoriIndustri = new Kategori_Industri__c();
        KategoriIndustri.Name = 'Others'; 
        KategoriIndustri.prefix_ms__c = 'oth' ;
        insert KategoriIndustri;
        
        Account acc = new Account ();
        acc.Name='IMS';
        acc.Account_Type__c='Media_Seller';
        acc.Legal_Name__c='IMS';
        acc.Category__c='others';
        acc.Kategori_Industri__c= KategoriIndustri.Id;
        acc.prefix_ms__c='ims';
        insert acc;
        
        SID_Tools__c SIT = new SID_Tools__c();
        SIT.Sender_ID__c='jatis';
        SIT.Media_Seller__c=acc.id;
        SIT.Kategori_Industri__c = KategoriIndustri.Id;
        SIT.Media_Seller__c = acc.Id;
        SIT.Format_Pesan__c = 'TEST';
        SIT.Type_Sender__c='Premium';
        SIT.Kategori_Pesan__c='SMS Bulk';
        SIT.Type_SMS__c='SMS Bulk';
        SIT.Status__c = 'Draft';
        insert SIT;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = SIT.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
       
        Test.startTest();
        cdl.Visibility = 'AllUsers'; 
        update cdl;
        delete cdl;
        Test.stopTest();
    }
    
}