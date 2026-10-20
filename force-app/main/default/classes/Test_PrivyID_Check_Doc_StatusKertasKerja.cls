@isTest
public class Test_PrivyID_Check_Doc_StatusKertasKerja {
    
    static testMethod void test_privyId_checkStatusKK(){
        
        Kertas_Kerja__c kk_ds = new Kertas_Kerja__c();
        kk_ds.Month__c = 'January';
        kk_ds.Year__c = '2021';
        kk_ds.Status__c = 'Draft';
        kk_ds.Type__c = 'Direct Sales';
        insert kk_ds;
        
        REST_PrivyID_Check_Doc_StatusKertasKerja.CheckDocumentStatus(kk_ds.Id);
        
    }

}