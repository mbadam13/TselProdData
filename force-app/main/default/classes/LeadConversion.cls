/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 05-11-2023
 * @last modified by  : Diky Nurosid
**/
public class LeadConversion
{
    @InvocableMethod
    public static void LeadConversion (List<Id> LeadIds)
    {
        LeadStatus CLeadStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        Lead leadObj = [SELECT Id, Name, Account_Type__c, email, PIC_Telkomsel__c, NPWP__c, Nomor_Rekening__c, Nomor_Induk_Berusaha__c, 
                        Nama_Penjabat__c, Nama_Pemilik__c, Legal_Name__c, Kategori_Bisnis__c, Jabatan_Penjabat__c, IsLead__c, Alamat_PIC_Marketing__c, 
                        Alamat_Usaha__c, Advertiser_Brand__c, Chatter_Email__c, Chatter_Name__c, CategoryOLD__c, Direct_Indirect__c, 
                        Email_Temporary__c, Title_PIC_Marketing__c, Company , PIC_Marketing__c, PIC_Marketing_Mobile__c, PIC_Marketing_Email__c, 
                        Site_Domain__c, Tipe_Platform__c, Total_Ad_Request_Bulan__c, Tipe_Display_Ads__c, Tipe_Video_Ads__c, Content__c, 
                        Content_Sections__c, Privacy_Policy__c, Nomor_Verifikasi_Dewan_Pers__c, Nama_Bank__c , Header_Bidding__c, Bundle_ID__c
                        FROM Lead 
                        WHERE id =: LeadIds[0]];
        System.debug('leadObj ==>' + leadObj);
        System.debug('Tipe_Platform__c ==>' + leadObj.Tipe_Platform__c);
        Database.LeadConvert lc = new Database.LeadConvert();
         System.debug('leadConvert ==>' + lc);
        lc.setLeadId(LeadIds[0]);
        lc.setConvertedStatus(CLeadStatus.MasterLabel);
        lc.setDoNotCreateOpportunity(TRUE);
        
        boolean AccountNotExist=FALSE;
        boolean ContactNotExist=FALSE;
        
        //Query Account based on Name/lead.Company
        List <Account> ListAcc = [SELECT id, name FROM Account WHERE name =: leadObj.company LIMIT 1]; system.debug('*** ListAcc = ' + ListAcc.size() + ' | ' + ListAcc);
		//Check if there is exsiting account found
        if(ListAcc.size()>0){
            lc.setAccountId(ListAcc[0].Id); //Account found --> set lead conversion to use existing account            
        } else {
            AccountNotExist=TRUE;// ELSE is account not exits == true
        }
        
        //Query Contact based on Email for lead.picclient
        List <Contact> ListContClient = [SELECT Id, Name, AccountId, Account.Name FROM Contact WHERE Email =: leadObj.Email LIMIT 1]; system.debug('*** ListContClient = ' + ListContClient.size() + ' | ' + ListContClient);
        //Check if there is exsiting contact found
        if(ListContClient.Size()>0){
            lc.setContactId(ListContClient[0].Id); //Contact found --> set lead conversion to use existing contact
            if(AccountNotExist=TRUE){// if isaccount not exist == true
            	lc.setAccountId(ListContClient[0].AccountId);
            }
        } else {
            ContactNotExist=TRUE;
        }
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        Id accId = lcr.getAccountId();
        Id contId = lcr.getContactId();
        
        if(AccountNotExist==TRUE && ContactNotExist==FALSE){
            Account acc = New Account();
            acc.Name = leadObj.Company;
            acc.Account_Type__c = leadObj.Account_Type__c;
            acc.Alamat_Usaha__c = leadObj.Alamat_Usaha__c;
            acc.Brand_Name__c = leadObj.Advertiser_Brand__c;
            acc.Category__c = leadObj.CategoryOLD__c;
            acc.Chatter_Email__c = leadObj.Chatter_Email__c;
            acc.Chatter_Name__c = leadObj.Chatter_Name__c;
            acc.Content__c = leadObj.Content__c;
            acc.Content_Sections__c = leadObj.Content_Sections__c;
            acc.Direct_Indirect__c = leadObj.Direct_Indirect__c;
            acc.Email__c = leadObj.Email_Temporary__c;
            acc.Converted_from_Lead__c = leadObj.IsLead__c;
            acc.Jabatan_Penjabat__c = leadObj.Jabatan_Penjabat__c;
            acc.Kategori_Bisnis__c = leadObj.Kategori_Bisnis__c;
            acc.Legal_Name__c = leadObj.Legal_Name__c;
            acc.Nama_Bank__c = leadObj.Nama_Bank__c;
            acc.Nama_Pemilik__c = leadObj.Nama_Pemilik__c;
            acc.Nama_Penjabat__c = leadObj.Nama_Penjabat__c;
            acc.Nomor_Induk_Berusaha__c = leadObj.Nomor_Induk_Berusaha__c;
            acc.Nomor_Rekening__c = leadObj.Nomor_Rekening__c;
            acc.Nomor_Verifikasi_Dewan_Pers__c = leadObj.Nomor_Verifikasi_Dewan_Pers__c;
            acc.NPWP__c = leadObj.NPWP__c;
            acc.PIC_Telkomsel__c = leadObj.PIC_Telkomsel__c;
            acc.Privacy_Policy__c = leadObj.Privacy_Policy__c;
            acc.Site_Domain__c = leadObj.Site_Domain__c;
            acc.Tipe_Display_Ads__c = leadObj.Tipe_Display_Ads__c;
            acc.Tipe_Platform__c = leadObj.Tipe_Platform__c;
            acc.Tipe_Video_Ads__c = leadObj.Tipe_Video_Ads__c;
            acc.Total_Ad_Request_Bulan__c = leadObj.Total_Ad_Request_Bulan__c;
            acc.Header_Bidding__c = leadObj.Header_Bidding__c;
            acc.Bundle_ID__c = leadObj.Bundle_ID__c;
            insert acc;
            accId = acc.Id;
            
            AccountContactRelation acr = New AccountContactRelation();
            acr.AccountId = accId;
            acr.ContactId = contId;
            acr.IsActive = True;
            insert acr;
        }
        /*if(Account not exist == true){
            create accountbaru
			insert accountbaru;
			accId=account.id
        }*/
        
        system.debug('*** accId = ' + accId);
        system.debug('*** contId = ' + contId); 
		
        if(ListAcc.size()>0){
            List<String> platformList;
            List<String> displayAdsList;
            List<String> videoAdsList;

            platformList = (leadObj.Tipe_Platform__c != null && leadObj.Tipe_Platform__c != '') ? leadObj.Tipe_Platform__c.split(';') : new List<String>();
            displayAdsList = (leadObj.Tipe_Display_Ads__c != null && leadObj.Tipe_Display_Ads__c != '') ? leadObj.Tipe_Display_Ads__c.split(';') : new List<String>();
            videoAdsList = (leadObj.Tipe_Video_Ads__c != null && leadObj.Tipe_Video_Ads__c != '') ? leadObj.Tipe_Video_Ads__c.split(';') : new List<String>();
           
            List<Domains__c> domainList = new List<Domains__c>();
           
           
                List<String> newDisplayAdsList = new List<String>();
                List<String> newPlatformList = new List<String>();
                List<String> newVideoAdsList = new List<String>();

                for(String platform : platformList){
                    if(platform.contains('Web') || platform.contains('Mobile')){
                        newPlatformList.add(platform);
                    }
                }
                if(newPlatformList.contains('Web') || newPlatformList.contains('Mobile')){
                    for(String displayAds : displayAdsList){
                        if(displayAds.contains('Desktop') && platformList.contains('Web')){
                            newDisplayAdsList.add(displayAds);
                        }else if(displayAds.contains('Mobile') && platformList.contains('Mobile')){
                            newDisplayAdsList.add(displayAds);
                        }
                    }
                    for (String webVideoAds : videoAdsList) {
                        if(!webVideoAds.contains('IOS') && !webVideoAds.contains('Android')) {
                            System.debug('webVideoAds ==> '+ webVideoAds);
                            newVideoAdsList.add(webVideoAds);
                        }
                    }
                    Domains__c domain = new Domains__c();
                    domain.Domain_Name__c = leadObj.Site_Domain__c;
                    domain.Account__c = ListAcc[0].id; //tandain
                    domain.Status__c = 'Draft';
                    domain.Tipe_Platform__c = String.join(newPlatformList, ';');
                    domain.Total_Ad_Request_Bulan__c = leadObj.Total_Ad_Request_Bulan__c;
                    domain.Tipe_Display_Ads__c = String.join(newDisplayAdsList, ';');
                    domain.Tipe_Video_Ads__c = String.join(newVideoAdsList, ';');
                    domain.Content__c = leadObj.Content__c;
                    domain.Content_Sections__c = leadObj.Content_Sections__c;
                    domain.Privacy_Policy__c = leadObj.Privacy_Policy__c;
                    domain.Nomor_verifikasi_Dewan_Pers__c = leadObj.Nomor_Verifikasi_Dewan_Pers__c;
                    domain.Header_Bidding__c = leadObj.Header_Bidding__c;
                    //domain.Bundle_ID__c = leadObj.Bundle_ID__c;
                    domainList.add(domain);
                }
                
            
            if(platformList.contains('Application')){
                List<String> appDisplayAdsList = new List<String>();
                List<String> appVideoAdsList = new List<String>();
                for(String displayAds : displayAdsList){
                    if(displayAds.contains('IOS') || displayAds.contains('Android')){
                        appDisplayAdsList.add(displayAds);
                    }
                }
                for (String videoAds : videoAdsList) {
                    for (String platform : platformList) {
                        if((platform == 'Application') && (videoAds.contains('IOS') || videoAds.contains('Android'))) {
                            appVideoAdsList.add(videoAds);
                        }
                    }
                }
                Domains__c bundle = new Domains__c();
                bundle.Domain_Name__c = leadObj.Site_Domain__c;
                bundle.Account__c = ListAcc[0].id; //tandain
                bundle.Status__c = 'Draft';
                bundle.Tipe_Platform__c = 'Application';
                bundle.Total_Ad_Request_Bulan__c = leadObj.Total_Ad_Request_Bulan__c;
                bundle.Tipe_Display_Ads__c = String.join(appDisplayAdsList, ';');
                bundle.Tipe_Video_Ads__c =  String.join(appVideoAdsList, ';');
                bundle.Content__c = leadObj.Content__c;
                bundle.Content_Sections__c = leadObj.Content_Sections__c;
                bundle.Privacy_Policy__c = leadObj.Privacy_Policy__c;
                bundle.Nomor_verifikasi_Dewan_Pers__c = leadObj.Nomor_Verifikasi_Dewan_Pers__c;
                bundle.Header_Bidding__c = leadObj.Header_Bidding__c;
                bundle.Bundle_ID__c = leadObj.Bundle_ID__c;
                domainList.add(bundle);
            }
            insert domainList;
        }
        
        List<Contact> listContConverted = [SELECT Id, Name, Email FROM Contact WHERE Id =:contId ];
        List<Account> listAccConverted = [SELECT Id, Name FROM Account WHERE Id =:accId ];
        
        List <PIC_Client__c> ListClient = [SELECT Id, Name, Publisher__c, PIC_Client__c FROM PIC_Client__c WHERE PIC_Client_Email__c =: listContConverted[0].Email AND Publisher_Name__c =: listAccConverted[0].Name LIMIT 1];
        if(ListClient.size()==0){
			PIC_Client__c cl = new PIC_Client__c();
            cl.Publisher__c = accId;
            cl.PIC_Client__c = contId;
            Insert cl;
        }
        
        Id Cid_PIC_Marketing = null;
        if(leadObj.PIC_Marketing__c != null){
            if(leadObj.PIC_Marketing_Email__c != leadObj.Email){
                
                List<Contact> ListContMarketing = [SELECT Id, Name, Email FROM Contact WHERE Email =: leadObj.PIC_Marketing_Email__c LIMIT 1];
                
                if(ListContMarketing.Size()==0){
                    Contact ct = new Contact();
                	ct.LastName = leadObj.PIC_Marketing__c;
                	ct.Phone = leadObj.PIC_Marketing_Mobile__c;
                	ct.Email = leadObj.PIC_Marketing_Email__c;
                    ct.Title = leadObj.Title_PIC_Marketing__c;                  
                    ct.Alamat__c = leadObj.Alamat_PIC_Marketing__c;
                	ct.AccountId = accId;
                	insert ct;
                	Cid_PIC_Marketing = ct.Id;
               	} else {
                	Cid_PIC_Marketing = ListContMarketing[0].Id;
            	}
                
            }else{
                Cid_PIC_Marketing = listContConverted[0].Id;
            }
            
            List <PIC_Marketing__c> ListMarketing = [SELECT Id, Name, PIC_Marketing__c, Publisher__c FROM PIC_Marketing__c WHERE PIC_Marketing__c =: leadObj.PIC_Marketing_Email__c AND Publisher_Name__c =: listAccConverted[0].Name LIMIT 1];
            if(ListMarketing.Size()==0){
                PIC_Marketing__c pm = new PIC_Marketing__c();
                pm.Publisher__c = accId;
                pm.PIC_Marketing__c = Cid_PIC_Marketing;
                insert pm;
            }
        }
        
    }
}