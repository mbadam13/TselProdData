@isTest(seeAlldata=true)
public class Test_REST_CheckStatus_PrivyID_SOAClass {
  public static testMethod void testMethod_CheckStatus_PrivyID_SOA() {
 
    //Create SOA
        //Test.startTest();
        
        LIST<user> u=[SELECT id from user where username='dev1@telkomsel.co.id' LIMIT 1];
        
        Account acc = new Account ();
        acc.Name='Suka Selalu Aka';
        insert acc;

        Contact cont = new Contact();
        cont.lastName ='Doddy';
        cont.accountid = acc.id;
        insert cont;
        
        Opportunity opp = new Opportunity();
        opp.name = 'TEst';
        opp.StageName ='Prospecting';
        opp.accountid = acc.id;

        Pricebook2 PB=[SELECT id from PriceBook2 limit 1];
        opp.Pricebook2id=PB.id;
        opp.CloseDate=system.today().adddays(10);
        opp.Approval_Status__c='Approved';
        opp.Check_PO__c='OK';
        Upsert opp;
        
        
        //SOA
        SOA__c newSOA = new SOA__c();
        newSOA.SOA_Start_Date__c= date.today();
        newSOA.SOA_End_Date__c= date.today();
        newSOA.Opportunity__c=opp.id;
        newSOA.docToken__c=Label.docToken_Test;
        Upsert newSOA;
    
    Test.startTest();
     ApexPages.StandardController ssc = new ApexPages.StandardController(newSOA);
     REST_PrivyID_Check_Doc_Status extension = new REST_PrivyID_Check_Doc_Status(ssc);
     extension.CheckDocument();
     extension.back();
     Test.stopTest();
  }
}