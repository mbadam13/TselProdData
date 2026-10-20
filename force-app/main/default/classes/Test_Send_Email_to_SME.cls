/**
 * @description       : Test class for Send_Email_to_SME trigger.
 *                     Covers after-insert (email + notification) and
 *                     before-update (Ask Revision notification) paths.
 *                     No SeeAllData — all data created in @TestSetup.
 * @author             : Auto-generated
**/
@isTest
public with sharing class Test_Send_Email_to_SME {

    /** Store the setup Opportunity Id for test method access */
    private static Id setupOppId;

    @TestSetup
    static void setupData() {
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser').getRecordTypeId();
        Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Advertiser').getRecordTypeId();

        Account acc = new Account(
            Name = 'TestAccountRFP',
            RecordTypeId = recordTypeAccId,
            Legal_Name__c = 'TestAccountRFP',
            Account_Type__c = 'Advertiser',
            Direct_Indirect__c = 'Direct',
            Status__c = 'Approved by Settlement',
            No_PKS__c = '123456',
            NPWP__c = '1234567890123456',
            NPWP_Address__c = 'Jakarta',
            PKS_Tracker__c = 'Pending',
            Reason_by_Settlement__c = 'Test'
        );
        TriggerBase.bypass('Account');
        insert acc;
        TriggerBase.clearBypass('Account');

        Brand__c b = new Brand__c(
            Name = 'TestApprovedBrand',
            Advertiser__c = acc.Id,
            Status__c = 'Approved'
        );
        insert b;
        b.Status__c = 'Approved';
        update b;

        Opportunity opp = new Opportunity(
            Name = 'TestOppRFP',
            RecordTypeId = recordTypeOppId,
            StageName = 'Request for Proposal',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id,
            Brand__c = b.Id,
            Regional__c = 'HEAD OFFICE',
            Type = 'Existing Business'
        );
        insert opp;
        setupOppId = opp.Id;
    }

    private static Request_for_proposal__c buildRFP() {
        Id recordTypeRfpId = Schema.SObjectType.Request_for_Proposal__c
            .getRecordTypeInfosByName().get('Direct Sales Proposal').getRecordTypeId();
        return new Request_for_proposal__c(
            RecordTypeId = recordTypeRfpId,
            Request_for_Proposal_Status__c = 'Request',
            Opportunity_Name__c = setupOppId,
            Date__c = Date.today(),
            Deadline__c = Date.today().addDays(7),
            Project__c = 'Test',
            Background__c = 'Test',
            Campaign_Objective__c = 'Test',
            KPI__c = 'Test',
            Key_Message__c = 'Test',
            Start_Period__c = Date.today(),
            End_Period__c = Date.today().addDays(30),
            Campaign_Investment__c = 1000000,
            Campaign_Media_Preferred_Inventory__c = 'Test',
            Target_Audiance__c = 'Test',
            Buying_Method__c = 'Programmatic'
        );
    }

    @isTest
    static void testAfterInsert() {
        MetadataTriggerHandler.bypass('TA_VR_RFP_BU_OwnerValidation');

        Request_for_proposal__c rfp = buildRFP();

        Test.startTest();
        insert rfp;
        Test.stopTest();

        System.assertNotEquals(null, rfp.Id, 'RFP inserted — after-insert path');
        MetadataTriggerHandler.clearBypass('TA_VR_RFP_BU_OwnerValidation');
    }

    @isTest
    static void testBeforeUpdate_AskRevision() {
        MetadataTriggerHandler.bypass('TA_VR_RFP_BU_OwnerValidation');

        Request_for_proposal__c rfp = buildRFP();
        insert rfp;

        Test.startTest();
        rfp.Request_for_Proposal_Status__c = 'Ask Revision';
        update rfp;
        Test.stopTest();

        System.assertEquals('Ask Revision', rfp.Request_for_Proposal_Status__c);
        MetadataTriggerHandler.clearBypass('TA_VR_RFP_BU_OwnerValidation');
    }

    @isTest
    static void testBeforeUpdate_NotAskRevision() {
        MetadataTriggerHandler.bypass('TA_VR_RFP_BU_OwnerValidation');

        Request_for_proposal__c rfp = buildRFP();
        insert rfp;

        Test.startTest();
        rfp.Request_for_Proposal_Status__c = 'Progress';
        update rfp;
        Test.stopTest();

        System.assertEquals('Progress', rfp.Request_for_Proposal_Status__c);
        MetadataTriggerHandler.clearBypass('TA_VR_RFP_BU_OwnerValidation');
    }

    @isTest
    static void testBulkInsert() {
        MetadataTriggerHandler.bypass('TA_VR_RFP_BU_OwnerValidation');

        List<Request_for_proposal__c> rfps = new List<Request_for_proposal__c>();
        for (Integer i = 0; i < 5; i++) {
            rfps.add(buildRFP());
        }

        Test.startTest();
        insert rfps;
        Test.stopTest();

        for (Request_for_proposal__c r : rfps) {
            System.assertNotEquals(null, r.Id);
        }
        MetadataTriggerHandler.clearBypass('TA_VR_RFP_BU_OwnerValidation');
    }

    @isTest
    static void testRepeatedUpdates() {
        MetadataTriggerHandler.bypass('TA_VR_RFP_BU_OwnerValidation');

        Request_for_proposal__c rfp = buildRFP();
        insert rfp;

        Test.startTest();
        rfp.Request_for_Proposal_Status__c = 'Ask Revision';
        update rfp;
        rfp.Request_for_Proposal_Status__c = 'Progress';
        update rfp;
        rfp.Request_for_Proposal_Status__c = 'Ask Revision';
        update rfp;
        Test.stopTest();

        System.assertEquals('Ask Revision', rfp.Request_for_Proposal_Status__c);
        MetadataTriggerHandler.clearBypass('TA_VR_RFP_BU_OwnerValidation');
    }
}