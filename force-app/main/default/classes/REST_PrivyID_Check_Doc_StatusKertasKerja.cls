public class REST_PrivyID_Check_Doc_StatusKertasKerja {
    
    @future(callout=true)
	public static void CheckDocumentStatus(Id kk_id){
        
		try
        { 
            List<String> listStatus = new list<String>();
            
            Kertas_Kerja__c kkRec = [SELECT Id, Name, docToken__c, PrivyID_Status__c, download__c, Info_PrivyID__c FROM Kertas_Kerja__c WHERE Id =: kk_id];
            system.debug('*** kkRec = ' + kkRec);
           
            String docToken = kkRec.docToken__c;
            
			Http http = new Http();
            
            String EndPoints= Label.EndPoints_Status+docToken; System.debug('request.setEndpoint = '+EndPoints);
            String username = Label.username;
            String password = Label.password; 
            Blob headerValue = Blob.valueOf(username + ':' + password);
            String authorizationHeader = 'Basic  ' + EncodingUtil.base64Encode(headerValue);
            
            HttpRequest request = new HttpRequest();
            request.setTimeout(120000);
            request.setEndpoint(EndPoints);
            request.setMethod('GET');
            request.setHeader('Authorization', authorizationHeader);
            request.setHeader('Merchant-Key', Label.Merchant_Key);
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
              
            HttpResponse response = new HttpResponse();
        
            if (!Test.isRunningTest()){           
                response = http.send(request);
            } else{
                response.setStatusCode(200);
            }
            
            // Parse the JSON response
           	if(response.getStatusCode() == 200 || Test.isRunningTest()){
                
                System.debug(response.getBody());
                
                // Parse JSON response to get all the totalPrice field values.
                String signatoryStatus;
                String privyid;
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
                
                Map<String, Object> paramMap = (Map<String, Object>) JSON.deserializeUntyped(parser);
                List<Object> objList = (List<Object>) AppUtils.getListDataOnMap(paramMap, 'data::recipients');
                System.debug('objList nya : ' + objList); 
                for (Object obj : objList){
                	Map<String, Object> tmpMapRec = (Map<String, Object>) obj;
                    privyid = AppUtils.getStringDataOnMap(tmpMapRec, 'privyId') ;
                    signatoryStatus= AppUtils.getStringDataOnMap(tmpMapRec, 'signatoryStatus');
                    signedAt= AppUtils.getStringDataOnMap(tmpMapRec, 'signedAt');
                    Map<String, String> userMap = new Map<String, String>(); 
                    for(User usrlist : [SELECT Id, Name, User_s_PrivyID__c FROM User]){
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
                kkRec.Info_PrivyID__c = Tampung;
                kkRec.PrivyID_Status__c = documentStatus;
                kkRec.download__c = download;
                if(documentStatus=='In Progress' && listStatus.size()>0)
                {
                	kkRec.Status_Approval_PrivyId__c=listStatus[0];
                }
                if(documentStatus=='Completed')
                {
                	kkRec.Status_Approval_PrivyId__c='Completed';
                }
                
                update kkRec;    
        	}
            
        }
        catch(exception e) 
        {
            string errMessage = 'Error on REST_PrivyID_Check_Doc_StatusKertasKerja function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }
}