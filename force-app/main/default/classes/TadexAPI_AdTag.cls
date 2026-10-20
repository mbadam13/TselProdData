global class TadexAPI_AdTag {
    
    @future (callout=true)
    public static void createAdTag(Id adTagId){
        
        system.debug(' Masuk TadexAPI_AdTag.createAdTag !!! ');
        
        Ad_Tag__c adTagRec = [SELECT Id, Name, publisherSiteurl__c, adTag_Name__c, adCodeTypeId__c, adTypeId__c, foldPlacementId__c, 
                                     pagePlacementId__c, adSize__c, Ad_Tag_ID__c, 
                                     Ad_Tag_Script__c, Ad_Type__c  
                              FROM Ad_Tag__c WHERE Id =: adTagId];
                
        Log_API__c log = new Log_API__c();
        
        try{
            
            String reqBody = '';
            if(adTagRec.Ad_Type__c == 'Display'){
                reqBody = '{"publisherId":'+system.label.Tadex_Publisher_Id+',"publisherSiteurl":"'+adTagRec.publisherSiteurl__c+'","adTagName":"'+adTagRec.adTag_Name__c+'","adCodeTypeId":'+adTagRec.adCodeTypeId__c+',"adTypeId":'+adTagRec.adTypeId__c+',"foldPlacementId":'+adTagRec.foldPlacementId__c+',"pagePlacementId":'+adTagRec.pagePlacementId__c+',"adSize":{"id":'+adTagRec.adSize__c+'},"adTagPlacements":[{"adTagPlacementId":0,"ecpm":'+system.label.AdTag_param_ecpm+',"adScript":"'+label.Tadex_adScript_display+'","currency":'+system.label.AdTag_param_currency+'}]}';
            }else if(adTagRec.Ad_Type__c == 'Video'){
                reqBody = '{"publisherId":'+system.label.Tadex_Publisher_Id+',"publisherSiteurl":"'+adTagRec.publisherSiteurl__c+'","adTagName":"'+adTagRec.adTag_Name__c+'","adCodeTypeId":'+adTagRec.adCodeTypeId__c+',"adTypeId":'+adTagRec.adTypeId__c+',"foldPlacementId":'+adTagRec.foldPlacementId__c+',"pagePlacementId":'+adTagRec.pagePlacementId__c+',"adSize":{"id":'+adTagRec.adSize__c+'},"adTagPlacements":[{"adTagPlacementId":0,"ecpm":'+system.label.AdTag_param_ecpm+',"adScript":"'+label.Tadex_adScript_video+'","currency":'+system.label.AdTag_param_currency+'}]' +
                          ',"videoProperties":{"protocol":{"id":2},"minDuration":5,"maxDuration":300,"videoLinearity":0,"videoPosition":1,"vpaidVersion":0,"videoMimeTypes":[1,5,7],"placementId":1,"isSkippable":false}}';
            }
            system.debug('*** reqBody = ' + reqBody);
            
            String endPoint = system.label.Tadex_API_End_Point+'/publisherAdTag?entityId='+system.label.Tadex_Publisher_Id;
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
            Integer ad_tag_id = null;
            String ad_tag_script = ''; 
            
            // For Test Class -start
            HttpResponse res_sample = new HttpResponse();
            res_sample.setHeader('Content-Type', 'application/json');
            res_sample.setStatusCode(200);
            // For Test Class -end
            
            HTTPResponse responsResult = new HTTPResponse();
            if(Test.isRunningTest() == false){
                responsResult = http.send(myRequestResult);
            }else{
                res_sample.setBody('{"adTagId":1234567,"adTagScript":"abcde"}');
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
            
            ad_tag_id = (Integer)paramMapAll.get('adTagId');
            ad_tag_script = (String)paramMapAll.get('adTagScript');
            system.debug('*** ad_tag_id |  ad_tag_script = ' + ad_tag_id + ' | ' + ad_tag_script);
            
            if(ad_tag_id != null){
                adTagRec.Ad_Tag_ID__c = String.valueOf(ad_tag_id);
                adTagRec.Ad_Tag_Script__c = ad_tag_script;
                update adTagRec;
            }
        }
        catch(Exception e){
            if(log.Response__c != null && log.Response__c != ''){
                log.Response__c = log.Response__c + '\n---------------\n'+ e.getmessage();
            }else{
                log.Response__c = e.getmessage();
            }
        }
        
        log.Notes__c = 'Ad_Tag__c | ' + adTagRec.Name + ' | ' + adTagRec.Id;
        insert log; 
        system.debug('*** log = ' + log);
        system.debug('*** log.Response__c = ' + log.Response__c);
    }
}