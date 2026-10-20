/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 08-14-2024
 * @last modified by  : Syaiful Syafani
**/
@isTest
public with sharing class Test_Trigger_Contact_After_Insert_v2 {
    @IsTest
    static void insertContact(){
        // === create contract ===
        Id accRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser').getRecordTypeId();
        Account accRec = new Account(
            Name                = 'Delight',
            Legal_Name__c       = 'Delight',
            Account_Type__c	    = 'Advertiser',
            RecordTypeId        = accRecordType,
            Brand_Category__c   = 'AUTOMOTIVE & ACCESSORIES'
        );
        Insert accRec;

        // === create lob ===
        LOB__c lobRec = new LOB__c(
            Name                = 'AUTOMOTIVE & ACCESSORIES',
            LOB_Unique_ID__c    = 'AUTOMOTIVE & ACCESSORIES',
            Active__c           = true
        );
        Insert lobRec;

        // === create contact ===
        Contact conRec = new Contact(
            LastName                = 'Adul',
            AccountId               = accRec.Id,
            Converted_from_Lead__c  = true,
            Active__c               = true
        );
        Test.startTest();
            Insert conRec;
        Test.stopTest();
    }
}