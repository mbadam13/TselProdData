@isTest
public class Test_Trigger_Insert_Site {

    @isTest static void Trigger_Insert_Site(){
        
        RecordType rc = [SELECT Id, Name, DeveloperName, IsActive, SobjectType FROM RecordType WHERE DeveloperName = 'Publisher' AND SobjectType = 'Account'];
        System.debug('*** rc = ' + rc );
        
        Account acc = new Account();
        acc.Name = 'Acc Testing';
        acc.Account_Type__c = 'Publisher';
        acc.Site_Domain__c = 'www.abc.com';
        acc.Bundle_ID__c = 'com.abc.hosted';
        acc.Nomor_Verifikasi_Dewan_Pers__c = '456/DP-Terverifikasi/K/XI/2020';
        acc.Nomor_Induk_Berusaha__c = '12345001';
        acc.Nama_Penjabat__c = 'Joice';
        acc.AccountSource = 'TADEX Form';
        acc.Publisher_Status__c = 'Ad Tag Shared';
        acc.Jabatan_Penjabat__c = 'Manager';
        acc.Contract_Bypass_Approval__c = 'Approved';
        acc.Tipe_Platform__c = 'Web;Mobile;Application';
        acc.Tipe_Display_Ads__c = 'Desktop Display 300x250;Desktop Display 728x90;Desktop Display 320x50;Mobile Display 300x250;Mobile Display 320x50;Desktop Display 300x600;Mobile Display 300x600;IOS Display 728x90;IOS Display 300x250;IOS Display 320x50;IOS Display 300x600;Android Display 728x90;Android Display 300x250;Android Display 320x50;Android Display 300x600';
        acc.Tipe_Video_Ads__c = 'Video instream - VAST;Video instream - VPAID;Video outstream - VAST;Video outstream - VPAID;IOS Video instream - VAST;IOS Video instream - VPAID;IOS Video outstream - VAST;IOS Video outstream - VPAID;Android Video instream - VAST;Android Video instream - VPAID;Android Video outstream - VAST;Android Video outstream - VPAID';
        acc.Total_Ad_Request_Bulan__c = 1000;
        acc.Content__c = 'Specific';
        acc.Content_Sections__c = 'Sports;Style & Fashion';
        acc.Nama_Pemilik__c = 'Tika';
        acc.Nomor_Rekening__c = '098907890079';
        acc.Chatter_Name__c = 'Aprilia';
        //acc.Chatter_Group_Id__c = '0F9p0000000NWMyCAO';
        acc.Chatter_Email__c = 'aprilia@dmnt.com';
        acc.Contract_Bypass_Approval__c = 'Approved';
        acc.RecordTypeId = rc.Id;
        acc.Header_Bidding__c = 'Implementasi Header Bidding';
        insert acc;
        
        acc.Publisher_Status__c = 'Contract Signed';
        acc.Contract_Bypass_Approval__c = 'Approved';
        update acc;
		  String chatterGroupName = acc.Name + ' - Group';
		/*CollaborationGroup  CG =  new CollaborationGroup();
        CG.Name = chatterGroupName;
        CG.CollaborationType = 'Private';
        Insert CG;
        system.debug('*** acc.Chatter_Group_Id__c = ' + acc.Chatter_Group_Id__c);
        
        List<CollaborationGroup> cgList = [SELECT Id, Name, CollaborationType FROM CollaborationGroup WHERE Name =: chatterGroupName];
        system.debug('*** cgList = ' + cgList.size() + ' | ' + cgList);
        
        acc.Chatter_Group_Id__c = CG.Id;
        update acc;
        */
        Berita_Acara__c ba = new Berita_Acara__c();
        ba.Month__c = 'December';
        ba.Year__c = '2021';
        //ba.BAST_No__c = '123450003';
        ba.Account__c = acc.Id;
        ba.Exchange_Rate__c = 14550;
        ba.Status__c = 'Shared';
        insert ba;
        
        Domains__c dom = new Domains__c();
        dom.Domain_Name__c = 'www.abc.com';
        dom.Bundle_ID__c = 'com.abc.hosted';
        dom.Status__c = 'Active';
        dom.Account__c = acc.Id;
        dom.Total_Ad_Request_Bulan__c = 1000;
        dom.Tipe_Platform__c = 'Web;Mobile;Application';
        dom.Tipe_Display_Ads__c = 'Desktop Display 300x250;Desktop Display 728x90;Desktop Display 320x50;Mobile Display 300x250;Mobile Display 320x50;Desktop Display 300x600;Mobile Display 300x600;IOS Display 728x90;IOS Display 300x250;IOS Display 320x50;IOS Display 300x600;Android Display 728x90;Android Display 300x250;Android Display 320x50;Android Display 300x600';
        dom.Tipe_Video_Ads__c = 'Video instream - VAST;Video instream - VPAID;Video outstream - VAST;Video outstream - VPAID;IOS Video instream - VAST;IOS Video instream - VPAID;IOS Video outstream - VAST;IOS Video outstream - VPAID;Android Video instream - VAST;Android Video instream - VPAID;Android Video outstream - VAST;Android Video outstream - VPAID';
        insert dom;
                   
        Sites__c st = new Sites__c();
        st.Site_ID__c = '796787';
        st.siteUrl__c = 'TADEX|MOBILE_APP_IOS|PT_Berkah_Maju_Sentosa|com.usamah.ridha.official|Business';
        st.Domain__c = dom.Id;        
        st.Platform__c = 'Application';
        st.Application_Type__c = 'IOS';
        st.Status__c = 'New';
        insert st;
        
        st.Status__c = 'Approved';
        update st;                
        
        Demand_Source_Information__c dsi = new Demand_Source_Information__c();
        dsi.Demand_Source__c = 'Programmatic PMP with Tadex\'s DSP';
        dsi.Share__c = 10;
        insert dsi;
        
        Business_Model_Category__c bmc = new Business_Model_Category__c();
        bmc.BMC_Text__c = 'TADEX_METRANET';
        bmc.Percentage__c = 10;
        bmc.Demand_Source__c = 'Programmatic PMP with Client\'s DSP';
        bmc.BMC_Name__c = 'Tadex Metranet';
        bmc.Demand_Source_Information__c = dsi.Id;
        insert bmc;
        
        Business_Model_Category__c bmc2 = new Business_Model_Category__c();
        bmc2.BMC_Text__c = 'TADEX_MITRANET';
        bmc2.Percentage__c = 20;
        bmc2.Demand_Source__c = 'Programmatic PMP with Tadex\'s DSP';
        bmc2.BMC_Name__c = 'Tadex Mitranet';
        bmc2.Demand_Source_Information__c = dsi.Id;
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
        tf.Business_Model_Category__c = bmc.Id;
        tf.Total_Telkomsel_Share__c = 10;
        insert tf;
        
        Traffic__c tf2 = new Traffic__c();
        tf2.Sites__c = st.Id;
        tf2.Date__c = Date.today();
        tf2.Deal_ID__c = 'PM-DZDH-0003';
        tf2.Deal__c = 'TADEX_ULTRA_TTD_2045_VIDEO_12042022';
        tf2.Paid_Impressions__c = 9951;
        tf2.Revenue_USD__c = 9.95;
        tf2.Deal_Source__c = 'Publisher';
        tf2.Fee__c = 10;
        tf2.PMP_Fees__c = 1;
        tf2.Net_Revenue__c = 8.96;
        tf2.Business_Model_Category__c = bmc2.Id;
        tf2.Total_Telkomsel_Share__c = 17;
        tf2.Demand_Source__c = 'Programmatic PMP with Tadex\'s DSP';
        insert tf2;     
        
        try
            {delete ba;}
        catch(Exception ex)
            {Boolean expectedExceptionThrown =  ex.getMessage().contains('There is Traffic data for this Berita Acara, so it cannot be deleted.') ? true : false;}
        
        Account acc1 = acc.clone(false, false, false, false);
        insert acc1;
        
        List<Sites__c> checkSiteList = [SELECT Id, Name, siteUrl__c, Status__c FROM Sites__c WHERE Domain__c =: dom.Id];
        system.debug('*** checkSiteList = ' + checkSiteList.size() + ' | ' + checkSiteList);
        
        for(Sites__c siteRec : checkSiteList){
            siteRec.Status__c = 'Approved';
        }
        update checkSiteList;
        
        List<Ad_Tag__c> checkAdTagList = [SELECT Id, Name, Ad_Tag_Script__c FROM Ad_Tag__c WHERE Sites__r.Domain__c =: dom.Id];
        system.debug('*** checkAdTagList = ' + checkAdTagList.size() + ' | ' + checkAdTagList);
        
        for(Ad_Tag__c adTagRec : checkAdTagList){
            adTagRec.Ad_Tag_Script__c = 'var kadschain = xxx</script>yyy';
        }
        update checkAdTagList;
        
        dom.Status__c = 'Draft';
        update dom;
        dom.Status__c = 'Active';
        update dom;
        
        try{
            dom.Account__c = acc1.Id;
            update dom;
        }catch(Exception ex)
            {Boolean expectedExceptionThrown =  ex.getMessage().contains('Account cannot be updated.') ? true : false;}
        
    }
}