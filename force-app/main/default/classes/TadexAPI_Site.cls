global class TadexAPI_Site {
    
    @future (callout=true)
    public static void createSite(Id siteId){
        
        system.debug(' Masuk TadexAPI_Site.createSite !!! ');
        
        Sites__c siteRec = [SELECT Id, Name, domainName__c, siteUrl__c, monthlyImpressions__c, platformId__c, Site_ID__c, privacyPolicyUrl__c FROM Sites__c WHERE Id =: siteId];
        
        Log_API__c log = new Log_API__c();
        
        try{
            
            String param_privacyPolicyUrl = '';
            if(siteRec.privacyPolicyUrl__c != null)
                {param_privacyPolicyUrl = siteRec.privacyPolicyUrl__c;}
            
            String str_domainName = '';
            if(system.label.Tadex_Hit_Site_Testing == 'YES'){
                str_domainName = system.label.Tadex_Domain_For_Testing;
            }else{
                str_domainName = siteRec.domainName__c;
            }
            system.debug('*** str_domainName = ' + str_domainName);
            
            String reqBody = '{"publisherId":'+system.label.Tadex_Publisher_Id+',"siteDomain":{"domainName":"'+system.label.Domain_Protocol+str_domainName+'/" },"siteUrl":"'+siteRec.siteUrl__c+'","privacyPolicyUrl":"'+param_privacyPolicyUrl+'","monthlyImpressions":"'+siteRec.monthlyImpressions__c+'","iabPrimaryVerticalList":[{"iabId":"IAB12"}],"platformId":'+siteRec.platformId__c+',"publisherSiteSettings":{"apiSetting":false,"isCoppaCompliant":false,"forceSecureAd":1}}';
            system.debug('*** reqBody = ' + reqBody);
            String endPoint = system.label.Tadex_API_End_Point+'/publisherSites?entityId='+system.label.Tadex_Publisher_Id;
            system.debug('*** endPoint = ' + endPoint);
            
            HttpRequest myRequestResult = new HTTPRequest();
            myRequestResult.setMethod('POST');
            myRequestResult.setHeader('Content-Type', 'application/json');
            myRequestResult.setHeader('Authorization','Bearer '+system.label.Tadex_Access_Token);
            myRequestResult.setendpoint(endPoint);
            myRequestResult.setbody(reqBody);
            myRequestResult.settimeout(120000);
            
            log.Input_Parameter__c = reqBody;
            log.Input_Url__c = endPoint;
            
            Http http = new Http();
            Map<String, Object> paramMapAll = new Map<String, Object>();
            Integer site_id = null;
            
            // For Test Class -start
            HttpResponse res_sample = new HttpResponse();
            res_sample.setHeader('Content-Type', 'application/json');
            res_sample.setStatusCode(200);
            // For Test Class -end
            
            HTTPResponse responsResult = new HTTPResponse();
            if(Test.isRunningTest() == false){
                responsResult = http.send(myRequestResult);
            }else{
                res_sample.setBody('{"Id":12345,"siteId":2345}');
                responsResult = res_sample;
            }
            
            log.Status__c = responsResult.getStatus();
            log.Status_Code__c = responsResult.getStatusCode();
            
            String responseBody = responsResult.getbody(); system.debug('*** responseBody ori = ' + responseBody);
            log.Response__c = responseBody;
            if(log.Status_Code__c != 200){
                responseBody = responseBody.substringAfter('[');
                responseBody = responseBody.substringBeforeLast(']'); 
            } system.debug('*** responseBody = ' + responseBody);
            paramMapAll = (Map<String, Object>) JSON.deserializeUntyped(responseBody); system.debug('*** paramMapAll = ' + paramMapAll);
            
            site_id = (Integer)paramMapAll.get('siteId');
            system.debug('*** site_id = ' + site_id);
            
            if(site_id != null){
                siteRec.Site_ID__c = String.valueOf(site_id);
                update siteRec;
            }
        }
        catch(Exception e){
            if(log.Response__c != null && log.Response__c != ''){
                log.Response__c = log.Response__c + '\n---------------\n'+ e.getmessage();
            }else{
                log.Response__c = e.getmessage();
            }
        }
        
        log.Notes__c = 'Site__c | ' + siteRec.Name + ' | ' + siteRec.Id;
        insert log; 
        system.debug('*** log = ' + log);
        system.debug('*** log.Response__c = ' + log.Response__c);
    }
    
}