/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-30-2024
 * @last modified by  : Syaiful Syafani
**/
@isTest
public with sharing class LeadService_Test {
    @TestSetup
    static void makeData(){
        Lead leadExisting = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Legal_Name__c = 'Test Legal Name',
            Status = 'Open',
            Email = 'test@invalid.com.invalid'
        ); 
        insert leadExisting;
    }

    @isTest
    static void testInsertNewLead(){
        Lead newLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Legal_Name__c = 'Test Legal Name',
            Status = 'Open',
            Email = 'test@invalid.com.invalid'
        );
        Database.SaveResult sr = Database.insert(newLead, false);

        System.assertEquals('Unable to input leads because these leads already exist in Salesforce', sr.getErrors()[0].getMessage());
    }
}