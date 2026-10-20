public class PrivyId_KertasKerja {
    
	@future(callout=true)
    public static void sendPrivyId_KertasKerja(Id kk_id){
        
        system.debug('*** Masuk sendPrivyId_KertasKerja !!!');
        
        try{
            
            Kertas_Kerja__c kkRec = [SELECT Id, Name, Kertas_Kerja_Name__c, Type__c, docType__c FROM Kertas_Kerja__c WHERE Id =: kk_id AND Status__c = 'Review'];
            system.debug('*** kkRec = ' + kkRec);
            
            // -------------------------------------------------- Get ContentVersion Pdf KK -------------------------- //
            
            String pathOnClient_doc = kkRec.Kertas_Kerja_Name__c + '.pdf';
            ContentVersion cv = [SELECT Id, Title, VersionData FROM ContentVersion WHERE PathOnClient =: pathOnClient_doc ORDER BY CreatedDate DESC LIMIT 1];
            system.debug('*** cv = ' + cv);
            
            // -------------------------------------------------- Send PrivyId KK -------------------------- //
            
            String username = Label.username;
        	String password = Label.password; 
        	Blob headerValue = Blob.valueOf(username + ':' + password);
        	String authorizationHeader = 'Basic  ' + EncodingUtil.base64Encode(headerValue);
            
            Http http = new Http();
            
            HttpRequest request = new HttpRequest();
        	request.setTimeout(120000); // timeout in milliseconds
        	request.setEndpoint(Label.EndPoints_Upload);
        	request.setMethod('POST');
        	request.setHeader('Authorization', authorizationHeader);
        	request.setHeader('Merchant-Key', Label.Merchant_Key);
        	request.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
            
            // Set the body as a JSON object
        	if(kkRec != null){
            	request.setBody('{"documentTitle":"'+cv.Title+'","docType":"'+ kkRec.docType__c+'","owner":{"privyId":"'+Label.Admin_PrivyId+'","enterpriseToken":"'+Label.enterpriseToken+'"},"recipients":[{"privyId":"'+Label.Settlement_User_s_PrivyID+'","type":"Signer","enterpriseToken":"'+Label.enterpriseToken+'"},{"privyId":"'+Label.KertasKerja_PrivyID+'","type":"Signer","enterpriseToken":"'+Label.enterpriseToken+'"}],"document":"'+EncodingUtil.base64Encode(cv.VersionData)+'"}');           
        		system.debug('*** request.setBody = ' + '{"documentTitle":"'+cv.Title+'","docType":"'+kkRec.docType__c+'","owner":{"privyId":"'+Label.Admin_PrivyId+'","enterpriseToken":"'+Label.enterpriseToken+'"},"recipients":[{"privyId":"'+Label.Settlement_User_s_PrivyID+'","type":"Signer","enterpriseToken":"'+Label.enterpriseToken+'"},{"privyId":"'+Label.KertasKerja_PrivyID+'","type":"Signer","enterpriseToken":"'+Label.enterpriseToken+'"}],"document":"'+EncodingUtil.base64Encode(cv.VersionData)+'"}');
            }
            
            HttpResponse response = new HttpResponse();
        
            if (!Test.isRunningTest()){        
                response = http.send(request);
            }else{
                response.setStatusCode(201);
            }
            
            system.debug('*** response StatusCode & Status = ' + response.getStatusCode() + ' | ' + response.getStatus());
            
            // Parse the JSON response
            if(response.getStatusCode() == 201 || Test.isRunningTest()){
                
            	system.debug('*** response.getBody() = ' + response.getBody());
                
                Kertas_Kerja__c kkRecUpdate = [SELECT Id, Name, docToken__c, PrivyID_Status__c, urlDocument__c, Submit_Date__c FROM Kertas_Kerja__c WHERE Id =: kk_id];
                system.debug('*** kkRec = ' + kkRec);
                
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
                kkRecUpdate.docToken__c = docToken;
                kkRecUpdate.PrivyID_Status__c = 'In Progress';
                kkRecUpdate.urlDocument__c = urlDocument;
                kkRecUpdate.Submit_Date__c = system.now();
                update kkRecUpdate;

            }
        }
        catch(exception e){
            
            String errMessage = 'Error on PrivyId_KertasKerja function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage);
        }
    }
}