/**
 * @description       : test data setup
 * @author            : RKA
 * @group             : 
 * @last modified on  : 07-16-2024
 * @last modified by  : RKA
**/
@IsTest
public without sharing class TestDataFactory {

    public static Lead createLead() {
        Lead tmpLead = new Lead();
        tmpLead.Company = 'test';
        tmpLead.Legal_Name__c = 'test';
        tmpLead.Status = 'New';
        tmpLead.Account_Type__c = 'Advertiser';
        tmpLead.LeadSource = 'Instagram';
        tmpLead.Rating = 'Warm';
        tmpLead.LastName = 'test';
        tmpLead.Email = 'test@mail.com';
        tmpLead.Phone = '087417234823448237';
        tmpLead.Description = 'test';
        return tmpLead;
    }
}