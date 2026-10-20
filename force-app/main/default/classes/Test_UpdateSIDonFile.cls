@isTest
public class Test_UpdateSIDonFile {
    
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
            VersionData = Blob.valueOf('Test Content')
        );
        insert contentVersion;   
        system.Debug('46 contentVersion : '+contentVersion);

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        system.Debug('49 documents : '+documents);
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = SIT.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdl.Visibility = 'AllUsers'; 
        insert cdl;
        system.Debug('57 cdl : '+cdl);

        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            ContentDocumentId = documents[0].Id,
            IsMajorVersion = true
        );
        insert contentVersion2;   
        system.Debug('65 contentVersion2 : '+contentVersion2);

        SID_Tools__c SIT2 = new SID_Tools__c();
        SIT2.Sender_ID__c='jatis';
        SIT2.Media_Seller__c=acc.id;
        SIT2.Kategori_Industri__c = KategoriIndustri.Id;
        SIT2.Media_Seller__c = acc.Id;
        SIT2.Format_Pesan__c = 'TEST';
        SIT2.Type_Sender__c='Premium';
        SIT2.Kategori_Pesan__c='SMS Bulk';
        SIT2.Type_SMS__c='SMS Bulk';
        SIT2.Status__c = 'Draft';
        insert SIT2;

        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = SIT2.id;
        cdl2.ContentDocumentId = contentVersion2.ContentDocumentId;
        cdl2.shareType = 'V';
        cdl2.Visibility = 'AllUsers'; 
        insert cdl2;
        system.Debug('86 cdl2 : '+cdl2);
    }    
    
}