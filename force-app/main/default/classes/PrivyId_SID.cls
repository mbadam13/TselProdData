public class PrivyId_SID {
	
    @future(callout=true)
    public static void sendPrivyId_SID(String SID){
        String msg = '';
    	try{
            system.debug('*** Masuk sendPrivyId_SID !!!');
            String base64EncodeString; 	
            String titledoc;
			String sts = 'In Progress';
            
            SID_Tools__c[] accts = [SELECT Id from SID_Tools__c WHERE id =: SID and SID_Approval__c = 'Approved'];
            
            List<ContentVersion> attachments = AppUtils.getPrivyFilesOnBase64(SID);
            
            if(attachments.size() > 0){
            	Integer attInd = 0;
                for(ContentVersion att : attachments){
                	base64EncodeString = EncodingUtil.base64Encode(att.VersionData);
                    Blob fileContentBlob = att.VersionData;
                    titledoc = att.Title;
                }
          	}else{
            	/*ApexPages.Message Msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Field should not be empty when selected');
                ApexPages.addMessage(Msg);*/
                msg = 'Tidak ada attachment.'; // -add Dby
                system.debug('*** msg = ' + msg);
           	}
			
       		Blob fileContentBlob = EncodingUtil.base64Decode(base64EncodeString);
        	Http http = new Http();
        	HttpRequest request = new HttpRequest();
        	request.setTimeout(120000); // timeout in milliseconds
        	request.setEndpoint(Label.EndPoints_Upload);
        	request.setMethod('POST');
        	String username = Label.username;
        	String password = Label.password; 
        	Blob headerValue = Blob.valueOf(username + ':' + password);
        	String authorizationHeader = 'Basic  ' + EncodingUtil.base64Encode(headerValue);
        	request.setHeader('Authorization', authorizationHeader);
        	request.setHeader('Merchant-Key', Label.Merchant_Key);
        	request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
       		// Set the body as a JSON object
        	String privyd_user;
        	String privyd_manager;
        	String privyd_ops;
        	String docType;
        	List<SID_Tools__c> Camp_Myads_listuser = new List <SID_Tools__c>();
        	List<SID_Tools__c> listuserCamp_Myads = [SELECT Id, docToken__c, docType__c, User_s_PrivyID__c, SM_User_s_PrivyID__c, Operation_User_PrivyID__c FROM SID_Tools__c WHERE Id =: SID];
       		
        	for(SID_Tools__c thisItem1 : listuserCamp_Myads){
                privyd_user = thisItem1.User_s_PrivyID__c;
                privyd_manager = thisItem1.SM_User_s_PrivyID__c;
                privyd_ops = thisItem1.Operation_User_PrivyID__c;
                docType = thisItem1.docType__c;
            }
        
        	if(accts.size() > 0){
            	request.setBody('{"documentTitle":"'+titledoc+'","docType":"'+docType+'","owner":{"privyId":"'+Label.Admin_PrivyId+'","enterpriseToken":"'+Label.enterpriseToken+'"},"recipients":[{"privyId":"'+privyd_user+'","type":"Signer","enterpriseToken":""},{"privyId":"'+privyd_manager+'","type":"Signer","enterpriseToken":"'+Label.enterpriseToken+'"},{"privyId":"'+privyd_ops+'","type":"Signer","enterpriseToken":"'+Label.enterpriseToken+'"}],"document":"'+EncodingUtil.base64Encode(fileContentBlob)+'"}');           
        		//-add Dby
        		system.debug('*** request.setBody = ' + '{"documentTitle":"'+titledoc+'","docType":"'+docType+'","owner":{"privyId":"'+Label.Admin_PrivyId+'","enterpriseToken":"'+Label.enterpriseToken+'"},"recipients":[{"privyId":"'+privyd_user+'","type":"Signer","enterpriseToken":""},{"privyId":"'+privyd_manager+'","type":"Signer","enterpriseToken":"'+Label.enterpriseToken+'"},{"privyId":"'+privyd_ops+'","type":"Signer","enterpriseToken":"'+Label.enterpriseToken+'"}],"document":"'+EncodingUtil.base64Encode(fileContentBlob)+'"}');
            }
            
        	HttpResponse response = new HttpResponse();
        
            if (!Test.isRunningTest()){        
                response = http.send(request);
                /*//unLock the accounts
                Approval.UnlockResult[] lrList = Approval.unlock(accts, false);
                // Iterate through each returned result
                for(Approval.UnlockResult lr : lrList){
                	if(lr.isSuccess()){
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully UnlockResult account with ID: ' + lr.getId());
                    }else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : lr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }*/
            }else{
                response.setStatusCode(201);
            }
            
            // Parse the JSON response
            if(response.getStatusCode() == 201 || Test.isRunningTest()){
            	System.debug(response.getBody());
                // create the new soa
                List<SID_Tools__c> Camp_Myads_list = new List <SID_Tools__c>();
                List<SID_Tools__c> listCamp_Myads = [SELECT id,docToken__c FROM SID_Tools__c WHERE id = :SID] ;
                for(SID_Tools__c thisItem : listCamp_Myads){
                    // Parse JSON response to get all the totalPrice field values.
                    String docToken;
                    String urlDocument;
                    JSONParser parser = null;
                    if(!Test.isRunningTest()){
                        parser = JSON.createParser(response.getBody());                     
                    }else{
                        parser = JSON.createParser('{"code":200,"data":{"title":"Mustika Indonesia_CO PrivyID (5)","docToken":"00f2123958307c3ed33dce97cdcc349b238c230131585ae1876ae25334348aa7","recipients":[{"privyId":"AV9615","type":"Signer","signatoryStatus":"In Progress","signedAt":null},{"privyId":"YP8090","type":"Signer","signatoryStatus":"In Progress","signedAt":null}],"documentStatus":"In Progress","urlDocument":"https://sign.privy.id/doc/00f2123958307c3ed33dce97cdcc349b238c230131585ae1876ae25334348aa7"},"message":"Successfully get a status document"}');
                    }
                    while (parser.nextToken() != null){
                        if (parser.getText() == 'docToken'){
                            // Get the value.
                            parser.nextToken();
                            // Compute the grand total price for all invoices.
                            docToken = parser.getText();
                        }
                        if (parser.getText() == 'urlDocument'){
                            // Get the value.
                            parser.nextToken();
                            // Compute the grand total price for all invoices.
                            urlDocument= parser.getText();
                        }
                    }
                    thisItem.docToken__c=docToken;
                    thisItem.documentStatus__c=sts;
                    thisItem.urlDocument__c=urlDocument;
                    thisItem.Submit_Date__c =date.today();
                    Camp_Myads_list.add(thisItem);
                }
                update Camp_Myads_list;
                /*//locked Record
                Approval.LockResult[] ulrList = Approval.lock(accts, false);
                // Iterate through each returned result
                for(Approval.LockResult ulr : ulrList){
                    if(ulr.isSuccess()){
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully lockResult account with ID: ' + ulr.getId());
                    }else{
                        // Operation failed, so get all errors                
                        for(Database.Error err : ulr.getErrors()){
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }*/         
			}else{
           		// Parse the JSON response
               	System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
                string errMessage = 'Error on REST_PrivyID_SendPrivyidSID function:: The status code returned was not expected: ' +response.getStatusCode() + ' ' + response.getStatus()+ ' '+response.getBody();
                system.debug('==================== error message : ' + errMessage);
                AppUtils.putError(errMessage );
          	}
      	}//endtry
       	catch(exception e){
            string errMessage = 'Error on REST_PrivyID_SendPrivyidSID function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        } 
    }
}