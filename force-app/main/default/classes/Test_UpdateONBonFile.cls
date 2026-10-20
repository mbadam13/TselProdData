@isTest
public class Test_UpdateONBonFile {
    
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
        
        Order_Non_Bulk__c ONB = new Order_Non_Bulk__c();
        ONB.Campaign_Name__c='Ini Testing ONB';
        ONB.Channel__c='SMS';
        ONB.Sender__c='senderonb';
        ONB.Order_Start_Date__c=system.today();
        ONB.Order_End_Date__c=system.today();
        ONB.Kategori_Industri__c= KategoriIndustri.Id;
        ONB.Campaign_Type__c='LBA';
        ONB.Agency__c=acc.id;
        insert ONB;
        
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
        cdl.LinkedEntityId = ONB.id;
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

        Order_Non_Bulk__c ONB2 = new Order_Non_Bulk__c();
        ONB2.Campaign_Name__c='Ini Testing ONB';
        ONB2.Channel__c='SMS';
        ONB2.Sender__c='senderonb';
        ONB2.Order_Start_Date__c=system.today();
        ONB2.Order_End_Date__c=system.today();
        ONB2.Kategori_Industri__c= KategoriIndustri.Id;
        ONB2.Campaign_Type__c='LBA';
        ONB2.Agency__c=acc.id;
        insert ONB2;

        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = SIT2.id;
        cdl2.ContentDocumentId = contentVersion2.ContentDocumentId;
        cdl2.shareType = 'V';
        cdl2.Visibility = 'AllUsers'; 
        insert cdl2;
        system.Debug('86 cdl2 : '+cdl2);

        ContentDocumentLink cdl3 = New ContentDocumentLink();
        cdl3.LinkedEntityId = ONB2.id;
        cdl3.ContentDocumentId = contentVersion2.ContentDocumentId;
        cdl3.shareType = 'V';
        cdl3.Visibility = 'AllUsers'; 
        insert cdl3;
        system.Debug('103 cdl3 : '+cdl3);
    }  
    
}