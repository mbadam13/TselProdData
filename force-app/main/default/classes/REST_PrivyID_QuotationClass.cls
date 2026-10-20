/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 11-16-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   11-16-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class REST_PrivyID_QuotationClass {
    ApexPages.StandardSetController setCon; 
    ApexPages.StandardController con;
    public String QuoteID{get;set;}
    public List<ContentVersion> getFile{get;set;}
     
    //-- constructor
    public REST_PrivyID_QuotationClass(ApexPages.StandardController controller){
        con = controller;
        
        //SOAID = ApexPages.currentPage().getParameters().get('id');
        QuoteID = con.getRecord().id;
        getFile = AppUtils.getPrivyFilesOnBase64(QuoteID);
    }

    
    //@future(callout=true)
    public void UploadDocument ()
    {
     try
        { 
            String sts='In Progress';
            string base64EncodeString;
            string titledoc;          
                            
            List<ContentVersion> attachments = AppUtils.getPrivyFilesOnBase64(QuoteID);
            //List<String> attachmentIDs = new List<String>();

            if (attachments.size() >0)
            {
                integer attInd=0;
                For (ContentVersion att :attachments) {
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
            
            //Set the body as a JSON object
            List<Quote> listuserQuote = [SELECT id,docToken__c,docType__c,User_s_PrivyID__c,User_s_PrivyID_Manager__c FROM Quote WHERE id = :QuoteID] ;
            String privyd_user;
            String privyd_manager;
            String docType;
            for(Quote thisItem1 : listuserQuote)
            {
                privyd_user=thisItem1.User_s_PrivyID__c;
                privyd_manager=thisItem1.User_s_PrivyID_Manager__c;   
                docType = thisItem1.docType__c;
                
            }

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
                    List<Quote> Quote_list = new List <Quote>();
                    List<Quote> listQuote = [SELECT id,docToken__c FROM Quote WHERE id = :QuoteID] ;
                    for(Quote thisItem : listQuote)
                    {
                        // Parse JSON response to get all the totalPrice field values.
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
                        Quote_list.add(thisItem);
                    }
                    update Quote_list;
            }

        }//endtry   
        catch(exception e) 
        {
            string errMessage = 'Error on REST_PrivyID_QuotationClass function::' + e.getmessage() + '::' + e.getLineNumber() ;
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