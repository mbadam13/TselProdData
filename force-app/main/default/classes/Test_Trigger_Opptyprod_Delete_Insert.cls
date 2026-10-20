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
public class Test_Trigger_Opptyprod_Delete_Insert {

    static testMethod void testMethod_Delete_OpportunityProduct() {
        Test.startTest();

        LIST<user> u=[SELECT id from user where username='andi_mario@telkomsel.co.id' LIMIT 1];
        List<Product2> prod=[SELECT id FROM Product2 where Name='SMS Bulk OTP' LIMIT 1];
        List<PricebookEntry> pbe=[SELECT id FROM PricebookEntry where Product2Id=:prod[0].id LIMIT 1];
        
        Account acc = new Account ();
        Account A=[SELECT id from Account where Ownerid=:u[0].id LIMIT 1];
        acc = a;

        Contact cont = new Contact();
        cont.lastName ='Doddy';
        cont.accountid = acc.id;
        insert cont;
        
        Opportunity opp = new Opportunity();
        opp.name = 'TEst';
        opp.StageName ='Prospecting';
        opp.accountid = acc.id;
        opp.Marketing_Package__c=FALSE;

        Pricebook2 PB=[SELECT id from PriceBook2 WHERE Name='Standard Price Book'];
        opp.Pricebook2id=PB.id;
        opp.CloseDate=system.today().adddays(10);
        opp.Approval_Status__c='Approved';
        opp.Check_PO__c='OK';
        
        Upsert opp;
        
        OpportunityLineItem oli =new OpportunityLineItem();
        oli.Product2id=prod[0].id;
        oli.Quantity=1000;
        oli.UnitPrice=100000;
        oli.PricebookEntryId=pbe[0].id;
        oli.opportunityid=opp.id;
        Upsert oli id;
        
        delete oli;
        Test.stopTest();

    }
}