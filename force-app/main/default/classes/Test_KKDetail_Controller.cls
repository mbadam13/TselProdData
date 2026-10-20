@isTest
public class Test_KKDetail_Controller {
    static testMethod void myUnitTest() {
        Account accDWS = new Account();
        accDWS.Name = 'DWS';
        insert accDWS;
        
        Account accMustika = new Account();
        accMustika.Name = 'Mustika';
        insert accMustika;
        
        Kertas_Kerja__c kkRec = new Kertas_Kerja__c();
        kkRec.Kertas_Kerja_Name__c = 'Kertas Kerja Name Testing Direct Sales';
        kkRec.Month__c = 'January';
        kkRec.Year__c = '2021';
        kkRec.Type__c = 'Media Seller';    
        kkRec.Media_Seller__c = accMustika.Id;
        insert kkRec;
        
        
        kkRec.Month__c = 'February';
        kkRec.Year__c = '2021';
        update kkRec;
       
        kkRec.Month__c = 'March';
        kkRec.Year__c = '2021';
        update kkRec;
        
        kkRec.Month__c = 'April';
        kkRec.Year__c = '2021';
        update kkRec;
        
        kkRec.Month__c = 'May';
        kkRec.Year__c = '2021';
        update kkRec;
        
        kkRec.Month__c = 'June';
        kkRec.Year__c = '2021';
        update kkRec;
        
        kkRec.Month__c = 'July';
        kkRec.Year__c = '2021';
        update kkRec;
        
        kkRec.Month__c = 'August';
        kkRec.Year__c = '2021';
        update kkRec;
        
        kkRec.Month__c = 'September';
        kkRec.Year__c = '2021';
        update kkRec;
        
        kkRec.Month__c = 'October';
        kkRec.Year__c = '2021';
        update kkRec;
        
        kkRec.Month__c = 'November';
        kkRec.Year__c = '2021';
        update kkRec;
        
        kkRec.Month__c = 'December';
        kkRec.Year__c = '2021';
        update kkRec;
        
        Kertas_Kerja_Detail__c KKDrecMustika = new Kertas_Kerja_Detail__c();
        KKDrecMustika.Month__c = 'January';
        KKDrecMustika.Year__c = '2021';
        KKDrecMustika.Start_Date__c = date.newInstance(2021, 01, 15);
        KKDrecMustika.End_Date__c = date.newInstance(2021, 12, 30);      
        KKDrecMustika.Media_Seller__c = kkRec.Media_Seller__c;
        KKDrecMustika.Type__c = 'Pembelian';
        KKDrecMustika.Pembelian__c = 90000;
        insert KKDrecMustika;
        
        PageReference pRef1 = Page.KKDetail_Page;
        pRef1.getParameters().put('Id', String.valueOf(kkRec.Id));
        Test.setCurrentPage(pRef1);
        
        PageReference pRefKKD = Page.KKDetail_Page;
        pRefKKD.getParameters().put('Id', String.valueOf(kkRec.Id));
        Test.setCurrentPage(pRefKKD);
        ApexPages.StandardController sc = new  ApexPages.StandardController(kkRec);
        KKDetail_Controller testKKD = new KKDetail_Controller(sc);
        
    }

}