/**
 * @description       : 
 * @author            : Diky Nurosid
 * @group             : 
 * @last modified on  : 02-24-2023
 * @last modified by  : Diky Nurosid
**/
trigger Trigger_Update_Domain on Domains__c (before update, after update) {

if (label.Trigger_Update_Domain_On == 'YES') {

    for(Domains__c domainRec : Trigger.new){
         
        Domains__c oldDomainRec = Trigger.oldMap.get(domainRec.Id);
        
        if(trigger.isBefore){
            if(domainRec.Account__c != oldDomainRec.Account__c){
                domainRec.addError('Account cannot be updated.');
            }
        }
        
        if(trigger.isAfter){
        
            // Plan if update flag then send chatter post & file txt to Chatter Group --> flag ==> Status Approved
            if(domainRec.Status__c == 'Active' && domainRec.Status__c != oldDomainRec.Status__c){
                
                List<Contract> contractList = [SELECT Id, Name FROM Contract WHERE AccountId =: domainRec.Account__c AND Status = 'Activated'];
                system.debug('*** contractList = ' + contractList.size() + ' | ' + contractList);
                
                if(contractList.size() == 0){
                    String contractBypassApproval = [SELECT Contract_Bypass_Approval__c FROM Account WHERE Id =: domainRec.Account__c].Contract_Bypass_Approval__c;                
                    if(contractBypassApproval != 'Approved'){
                        domainRec.addError('Domain can\'t be active if Publisher doesn\t have active contract or bypass approval...');
                    }
                }
                
                List<Ad_Tag__c> adTagList = new List<Ad_Tag__c>();
                List<Ad_Tag__c> adTagWithSiteNotApprovedList = new List<Ad_Tag__c>();
                
                List<Ad_Tag__c> allAdTagList = [SELECT Id, Name, Ad_Tag_ID__c, Ad_Tag_Script__c, adTag_Name__c, Ad_Type__c, Platform__c, Sites__r.Status__c,Sites__r.Application_Type__c FROM Ad_Tag__c 
                                                WHERE Sites__r.Domain__c =: domainRec.Id];
                system.debug('*** allAdTagList = ' + allAdTagList.size() + ' | ' + allAdTagList);
                
                for(Ad_Tag__c adTag_rec : allAdTagList){
                    if(adTag_rec.Sites__r.Status__c != 'Approved')
                        {adTagWithSiteNotApprovedList.add(adTag_rec);}
                    else
                        {adTagList.add(adTag_rec);}
                }
                
                if(adTagWithSiteNotApprovedList.size() > 0) {
                    domainRec.addError('There is at least 1 Site record with Status not "Approved" for this Domain.');
                } else{
                
                    if(adTagList.size() > 0){
                    
                        String bodyText = '';
                        
                        for(Ad_Tag__c adTagRec : adTagList){
                                
                            String str_AdTagScript = adTagRec.Ad_Tag_Script__c;
                            if(str_AdTagScript != '' && str_AdTagScript != null){
                                String str_AdTagScript_end = '\n</script>' + str_AdTagScript.substringAfter('</script>');
                                str_AdTagScript = str_AdTagScript.substringBefore('var kadschain');
                                String replacementScript = '';
                                if(adTagRec.Ad_Type__c == 'Display'){
                                    if(adTagRec.Platform__c == 'Web'){
                                        replacementScript = system.label.Tadex_AdTagScript_Replacement_DisplayWeb.unescapeEcmaScript();
                                    }else if(adTagRec.Platform__c == 'Mobile'){
                                        replacementScript = system.label.Tadex_AdTagScript_Replacement_DisplayMobile.unescapeEcmaScript();
                                    }else if(adTagRec.Platform__c == 'Application'){
                                        if(adTagRec.Sites__r.Application_Type__c == 'IOS'){
                                            replacementScript = system.label.Tadex_AdTagScript_Replacement_DisplayMOBILE_APP_IOS.unescapeEcmaScript();
                                        }else if(adTagRec.Sites__r.Application_Type__c == 'ANDROID'){
                                            replacementScript = system.label.Tadex_AdTagScript_Replacement_DisplayMOBILE_APP_ANDROID.unescapeEcmaScript();
                                        }
                                    }
                                }
                                
                                str_AdTagScript = str_AdTagScript + replacementScript + str_AdTagScript_end;
                                system.debug('*** str_AdTagScript final = ' + str_AdTagScript);
                                
                                String separator = '';
                                if(bodyText != ''){
                                    separator = '----------------------------------------------------------------------------------------------------------------\n\n';
                                }
                                bodyText = bodyText + separator + adTagRec.adTag_Name__c + '\n\n' + str_AdTagScript + '\n\n';
                            }
                            
                        }
                        
                        ContentVersion cv = new ContentVersion();
                        String fiBody;
                        if(domainRec.Bundle_Id__c != null && domainRec.Domain_Name__c == null){
                            fiBody = 'Ad Tag Script for Bundle ID ' + domainRec.Bundle_Id__c + '. Please find the attachment below.';
                            cv.Title = 'Ad Tag Script for Bundle ID ' + domainRec.Bundle_Id__c;
                            cv.PathOnClient = 'AdTagScriptForBundleID_' + domainRec.Bundle_Id__c +'.txt';
                            cv.VersionData = Blob.valueOf(String.valueOf(bodyText));
                            cv.Description = 'AdTagScript for Bundle ID' + domainRec.Bundle_Id__c + ' File';
                        }else if(domainRec.Bundle_Id__c == null && domainRec.Domain_Name__c != null){
                            fiBody = 'Ad Tag Script for Domain ' + domainRec.Domain_Name__c + '. Please find the attachment below.';
                            cv.Title = 'Ad Tag Script for Domain ' + domainRec.Domain_Name__c;
                            cv.PathOnClient = 'AdTagScriptForDomain_' + domainRec.Domain_Name__c +'.txt';
                            cv.VersionData = Blob.valueOf(String.valueOf(bodyText));
                            cv.Description = 'AdTagScript for Domain' + domainRec.Domain_Name__c + ' File';
                        }else if(domainRec.Bundle_Id__c != null && domainRec.Domain_Name__c != null){
                            fiBody = 'Ad Tag Script for Domain ' + domainRec.Domain_Name__c + ' & Bundle ID' + domainRec.Bundle_Id__c +' . Please find the attachment below.';
                            cv.Title = 'Ad Tag Script for Domain '+domainRec.Domain_Name__c+' & Bundle ID' + domainRec.Bundle_Id__c;
                            cv.PathOnClient = 'AdTagScriptForDomain_' + domainRec.Domain_Name__c +'_BundleID_' + domainRec.Bundle_Id__c + '.txt';
                            cv.VersionData = Blob.valueOf(String.valueOf(bodyText));
                            cv.Description = 'AdTagScript for Domain '+domainRec.Domain_Name__c+' & Bundle ID' + domainRec.Bundle_Id__c + ' File';
                        }
                       
                        insert cv;                                                
                        
                        FeedItem fi = new FeedItem();
                        fi.Body = fiBody;
                        fi.ParentId = domainRec.Chatter_Group_Id__c; 
                        insert fi;
                        
                        FeedAttachment fa = new FeedAttachment();
                        fa.FeedEntityId = fi.Id;
                        fa.RecordId = cv.Id;
                        fa.Type = 'CONTENT'; 
                        insert fa;
                        
                        String bodyText2 = 'pubmatic.com, 157566 , DIRECT, 5d62403b186f2ace';
                        
                        ContentVersion cv2 = new ContentVersion();
                        cv2.Title ='Tadex_ads';
                        cv2.PathOnClient = 'Tadex_ads_' + '.txt';
                        cv2.VersionData = Blob.valueOf(String.valueOf(bodyText2));
                        cv2.Description = 'Tadex_ads' + ' File';
                        insert cv2;
                        
                        FeedAttachment fa2 = new FeedAttachment();
                        fa2.FeedEntityId = fi.Id;
                        fa2.RecordId = cv2.Id;
                        fa2.Type = 'CONTENT';
                        insert fa2;
                        
                    }
                    
                }
                
            }  
        }
    }

}

}