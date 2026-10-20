public class Schedule_SendSIDDocsUsingRESTAPI {
  @future(callout=true)
   public static void callcekSIDDoc (String id, String SenderID)
   {
        System.debug('Created Sender Id:'+SenderID);
        List<String> listStatus = new list<String>();         
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setTimeout(120000); // timeout in milliseconds
        String EndPoints= Label.EndPoints_Status+SenderID;
        System.debug('request.setEndpoint = '+EndPoints);
        request.setEndpoint(EndPoints);
        request.setMethod('GET');
        String username = Label.username;
        String password = Label.password; 
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader);
        System.debug('Authorization Header: ' + authorizationHeader);
        request.setHeader('Merchant-Key', Label.Merchant_Key);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
         HttpResponse response = new HttpResponse();
        Try{
           
         
            if (!Test.isRunningTest()){           
                response = http.send(request);
                System.debug('=== response.getBody() :' + response.getBody());
                System.debug('=== response() :' + response);
            }
            else {
                response.setStatusCode(200);
            }
                // Parse the JSON response
                if (response.getStatusCode() == 200 || Test.isRunningTest() )
                {
                    System.debug('=== response.getBody() :' + response.getBody());
                    // create the new soa
                        List<SID_Tools__c> Camp_list = new List <SID_Tools__c>();
                        List<SID_Tools__c> listCamp = [SELECT id,documentStatus__c,signatoryStatus__c,download__c FROM SID_Tools__c WHERE docToken__c= :SenderId] ;
                         for(SID_Tools__c thisItem : listCamp)
                         {
                             // Parse JSON response to get all the totalPrice field values.
                                String signatoryStatus;
                                String privyid;
                                String signatoryStatus3;
                                String signedAt;
                                String documentStatus;
                                String download;
                                String Tampung;
                                String CekStatus;
                                
                                Tampung='';
                                CekStatus='';
                                String parser = null;
                                if(!Test.isRunningTest()){
                                    parser = response.getBody();                     
                                }
                                else{
                                    parser = '{"code":200,"data":{"title":"dws_Nadyne_SID PrivyID","docToken":"a3f646daf570485cd52d19ce7d91ed382b205558aa73f4a8f60bd2d8916fb552","recipients":[{"privyId":"AV9615","type":"Signer","signatoryStatus":"In Progress","signedAt":null},{"privyId":"TZ1129","type":"Signer","signatoryStatus":"Completed","signedAt":"2020-11-26T10:11:29.000+07:00"},{"privyId":"TO5708","type":"Signer","signatoryStatus":"In Progress","signedAt":null}],"documentStatus":"In Progress","urlDocument":"https://sign.privy.id/doc/a3f646daf570485cd52d19ce7d91ed382b205558aa73f4a8f60bd2d8916fb552"},"message":"Successfully get a status document"}';
                                }
                                
                                //JSONParser parser = JSON.createParser(response.getBody());
                                //String jsonResponse = '{"data": ' + response.getBody() + '}';
                                Map<String, Object> paramMap = (Map<String, Object>) JSON.deserializeUntyped(parser);
                                List <Object> objList = (List<Object>)  AppUtils.getListDataOnMap(paramMap, 'data::recipients');
                                System.debug('objList nya : ' + objList); 
                                for (Object obj : objList) {
                                    Map<String, Object> tmpMapRec = (Map<String, Object>) obj;
                                    privyid = AppUtils.getStringDataOnMap(tmpMapRec, 'privyId') ;
                                    signatoryStatus= AppUtils.getStringDataOnMap(tmpMapRec, 'signatoryStatus');
                                    signedAt= AppUtils.getStringDataOnMap(tmpMapRec, 'signedAt');
                                     Map<String, String> userMap = new Map<String, String>(); 
                                    for(User usrlist : [SELECT id,Name,User_s_PrivyID__c FROM User])
                                    {
                                       userMap.put(usrlist.User_s_PrivyID__c, usrlist.Name);
                                    }
                                     String value = userMap.get(privyId);
                                     String ressignedAt;
                                     if(signedAt!=NULL){
                                         ressignedAt = signedAt.substring(0,19);
                                         ressignedAt = ressignedAt.replaceAll('T', ' ');
                                     }
                                     else
                                     {
                                         ressignedAt = '';
                                     }
                                      system.debug('Isi ressignedAt '+ressignedAt);
                                     if(signatoryStatus=='In Progress'){
                                         CekStatus='Waiting approval from '+value;
                                         listStatus.add('Waiting approval from '+value);
                                     }
                                     else{
                                         CekStatus='Completed';
                                         listStatus.add('Completed');
                                     }
                                    Tampung += 'PrivyId:'+value+'\n'+'Status:'+signatoryStatus+'\n'+'Datetime:'+AppUtils.strToDateTime(ressignedAt,'yyyy-mm-dd hh:mm:ss')+'\n'+'\n';
                                }
                                
                                 documentStatus= AppUtils.getStringDataOnMap(paramMap, 'data::documentStatus') ;
                                 download= AppUtils.getStringDataOnMap(paramMap, 'data::download') ;
                                 thisItem.Info_PrivyID__c=Tampung;
                                 thisItem.documentStatus__c=documentStatus;
                                 if(documentStatus=='In Progress' && listStatus.size()>0)
                                 {
                                    thisItem.Status_Approval_PrivyId__c=listStatus[0];
                                 }
                                 if(documentStatus=='Completed')
                                 {
                                      thisItem.Status_Approval_PrivyId__c='Completed';
                                 }
                                 thisItem.download__c=download;
                                 
                                 Camp_list.add(thisItem);
                         }
                        update Camp_list;
                        
        }
            
            }catch(Exception e){
                string err_message;
            err_message = '=== Error ::' + e.getmessage() + ' - ' +e.getStacktraceString() + '::' + e.getLineNumber();
            System.debug(err_message);
       }
   }
}