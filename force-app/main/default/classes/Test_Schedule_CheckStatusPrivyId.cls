@isTest
public class Test_Schedule_CheckStatusPrivyId {
 	
    public static String CRONexp = '0 6 * * * ?';
    static testmethod void testScheduledJob() {
        
        Test.startTest();
        // Data
        Kertas_Kerja__c kkRec = new Kertas_Kerja__c();
        kkRec.Kertas_Kerja_Name__c = 'Kertas Kerja Name Testing Direct Sales';
        kkRec.Month__c = 'January';
        kkRec.Year__c = '2021';
        kkRec.Type__c = 'Direct Sales';
        kkRec.Status__c = 'Review';
        insert kkRec;
        
        Id kkRecID = System.schedule('Status Update', CRONexp, new Schedule_CheckStatusPrivyId_KertasKerja());     
        Test.stopTest();

    }
}