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
public class Test_GenerateSOAController {

    static testMethod void testMethod_Generate_SOA() {
        Test.startTest();
        
        LIST<user> u=[SELECT id from user where username='andi_mario@telkomsel.co.id' LIMIT 1];
        
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

        Pricebook2 PB=[SELECT id from PriceBook2 WHERE Name='Standard Price Book'];
        opp.Pricebook2id=PB.id;
        opp.CloseDate=system.today().adddays(10);
        opp.Approval_Status__c='Approved';
        opp.Check_PO__c='OK';
        Upsert opp;
        
        opp.StageName ='Closed Won';
        Upsert opp id;
          
        //Contract
        Contract newContract = new Contract();
        newContract.StartDate= date.today();
        newContract.ContractTerm= 1;
        newContract.Opportunity__c=opp.id;
        newContract.AccountId=acc.id;
        upsert newContract;
        
        List<Contract> LContract=[SELECT id from Contract where Opportunity__c=:opp.id LIMIT 1];
       
        //List<OrderItem> LOrderItem=[SELECT id,campaign_id__c from OrderItem where campaign_id__c!=null LIMIT 1];
        
        List<Product2> prod=[SELECT id FROM Product2 where Name='Targeted SMS Basic' LIMIT 1];
        List<PricebookEntry> pbe=[SELECT id FROM PricebookEntry where Product2Id=:prod[0].id LIMIT 1];
        
        //SOA
        SOA__c newSOA = new SOA__c();
        newSOA.SOA_Start_Date__c= date.today();
        newSOA.SOA_End_Date__c= date.today();
        newSOA.Opportunity__c=opp.id;

        Upsert newSOA;

        List<SOA__c> lnewsoa=[SELECT id,name FROM SOA__c where id=:newSOA.id LIMIT 1];
        
        //SOA Detail
        SOA_Detail__c newSOADetail = new SOA_Detail__c();
        newSOADetail.Start_Date__c= date.today();
        newSOADetail.End_Date__c= date.today();
        newSOADetail.SOA__c=newSOA.id;
        newSOADetail.Campaign_ID__c=lnewsoa[0].Name+'_'+'001'+'_'+1;
        newSOADetail.PricebookEntryId__c=pbe[0].id;
        newSOADetail.product__c=prod[0].id;
        newSOADetail.Quantity__c=1000;
        newSOADetail.Unit_Price__c=100000;

        Upsert newSOADetail;
        system.debug('isi debug newSOADetail'+newSOADetail.name);
       
       List<SOA_Detail__c> lnewsoadetails=[SELECT id,name,campaign_id__c FROM SOA_Detail__c where soa__c=:newSOA.id];
       system.debug('size lnewsoadetails'+lnewsoadetails.size());
       
       //buat panggil Generatesoa
       ApexPages.StandardController ssc = new ApexPages.StandardController(newSOA);
        GenerateSOAController gsc = new GenerateSOAController(ssc);
        Test.stopTest();

    }
}