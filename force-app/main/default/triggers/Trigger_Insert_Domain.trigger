/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 05-05-2023
 * @last modified by  : Diky Nurosid
**/
trigger Trigger_Insert_Domain on Domains__c (after insert) {
    
    if (label.Trigger_Insert_Domain_On == 'YES') {
        List<String> contentSectionList;
        List<String> platformList;
        List<String> displayAdsList;
        List<String> videoAdsList;
        for(Domains__c newDomain : trigger.new){
            
            contentSectionList = (newDomain.Content_Sections__c != null && newDomain.Content_Sections__c != '') ? newDomain.Content_Sections__c.split(';') : new List<String>();
            platformList = (newDomain.Tipe_Platform__c != null && newDomain.Tipe_Platform__c != '') ? newDomain.Tipe_Platform__c.split(';') : new List<String>();
            displayAdsList = (newDomain.Tipe_Display_Ads__c != null && newDomain.Tipe_Display_Ads__c != '') ? newDomain.Tipe_Display_Ads__c.split(';') : new List<String>();
            videoAdsList = (newDomain.Tipe_Video_Ads__c != null && newDomain.Tipe_Video_Ads__c != '') ? newDomain.Tipe_Video_Ads__c.split(';') : new List<String>();
            
            String domain_temp = (newDomain.Domain_Name__c != null && newDomain.Domain_Name__c != '') ? newDomain.Domain_Name__c.replace('www.', '').capitalize() : '';
            String bundleId = (newDomain.Bundle_Id__c != null && newDomain.Bundle_Id__c != '') ? newDomain.Bundle_Id__c : '';
            String company_temp = (newDomain.Account_Name__c != null && newDomain.Account_Name__c != '') ? newDomain.Account_Name__c.remove('.').replace(' ', '_') : '';
            
            List<String> adTagNameList_temp = new List<String>();
            Map<String, String> map_adTagName_adType = new Map<String, String>();
            Map<String, String> map_adTagName_size = new Map<String, String>();
            String adTagName_temp = '';
            
            for(String displayAds : displayAdsList){
                String size = displayAds.substringAfterLast(' ');
                if(displayAds.contains('Desktop') && platformList.contains('Web')){
                    adTagName_temp = domain_temp + '_Desktop_' +  size;
                }else if(displayAds.contains('Mobile') && platformList.contains('Mobile')){
                    adTagName_temp = domain_temp + '_Mobile_' +  size;
                }else if(displayAds.contains('IOS') && platformList.contains('Application')){
                    adTagName_temp = bundleId + '_IOS_' +  size;
                }else if(displayAds.contains('Android') && platformList.contains('Application')){
                    adTagName_temp = bundleId + '_ANDROID_' +  size;
                }
                if(adTagName_temp != ''){
                    if(newDomain.OptionField__c != null && newDomain.OptionField__c != ''){
                        adTagName_temp += '_' + newDomain.OptionField__c.trim();
                    }
                    adTagNameList_temp.add(adTagName_temp);
                    
                }
            }
             system.debug('*** adTagNameList_temp D = '  + adTagNameList_temp.size() + ' | ' + adTagNameList_temp);
            system.debug('*** map_adTagName_adType D = '  + map_adTagName_adType.size() + ' | ' + map_adTagName_adType);
            system.debug('*** map_adTagName_size D = '  + map_adTagName_size.size() + ' | ' + map_adTagName_size);
            
            // Looping Video Ads List
            for (String videoAds : videoAdsList) {
                System.debug(videoAds);
                List<String> tipeVideoAds_split = videoAds.split(' ');
                String firstTag = domain_temp;
                String secondTag = tipeVideoAds_split[1].capitalize();
                String thirdTag = tipeVideoAds_split[3];
                String platformResult;
                for (String platform : platformList) {
                    
                    if(platform == 'Application' && (videoAds.contains('IOS') || videoAds.contains('Android'))){
                        
                        firstTag = bundleID;
                        platformResult = tipeVideoAds_split[0].toUpperCase();
                        secondTag = tipeVideoAds_split[2].capitalize();
                        thirdTag = tipeVideoAds_split[4];
                        System.debug(platformResult +' ==> '+ videoAds);
                        
                    }else if((platform == 'Web' || platform == 'Mobile') && (!videoAds.contains('IOS') && !videoAds.contains('Android'))) {
                        if (platform == 'Web') {
                            platformResult = 'Desktop';
                            System.debug(platformResult +' ==> '+ videoAds);
                        } else if (platform == 'Mobile') {
                           
                            platformResult = 'Mobile';
                            System.debug(platformResult +' ==> '+ videoAds);
                        }
                    }
                    
                    if(platformResult != null && thirdTag != '' && thirdTag != null){
                        adTagName_temp = firstTag + '_' + secondTag + '_' + thirdTag + '_' + platformResult + '_0x0_5-30s';
                    }

                    if(newDomain.OptionField__c != null && newDomain.OptionField__c != ''){
                        adTagName_temp = adTagName_temp + '_' + newDomain.OptionField__c.trim();
                    }
                    adTagNameList_temp.add(adTagName_temp);
                    map_adTagName_adType.put(adTagName_temp, 'Video');
                    map_adTagName_size.put(adTagName_temp, 'Video');
                }
            }
            system.debug('*** adTagNameList_temp V = '  + adTagNameList_temp.size() + ' | ' + adTagNameList_temp);
            system.debug('*** map_adTagName_adType V = '  + map_adTagName_adType.size() + ' | ' + map_adTagName_adType);
            system.debug('*** map_adTagName_size V = '  + map_adTagName_size.size() + ' | ' + map_adTagName_size);
            
            // Generate site name & create map_siteName_adTagNameList  
            Map<String,List<String>> map_siteName_adTagNameList = new Map<String,List<String>>();
            Map<String,String> map_siteName_platform = new Map<String,String>();
            if(contentSectionList.size()>0){
                for(String contentSection : contentSectionList){
                    system.debug('*** contentSection = ' + contentSection);
                    String formattedContentSection = contentSection.replaceAll('[&,\\s]+', '-').replaceAll('’', '');
                    system.debug('*** contentSection = ' + formattedContentSection);

                    for(String adTagName : adTagNameList_temp){
                        system.debug('*** adTagName = ' + adTagName);
                        String siteName_temp;  
                        String adTagNameFormated;
                        String platform = '';
                        String stream = '';
                        String adTagNameLast;
                        String adTagName_check = adTagName.substringAfter(domain_temp+'_'); 
                        String adTagNameApplication_check = adTagName.substringAfter(bundleID+'_'); 
                     
                        if(adTagName_check.contains('Desktop'))
                        {
                            platform = 'Web';
                            adTagNameLast = adTagName.substringAfter(domain_temp+'_');
                            adTagNameFormated = domain_temp +'_'+ formattedContentSection+'_'+adTagNameLast;
                        }
                        else if(adTagName_check.contains('Mobile'))
                        {
                            platform = 'MobileWeb';
                            adTagNameLast = adTagName.substringAfter(domain_temp+'_');
                            adTagNameFormated = domain_temp +'_'+ formattedContentSection+'_'+adTagNameLast;
                        }
                        if(adTagNameApplication_check.contains('IOS'))
                        {
                            platform = 'MOBILE_APP_IOS';
                            adTagNameLast = adTagName.substringAfter(bundleID+'_');
                            adTagNameFormated = bundleID +'_'+ formattedContentSection+'_'+adTagNameLast;
                        }
                        else if(adTagNameApplication_check.contains('ANDROID'))
                        {
                            platform = 'MOBILE_APP_ANDROID';
                            adTagNameLast = adTagName.substringAfter(bundleID+'_');
                            adTagNameFormated = bundleID +'_'+ formattedContentSection+'_'+adTagNameLast;
                        }
                        
                        if(adTagName_check.contains('Outstream') || adTagNameApplication_check.contains('Outstream'))
                        {stream = '|Outstream';}
                        if(platform.contains('IOS') || platform.contains('ANDROID')){
                            siteName_temp = 'TADEX|' + platform + '|' + company_temp + '|' + bundleID + '|' + formattedContentSection + stream;
                        }else{
                            if(platform != ''){
                            siteName_temp = 'TADEX|' + platform + '|' + company_temp + '|' + domain_temp + '|' + formattedContentSection + stream;
                            }
                        }
                        // String siteName_temp = 'TADEX|' + platform + '|' + company_temp + '|' + domain_temp + stream;
                        
                        if(newDomain.OptionField__c != null && newDomain.OptionField__c != ''){
                            siteName_temp = siteName_temp + '|' + newDomain.OptionField__c.trim();
                        }
                        String sizeAdtag = adTagNameFormated.substringAfterLast('_');
                        system.debug('*** siteName_temp = ' + siteName_temp);
                        map_adTagName_adType.put(adTagNameFormated,'Display');
                        if(adTagNameFormated.contains('0x0_5-30s')){
                            map_adTagName_size.put(adTagNameFormated,'video');
                        }else{
                            map_adTagName_size.put(adTagNameFormated,sizeAdtag);
                        }
                        
                        List<String> atnList = new List<String>();
                        if(map_siteName_adTagNameList.containsKey(siteName_temp)){
                            atnList = map_siteName_adTagNameList.get(siteName_temp);
                            atnList.add(adTagNameFormated);
                            map_siteName_adTagNameList.remove(siteName_temp);
                            map_siteName_adTagNameList.put(siteName_temp,atnList);
                        }else{
                            atnList.add(adTagNameFormated);
                            map_siteName_adTagNameList.put(siteName_temp,atnList);
                            map_siteName_platform.put(siteName_temp,platform);
                        }
                    }
                }
            }else{
                for(String adTagName : adTagNameList_temp){
                    system.debug('*** adTagName = ' + adTagName);
                    String siteName_temp;  
                    String adTagNameFormated;
                    String platform = '';
                    String stream = '';
                    String adTagNameLast;
                    String adTagName_check = adTagName.substringAfter(domain_temp+'_'); 
                    String adTagNameApplication_check = adTagName.substringAfter(bundleID+'_'); 
                 
                    if(adTagName_check.contains('Desktop'))
                    {
                        platform = 'Web';
                        adTagNameLast = adTagName.substringAfter(domain_temp+'_');
                        adTagNameFormated = domain_temp +'_'+adTagNameLast;
                    }
                    else if(adTagName_check.contains('Mobile'))
                    {
                        platform = 'MobileWeb';
                        adTagNameLast = adTagName.substringAfter(domain_temp+'_');
                        adTagNameFormated = domain_temp +'_'+adTagNameLast;
                    }
                    if(adTagNameApplication_check.contains('IOS'))
                    {
                        platform = 'MOBILE_APP_IOS';
                        adTagNameLast = adTagName.substringAfter(bundleID+'_');
                        adTagNameFormated = bundleID +'_'+adTagNameLast;
                    }
                    else if(adTagNameApplication_check.contains('ANDROID'))
                    {
                        platform = 'MOBILE_APP_ANDROID';
                        adTagNameLast = adTagName.substringAfter(bundleID+'_');
                        adTagNameFormated = bundleID +'_'+adTagNameLast;
                    }
                    
                    if(adTagName_check.contains('Outstream') || adTagNameApplication_check.contains('Outstream'))
                    {stream = '|Outstream';}
                    if(platform.contains('IOS') || platform.contains('ANDROID')){
                        siteName_temp = 'TADEX|' + platform + '|' + company_temp + '|' + bundleID +stream;
                    }else{
                        if(platform != ''){
                        siteName_temp = 'TADEX|' + platform + '|' + company_temp + '|' + domain_temp +stream;
                        }
                    }
                    // String siteName_temp = 'TADEX|' + platform + '|' + company_temp + '|' + domain_temp + stream;
                    
                    if(newDomain.OptionField__c != null && newDomain.OptionField__c != ''){
                        siteName_temp = siteName_temp + '|' + newDomain.OptionField__c.trim();
                    }
                    String sizeAdtag = adTagNameFormated.substringAfterLast('_');
                    system.debug('*** siteName_temp = ' + siteName_temp);
                    map_adTagName_adType.put(adTagNameFormated,'Display');
                    if(adTagNameFormated.contains('0x0_5-30s')){
                        map_adTagName_size.put(adTagNameFormated,'video');
                    }else{
                        map_adTagName_size.put(adTagNameFormated,sizeAdtag);
                    }
                    
                    List<String> atnList = new List<String>();
                    if(map_siteName_adTagNameList.containsKey(siteName_temp)){
                        atnList = map_siteName_adTagNameList.get(siteName_temp);
                        atnList.add(adTagNameFormated);
                        map_siteName_adTagNameList.remove(siteName_temp);
                        map_siteName_adTagNameList.put(siteName_temp,atnList);
                    }else{
                        atnList.add(adTagNameFormated);
                        map_siteName_adTagNameList.put(siteName_temp,atnList);
                        map_siteName_platform.put(siteName_temp,platform);
                    }
                }
            }
            system.debug('*** map_siteName_adTagNameList = '  + map_siteName_adTagNameList.size() + ' | ' + map_siteName_adTagNameList);
            system.debug('*** map_siteName_platform = '  + map_siteName_platform.size() + ' | ' + map_siteName_platform);
            
            // Looping Keyset dari map_siteName_platform, insert site & create map_siteName_siteId
            List<Sites__c> siteRec_list = new List<Sites__c>();
            for(String siteName : map_siteName_platform.keySet()){
           
                String platform = map_siteName_platform.get(siteName);
                String applicationType = '';
                Sites__c site_rec = new Sites__c();
                site_rec.siteUrl__c = siteName;
                site_rec.Domain__c = newDomain.Id;
                site_rec.Status__c = 'New';
                
                if(platform == 'MobileWeb'){
                    platform = 'Mobile';
                }else if(platform == 'MOBILE_APP_IOS' || platform == 'MOBILE_APP_ANDROID') {
                    applicationType = platform.contains('IOS') ? 'IOS' : 'ANDROID';
                    platform = 'Application';
                }
                site_rec.Platform__c = platform;
                site_rec.Application_Type__c = applicationType;
               
                siteRec_list.add(site_rec);
            } system.debug('*** siteRec_list = ' + siteRec_list.size() + ' | ' + siteRec_list);
            insert siteRec_list;
            system.debug('*** siteRec_list after insert = ' + siteRec_list.size() + ' | ' + siteRec_list);
            
            Map<String,String> map_siteName_siteId = new Map<String,String>();
            for(Sites__c siteRec : siteRec_list){
                system.debug('*** siteRec.siteUrl__c = ' + siteRec.siteUrl__c);
                system.debug('*** siteRec.Id = ' + siteRec.Id);
                map_siteName_siteId.put(siteRec.siteUrl__c,siteRec.Id);
            }
            system.debug('*** map_siteName_siteId = ' + map_siteName_siteId.size() + ' | ' + map_siteName_siteId);
            
            // Looping map_siteName_siteId & insert Ad Tag
            List<Ad_Tag__c> adTagRec_list = new List<Ad_Tag__c>();
            for(String siteName : map_siteName_siteId.keySet()){
                List<String> addTagNameList = map_siteName_adTagNameList.get(siteName);
                system.debug('*** siteName = ' + siteName);
                system.debug('*** addTagNameList = ' + addTagNameList.size() + ' | ' + addTagNameList);
                for(String addTagName : addTagNameList){
                    Ad_Tag__c adTag_rec = new Ad_Tag__c();
                    adTag_rec.adTag_Name__c = addTagName;
                    adTag_rec.Ad_Type__c = map_adTagName_adType.get(addTagName);
                    adTag_rec.Ad_Size__c = map_adTagName_size.get(addTagName);
                    adTag_rec.Sites__c = map_siteName_siteId.get(siteName);
                    adTagRec_list.add(adTag_rec);
                }
            } system.debug('*** adTagRec_list = ' + adTagRec_list.size() + ' | ' + adTagRec_list);
            insert adTagRec_list;
            system.debug('*** adTagRec_list after insert = ' + adTagRec_list.size() + ' | ' + adTagRec_list);
        }
    }
    
}