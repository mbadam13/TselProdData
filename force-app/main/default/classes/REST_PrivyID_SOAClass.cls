/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-12-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-12-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class REST_PrivyID_SOAClass {
    ApexPages.StandardSetController setCon; 
    ApexPages.StandardController con;
    public String SOAID {get;set;}
    public List<ContentVersion> getFile{get;set;}
     
    //-- constructor
    public REST_PrivyID_SOAClass (ApexPages.StandardController controller){
        con = controller;       
        //SOAID = ApexPages.currentPage().getParameters().get('id');
        SOAID = con.getRecord().id;
         getFile = AppUtils.getPrivyFilesOnBase64(SOAID);
    }

    //@future(callout=true)
    public void UploadDocument ()
    {
        try
        {
            String sts='In Progress';
            string base64EncodeString;
            string titledoc;    
                
            system.debug('SOAID_pageid1=='+SOAID);
            system.debug('pageid2=='+ApexPages.currentPage().getParameters().get('id'));   
            //List<attachment> attachments = [SELECT id,body FROM Attachment WHERE parentid = :ApexPages.currentPage().getParameters().get('id')] ;       
            //List<ContentVersion> attachments = AppUtils.getPrivyFilesOnBase64(ApexPages.currentPage().getParameters().get('id'));
            List<ContentVersion> attachments = AppUtils.getPrivyFilesOnBase64(SOAID);
            //List<String> attachmentIDs = new List<String>();
            
            system.debug ('isi attachments'+attachments);
            if (attachments.size()>0)
            {
                integer attInd=0;
                For (ContentVersion att :attachments) 
                {
                    base64EncodeString = EncodingUtil.base64Encode(att.VersionData);
                    Blob fileContentBlob = att.VersionData;
                    titledoc = att.Title;
                }
            }
            else
            {
                system.debug ('isi attachments'+attachments);
                system.debug ('There was a problem with the Application service. Please call an administrator.');
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
            String docType;
            List<SOA__c> SOA_listuser = new List <SOA__c>();
            List<SOA__c> listuserSOA = [SELECT id,docToken__c,docType__c,User_s_PrivyID__c,User_s_PrivyID_Manager__c FROM SOA__C WHERE id = :SOAID] ;
            for(SOA__c thisItem1 : listuserSOA)
            {
                privyd_user=thisItem1.User_s_PrivyID__c;
                privyd_manager=thisItem1.User_s_PrivyID_Manager__c;   
                docType = thisItem1.docType__c;
            }

             //request.setBody('{"documentTitle":"'+titledoc+'","docType":"Parallel","owner":{"privyId":"'+Label.Admin_PrivyId+'","enterpriseToken":"'+Label.enterpriseToken+'"},"recipients":[{"privyId":"DEVME9615","type":"Signer","enterpriseToken":""}],"document":"'+EncodingUtil.base64Encode(fileContentBlob)+'"}');     
             //request.setBody('{"documentTitle":"'+titledoc+'","docType":"+docType +","owner":{"privyId":"'+Label.Admin_PrivyId+'","enterpriseToken":"'+Label.enterpriseToken+'"},"recipients":[{"privyId":"'+privyd_user+'","type":"Signer","enterpriseToken":""},{"privyId":"'+privyd_manager+'","type":"Signer","enterpriseToken":""}],"document":"'+EncodingUtil.base64Encode(fileContentBlob)+'"}');           
             request.setBody('{"documentTitle":"'+titledoc+'","docType":"'+docType+'","owner":{"privyId":"'+Label.Admin_PrivyId+'","enterpriseToken":"'+Label.enterpriseToken+'"},"recipients":[{"privyId":"'+privyd_user+'","type":"Signer","enterpriseToken":""},{"privyId":"'+privyd_manager+'","type":"Signer","enterpriseToken":""}],"document":"'+EncodingUtil.base64Encode(fileContentBlob)+'"}');           
             HttpResponse response = new HttpResponse();
            if (!Test.isRunningTest())
            {           
                response = http.send(request);
            }
            else 
            {
                response.setStatusCode(201);
            }
                // Parse the JSON response
            if (response.getStatusCode() == 201 || Test.isRunningTest() )
            {
                System.debug(response.getBody());
    
                // create the new soa
                List<SOA__c> SOA_list = new List <SOA__c>();
                system.debug('pageid'+ApexPages.currentPage().getParameters().get('id'));
                List<SOA__c> listSOA = [SELECT id,docToken__c FROM SOA__C WHERE id = :SOAID] ;
                for(SOA__c thisItem : listSOA)
                {
                    // Parse JSON response to get all the totalPrice field values.
                    String docToken;
                    String urlDocument;
                    JSONParser parser = null;
                    if(!Test.isRunningTest())
                    {
                        parser = JSON.createParser(response.getBody());
                    }
                    else
                    {
                        parser = JSON.createParser('{"code":200,"data":{"title":"Mustika Indonesia_CO PrivyID (5)","docToken":"00f2123958307c3ed33dce97cdcc349b238c230131585ae1876ae25334348aa7","recipients":[{"privyId":"AV9615","type":"Signer","signatoryStatus":"In Progress","signedAt":null},{"privyId":"YP8090","type":"Signer","signatoryStatus":"In Progress","signedAt":null}],"documentStatus":"In Progress","urlDocument":"https://sign.privy.id/doc/00f2123958307c3ed33dce97cdcc349b238c230131585ae1876ae25334348aa7"},"message":"Successfully get a status document"}');
                    }
                    while (parser.nextToken() != null) 
                    {
                        if (parser.getText() == 'docToken') 
                        {
                            // Get the value.
                            parser.nextToken();
                            // Compute the grand total price for all invoices.
                            docToken = parser.getText();
                        }            
                        if (parser.getText() == 'urlDocument') 
                        {
                                // Get the value.
                                parser.nextToken();
                                // Compute the grand total price for all invoices.
                                urlDocument= parser.getText();
                        }
                    }
                    thisItem.docToken__c=docToken;
                    thisItem.documentStatus__c=sts;
                    thisItem.urlDocument__c=urlDocument;
                    SOA_list.add(thisItem);
                }
                update SOA_list;
            }
            else 
            {
                System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus()+ ' '+response.getBody());
                string errMessage = 'Error on REST_PrivyID_SOAClass function:: The status code returned was not expected: ' +response.getStatusCode() + ' ' + response.getStatus()+ ' '+response.getBody();
                system.debug('==================== error message : ' + errMessage);
                AppUtils.putError(errMessage );            
            }  
       }//endtry
       catch(exception e) 
        {
            string errMessage = 'Error on REST_PrivyID_SOAClass function::' + e.getmessage() + '::' + e.getLineNumber() ;
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