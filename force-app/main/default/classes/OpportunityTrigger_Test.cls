/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-18-2024
 * @last modified by  : Syaiful Syafani
**/
@isTest
public with sharing class OpportunityTrigger_Test {
    @isTest
    static void insertOppty(){
        // get profle
        Profile proRec = [SELECT Id FROM Profile WHERE Name = 'SALES'];

        // create user
        User userRec = new User(
            FirstName           = 'Admin',
            LastName            = 'TV Ads',
            NIK__c              = '22222',
            Username            = 'admintv@digiads.com.invalid',
            Alias               = 'AdmTV',
            EmailEncodingKey    = 'UTF-8',
            Email               = 'admintv@digiads.com.invalid',
            ProfileId           = proRec.Id,
            LocaleSidKey        = 'en_US',
            LanguageLocaleKey   = 'en_US',
            TimeZoneSidKey      = 'America/Los_Angeles'
        );
        Insert userRec;

        // create account
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Account accRec = new Account(
            Name                    = 'Wira Pamungkas Pratama',            
            RecordTypeId            = recordTypeAccId,             
            Account_Type__c         = 'Agency',              
            Direct_Indirect__c      = 'Direct',           
            Status__c               = 'Approved by Settlement',    
            No_PKS__c               = '123456',                    
            NPWP__c                 = '123456789012345',             
            PKS_Tracker__c          = 'Pending',         
            Reason_by_Settlement__c = 'Test',
            NPWP_Address__c         = 'Test'
        );
        Insert accRec;

        // create opportunity
        Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Opportunity oppRec = new Opportunity(
            RecordTypeId            = recordTypeOppId,                                                          
            Name                    = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',  
            AccountId               = accRec.Id,                                                                      
            CloseDate               = Date.valueOf('2024-09-21'),                                                  
            Account_Type__c         = 'Agency',                                                              
            StageName               = 'Proposal',                                                                  
            Regional__c             = 'HEAD OFFICE',                                                             
            Probability             = 100,                                                                       
            Agency_Name__c          = accRec.Id,                                                                 
            Campaign_Customize__c   = false,                                                           
            Templated_Proposal__c   = true,                                                            
            Approval_Remark__c      = 'Approved',                                                         
            Document_Version__c     = 'Submit',                                                          
            Approval_Status__c      = 'Approved',                                                         
            Marketing_Package__c    = false,                                                            
            SME__c                  = false,                                                                                                                            
            Type                    = 'Existing Business',                                                              
            Penagihan_based_on__c   = 'Postpaid',                                                      
            Performance_Product__c  = false,                                                          
            Programmatic_Product__c = false,                                                         
            Performance_Done__c     = false,                                                             
            RFP_Status_sales__c     = 'Completed',                                                       
            Check_PO__c             = 'OK',
            Pricebook2Id            = Test.getStandardPricebookId(),
            OwnerId                 = userRec.Id
        );

        Test.startTest();
            Insert oppRec;
        Test.stopTest();
    }
}