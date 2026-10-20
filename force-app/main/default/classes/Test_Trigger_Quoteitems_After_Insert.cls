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
public class Test_Trigger_Quoteitems_After_Insert {

    static testMethod void testMethod_Create_Quote_lineitems() {
        Test.startTest();
        List <QuoteLineItem> QuoteItemlist = new List <QuoteLineItem>();
        
        LIST<user> u=[SELECT id from user where username='andi_mario@telkomsel.co.id' LIMIT 1];
        List<Product2> prod=[SELECT id FROM Product2 where Name='SMS Bulk OTP' LIMIT 1];
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
        opp.name = 'TEst';
        opp.StageName ='Prospecting';
        opp.Penagihan_based_on__c='Prepaid';
        opp.accountid = acc.id;

        Pricebook2 PB=[SELECT id from PriceBook2 WHERE Name='Standard Price Book'];
        opp.Pricebook2id=PB.id;
        opp.CloseDate=system.today().adddays(10);
        opp.Approval_Status__c='Approved';
        opp.Check_PO__c='OK';
        Upsert opp;
                
        opp.StageName ='Closed Won';
        Upsert opp id;
        List<Opportunity> Oppty=[SELECT id from Opportunity where Penagihan_based_on__c='Prepaid' LIMIT 1];
        
        OpportunityLineItem oli =new OpportunityLineItem();
        oli.Product2id=prod[0].id;
        oli.Quantity=1000;
        oli.UnitPrice=100000;
        oli.PricebookEntryId=pbe[0].id;
        oli.opportunityid=opp.id;
        Upsert oli id;
        
        //Contract
        Contract newContract = new Contract();
        newContract.StartDate= system.today();
        newContract.ContractTerm= 1;
        newContract.Opportunity__c=opp.id;
        newContract.AccountId=acc.id;
        upsert newContract;
        
        newContract.Status='Activated';
        upsert newContract id;
        
        Quote qt = new Quote();
        qt.Name='a';
        qt.OpportunityId=opp.id;
        qt.Start_Date__c=system.today().adddays(1);
        qt.End_Date__c=system.today().adddays(10);
        qt.ExpirationDate=system.today().adddays(1);
        upsert qt;
        
        qt.Upload_Bukti_Pembayaran__c = TRUE;
        qt.Status='Final';
        update qt;
        
        List<OpportunityLineItem> orderlis = [SELECT Id,OpportunityId,UnitPrice,Quantity,PricebookEntryId,Product_id_number__c,opportunity.Pricebook2Id FROM OpportunityLineItem LIMIT 1];
        List<Quote> Qto=[SELECT id from Quote LIMIT 1];
        for(OpportunityLineItem thisItem : orderlis)
        {
            QuoteLineItem newOi = new QuoteLineItem(UnitPrice= thisItem.UnitPrice,Quantity = 100,PricebookEntryId = thisItem.PricebookEntryId,QuoteId=Qto[0].id);
            QuoteItemlist.add(newOi);
        }
        upsert QuoteItemlist;
        Test.stopTest();

    }
}