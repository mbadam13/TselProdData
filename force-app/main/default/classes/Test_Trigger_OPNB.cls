@isTest
private class Test_Trigger_OPNB {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        Kategori_Industri__c kategInd = new Kategori_Industri__c();
        kategInd.Name = 'Banking';
        kategInd.prefix_ms__c = 'ban';
        insert kategInd; 
        
        Order_Non_Bulk__c ordnonbulk = new Order_Non_Bulk__c();
        ordnonbulk.Kategori_Industri__c = kategInd.id;
        ordnonbulk.Campaign_Name__c = 'Dummy Campaign';
        ordnonbulk.Campaign_Type__c = 'LBA';
        insert ordnonbulk;
        
        Product2 produk = new Product2();
        produk.Name = 'LBA SMS';
        produk.ProductCode = 'messaging';
        produk.Grouping__c = 'Media Seller';
        produk.MS_Type__c = 'Non Bulk';
        insert produk;
        
        Order_Product_Non_Bulk__c OPNB = new Order_Product_Non_Bulk__c();
        OPNB.Order_Non_Bulk_Number__c = ordnonbulk.id;
        OPNB.Product__c = produk.id;
        insert OPNB;
        
    }
}