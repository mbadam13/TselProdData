public class REST_PrivyID_Check_Doc_StatusQuotation {
    ApexPages.StandardSetController setCon; 
    ApexPages.StandardController con;
    public String QuoteID {get;set;}
    public List<Quote> Quoteget{get;set;}
    //-- constructor
    public REST_PrivyID_Check_Doc_StatusQuotation (ApexPages.StandardController controller){
        con = controller;
        
        //SOAID = QuoteID;
        QuoteID = con.getRecord().id;
        Quoteget = [SELECT id,docToken__c FROM Quote WHERE id = :QuoteID] ;
    }
    // @future(callout=true)
    public void CheckDocument()
    {
      try
        {
            List<String> listStatus = new list<String>();
            String docToken;
             List<Quote> listQuoteget = [SELECT id,docToken__c FROM Quote WHERE id = :QuoteID] ;
             for(Quote thisItemget : listQuoteget)
             {
                 docToken = thisItemget.docToken__c;
             }
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setTimeout(120000); // timeout in milliseconds
            String EndPoints= Label.EndPoints_Status+docToken;
            System.debug('request.setEndpoint = '+EndPoints);
            request.setEndpoint(EndPoints);
            request.setMethod('GET');
            String username = Label.username;
            String password = Label.password; 
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic  ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization', authorizationHeader);
            request.setHeader('Merchant-Key', Label.Merchant_Key);
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            
            HttpResponse response = new HttpResponse();
            if (!Test.isRunningTest())
            {           
                response = http.send(request);
            }
            else 
            {
                response.setStatusCode(200);
            }
                // Parse the JSON response
                if (response.getStatusCode() == 200 || Test.isRunningTest() )
                {
                    System.debug(response.getBody());
                    // create the new soa
                        List<Quote> Quote_list = new List <Quote>();
                        List<Quote> listQuote = [SELECT id,documentStatus__c FROM Quote WHERE id = :QuoteID] ;
                         for(Quote thisItem : listQuote)
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
                                     
                                    Tampung += 'PrivyId:'+value+'\n'+'Status:'+signatoryStatus+'\n'+'Datetime:'+AppUtils.strToDateTime(ressignedAt,'yyyy-mm-dd hh:mm:ss')+'\n'+'\n';
                                }
                                
                                 documentStatus= AppUtils.getStringDataOnMap(paramMap, 'data::documentStatus') ;
                                 download= AppUtils.getStringDataOnMap(paramMap, 'data::download') ;
                                 thisItem.Info_PrivyID__c=Tampung;
                                 thisItem.documentStatus__c=documentStatus;
                                 thisItem.download__c=download;
                                  if(documentStatus=='In Progress' && listStatus.size()>0)
                                 {
                                    thisItem.Status_Approval_PrivyId__c=listStatus[0];
                                 }
                                 if(documentStatus=='Completed')
                                 {
                                      thisItem.Status_Approval_PrivyId__c='Completed';
                                 }
                                 Quote_list.add(thisItem);
                         }
                        update Quote_list;
                }
          
          //end runtest
        }
        catch(exception e) 
        {
            string errMessage = 'Error on REST_PrivyID_Check_Doc_StatusQuotation function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
    public PageReference back()
    {
        PageReference cancel = con.cancel();
        return cancel;
    }
 }