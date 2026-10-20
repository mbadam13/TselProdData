@isTest
public class Test_ContentDocLinkTriggerONB {
    
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
           
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion2;    
        List<ContentDocument> documents2 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = ONB.id;
        cdl2.ContentDocumentId = documents2[0].Id;
        cdl2.shareType = 'V';
        insert cdl2;
        
        Test.startTest();
        cdl2.Visibility = 'AllUsers'; 
        update cdl2;
        delete cdl2;
        Test.stopTest();
    }
    
}