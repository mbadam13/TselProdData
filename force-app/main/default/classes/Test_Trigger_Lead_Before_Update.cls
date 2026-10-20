/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seealldata=true)
public class Test_Trigger_Lead_Before_Update {

    static testMethod void testMethod_Create_Lead() {
        Test.startTest();
        Request_for_proposal__c rfp = new Request_for_proposal__c();
        
        LIST<user> u=[SELECT id from user where username='andi_mario@telkomsel.co.id' LIMIT 1];
  
        Lead newlead = new Lead();
        newlead.LastName = 'TEst12';
        newlead.Status='New';
        newlead.Company='Jamet';
        newlead.legal_name__c= 'PT Jamet';
        newlead.LeadSource='Website';
        newlead.Account_Type__c='Advertiser';
        newlead.Rating='Hot';
        newlead.Email='test@jamet.com';
        Upsert newlead id;
        
        newlead.ownerid=u[0].id;
        Upsert newlead id;

        Test.stopTest();

    }
}