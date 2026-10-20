@isTest
public class GenerateQuotationControllerTest {

    private static Account createAccount() {
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Advertiser').getRecordTypeId();
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
        return acc;
    }

    private static Contact createContact(Account acc) {
        Contact cont = new Contact(LastName = 'Doddy', AccountId = acc.Id);
        insert cont;
        return cont;
    }

    private static Brand__c createBrand(Account acc) {
        Brand__c brand = new Brand__c(
            Name = 'Test Brand',
            Advertiser__c = acc.Id,
            Status__c = 'Approved'
        );
        insert brand;
        brand.Status__c = 'Approved';
        update brand;
        return brand;
    }

    private static Contract createContract(Account acc) {
        Contract con = new Contract(
            AccountId = acc.Id,
            StartDate = Date.today(),
            ContractTerm = 12,
            Status = 'Draft'
        );
        insert con;
        con.Status = 'Activated';
        update con;
        return con;
    }

    private static Opportunity createOpportunity(Account acc, Brand__c brand, Contract con, PricebookEntry pbe) {
        Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Advertiser').getRecordTypeId();
        Opportunity opp = new Opportunity(
            Name = 'Test999',
            RecordTypeId = recordTypeOppId,
            StageName = 'Prospecting',
            AccountId = acc.Id,
            CloseDate = System.today().addDays(10),
            Brand__c = brand.Id,
            Regional__c = 'HEAD OFFICE',
            Type = 'Existing Business',
            Sales_Manager__c = UserInfo.getUserId(),
            Campaign_Name__c = 'Test Campaign'
        );
        insert opp;

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 5,
            TotalPrice = 100000,
            PricebookEntryId = pbe.Id
        );
        insert oli;

        opp.StageName = 'Closed Won';
        opp.Check_PO__c = 'OK';
        opp.ContractId = con.Id;
        update opp;
        return opp;
    }

    private static Product2 createProduct() {
        Product2 pro = new Product2(Name = 'Existing Product', Product_Category__c = 'Advertising', Business_Product__c = 'Digital Media', PIC_Product_Type__c = 'Performance');
        insert pro;
        return pro;
    }

    private static PricebookEntry createPricebookEntry(Product2 pro) {
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = '01s2v00000BrLSkAAN',
            Product2Id = pro.Id,
            UnitPrice = 100000,
            IsActive = true
        );
        insert pbe;
        return pbe;
    }

    private static Quote createQuote(Opportunity opp, Account acc, Contact cont, PricebookEntry pbe) {
        Quote qt = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            ContactId = cont.Id,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addDays(30),
            Pricebook2Id = pbe.Pricebook2Id
        );
        insert qt;
        return qt;
    }

    private static QuoteLineItem createQuoteLineItem(Quote qt, Product2 pro, PricebookEntry pbe) {
        QuoteLineItem qli = new QuoteLineItem(
            QuoteId = qt.Id,
            Product2Id = pro.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1000,
            UnitPrice = 100000,
            Remarks__c = 'Test Remarks'
        );
        insert qli;
        return qli;
    }

    @isTest
    static void testMethod_Quotation_IDR() {
        Account acc = createAccount();
        Contact cont = createContact(acc);
        Brand__c brand = createBrand(acc);
        Contract con = createContract(acc);
        Product2 pro = createProduct();
        PricebookEntry pbe = createPricebookEntry(pro);
        Opportunity opp = createOpportunity(acc, brand, con, pbe);
        Quote qt = createQuote(opp, acc, cont, pbe);
        QuoteLineItem qli = createQuoteLineItem(qt, pro, pbe);

        Test.startTest();
        ApexPages.StandardController ssc = new ApexPages.StandardController(qt);
        GenerateQuotationController gsc = new GenerateQuotationController(ssc);
        Test.stopTest();

        System.assertNotEquals(null, gsc.grandTotal);
        System.assertEquals(100000000, gsc.grandTotal);
    }

    @isTest
    static void testMethod_Quotation_USD() {
        Account acc = createAccount();
        Contact cont = createContact(acc);
        Brand__c brand = createBrand(acc);
        Contract con = createContract(acc);
        Product2 pro = createProduct();
        PricebookEntry pbe = createPricebookEntry(pro);
        Opportunity opp = createOpportunity(acc, brand, con, pbe);
        Quote qt = createQuote(opp, acc, cont, pbe);
        QuoteLineItem qli = createQuoteLineItem(qt, pro, pbe);

        Test.startTest();
        ApexPages.StandardController ssc = new ApexPages.StandardController(qt);
        ApexPages.currentPage().getParameters().put('mode', 'USD');
        GenerateQuotationController gsc = new GenerateQuotationController(ssc);
        Test.stopTest();

        System.assertNotEquals(null, gsc.grandTotal);
        System.assertEquals(100000000, gsc.grandTotal);
        System.assertEquals('USD', gsc.mode);
    }
}