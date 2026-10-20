@isTest
public class Test_DataPerformanceCampaign_Controller {
    
    static testMethod void test_dpcController(){
        
        // --- Create Account --- //
        RecordType accountRecType = [SELECT Id, Name FROM RecordType WHERE Name = 'Advertiser' LIMIT 1];
        system.debug('>>> accountRecType = ' + accountRecType);
        
        Account acc_adv = new Account();
        acc_adv.Name = 'Account ADV';
        acc_adv.Account_Type__c = 'Advertiser';
        insert acc_adv;
        
        
        // --- Create Product --- //
        List<Product2> data_productList = new List<Product2>();
        
        Product2 prod1 = new Product2();
        prod1.Name = 'Performance CPI (All Industries)';
        prod1.ProductCode = 'Performance';
        prod1.Product_Type__c = 'All';
        prod1.Buying_Method__c = 'Performance';
        prod1.Family = 'All';
        prod1.IsActive = true;
        prod1.Product_Category__c = 'Advertising';
        data_productList.add(prod1);
        
        Product2 prod2 = new Product2();
        prod2.Name = 'Performance CPL (All Industries)';
        prod2.ProductCode = 'Performance';
        prod2.Product_Type__c = 'All';
        prod2.Buying_Method__c = 'Performance';
        prod2.Family = 'All';
        prod2.IsActive = true;
        prod2.Product_Category__c = 'Advertising';
        data_productList.add(prod2);
        
        Product2 prod3 = new Product2();
        prod3.Name = 'Performance CPA (All Industries)';
        prod3.ProductCode = 'Performance';
        prod3.Product_Type__c = 'All';
        prod3.Buying_Method__c = 'Performance';
        prod3.Family = 'All';
        prod3.IsActive = true;
        prod3.Product_Category__c = 'Advertising';
        data_productList.add(prod3);
        
        Product2 prod4 = new Product2();
        prod4.Name = 'Performance CPA (F&B)';
        prod4.ProductCode = 'Performance';
        prod4.Product_Type__c = 'All';
        prod4.Buying_Method__c = 'Performance';
        prod4.Family = 'All';
        prod4.IsActive = true;
        prod4.Product_Category__c = 'Advertising';
        data_productList.add(prod4);
        
        Product2 prod5 = new Product2();
        prod5.Name = 'Performance CPA (FMCG)';
        prod5.ProductCode = 'Performance';
        prod5.Product_Type__c = 'All';
        prod5.Buying_Method__c = 'Performance';
        prod5.Family = 'All';
        prod5.IsActive = true;
        prod5.Product_Category__c = 'Advertising';
        data_productList.add(prod5);
        
        Product2 prod6 = new Product2();
        prod6.Name = 'GITA | 1 GB 30 days';
        prod6.ProductCode = 'Reward';
        prod6.Product_Type__c = 'Data Reward';
        prod6.Buying_Method__c = 'I/O';
        prod6.Family = 'Data Reward';
        prod6.IsActive = true;
        prod6.Product_Category__c = 'Advertising';
        data_productList.add(prod6);
        
        insert data_productList;
        
        // --- Create PricebookEntry --- //
        List<PricebookEntry> pbeList = new List<PricebookEntry> ();
        
        PricebookEntry pbe_std_1 = new PricebookEntry();
		pbe_std_1.IsActive = true;
		pbe_std_1.Product2Id = prod1.Id;
		pbe_std_1.Pricebook2Id = Test.getStandardPricebookId();
     	pbe_std_1.UnitPrice = 500;
     	pbeList.add(pbe_std_1);
        
        PricebookEntry pbe_std_2 = new PricebookEntry();
		pbe_std_2.IsActive = true;
		pbe_std_2.Product2Id = prod2.Id;
		pbe_std_2.Pricebook2Id = Test.getStandardPricebookId();
     	pbe_std_2.UnitPrice = 30;
     	pbeList.add(pbe_std_2);
        
        PricebookEntry pbe_std_3 = new PricebookEntry();
		pbe_std_3.IsActive = true;
		pbe_std_3.Product2Id = prod3.Id;
		pbe_std_3.Pricebook2Id = Test.getStandardPricebookId();
     	pbe_std_3.UnitPrice = 50000;
     	pbeList.add(pbe_std_3);
        
        PricebookEntry pbe_std_4 = new PricebookEntry();
		pbe_std_4.IsActive = true;
		pbe_std_4.Product2Id = prod4.Id;
		pbe_std_4.Pricebook2Id = Test.getStandardPricebookId();
     	pbe_std_4.UnitPrice = 950;
     	pbeList.add(pbe_std_4);
        
        PricebookEntry pbe_std_5 = new PricebookEntry();
		pbe_std_5.IsActive = true;
		pbe_std_5.Product2Id = prod5.Id;
		pbe_std_5.Pricebook2Id = Test.getStandardPricebookId();
     	pbe_std_5.UnitPrice = 950;
     	pbeList.add(pbe_std_5);
        
        PricebookEntry pbe_std_6 = new PricebookEntry();
		pbe_std_6.IsActive = true;
		pbe_std_6.Product2Id = prod6.Id;
		pbe_std_6.Pricebook2Id = Test.getStandardPricebookId();
     	pbe_std_6.UnitPrice = 950;
     	pbeList.add(pbe_std_6);
        
        insert pbeList;
        
        // --- Create Opportunity --- //
        Opportunity opp_adv = new Opportunity();
        opp_adv.Name = 'Test Adv Opp';
        opp_adv.AccountId = acc_adv.Id;
        opp_adv.Account_Type__c = 'Advertiser';
        opp_adv.CloseDate = system.today();
        opp_adv.StageName = 'Prospecting';
        opp_adv.Penagihan_based_on__c = 'Postpaid';
        opp_adv.Templated_Proposal__c = true;
        insert opp_adv; 
        
        opp_adv.StageName = 'Visit / Call';
        opp_adv.Pricebook2Id = Test.getStandardPricebookId();
        update opp_adv;
        
        // --- Create OpportunityLineItem --- //
        List<OpportunityLineItem> oliListToInsert = new List<OpportunityLineItem>();
        
        OpportunityLineItem oli_prod1 = new OpportunityLineItem();
        oli_prod1.OpportunityId = opp_adv.Id;
        oli_prod1.Product2Id = data_productList[0].Id;
        oli_prod1.UnitPrice = 500;
        oli_prod1.PricebookEntryId = pbeList[0].Id;
        oli_prod1.Quantity = 100;
        oliListToInsert.add(oli_prod1);
        
        OpportunityLineItem oli_prod2 = new OpportunityLineItem();
        oli_prod2.OpportunityId = opp_adv.Id;
        oli_prod2.Product2Id = data_productList[1].Id;
        oli_prod2.UnitPrice = 600;
        oli_prod2.PricebookEntryId = pbeList[1].Id;
        oli_prod2.Quantity = 200;
        oliListToInsert.add(oli_prod2);
        
        OpportunityLineItem oli_prod3 = new OpportunityLineItem();
        oli_prod3.OpportunityId = opp_adv.Id;
        oli_prod3.Product2Id = data_productList[2].Id;
        oli_prod3.UnitPrice = 700;
        oli_prod3.PricebookEntryId = pbeList[2].Id;
        oli_prod3.Quantity = 300;
        oliListToInsert.add(oli_prod3);
        
        OpportunityLineItem oli_prod4 = new OpportunityLineItem();
        oli_prod4.OpportunityId = opp_adv.Id;
        oli_prod4.Product2Id = data_productList[3].Id;
        oli_prod4.UnitPrice = 500;
        oli_prod4.PricebookEntryId = pbeList[3].Id;
        oli_prod4.Quantity = 200;
        oliListToInsert.add(oli_prod4);
        
        OpportunityLineItem oli_prod5 = new OpportunityLineItem();
        oli_prod5.OpportunityId = opp_adv.Id;
        oli_prod5.Product2Id = data_productList[4].Id;
        oli_prod5.UnitPrice = 650;
        oli_prod5.PricebookEntryId = pbeList[4].Id;
        oli_prod5.Quantity = 200;
        oliListToInsert.add(oli_prod5);
        
        OpportunityLineItem oli_prod6 = new OpportunityLineItem();
        oli_prod6.OpportunityId = opp_adv.Id;
        oli_prod6.Product2Id = data_productList[5].Id;
        oli_prod6.UnitPrice = 200;
        oli_prod6.PricebookEntryId = pbeList[5].Id;
        oli_prod6.Quantity = 100;
        oliListToInsert.add(oli_prod6);
        
        insert oliListToInsert;
        
        /*List<Performance_Campaign__c> pcList = [SELECT Id, Name FROM Performance_Campaign__c];
        system.debug('*** pcList = ' + pcList.size() + ' | ' + pcList);*/
        
        // --- Create Performance Campaign --- //
        Performance_Campaign__c pc_rec = new Performance_Campaign__c();
        pc_rec.Opportunity__c = opp_adv.Id;
        pc_rec.Campaign_Name__c = opp_adv.Id;
        pc_rec.Start_Periode__c = system.today();
        pc_rec.End_Periode__c = system.today().addDays(7);
        pc_rec.Campaign_Type__c = 'CPI;CPL;CPA';
        insert pc_rec;
        
        // --- Create Data Performance Campaign --- //
        Data_Performance_Campaign__c dpc_rec = new Data_Performance_Campaign__c();
        dpc_rec.Performance_Campaign__c = pc_rec.Id;
        dpc_rec.Date__c = system.today();
		dpc_rec.Harga_COGS_SMS__c = 15;
		dpc_rec.Impression__c = 1000;
        dpc_rec.Install__c = 2;
        dpc_rec.Register_Leads__c = 3;
        dpc_rec.Acquisition_All_Industries__c = 4;
        dpc_rec.Acquisition_F_B__c = 3;
        dpc_rec.Acquisition_FMCG__c = 2;
		dpc_rec.GITA_1_GB_30_days__c = 5;        
        insert dpc_rec;
        
        PageReference pr_datapc = Page.DataPerformanceCampaign_Page;
        pr_datapc.getParameters().put('Id',pc_rec.Id);
        Test.setCurrentPage(pr_datapc);
        
        DataPerformanceCampaign_Controller dpcCon = new DataPerformanceCampaign_Controller();
        dpcCon.cancelButton();
        
        dpcCon.param_dpcId = dpc_rec.Id;
        dpcCon.editLink();
        
        dpcCon.addButton();
        dpcCon.saveButton();
        dpcCon.GetProductTargetPrice();
        dpcCon.updateHPC();
        
    }

}