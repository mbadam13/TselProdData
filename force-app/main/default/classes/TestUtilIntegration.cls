/**
 * @description       : test class for UtilIntegration
 * @author            : RKA
 * @group             : 
 * @last modified on  : 07-16-2024
 * @last modified by  : RKA
**/
@IsTest
public without sharing class TestUtilIntegration {
    @IsTest
    static void testPostLead() {
        Map<String,String> mapHeader = new Map<String,String>();
        mapHeader.put('Content-Type', 'application/json');
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockLeadPatch());
            HttpResponse res = UtilIntegration.postLead('SFCSSM_Patch_Lead', 'ini', mapHeader);
        Test.stopTest();
    }

    @IsTest
    static void testDeleteLead() {
        Map<String,String> mapHeader = new Map<String,String>();
        mapHeader.put('Content-Type', 'application/json');
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockLeadDelete());
            UtilIntegration.deleteLead('SFCSSM_Delete_Lead', 'ini', mapHeader);
        Test.stopTest();
    }

    @IsTest
    static void testPostAccount() {
        Map<String,String> mapHeader = new Map<String,String>();
        mapHeader.put('Content-Type', 'application/json');

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockAccountPost());
            UtilIntegration.postAccount('SFCSSM_Post_Account', 'ini', mapHeader);
        Test.stopTest();
    }

    @IsTest
    static void testPostContact() {
        Map<String,String> mapHeader = new Map<String,String>();
        mapHeader.put('Content-Type', 'application/json');
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockContactPost());
            UtilIntegration.postContact('SFCSSM_Post_Contact', 'body', mapHeader);
        Test.stopTest();
    }

    public class MockLeadPatch implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[ {"id" : "001RM000003oLrfYAE","success" : true,"errors" : [ ]},{"success" : false,"errors" : [{"statusCode" : "MALFORMED_ID","message" : "malformed id 001RM000003oLrB000","fields" : [ ]}]}]');
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockAccountPost implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[ {"id" : "001RM000003oLrfYAE","success" : true,"errors" : [ ]},{"success" : false,"errors" : [{"statusCode" : "MALFORMED_ID","message" : "malformed id 001RM000003oLrB000","fields" : [ ]}]}]');
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockContactPost implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[ {"id" : "001RM000003oLrfYAE","success" : true,"errors" : [ ]}]');
            res.setStatusCode(200);
            return res;
        }
    }

    public class MockLeadDelete implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('[ {"id" : "001RM000003oLrfYAE","success" : true,"errors" : [ ]},{"success" : false,"errors" : [{"statusCode" : "MALFORMED_ID","message" : "malformed id 001RM000003oLrB000","fields" : [ ]}]}]');
            res.setStatusCode(200);
            return res;
        }
    }
}