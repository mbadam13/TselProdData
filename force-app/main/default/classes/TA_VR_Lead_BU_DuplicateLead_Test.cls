/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-30-2024
 * @last modified by  : Bagus Aries Setiawan
**/
@isTest
public with sharing class TA_VR_Lead_BU_DuplicateLead_Test {
    @TestSetup
    static void makeData(){
        Lead lead1 = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Legal_Name__c = 'Test Legal Name',
            Status = 'Open',
            Email = 'test@invalid.com.invalid'
        ); 
        insert lead1;
    }

    @isTest
    static void testUpdateLead(){
        Lead updateLead = [SELECT Id, Legal_Name__c FROM Lead WHERE Legal_Name__c = 'Test Legal Name' LIMIT 1];
        updateLead.Legal_Name__c = 'Test Legal Name New';
        update updateLead;
    }

    @isTest
    static void testUpdateLeadWithExistingLead(){
        Lead lead2 = new Lead(
            FirstName = 'Test2',
            LastName = 'Lead2',
            Company = 'Test Company2',
            Legal_Name__c = 'Test Legal Name New',
            Status = 'Open',
            Email = 'test1@invalid.com.invalid'
        ); 
        insert lead2;
        Lead updateLead = [SELECT Id, Legal_Name__c FROM Lead WHERE Legal_Name__c = 'Test Legal Name' LIMIT 1];
        updateLead.Legal_Name__c = 'Test Legal Name New';

        Database.SaveResult sr = Database.update(updateLead, false);

        System.assertEquals('Unable to update leads because these leads already exist in Salesforce', sr.getErrors()[0].getMessage());
    }
}