@isTest
public class Test_TrafficPage {
    
    static testMethod void TrafficController(){
        
        RecordType rc = [SELECT Id, Name, DeveloperName, IsActive, SobjectType FROM RecordType WHERE DeveloperName = 'Publisher' AND SobjectType = 'Account'];
        System.debug('*** rc = ' + rc );
    
        Account acc = new Account();
        acc.Name = 'Acc Testing';
        acc.Nomor_Verifikasi_Dewan_Pers__c = '12/DP-Terverifikasi/K/II/2017';
        acc.Site_Domain__c = 'dinamomediant.com';
        acc.Nomor_Induk_Berusaha__c = '12345001';
        acc.Nama_Penjabat__c = 'Yoise';
        acc.Account_Type__c = 'Publisher';
        acc.AccountSource = 'TADEX Form';
        acc.Publisher_Status__c = 'Ad Tag Shared';
        acc.Jabatan_Penjabat__c = 'Staff Khusus';
        acc.Contract_Bypass_Approval__c = 'Approved';
        acc.Tipe_Platform__c = 'Web;Mobile';
        acc.Tipe_Display_Ads__c = 'Desktop Display 300x250;Desktop Display 728x90;Desktop Display 320x50;Mobile Display 300x250';
        acc.Tipe_Video_Ads__c = 'Video instream - VAST;Video instream - VPAID;Video outstream - VAST';
        acc.Total_Ad_Request_Bulan__c = 1000;
        acc.Content_Sections__c = 'Food;Tekno;Lifestyle';
        acc.Content__c = 'Specific';
        acc.Nama_Pemilik__c = 'Kartika';
        acc.Nomor_Rekening__c = '098907890079';
        acc.Chatter_Name__c = 'Fransiska';
        //acc.Chatter_Group_Id__c = '0F9p0000000NWMyCAO';
        acc.Chatter_Group_Id__c = '';
        acc.Chatter_Email__c = 'fransiska@dmnt.com';
        acc.RecordTypeId = rc.Id;
        insert acc;
        
        acc.Publisher_Status__c = 'Contract Signed';
        acc.Contract_Bypass_Approval__c = 'Approved';
        update acc;
        
        system.debug('*** acc.Chatter_Group_Id__c = ' + acc.Chatter_Group_Id__c);
        
        String chatterGroupName1 = acc.Name + ' - Group';
        String chatterGroupName2 = acc.Name + '- Group';
        List<CollaborationGroup> cgList = [SELECT Id, Name FROM CollaborationGroup WHERE Name =: chatterGroupName1 OR Name =: chatterGroupName2];
        system.debug('*** cgList = ' + cgList.size() + ' | ' + cgList);
        
        acc.Chatter_Group_Id__c = cgList[0].Id;
        update acc;
        
        Berita_Acara__c ba = new Berita_Acara__c();
        ba.Month__c = 'December';
        ba.Year__c = '2021';
        //ba.BAST_No__c = '123450003';
        ba.Account__c = acc.Id;
        ba.Exchange_Rate__c = 14550;
        ba.Status__c = 'Draft';
        insert ba;
        
        //ba.Status__c = 'Shared';
        //update ba;
        
        Domains__c dom = new Domains__c();
        dom.Domain_Name__c = 'www.abc.com';
        dom.Status__c = 'Active';
        dom.Account__c = acc.Id;
        dom.Total_Ad_Request_Bulan__c = 1500000;
        dom.Tipe_Platform__c = 'Web';
        dom.Tipe_Display_Ads__c = 'Desktop Display 300x250';
        dom.Tipe_Video_Ads__c = 'Video instream - VPAID;Video outstream - VAST';
        insert dom;
                   
        Sites__c st = new Sites__c();
        st.Site_ID__c = '796787';
        st.siteUrl__c = 'TADEX|Web|Abc|Abc.com|Outstream';
        st.Domain__c = dom.Id;        
        st.Platform__c = 'Web';
        st.Status__c = 'New';
        insert st;
		
        st.Status__c = 'Request Ad Tag';
        update st;
        
        Sites__c st1 = new Sites__c();
        st1.Site_ID__c = '796788';
        st1.siteUrl__c = 'TADEX|MobileWeb|PT_Abc_Oke_Bgt_1234567890|Abc12345678990.com|Outstream';
        st1.Domain__c = dom.Id;        
        st1.Platform__c = 'Mobile';
        st1.Status__c = 'New';
        insert st1;
        
        Sites__c st2 = new Sites__c();
        st2.Site_ID__c = '796789';
        st2.siteUrl__c = 'TADEX|MobileWeb|PT_Abc_Oke_Bgt_1234567890|Abc123.com';
        st2.Domain__c = dom.Id;        
        st2.Platform__c = 'Mobile';
        st2.Status__c = 'New';
        insert st2;
        
        Sites__c st3 = new Sites__c();
        st3.Site_ID__c = '796790';
        st3.siteUrl__c = 'TADEX_MobileWeb-PT_Abc_Oke_Bgt_1234567890';
        st3.Domain__c = dom.Id;        
        st3.Platform__c = 'Mobile';
        st3.Status__c = 'New';
        insert st3;
        
        Demand_Source_Information__c dsi = new Demand_Source_Information__c();
        dsi.Demand_Source__c = 'Programmatic PMP with Tadex\'s DSP';
        dsi.Share__c = 10;
        insert dsi;
        
        Demand_Source_Information__c dsi2 = new Demand_Source_Information__c();
        dsi2.Demand_Source__c = 'Programmatic PMP with Client\'s DSP';
        dsi2.Share__c = 10;
        insert dsi2;
        
        Business_Model_Category__c bmc = new Business_Model_Category__c();
        bmc.BMC_Text__c = 'TADEX_METRANET';
        bmc.Percentage__c = 10;
        //bmc.Demand_Source__c = 'Programmatic PMP with Client\'s DSP';
        bmc.Demand_Source__c = 'Programmatic PMP with Tadex\'s DSP';
        bmc.BMC_Name__c = 'Tadex Metranet';
        bmc.Demand_Source_Information__c = dsi.Id;
        insert bmc;
        
        update bmc;
        
        /*Business_Model_Category__c bmc2 = new Business_Model_Category__c();
        bmc2.BMC_Text__c = 'TADEX_METRANET';
        bmc2.Percentage__c = 20;
        bmc.Demand_Source__c = 'Programmatic PMP with Tadex\'s DSP';
        bmc2.BMC_Name__c = 'Tadex Metranet';
        insert bmc2;*/
        
        Business_Model_Category__c bmc2 = new Business_Model_Category__c();
        bmc2.BMC_Text__c = 'TADEX_';
        bmc2.Percentage__c = 20;
        bmc2.Demand_Source__c = 'Programmatic PMP with Client\'s DSP';
        bmc2.Demand_Source_Information__c = dsi2.Id;
        bmc2.BMC_Name__c = 'Tadex Client';
        insert bmc2;
        
        Traffic__c tf = new Traffic__c();
        tf.Sites__c = st.Id;
        tf.Berita_Acara__c = ba.Id;
        tf.Date__c = Date.today();
        tf.Deal_ID__c = 'PM-DZDH-0639';
        tf.Deal__c = 'TADEX_METRANET_TTD_3729_DISPLAY_16042021';
        tf.Paid_Impressions__c = 165;
        tf.Revenue_USD__c = 0.16;
        tf.Deal_Source__c = 'Publisher';
        tf.Fee__c = 10;
        tf.PMP_Fees__c = 0.11;
        tf.Net_Revenue__c = 0.26;
        //tf.Business_Model_Category__c = bmc.Id;
        tf.Total_Telkomsel_Share__c = 10;
        insert tf;
        
        Traffic__c tf2 = new Traffic__c();
        tf2.Sites__c = st.Id;
        tf2.Berita_Acara__c = ba.Id;
        tf2.Date__c = Date.today();
        tf2.Deal_ID__c = 'PM-DZDH-0639';
        tf2.Deal__c = 'TADEX_METRANET_TTD_3729_DISPLAY_16042021';
        tf2.Paid_Impressions__c = 165;
        tf2.Revenue_USD__c = 0.16;
        tf2.Deal_Source__c = 'Publisher';
        tf2.Fee__c = 10;
        tf2.PMP_Fees__c = 0.11;
        tf2.Net_Revenue__c = 0.26;
        //tf2.Business_Model_Category__c = bmc2.id;
        tf2.Total_Telkomsel_Share__c = 10;
        insert tf2;
        
        Traffic__c tf3 = new Traffic__c();
        tf3.Sites__c = st1.Id;
        tf3.Berita_Acara__c = ba.Id;
        tf3.Date__c = Date.today();
        tf3.Deal_ID__c = 'PM-DZDH-0639';
        tf3.Deal__c = 'TADEX_METRANET_TTD_3729_DISPLAY_16042021_METRANET_TTD_METRANET_TTD';
        tf3.Paid_Impressions__c = 165;
        tf3.Revenue_USD__c = 0.16;
        tf3.Deal_Source__c = 'Publisher';
        tf3.Fee__c = 10;
        tf3.PMP_Fees__c = 0.11;
        tf3.Net_Revenue__c = 0.26;
        tf3.Total_Telkomsel_Share__c = 10;
        insert tf3;
        
        Traffic__c tf4 = new Traffic__c();
        tf4.Sites__c = st2.Id;
        tf4.Berita_Acara__c = ba.Id;
        tf4.Date__c = Date.today();
        tf4.Deal_ID__c = 'PM-DZDH-0639';
        tf4.Deal__c = 'TADEX_METRANET_TTD_3729_DISPLAY_16042021_METRANET_TTD_METRANET_TTD';
        tf4.Paid_Impressions__c = 165;
        tf4.Revenue_USD__c = 0.16;
        tf4.Deal_Source__c = 'Publisher';
        tf4.Fee__c = 10;
        tf4.PMP_Fees__c = 0.11;
        tf4.Net_Revenue__c = 0.26;
        tf4.Total_Telkomsel_Share__c = 10;
        insert tf4;
        
        Traffic__c tf5 = new Traffic__c();
        tf5.Sites__c = st3.Id;
        tf5.Berita_Acara__c = ba.Id;
        tf5.Date__c = Date.today();
        tf5.Deal_ID__c = 'PM-DZDH-0639';
        tf5.Deal__c = 'TADEX_METRANET_TTD_3729_DISPLAY_16042021_METRANET_TTD_METRANET_TTD';
        tf5.Paid_Impressions__c = 165;
        tf5.Revenue_USD__c = 0.16;
        tf5.Deal_Source__c = 'Publisher';
        tf5.Fee__c = 10;
        tf5.PMP_Fees__c = 0.11;
        tf5.Net_Revenue__c = 0.26;
        tf5.Total_Telkomsel_Share__c = 10;
        insert tf5;
        
        DateTime dt = system.now();
        String dt_month = dt.format('MMMM');
        String dt_year = dt.format('yyyy');
        
        Berita_Acara__c ba2 = new Berita_Acara__c();
        ba2.Month__c = dt_month;
        ba2.Year__c = dt_year;
        //ba2.BAST_No__c = '123450003';
        ba2.Account__c = acc.Id;
        ba2.Exchange_Rate__c = 14550;
        ba2.Status__c = 'Draft';
        insert ba2;
        
        PageReference pRef1 = Page.TrafficPage;
        pRef1.getParameters().put('Id', String.valueOf(ba.Id));
        Test.setCurrentPage(pRef1);
        
        TrafficController testTraffic = new TrafficController();
        
        PageReference pRefBa = Page.BeritaAcara_pdf;
        pRefBa.getParameters().put('Id', String.valueOf(ba.Id));
        Test.setCurrentPage(pRefBa);
        ApexPages.StandardController sc = new  ApexPages.StandardController(ba);
        BeritaAcara_controller testBA = new BeritaAcara_controller(sc);
        
        Tadex_ShareDocs.share_ba_traffic(ba.Id);
    }    
}