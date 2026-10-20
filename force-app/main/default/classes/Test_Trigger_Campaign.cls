@isTest
private class Test_Trigger_Campaign {
    
    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Kategori_Industri__c kategInd = new Kategori_Industri__c();
        kategInd.Name = 'Banking';
        kategInd.prefix_ms__c = 'ban';
        insert kategInd; 
        
        Account acc = new Account ();
        acc.Name='IMS';
        acc.Account_Type__c='Media_Seller';
        acc.Legal_Name__c='IMS';
        acc.Category__c='others';
        acc.Kategori_Industri__c=kategInd.id;
        acc.prefix_ms__c='ban';    
        acc.user_id__c = 'REG-DO-0000';
        insert acc;
        
        test.startTest();
        Campaigns__c camp = new Campaigns__c();
        camp.Tanggal_Iklan__c = system.today();
        camp.ID_Iklan__c = '1234';
        camp.User_ID__c = acc.id;  
        camp.Kategori_Campaign__c = 'Seasonal';
        camp.ID_Iklan__c = '1212';
        camp.Id_Paket__c = '1111';
        
        insert camp;
        test.stopTest();
    }
    
    static testMethod void myUnitTest2() {
        //for api phase 5 update 9/6/2023
        Account acc = new Account ();
        acc.Name='IMS';
        acc.Account_Type__c='Media_Seller';
        acc.Legal_Name__c='IMS';
        acc.Category__c='others';
        acc.prefix_ms__c='ban';    
        acc.user_id__c = 'REG-DO-0000';
        insert acc;
        
        test.startTest();
        Campaigns__c camp = new Campaigns__c();
        camp.Tanggal_Iklan__c = system.today();
        camp.ID_Iklan__c = '1234';
        camp.User_ID__c = acc.id;  
        camp.Kategori_Campaign__c = 'Non Seasonal';
        camp.ID_Iklan__c = '1212';
        
        insert camp;
        test.stopTest();
    }
}