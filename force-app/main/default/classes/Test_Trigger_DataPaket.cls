@istest
public class Test_Trigger_DataPaket {
    
    static testMethod void myUnitTest() {        
        Account acc = new Account ();
        acc.Name='IMS';
        acc.Account_Type__c='Media_Seller';
        acc.Legal_Name__c='IMS';
        acc.Category__c='others';
        acc.prefix_ms__c='ban';
        acc.user_id__c = 'REG-DO-0000';
        insert acc;
        
        test.startTest();
        Data_Paket_Seasonal__c datapaketObj = new Data_Paket_Seasonal__c();
        datapaketObj.User_Client_Id__c = acc.id;                         
            datapaketObj.Company_Name__c = 'Grand Depok City';                     
            datapaketObj.Product_Type__c = 'TARGETED';                          
            datapaketObj.Email__c = 'nobby@elsnotebookcenter.com';                
            datapaketObj.Id_Paket__c = '334422';                                 
            datapaketObj.Jumlah_Penerima_Paket__c = 999;                      
            datapaketObj.Harga_Paket__c = 1000000.00;                            
            datapaketObj.Id_Data_Paket_Seasonal__c = 'REG-DO-000000083599_334422';
        insert datapaketObj;
        test.stopTest();
    } 
}