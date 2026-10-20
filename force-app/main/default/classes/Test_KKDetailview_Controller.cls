@isTest
public class Test_KKDetailview_Controller {
    static testMethod void myUnitTest() {
        
        //Kertas_Kerja__c kkRec = [SELECT Id, Name, Kertas_Kerja_Name__c, Month__c, Year__c, Type__c, Media_Seller__c, Media_Seller_Name__c FROM Kertas_Kerja__c WHERE Id =: kk_id];
        Account accDWS = new Account();
        accDWS.Name = 'DWS';
        insert accDWS;
        
        Account accMustika = new Account();
        accMustika.Name = 'Mustika';
        insert accMustika;
        
        Kertas_Kerja__c kkRecDS = new Kertas_Kerja__c();
        kkRecDS.Kertas_Kerja_Name__c = 'Kertas Kerja Name Testing Direct Sales';
        kkRecDS.Month__c = 'January';
        kkRecDS.Year__c = '2021';
        kkRecDS.Type__c = 'Direct Sales';
        insert kkRecDS;
        
        kkRecDS.Month__c = 'February';
        kkRecDS.Year__c = '2021';
        update kkRecDS;
       
        kkRecDS.Month__c = 'March';
        kkRecDS.Year__c = '2021';
        update kkRecDS;
        
        kkRecDS.Month__c = 'April';
        kkRecDS.Year__c = '2021';
        update kkRecDS;
        
        kkRecDS.Month__c = 'May';
        kkRecDS.Year__c = '2021';
        update kkRecDS;
        
        kkRecDS.Month__c = 'June';
        kkRecDS.Year__c = '2021';
        update kkRecDS;
        
        kkRecDS.Month__c = 'July';
        kkRecDS.Year__c = '2021';
        update kkRecDS;
        
        kkRecDS.Month__c = 'August';
        kkRecDS.Year__c = '2021';
        update kkRecDS;
        
        kkRecDS.Month__c = 'September';
        kkRecDS.Year__c = '2021';
        update kkRecDS;
        
        kkRecDS.Month__c = 'October';
        kkRecDS.Year__c = '2021';
        update kkRecDS;
        
        kkRecDS.Month__c = 'November';
        kkRecDS.Year__c = '2021';
        update kkRecDS;
        
        kkRecDS.Month__c = 'December';
        kkRecDS.Year__c = '2021';
        update kkRecDS;

        
        
        system.debug('kkRecDS'+kkRecDS);
        
        Kertas_Kerja__c kkRecMSDWS = new Kertas_Kerja__c();
        kkRecMSDWS.Kertas_Kerja_Name__c = 'Kertas Kerja Name Testing Media Seller DWS';
        kkRecMSDWS.Month__c = 'January';
        kkRecMSDWS.Year__c = '2021';
        kkRecMSDWS.Type__c = 'Media Seller';       
        kkRecMSDWS.Media_Seller__c = accDWS.Id;
        insert kkRecMSDWS;           
        system.debug('kkRecMS'+kkRecMSDWS);
        
        Kertas_Kerja__c kkRecMSMustika = new Kertas_Kerja__c();
        kkRecMSMustika.Kertas_Kerja_Name__c = 'Kertas Kerja Name Testing Media Seller Mustika';
        kkRecMSMustika.Month__c = 'February';
        kkRecMSMustika.Year__c = '2021';
        kkRecMSMustika.Type__c = 'Media Seller';    
        kkRecMSMustika.Media_Seller__c = accMustika.Id;
        insert kkRecMSMustika;
        system.debug('kkRecMS'+kkRecMSMustika);
        
        Kertas_Kerja_Detail__c KKDrecDWS = new Kertas_Kerja_Detail__c();
        KKDrecDWS.Kertas_Kerja_Detail_Name__c = 'Testing MS DWS';
        KKDrecDWS.Month__c = 'January';
        KKDrecDWS.Year__c = '2021';   
        KKDrecDWS.Start_Date__c = date.newInstance(2021, 01, 15);
        KKDrecDWS.End_Date__c = date.newInstance(2021, 12, 30);  
        KKDrecDWS.Media_Seller__c = kkRecMSDWS.Media_Seller__c;
        KKDrecDWS.Type__c = 'Pembelian';
        KKDrecDWS.Pembelian__c = 90000;
        insert KKDrecDWS;
        
        Kertas_Kerja_Detail__c KKDrecMustika = new Kertas_Kerja_Detail__c();
        KKDrecMustika.Month__c = 'January';
        KKDrecMustika.Year__c = '2021';
        KKDrecMustika.Start_Date__c = date.newInstance(2021, 01, 15);
        KKDrecMustika.End_Date__c = date.newInstance(2021, 12, 30);      
        KKDrecMustika.Media_Seller__c = kkRecMSMustika.Media_Seller__c;
        KKDrecMustika.Type__c = 'Pembelian';
        KKDrecMustika.Pembelian__c = 90000;
        insert KKDrecMustika;
        
        Kertas_Kerja_Detail__c KKDrecNull = new Kertas_Kerja_Detail__c();
        KKDrecNull.Start_Date__c = date.newInstance(2021, 01, 15);
        KKDrecNull.End_Date__c = date.newInstance(2021, 12, 30);      
        KKDrecNull.Media_Seller__c = kkRecMSDWS.Media_Seller__c;
        KKDrecNull.Type__c = 'Pembelian';
        KKDrecNull.Pembelian__c = 90000;
        insert KKDrecNull;
                
        
        //testing untuk Direct Sales
        ApexPages.StandardController sc = new ApexPages.StandardController(kkRecDS);
        ApexPages.currentPage().getParameters().put('Id',kkRecDS.id);           
        KKDetailview_Controller testKKDetailview = new KKDetailview_Controller(sc);
        
        PageReference pRef = Page.KKDetailview_page;
        pRef.getParameters().put('Id', String.valueOf(kkRecDS.Id));
        Test.setCurrentPage(pRef);
        testKKDetailview.createkkd();
        
        //testing untuk KKD Media Seller   
     	ApexPages.StandardController sc2 = new ApexPages.StandardController(kkRecMSDWS);
        ApexPages.currentPage().getParameters().put('Id',kkRecMSDWS.id);           
        KKDetailview_Controller testKKDetailview2 = new KKDetailview_Controller(sc2);
        
        testKKDetailview.isCreate = false;
        testKKDetailview.amounttemp = 90000;
        testKKDetailview.KKDrec = KKDrecDWS;
        testKKDetailview.createkkd();
        testKKDetailview.KKD_ID = KKDrecDWS.Id;
        testKKDetailview.EdittheSection();
        testKKDetailview.addButton();
        testKKDetailview.cancelButton();
        
    }
}