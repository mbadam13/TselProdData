/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-15-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-15-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class REST_PrivyID_SendPrivyidCampMyAds {
    ApexPages.StandardSetController setCon; 
    ApexPages.StandardController con;
    String User_s_PrivyID_Manager;
    public List<ContentVersion> getFile{get;set;}
    public String CampaignMyadsID {get;set;}
     
    //-- constructor
    public REST_PrivyID_SendPrivyidCampMyAds(ApexPages.StandardController controller){
        con = controller;
        
        //SOAID = CampaignMyadsID;
        CampaignMyadsID = con.getRecord().id;
        getFile = AppUtils.getPrivyFilesOnBase64(CampaignMyadsID);
        system.debug('isi getFile '+getFile );
    }

    public void UploadDocument ()
    {
        try
        {
            String sts='In Progress';
            //String query = 'SELECT id,documentStatus__c,docToken__c FROM SOA__C WHERE documentStatus__c='+sts;

            string base64EncodeString; 
            string titledoc;         
            List<ContentVersion> attachments = AppUtils.getPrivyFilesOnBase64(CampaignMyadsID); //a0K0l000007Wn2iEAC
            List<String> attachmentIDs = new List<String>();
            
 
            if (attachments.size() >0)
            {
                integer attInd=0;
                For (ContentVersion att :attachments) 
                {
                    base64EncodeString = EncodingUtil.base64Encode(att.VersionData);
                    Blob fileContentBlob = att.VersionData;
                    titledoc = att.Title;
                }
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
            String Recipients_Type1;
            String privyd_manager;
            String Recipients_Type2;
            String privyd_gm;
            String Recipients_Type3;
            String privyd_svp;
            String Recipients_Type4;
            String docType;
            List<Campaign_MyAds__c> Camp_Myads_listuser = new List <Campaign_MyAds__c>();
            List<Campaign_MyAds__c> listuserCamp_Myads = [SELECT id,docToken__c,docType__c,User_s_PrivyID__c,Recipients_Type_1__c,User_s_PrivyID_Manager__c,Recipients_Type_2__c,GM_User_s_PrivyID__c,Recipients_Type_3__c,SVP_User_s_PrivyID__c,Recipients_Type_4__c FROM Campaign_MyAds__c WHERE id = :CampaignMyadsID] ;
            for(Campaign_MyAds__c thisItem1 : listuserCamp_Myads)
            {
                privyd_user=thisItem1.User_s_PrivyID__c;
                Recipients_Type1 =thisItem1.Recipients_Type_1__c;
                privyd_manager=thisItem1.User_s_PrivyID_Manager__c;
                Recipients_Type2 =thisItem1.Recipients_Type_2__c;
                privyd_gm=thisItem1.GM_User_s_PrivyID__c;
                Recipients_Type3 =thisItem1.Recipients_Type_3__c;
                privyd_svp=thisItem1.SVP_User_s_PrivyID__c;
                Recipients_Type4 =thisItem1.Recipients_Type_4__c;
                
                docType = thisItem1.docType__c;
                
            }
            //case1
            /*if(Recipients_Type2==null && Recipients_Type3==null && Recipients_Type4==null)
            {
                request.setBody('{"documentTitle":"'+titledoc+'","docType":"'+docType+'","owner":{"privyId":"'+Label.Admin_PrivyId+'","enterpriseToken":"'+Label.enterpriseToken+'"},"recipients":[{"privyId":"'+privyd_manager+'","type":"'+Recipients_Type1+'","enterpriseToken":""}],"document":"'+EncodingUtil.base64Encode(fileContentBlob)+'"}');
            }*/
            //case2
            if(Recipients_Type3==null && Recipients_Type4==null)
            {
                system.debug('Masuk 3&4');
                
                
                //request.setBody('{"documentTitle":"'+titledoc+'","docType":"'+docType+'","owner":{"privyId":"'+Label.Admin_PrivyId+'","enterpriseToken":"'+Label.enterpriseToken+'"},"recipients":[{"privyId":"'+privyd_user+'","type":"'+Recipients_Type1+'","enterpriseToken":""},{"privyId":"'+privyd_manager+'","type":"'+Recipients_Type2+'","enterpriseToken":""}],"document":"'+EncodingUtil.base64Encode(fileContentBlob)+'"}');           
                  request.setBody('{"documentTitle":"'+titledoc+'","docType":"'+docType+'","owner":{"privyId":"'+Label.Admin_PrivyId+'","enterpriseToken":"'+Label.enterpriseToken+'"},"recipients":[{"privyId":"'+privyd_user+'","type":"'+Recipients_Type1+'","enterpriseToken":""},{"privyId":"'+privyd_manager+'","type":"'+Recipients_Type2+'","enterpriseToken":""}],"document":"'+EncodingUtil.base64Encode(fileContentBlob)+'"}');
            }
            //case 3
            if(Recipients_Type3!=null && Recipients_Type4==null)
            {
                request.setBody('{"documentTitle":"'+titledoc+'","docType":"'+docType+'","owner":{"privyId":"'+Label.Admin_PrivyId+'","enterpriseToken":"'+Label.enterpriseToken+'"},"recipients":[{"privyId":"'+privyd_user+'","type":"'+Recipients_Type1+'","enterpriseToken":""},{"privyId":"'+privyd_manager+'","type":"'+Recipients_Type2+'","enterpriseToken":""},{"privyId":"'+privyd_gm+'","type":"'+Recipients_Type3+'","enterpriseToken":""}],"document":"'+EncodingUtil.base64Encode(fileContentBlob)+'"}');              
            }
            if(Recipients_Type2!=null && Recipients_Type3!=null && Recipients_Type4!=null)
            {
                system.debug('Masuk 2&3&4');
                request.setBody('{"documentTitle":"'+titledoc+'","docType":"'+docType+'","owner":{"privyId":"'+Label.Admin_PrivyId+'","enterpriseToken":"'+Label.enterpriseToken+'"},"recipients":[{"privyId":"'+privyd_user+'","type":"'+Recipients_Type1+'","enterpriseToken":""},{"privyId":"'+privyd_manager+'","type":"'+Recipients_Type2+'","enterpriseToken":""},{"privyId":"'+privyd_gm+'","type":"'+Recipients_Type3+'","enterpriseToken":""},{"privyId":"'+privyd_svp+'","type":"'+Recipients_Type4+'","enterpriseToken":""}],"document":"'+EncodingUtil.base64Encode(fileContentBlob)+'"}');           
            }
            HttpResponse response = new HttpResponse();
            if (!Test.isRunningTest()){           
            response = http.send(request);
            }
            else {
                response.setStatusCode(201);
            }
                
            // Parse the JSON response
            if (response.getStatusCode() == 201 || Test.isRunningTest() )
            {
                System.debug(response.getBody());

                // create the new soa
                List<Campaign_MyAds__c> Camp_Myads_list = new List <Campaign_MyAds__c>();
                List<Campaign_MyAds__c> listCamp_Myads = [SELECT id,docToken__c FROM Campaign_MyAds__c WHERE id = :CampaignMyadsID] ;
                for(Campaign_MyAds__c thisItem : listCamp_Myads)
                {
                    // Parse JSON response to get all the totalPrice field values.
                        String docToken;
                        String urlDocument;
                    JSONParser parser = JSON.createParser(response.getBody());
                    while (parser.nextToken() != null) {
                        if (parser.getText() == 'docToken') {
                            // Get the value.
                            parser.nextToken();
                            // Compute the grand total price for all invoices.
                            docToken = parser.getText();
                        }
                        if (parser.getText() == 'urlDocument') {
                            // Get the value.
                            parser.nextToken();
                            // Compute the grand total price for all invoices.
                            urlDocument= parser.getText();
                        }
                    }
                    thisItem.docToken__c=docToken;
                    thisItem.documentStatus__c=sts;
                    thisItem.urlDocument__c=urlDocument;
                    Camp_Myads_list.add(thisItem);
                }
                    update Camp_Myads_list;
            }
            else
            {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                string errMessage = 'Error on REST_PrivyID_SendPrivyidCampMyAds function:: The status code returned was not expected: ' +response.getStatusCode() + ' ' + response.getStatus()+ ' ' + response.getBody();
                system.debug('==================== error message : ' + errMessage);
                AppUtils.putError(errMessage );    
            }            
        }//try
        catch(exception e) 
        {
            string errMessage = 'Error on REST_PrivyID_SendPrivyidCampMyAds function::' + e.getmessage() + '::' + e.getLineNumber() ;
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