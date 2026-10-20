@isTest
public class GenerateSOAControllerTest {

    static testMethod void testMethod_Generate_SOA() {
        // Get RecordTypes
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser').getRecordTypeId();
        Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Advertiser').getRecordTypeId();

        // 1. Account
        Account acc = new Account(
            Name = 'Test Account',
            RecordTypeId = recordTypeAccId,
            Legal_Name__c = 'Test Legal',
            Account_Type__c = 'Advertiser',
            Direct_Indirect__c = 'Direct',
            Status__c = 'Approved by Settlement',
            No_PKS__c = '123456',
            NPWP__c = '1234567890123456',
            NPWP_Address__c = 'Jakarta',
            PKS_Tracker__c = 'Pending',
            Reason_by_Settlement__c = 'Test'
        );
        TriggerBase.bypass('Account');
        insert acc;
        TriggerBase.clearBypass('Account');

        // 2. Contact
        Contact cont = new Contact(LastName = 'Doddy', AccountId = acc.Id);
        insert cont;

        // 3. Brand
        Brand__c brand = new Brand__c(
            Name = 'Test Brand',
            Advertiser__c = acc.Id,
            Status__c = 'Approved'
        );
        insert brand;
        brand.Status__c = 'Approved';
        update brand;

        // 4. Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test999',
            RecordTypeId = recordTypeOppId,
            StageName = 'Prospecting',
            AccountId = acc.Id,
            CloseDate = System.today().addDays(10),
            Brand__c = brand.Id,
            Regional__c = 'HEAD OFFICE',
            Type = 'Existing Business'
        );
        insert opp;

        // 5. Pricebook & Product
        Pricebook2 priceBook = new Pricebook2(Name = 'Standard Price Book');
        insert priceBook;

        Product2 pro = new Product2(Name = 'Existing Product', Product_Category__c = 'Advertising', Business_Product__c = 'Digital Media', PIC_Product_Type__c = 'Performance');
        insert pro;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = '01s2v00000BrLSkAAN',
            Product2Id = pro.Id,
            UnitPrice = 100000,
            IsActive = true
        );
        insert pbe;

        OpportunityLineItem oppProduct = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 5,
            TotalPrice = 100000,
            PricebookEntryId = pbe.Id
        );
        insert oppProduct;

        // Update Opp to Closed Won (required before creating SOA)
        Contract con = new Contract(
            AccountId = acc.Id,
            StartDate = Date.today(),
            ContractTerm = 12,
            Status = 'Draft'
        );
        insert con;
        con.Status = 'Activated';
        update con;

        acc.ContractId__c = con.Id;
        update acc;

        opp.StageName = 'Closed Won';
        opp.Check_PO__c = 'OK';
        update opp;

        // 6. SOA
        SOA__c newSOA = new SOA__c(
            Opportunity__c = opp.Id,
            SOA_Start_Date__c = Date.today(),
            SOA_End_Date__c = Date.today(),
            Attention__c = cont.Id
        );
        insert newSOA;

        // 7. SOA Detail
        SOA_Detail__c newSOADetail = new SOA_Detail__c(
            SOA__c = newSOA.Id,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today(),
            Campaign_ID__c = newSOA.Name + '_' + '001' + '_' + 1,
            PricebookEntryId__c = pbe.Id,
            Product__c = pro.Id,
            Quantity__c = 1000,
            Unit_Price__c = 100000
        );
        insert newSOADetail;

        // Perform the Test
        Test.startTest();
        ApexPages.StandardController ssc = new ApexPages.StandardController(newSOA);
        GenerateSOAController gsc = new GenerateSOAController(ssc);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, gsc.grandTotal);
        System.assertEquals(100000000, gsc.grandTotal);
    }
}