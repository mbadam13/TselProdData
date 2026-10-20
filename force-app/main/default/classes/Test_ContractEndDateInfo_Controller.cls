@isTest
public class Test_ContractEndDateInfo_Controller {
    
    static testMethod void testCEDInfo(){
        Account acc = new Account();
        acc.Name = 'Acc ABC';
        acc.Status__c = 'Approved by Settlement';
        acc.NPWP__c = '1234';
        insert acc; 
        system.debug('>>> acc = ' + acc);
        
        Contract contractRec = new Contract();
        contractRec.AccountId = acc.Id;
        contractRec.Status = 'Draft';
        contractRec.StartDate = system.today().addDays(-30); 
        contractRec.ContractTerm = 1;
        insert contractRec; 
        
        contractRec.status = 'Activated';
        Upsert contractRec;
        
        Contact contactRec = new Contact();
        contactRec.AccountId = acc.Id;       // Account Name
        contactRec.Title = 'VP Marketing';          // Title
        contactRec.Email = 'rina@aksimuda.id';      // Email
        contactRec.MobilePhone = '08111998020';     // Mobile
        contactRec.Active__c = false;               // Active?
        contactRec.Converted_from_Lead__c = false;  // Converted from Lead
        contactRec.LastName = 'rina';
        insert contactRec;
        
        LOB__c LOB = new LOB__c();
        LOB.Name = 'abc';
        LOB.Active__c = TRUE;
        Insert LOB;
        
        Brand__c Brand = new Brand__c();
        Brand.Name = 'abc';
        Brand.PIC_Advertiser__c = contactRec.id;
        Brand.Brand_Category__c = LOB.id;
        insert Brand;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.AccountId = acc.Id;
        opp.Account_Type__c = 'Advertiser';
        opp.CloseDate = system.today();
        opp.StageName = 'Prospecting';
        opp.ContractId = contractRec.id;
        opp.Brand__c = Brand.id;
        insert opp; 
        system.debug('>>> opp = ' + opp.Display_Contract_End_Date_Info__c);
        
        opp.Templated_Proposal__c = true;
        update opp;
        
        opp.StageName = 'Visit / Call';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
        
        List<Product2> prodListToInsert = new List<Product2>();
        
        Product2 prod1 = new Product2();
        prod1.Name = 'BULK (SMS)';
        prod1.QuantityUnitOfMeasure = '123';
        prod1.ProductCode = 'Messaging';
        prod1.Product_Type__c = 'SMS';
        prod1.Buying_Method__c = 'I/O';
        prod1.Product_Category__c = 'RCS';
        prod1.Family = 'SMS';
        prod1.IsActive = true;
        prodListToInsert.add(prod1);
        
        Product2 prod2 = new Product2();
        prod2.Name = 'FRIDA | 3.001 - 10.000 GB';
        prod2.ProductCode = 'Reward';
        prod2.QuantityUnitOfMeasure = '123';
        prod2.Product_Type__c = 'Data Reward';
        prod2.Buying_Method__c = 'I/O';
        prod2.Family = 'Data Reward';
        prod2.Product_Category__c = 'RCS';
        prod2.IsActive = true;
        prodListToInsert.add(prod2);
        
        Product2 prod3 = new Product2();
        prod3.Name = 'GITA | 3 GB 30 days';
        prod3.ProductCode = 'Reward';
        prod3.QuantityUnitOfMeasure = '123';
        prod3.Product_Type__c = 'Data Reward';
        prod3.Buying_Method__c = 'I/O';
        prod3.Family = 'Data Reward';
        prod3.Product_Category__c = 'RCS';
        prod3.IsActive = true;
        prodListToInsert.add(prod3);
        
        Product2 prod4 = new Product2();
        prod4.Name = 'IVR Bulk Advertising';
        prod4.ProductCode = 'Messaging';
        prod4.QuantityUnitOfMeasure = '123';
        prod4.Product_Type__c = 'IVR';
        prod4.Buying_Method__c = 'I/O';
        prod4.Family = 'IVR';
        prod4.Product_Category__c = 'RCS';
        prod4.IsActive = true;
        prodListToInsert.add(prod4);
        
        insert prodListToInsert;
        system.debug('>>> prodListToInsert.size() = ' + prodListToInsert.size());
        system.debug('>>> prodListToInsert = ' + prodListToInsert);
        
        List<PricebookEntry> pbeListToInsert = new List<PricebookEntry> ();
        
        PricebookEntry pbe_std_1 = new PricebookEntry();
        pbe_std_1.IsActive = true;
        pbe_std_1.Product2Id = prod1.Id;
        pbe_std_1.Pricebook2Id = Test.getStandardPricebookId();
        pbe_std_1.UnitPrice = 500;
        pbeListToInsert.add(pbe_std_1);
        
        PricebookEntry pbe_std_2 = new PricebookEntry();
        pbe_std_2.IsActive = true;
        pbe_std_2.Product2Id = prod2.Id;
        pbe_std_2.Pricebook2Id = Test.getStandardPricebookId();
        pbe_std_2.UnitPrice = 30;
        pbeListToInsert.add(pbe_std_2);
        
        PricebookEntry pbe_std_3 = new PricebookEntry();
        pbe_std_3.IsActive = true;
        pbe_std_3.Product2Id = prod3.Id;
        pbe_std_3.Pricebook2Id = Test.getStandardPricebookId();
        pbe_std_3.UnitPrice = 50000;
        pbeListToInsert.add(pbe_std_3);
        
        PricebookEntry pbe_std_4 = new PricebookEntry();
        pbe_std_4.IsActive = true;
        pbe_std_4.Product2Id = prod4.Id;
        pbe_std_4.Pricebook2Id = Test.getStandardPricebookId();
        pbe_std_4.UnitPrice = 950;
        pbeListToInsert.add(pbe_std_4);
        
        insert pbeListToInsert;
        system.debug('>>> pbeListToInsert.size() = ' + pbeListToInsert.size());
        system.debug('>>> pbeListToInsert = ' + pbeListToInsert);
        
        PERFORMANCE_Campaign__c pc_rec = new PERFORMANCE_Campaign__c();
        pc_rec.Campaign_Name__c = opp.Id;
        pc_rec.Opportunity__c = opp.Id;
        pc_rec.Start_Periode__c = system.today();
        pc_rec.End_Periode__c = system.today().addDays(10);
        pc_rec.Campaign_Type__c = 'CPL';
        insert pc_rec;
        
        delete pc_rec;
        
        Test.startTest();
        
        List<Contact> ctList = [SELECT Id, Name FROM Contact ORDER BY CreatedDate ASC];
        
        List<Opportunity> oppList = [SELECT Id, Name, AccountId, Account_Type__c, CloseDate, StageName FROM Opportunity ORDER BY CreatedDate ASC];
        
        List<Product2> prodList = [SELECT Id, Name, ProductCode, Product_Type__c, Buying_Method__c, Family, IsActive FROM Product2 ORDER BY CreatedDate ASC];
        
        List<PricebookEntry> pbeList = [SELECT Id, IsActive, Product2Id, Pricebook2Id, UnitPrice FROM PricebookEntry ORDER BY CreatedDate ASC];
        
        List<OpportunityLineItem> oliListToInsert = new List<OpportunityLineItem>();
        
        OpportunityLineItem oli_prod1 = new OpportunityLineItem();
        oli_prod1.OpportunityId = oppList[0].Id;
        oli_prod1.Product2Id = prodList[0].Id;
        oli_prod1.UnitPrice = 500;
        oli_prod1.PricebookEntryId = pbeList[0].Id;
        oli_prod1.Quantity = 100;
        oliListToInsert.add(oli_prod1);
        
        insert oliListToInsert;
        system.debug('>>> oliListToInsert.size() = ' + oliListToInsert.size());
        system.debug('>>> oliListToInsert = ' + oliListToInsert);
        
        oppList[0].Type = 'Existing Business';
        oppList[0].Penagihan_based_on__c = 'Prepaid';
        oppList[0].StageName = 'Negotiation';
        update oppList[0];
        
        oppList[0].StageName = 'Proposal';
        oppList[0].isSubmitCheckPOApproval__c = true;
        oppList[0].Approval_Status__c = 'Approved';
        oppList[0].Check_PO__c = 'OK';
        update oppList[0];
        
        oppList[0].StageName = 'Closed Won';
        update oppList[0];
        
        Quote quotation_Rec = new Quote();
        quotation_Rec.Name = 'Test 123';
        quotation_Rec.OpportunityId = opp.id;
        quotation_Rec.ContactId = contactRec.id;
        quotation_Rec.Start_Date__c = date.newInstance(2022, 8, 26);
        quotation_Rec.End_Date__c = date.newInstance(2022, 11, 9);
        insert quotation_Rec;
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(opp.Id));
        ContractEndDateInfo_Controller testContract = new ContractEndDateInfo_Controller();
        
        //=====================================================================================================================================        
        
        contractRec.StartDate = system.today().addDays(-40);
        update contractRec;
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(opp.Id));
        ContractEndDateInfo_Controller testContract2 = new ContractEndDateInfo_Controller();
        
        contractRec.StartDate = system.today().addDays(-20);
        update contractRec;
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(opp.Id));
        ContractEndDateInfo_Controller testContract3 = new ContractEndDateInfo_Controller();
        
        //=====================================================================================================================================                
        
        Test.stopTest();      
    }
}