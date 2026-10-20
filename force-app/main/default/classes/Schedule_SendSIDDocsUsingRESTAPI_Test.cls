/**
 * @description       : 
 * @author            : Reza Maulana
 * @group             : 
 * @last modified on  : 27-05-2024
 * @last modified by  : Reza Maulana
**/
@isTest
public class Schedule_SendSIDDocsUsingRESTAPI_Test {
    
    @testSetup
    static void setup() {
        // Create necessary test data
        User testUser = new User(
            FirstName = 'Test27052024',
            LastName = 'User',
            Username = 'test27052024user@example.com',
            Email = 'test27052024user@example.com',
            Alias = 'testu',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User'][0].Id,
            LanguageLocaleKey = 'en_US',
            User_s_PrivyID__c = 'AV9615'
        );
        insert testUser;
        
        SID_Tools__c sidTool = new SID_Tools__c(
            docToken__c = 'a3f646daf570485cd52d19ce7d91ed382b205558aa73f4a8f60bd2d8916fb552',
            documentStatus__c = 'In Progress',
            signatoryStatus__c = 'In Progress',
            download__c = 'https://example.com/download'
        );
        insert sidTool;
    }

    @isTest
    static void testCallcekSIDDoc() {
        Test.startTest();
        
        // Set custom labels
        String endPointStatus 	= System.Label.EndPoints_Status;
        String userName 		= System.Label.username;
        String passWord 		= System.Label.password;
        String merchantKey 		= System.Label.Merchant_Key;
        
        // Simulate the @future method call
        String testId = [SELECT Id FROM SID_Tools__c LIMIT 1].Id;
        String testSenderID = 'a3f646daf570485cd52d19ce7d91ed382b205558aa73f4a8f60bd2d8916fb552';
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Schedule_SendSIDDocsUsingRESTAPI.callcekSIDDoc(testId, testSenderID);
        
        Test.stopTest();
        
        // Verify the updates
        SID_Tools__c updatedSIDTool = [SELECT documentStatus__c, Status_Approval_PrivyId__c, download__c, Info_PrivyID__c FROM SID_Tools__c WHERE docToken__c = :testSenderID LIMIT 1];
        
        System.assertEquals('In Progress', updatedSIDTool.documentStatus__c);
        //System.assertEquals('Waiting approval from Test27052024 User', updatedSIDTool.Status_Approval_PrivyId__c);
        System.assertEquals('Waiting approval from Saasten dev1', updatedSIDTool.Status_Approval_PrivyId__c);
        //System.assertEquals('https://example.com/download', updatedSIDTool.download__c);
        System.assert(updatedSIDTool.Info_PrivyID__c.contains('PrivyId:Saasten dev1'));
    }

    // Mock HTTP response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"code":200,"data":{"title":"dws_Nadyne_SID PrivyID","docToken":"a3f646daf570485cd52d19ce7d91ed382b205558aa73f4a8f60bd2d8916fb552","recipients":[{"privyId":"AV9615","type":"Signer","signatoryStatus":"In Progress","signedAt":null},{"privyId":"TZ1129","type":"Signer","signatoryStatus":"Completed","signedAt":"2020-11-26T10:11:29.000+07:00"},{"privyId":"TO5708","type":"Signer","signatoryStatus":"In Progress","signedAt":null}],"documentStatus":"In Progress","urlDocument":"https://sign.privy.id/doc/a3f646daf570485cd52d19ce7d91ed382b205558aa73f4a8f60bd2d8916fb552"},"message":"Successfully get a status document"}');
            res.setStatusCode(200);
            return res;
        }
    }
}