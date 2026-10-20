/**
 * @description       : test class for LeadManagerHandler
 * @author            : RKA
 * @group             : 
 * @last modified on  : 07-16-2024
 * @last modified by  : RKA
**/
@IsTest
public without sharing class TestLeadManagerHandler {
    public static final String RT_LEAD_GENERAL = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();
    public static final String RT_LEAD_SME = Schema.getGlobalDescribe().get('Lead').getDescribe().getRecordTypeInfosByDeveloperName().get('Lead_SME').getRecordTypeId(); 

    @IsTest
    static void testLeadTSurvey() {
        
        Test.startTest();
            Lead tmpLead = TestDataFactory.createLead();
            tmpLead.RecordTypeId = RT_LEAD_GENERAL;
            Database.insert(tmpLead, AccessLevel.SYSTEM_MODE);
            Database.update(tmpLead, AccessLevel.SYSTEM_MODE);
            Database.delete(tmpLead.Id, AccessLevel.SYSTEM_MODE);
        Test.stopTest();
    }
}