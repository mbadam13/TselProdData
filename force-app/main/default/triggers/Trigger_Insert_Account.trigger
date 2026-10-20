/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 05-11-2023
 * @last modified by  : Diky Nurosid
**/
trigger Trigger_Insert_Account on Account (after insert) {
    
if (label.Trigger_Insert_Account_On == 'YES') {
    
    for(Account newAcc : trigger.new){
       
        if(newAcc.Account_Type__c == 'Publisher'){
            List<String> platformList;
            List<String> displayAdsList;
            List<String> videoAdsList;
            List<Domains__c> domainList = new List<Domains__c>();

            platformList = (newAcc.Tipe_Platform__c != null && newAcc.Tipe_Platform__c != '') ? newAcc.Tipe_Platform__c.split(';') : new List<String>();
            displayAdsList = (newAcc.Tipe_Display_Ads__c != null && newAcc.Tipe_Display_Ads__c != '') ? newAcc.Tipe_Display_Ads__c.split(';') : new List<String>();
            videoAdsList = (newAcc.Tipe_Video_Ads__c != null && newAcc.Tipe_Video_Ads__c != '') ? newAcc.Tipe_Video_Ads__c.split(';') : new List<String>();
           
          
            List<String> newDisplayAdsList = new List<String>();
            List<String> newPlatformList = new List<String>();
            List<String> newVideoAdsList = new List<String>();
            //  String newPlatform = '';
            for(String platform : platformList){
                if(platform.contains('Web') || platform.contains('Mobile')){
                    newPlatformList.add(platform);
                }
            }
           

            if(platformList.contains('Web') || platformList.contains('Mobile')){
                
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
                domain.Domain_Name__c = newAcc.Site_Domain__c;
                domain.Bundle_ID__c = null;
                domain.Account__c = newAcc.Id;
                domain.Status__c = 'Draft';
                domain.Tipe_Platform__c = String.join(newPlatformList, ';');
                domain.Total_Ad_Request_Bulan__c = newAcc.Total_Ad_Request_Bulan__c;
                domain.Tipe_Display_Ads__c = String.join(newDisplayAdsList, ';');
                domain.Tipe_Video_Ads__c = String.join(newVideoAdsList, ';');
                domain.Content__c = newAcc.Content__c;
                domain.Content_Sections__c = newAcc.Content_Sections__c;
                domain.Privacy_Policy__c = newAcc.Privacy_Policy__c;
                domain.Nomor_verifikasi_Dewan_Pers__c = newAcc.Nomor_Verifikasi_Dewan_Pers__c;
                domain.Header_Bidding__c = newAcc.Header_Bidding__c;
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
                bundle.Domain_Name__c = newAcc.Site_Domain__c;
                bundle.Bundle_ID__c = newAcc.Bundle_ID__c;
                bundle.Account__c = newAcc.Id;
                bundle.Status__c = 'Draft';
                bundle.Tipe_Platform__c = 'Application';
                bundle.Total_Ad_Request_Bulan__c = newAcc.Total_Ad_Request_Bulan__c;
                bundle.Tipe_Display_Ads__c = String.join(appDisplayAdsList, ';');
                bundle.Tipe_Video_Ads__c = String.join(appVideoAdsList, ';');
                bundle.Content__c = newAcc.Content__c;
                bundle.Content_Sections__c = newAcc.Content_Sections__c;
                bundle.Privacy_Policy__c = newAcc.Privacy_Policy__c;
                bundle.Nomor_verifikasi_Dewan_Pers__c = newAcc.Nomor_Verifikasi_Dewan_Pers__c;
                bundle.Header_Bidding__c = newAcc.Header_Bidding__c;
                domainList.add(bundle);
            }
            insert domainList;
            
        }
    }
    
}

}