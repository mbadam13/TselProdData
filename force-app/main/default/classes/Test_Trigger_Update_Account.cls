@isTest
public class Test_Trigger_Update_Account {

    @isTest static void Trigger_Update_Site(){
        
        RecordType rc = [SELECT Id, Name, DeveloperName, IsActive, SobjectType FROM RecordType WHERE DeveloperName = 'Publisher' AND SobjectType = 'Account'];
        System.debug('*** rc = ' + rc );
        
        Account acc = new Account();
        acc.Name = 'PT Test 23 Sep 2021';
        acc.Site_Domain__c = 'www.test21sep2021aa.com';
        acc.Nomor_Verifikasi_Dewan_Pers__c = '23/566/TDP/2021';
        acc.Nomor_Induk_Berusaha__c = '643543523431';
        acc.Privacy_Policy__c = 'saasten.com/privacolicy';
        acc.Nama_Penjabat__c = 'Marwan';
        acc.Account_Type__c = 'Publisher';
        acc.AccountSource = 'TADEX Form';        
        acc.Publisher_Status__c = 'Draft Contract Sent';
        acc.Jabatan_Penjabat__c = 'CEO';        
        acc.Tipe_Platform__c = 'Web';
        acc.Tipe_Display_Ads__c = 'Desktop Display 300x250';
        acc.Content__c = 'General';
        acc.Total_Ad_Request_Bulan__c = 2000;
        acc.Tipe_Video_Ads__c = 'Video instream - VAST';
        acc.Nama_Pemilik__c = 'Dikka';
        acc.Nomor_Rekening__c = '12312312';
        acc.Chatter_Name__c = 'Marwin';
        acc.Chatter_Group_Id__c = '0F9p0000000NWSmCAO';
        acc.Chatter_Email__c = 'marwin@saasten.com';
        acc.RecordTypeId = rc.Id;
        insert acc;
        
        Domains__c dom = new Domains__c();
        dom.Domain_Name__c = 'www.test21sep2021aa.com';
        dom.Nomor_verifikasi_Dewan_Pers__c = '23/566/TDP/2021';
        dom.Privacy_Policy__c = 'saasten.com/privacolicy';
        dom.Status__c = 'Draft';
        dom.Account__c = acc.Id;
        dom.Content__c = 'General';
        dom.Total_Ad_Request_Bulan__c = 2000;
        dom.Tipe_Platform__c = 'Web';
        dom.Tipe_Display_Ads__c = 'Desktop Display 300x250';
        dom.Tipe_Video_Ads__c = 'Video instream - VAST';
        insert dom;
        
        Sites__c sts = new Sites__c();
        sts.Site_ID__c = '865199';
        sts.Domain__c = dom.Id;
        sts.Platform__c = 'Web';
        sts.Status__c = 'New';
        insert sts;
        
        Ad_Tag__c at = new Ad_Tag__c();
        at.Sites__c = sts.Id;
        at.Ad_Type__c = 'Display';
        //at.Ecpm__c = 1;
        //at.adScript__c = '<script async src="https://securepubads.g.doubleclick.net/tag/js/gpt.js">';
        //at.adTagPlacementId__c = 0;
        //at.currency__c = 1;
        //at.minDuration__c = 5;
        //at.maxDuration__c = 300;
        //at.videoMimeTypes__c = '1, 5, 7';
        //at.Ad_Tag_Name__c = 'Ad Tag Naming Convention';
        at.foldPlacementId__c = 0;
        at.pagePlacementId__c = 6;
        at.Ad_Size__c = '300x250';
        insert at;
        
        Ad_Tag__c at2 = new Ad_Tag__c();
        at2.Sites__c = sts.Id;
        at2.Ad_Type__c = 'Video';
        //at2.Ecpm__c = 1;
        //at2.adScript__c = '<script async src="https://securepubads.g.doubleclick.net/tag/js/gpt.js">';
        //at2.adTagPlacementId__c = 0;
        //at2.currency__c = 1;
        //at2.minDuration__c = 5;
        //at2.maxDuration__c = 300;
        //at2.videoMimeTypes__c = '1, 5, 7';        
        //at2.Ad_Tag_Name__c = 'Ad Tag Naming Convention';
        at2.foldPlacementId__c = 0;
        at2.pagePlacementId__c = 6;
        at2.Ad_Size__c = 'Video';
        insert at2;        
        
        sts.Status__c = 'Request Ad Tag';
        update sts;  
        
        acc.Publisher_Status__c = 'Contract Signed';
        update acc;
        
        acc.Publisher_Status__c = 'Ad Tag Shared';
        acc.Contract_Bypass_Approval__c = 'Approved';
        update acc;
        
        sts.Status__c = 'Approved';
        update sts;
        
        //dom.Status__c = 'Active';
        //update dom;
        
        
        List<Sites__c> checkSiteList = [SELECT Id, Name, siteUrl__c, Status__c FROM Sites__c WHERE Domain__c =: dom.Id];
        system.debug('*** checkSiteList = ' + checkSiteList.size() + ' | ' + checkSiteList);
        
        /*for(Sites__c siteRec : checkSiteList){
            siteRec.Status__c = 'Approved';
        }
        update checkSiteList;*/
        
        List<Ad_Tag__c> checkAdTagList = [SELECT Id, Name, Ad_Tag_Script__c FROM Ad_Tag__c WHERE Sites__r.Domain__c =: dom.Id];
        system.debug('*** checkAdTagList = ' + checkAdTagList.size() + ' | ' + checkAdTagList);
        
        /*for(Ad_Tag__c adTagRec : checkAdTagList){
            adTagRec.Ad_Tag_Script__c = 'var kadschain = xxx</script>yyy';
        }
        update checkAdTagList;*/
        
        TadexAPI_Site.createSite(checkSiteList[0].Id);
        TadexAPI_AdTag.createAdTag(checkAdTagList[0].Id);
    }
    
    @isTest static void Trigger_Update_Account(){
        TadexMemberSetting__c  TadexMemberSettingRec = new TadexMemberSetting__c();
        TadexMemberSettingRec.ID_User__c = '0052v00000fzOlkAAE'; //Id user production
		TadexMemberSettingRec.Name = 'Ayu S Hartati';        
        insert TadexMemberSettingRec;
        
        RecordType rc = [SELECT Id, Name, DeveloperName, IsActive, SobjectType FROM RecordType WHERE DeveloperName = 'Publisher' AND SobjectType = 'Account'];
        System.debug('*** rc = ' + rc );
        
        Account act = new Account();
        act.Name = 'PT Test 24 Sep 2021';
        act.Site_Domain__c = 'www.test24sep2021aa.com';
        act.Nomor_Verifikasi_Dewan_Pers__c = '24/566/TDP/2021';
        act.Nomor_Induk_Berusaha__c = '643543523499';
        act.Privacy_Policy__c = 'saasten.com/privacolicy24';
        act.Nama_Penjabat__c = 'Marwen';
        act.Account_Type__c = 'Publisher';
        act.AccountSource = 'TADEX Form';
        act.Publisher_Status__c = 'Draft Contract Sent';
        act.Jabatan_Penjabat__c = 'CEO';        
        act.Tipe_Platform__c = 'Web';
        act.Tipe_Display_Ads__c = 'Desktop Display 300x250';
        act.Content__c = 'General';
        act.Total_Ad_Request_Bulan__c = 3000;
        act.Tipe_Video_Ads__c = 'Video instream - VAST';
        act.Nama_Pemilik__c = 'Dikke';
        act.Nomor_Rekening__c = '1231231224';
        act.Chatter_Name__c = 'Marwun';
        act.Chatter_Group_Id__c = '0F9p0000000NWSmCAO';
        act.Chatter_Email__c = 'marwun@saasten.com';
        act.RecordTypeId = rc.Id;
        insert act;
        
        act.Publisher_Status__c = 'Contract Signed';
        update act;
        
        act.Publisher_Status__c = 'Ad Tag Shared';
        act.Contract_Bypass_Approval__c = 'Approved';
        update act;
        
        Berita_Acara__c bac = new Berita_Acara__c();
        bac.Month__c = 'December';
        bac.Year__c = '2021';
        //bac.BAST_No__c = '123450099';
        bac.Account__c = act.Id;
        bac.Exchange_Rate__c = 14850;
        bac.Status__c = 'Draft';
        insert bac;
        
        /*bac.Status__c = 'Shared';
        update bac;*/
        
        try{
            bac.Status__c = 'Shared';
        	update bac;
        }catch(Exception ex)
            {Boolean expectedExceptionThrown =  ex.getMessage().contains('There is no Traffic for this Berita Acara.') ? true : false;}
        
        Domains__c dom = new Domains__c();
        dom.Domain_Name__c = 'www.abc.com';
        dom.Status__c = 'Active';
        dom.Account__c = act.Id;
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
        st.Status__c = 'Request Ad Tag';
        insert st;
        
        //dom.Status__c = 'Active';
        //update dom;
        
        //st.Status__c = 'Approved';
        //update st;
        
        Ad_Tag__c at3 = new Ad_Tag__c();
        at3.Sites__c = st.Id;
        at3.Ad_Type__c = 'Display';
        //at3.Ecpm__c = 1;
        //at3.adScript__c = '';
        //at3.adTagPlacementId__c = 0;
        //at3.currency__c = 1;
        //at3.minDuration__c = 5;
        //at3.maxDuration__c = 300;
        //at3.videoMimeTypes__c = '1, 5, 7';        
        //at3.Ad_Tag_Name__c = 'Ad Tag Naming Convention';
        at3.foldPlacementId__c = 0;
        at3.pagePlacementId__c = 6;
        at3.Ad_Size__c = '300x250';
        insert at3;
        
        //at3.adScript__c = '<script async src="https://securepubads.g.doubleclick.net/tag/js/gpt.js">';
        //update at3;
        
        Ad_Tag__c at4 = new Ad_Tag__c();
        at4.Sites__c = st.Id;
        at4.Ad_Type__c = 'Video';
        //at4.Ecpm__c = 1;
        //at4.adScript__c = '<script async src="https://securepubads.g.doubleclick.net/tag/js/gpt.js">';
        //at4.adTagPlacementId__c = 0;
        //at4.currency__c = 1;
        //at4.minDuration__c = 5;
        //at4.maxDuration__c = 300;
        //at4.videoMimeTypes__c = '1, 5, 7';        
        //at4.Ad_Tag_Name__c = 'Ad Tag Naming Convention';
        at4.foldPlacementId__c = 0;
        at4.pagePlacementId__c = 6;
        at4.Ad_Size__c = 'Video';
        insert at4; 

		Demand_Source_Information__c dsi = new 	Demand_Source_Information__c();
        dsi.demand_Source__c = 'OMP';
        dsi.share__c = 0;
        Insert dsi;
               
        Business_Model_Category__c bmc = new Business_Model_Category__c();
        bmc.BMC_Text__c = 'TADEX_METRANET';
        bmc.Percentage__c = 10;
        bmc.Demand_Source__c = 'OMP';
        bmc.Demand_Source_Information__c = dsi.id;
        bmc.BMC_Name__c = 'Tadex Metranet';
 
        insert bmc;
       
        Traffic__c tf = new Traffic__c();
        tf.Sites__c = st.Id;
        tf.Berita_Acara__c = bac.Id;
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
        
    }
        
                                
}