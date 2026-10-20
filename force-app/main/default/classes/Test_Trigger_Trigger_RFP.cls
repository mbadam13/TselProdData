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
public class Test_Trigger_Trigger_RFP {

    static testMethod void testMethod_Create_RFP() {
        Test.startTest();
        Request_for_proposal__c rfp = new Request_for_proposal__c();
        
        LIST<user> u=[SELECT id from user where username='andi_mario@telkomsel.co.id' LIMIT 1];
        List<Product2> prod=[SELECT id FROM Product2 where Name='BULK (SMS Basic)' LIMIT 1];
        List<PricebookEntry> pbe=[SELECT id FROM PricebookEntry where Product2Id=:prod[0].id LIMIT 1];
        Account acc = new Account ();
        
        Account A=[SELECT id from Account where Ownerid=:u[0].id LIMIT 1];
        acc = a;
        acc.npwp__c='123412';
        acc.Status__c='Approved by Settlement';
        upsert acc id;
        Contact cont = new Contact();
        cont.lastName ='Doddy';
        cont.accountid = acc.id;
        insert cont;
        
        Opportunity opp = new Opportunity();
        opp.name = 'TEst12';
        opp.StageName ='Prospecting';
        opp.CloseDate=system.today().adddays(10);
        opp.accountid = acc.id;
        Upsert opp id;
        
        opp.StageName ='Request for Proposal';
        Upsert opp id;
        
        List<Opportunity> LOppty=[SELECT id from Opportunity LIMIT 1];
        List<Contact> LContact=[SELECT id from contact LIMIT 1];
        rfp.Opportunity_Name__c=LOppty[0].id;
        rfp.Request_for_Proposal_Status__c='Request';
        rfp.Date__c=date.today();
        rfp.PIC_Client__c=LContact[0].id;
        rfp.Product__c='Banner';
        rfp.Buying_Method__c='Performance';
        rfp.Deadline__c=AppUtils.nextDate(date.today(), 5, false, false, false);
        rfp.default_deadline__c=AppUtils.nextDate(date.today(), 5, false, false, false);
        rfp.Project__c='try';
        rfp.Background__c='try';
        rfp.Campaign_Objective__c='try';
        rfp.KPI__c='try';
        rfp.Key_Message__c='try';
        rfp.Start_Period__c=date.today();
        rfp.End_Period__c=date.today();
        rfp.Campaign_Investment__c=1234567;
        rfp.Campaign_Media_Preferred_Inventory__c='try';
        rfp.Document_Version__c='Draft';
        insert rfp;
        
        rfp.Document_Version__c='Submit';
        update rfp;
        Test.stopTest();

    }
}