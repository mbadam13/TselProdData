/**
 * @description       : test class for LeadServices
 * @author            : RKA
 * @group             : 
 * @last modified on  : 07-16-2024
 * @last modified by  : RKA
**/
@IsTest
public without sharing class TestLeadServices {
    public static final String RT_LEAD_GENERAL = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();
    public static final String RT_LEAD_SME = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Lead_SME').getRecordTypeId(); 

    @IsTest
    static void testDeleteLead() {
        Lead tmpLead = TestDataFactory.createLead();
        tmpLead.RecordTypeId = RT_LEAD_GENERAL;
        Database.insert(tmpLead, AccessLevel.SYSTEM_MODE);

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockLeadDelete());
            LeadServices.deleteLeadCSSM(tmpLead.Id);
        Test.stopTest();
    }

    @IsTest
    static void testPatchLead() {
        Lead tmpLead = TestDataFactory.createLead();
        tmpLead.RecordTypeId = RT_LEAD_GENERAL;
        Database.insert(tmpLead, AccessLevel.SYSTEM_MODE);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockLeadPatch());
            LeadServices.patchLead(new Set<String> {tmpLead.Id});
        Test.stopTest();
    }

    @IsTest
    static void testConvertLead() {
        Lead tmpLead = TestDataFactory.createLead();
        tmpLead.RecordTypeId = RT_LEAD_GENERAL;
        tmpLead.CSSM_Record_Id_DigiAds__c = '001RM000003oLrfYAE';
        Database.insert(tmpLead, AccessLevel.SYSTEM_MODE);

        Database.leadConvert lc = new Database.leadConvert();
        lc.setLeadId(tmpLead.id);
        
        leadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setDoNotCreateOpportunity(true);
        lc.setOwnerId(UserInfo.getUserId());
        Database.LeadConvertResult lcr = Database.convertLead(lc);

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockAccountPost());
            Test.setMock(HttpCalloutMock.class, new MockContactPost());
            LeadServices.convertLead(new Set<String> {tmpLead.Id});
        Test.stopTest();
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
}