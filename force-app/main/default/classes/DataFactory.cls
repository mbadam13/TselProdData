@isTest
public class DataFactory {
    
	public List<Account> createAccount(){
        system.debug('>>> Masuk createAccount !!!');
        
        RecordType accountRecType = [SELECT Id, Name FROM RecordType WHERE Name = 'Media Seller'];
        system.debug('>>> accountRecType = ' + accountRecType);
        
        List<Account> data_accountList = new List<Account>();
        
        Account acc_ds = new Account();
        acc_ds.Name = 'Account DS';
        acc_ds.Account_Type__c = 'Direct Sales';
        insert acc_ds;
        data_accountList.add(acc_ds);
        
        Account acc_dws = new Account();
        acc_dws.Name = 'DWS';
        acc_dws.Account_Type__c = 'Media Seller';
        acc_dws.RecordTypeId = accountRecType.Id;
        acc_dws.Active__c = true;
        insert acc_dws;
        data_accountList.add(acc_dws);
        
        Account acc_mus = new Account();
        acc_mus.Name = 'Mustika';
        acc_mus.Account_Type__c = 'Media Seller';
        acc_mus.RecordTypeId = accountRecType.Id;
        acc_mus.Active__c = true;
        insert acc_mus;
        data_accountList.add(acc_mus);
        
        return data_accountList;
    }
    
    public List<Product2> createProduct(){
        system.debug('>>> Masuk createProduct !!!');
		
		List<Product2> data_productList = new List<Product2>();
        
		Product2 prod1 = new Product2();
        prod1.Name = 'BULK (SMS)';
        prod1.ProductCode = 'Messaging';
        prod1.Product_Type__c = 'SMS';
        prod1.Buying_Method__c = 'I/O';
        prod1.Family = 'SMS';
        prod1.IsActive = true;
        prod1.Product_Name_MS__c = 'BULK (SMS)';
        data_productList.add(prod1);
        
        Product2 prod2 = new Product2();
        prod2.Name = 'FRIDA | 3.001 - 10.000 GB';
        prod2.ProductCode = 'Reward';
        prod2.Product_Type__c = 'Data Reward';
        prod2.Buying_Method__c = 'I/O';
        prod2.Family = 'Data Reward';
        prod2.IsActive = true;
        prod2.Product_Name_MS__c = 'FRIDA | 3.001 - 10.000 GB';
        data_productList.add(prod2);
        
        Product2 prod3 = new Product2();
        prod3.Name = 'GITA | 3 GB 30 days';
        prod3.ProductCode = 'Reward';
        prod3.Product_Type__c = 'Data Reward';
        prod3.Buying_Method__c = 'I/O';
        prod3.Family = 'Data Reward';
        prod3.IsActive = true;
        prod3.Product_Name_MS__c = 'GITA | 3 GB 30 days';
        data_productList.add(prod3);
        
        Product2 prod4 = new Product2();
        prod4.Name = 'IVR Bulk Advertising';
        prod4.ProductCode = 'Messaging';
        prod4.Product_Type__c = 'IVR';
        prod4.Buying_Method__c = 'I/O';
        prod4.Family = 'IVR';
        prod4.IsActive = true;
        prod4.Product_Name_MS__c = 'IVR Bulk Advertising';
        data_productList.add(prod4);
        
        insert data_productList;
        system.debug('>>> data_productList.size() = ' + data_productList.size());
        system.debug('>>> data_productList = ' + data_productList);
        
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
        
        return data_productList;
    }
    
    public List<Opportunity> createOpportunity(){
        system.debug('>>> Masuk createOpportunity !!!');
        
        List<Account> acc_list = createAccount();
        List<Product2> prod_list = createProduct();
        
        List<PricebookEntry> pbe_list = [SELECT Product2Id, Pricebook2Id, UnitPrice, IsActive FROM PricebookEntry ORDER BY CreatedDate ASC];
        
        List<Opportunity> data_oppList = new List<Opportunity>();
        
        Opportunity opp_ds_postpaid = new Opportunity();
        opp_ds_postpaid.Name = 'Test DS Opp';
        opp_ds_postpaid.AccountId = acc_list[0].Id;
        opp_ds_postpaid.Account_Type__c = 'Advertiser';
        opp_ds_postpaid.CloseDate = system.today();
        opp_ds_postpaid.StageName = 'Prospecting';
        opp_ds_postpaid.Penagihan_based_on__c = 'Postpaid';
        opp_ds_postpaid.Templated_Proposal__c = true;
        insert opp_ds_postpaid; 
        system.debug('>>> opp_ds_postpaid = ' + opp_ds_postpaid);
        
        opp_ds_postpaid.StageName = 'Visit / Call';
        opp_ds_postpaid.Pricebook2Id = Test.getStandardPricebookId();
        update opp_ds_postpaid;
        
        data_oppList.add(opp_ds_postpaid);
        
        List<OpportunityLineItem> oliListToInsert = new List<OpportunityLineItem>();
        
        OpportunityLineItem oli_prod1 = new OpportunityLineItem();
        oli_prod1.OpportunityId = data_oppList[0].Id;
        oli_prod1.Product2Id = prod_list[0].Id;
        oli_prod1.UnitPrice = 500;
        oli_prod1.PricebookEntryId = pbe_list[0].Id;
        oli_prod1.Quantity = 100;
        oliListToInsert.add(oli_prod1);
        
        OpportunityLineItem oli_prod2 = new OpportunityLineItem();
        oli_prod2.OpportunityId = data_oppList[0].Id;
        oli_prod2.Product2Id = prod_list[1].Id;
        oli_prod2.UnitPrice = 600;
        oli_prod2.PricebookEntryId = pbe_list[1].Id;
        oli_prod2.Quantity = 200;
        oliListToInsert.add(oli_prod2);
              
        insert oliListToInsert;
        system.debug('>>> oliListToInsert.size() = ' + oliListToInsert.size());
        system.debug('>>> oliListToInsert = ' + oliListToInsert);
        
        data_oppList[0].Type = 'Existing Business';
        data_oppList[0].StageName = 'Proposal';
        data_oppList[0].isSubmitCheckPOApproval__c = true;
        data_oppList[0].Approval_Status__c = 'Approved';
        data_oppList[0].Check_PO__c = 'OK';
        update data_oppList[0];
        
        data_oppList[0].StageName = 'Closed Won';
        update data_oppList[0];
        
        return data_oppList;
    }
    
    public List<Opportunity> createOpportunityPrepaid(){
        system.debug('>>> Masuk createOpportunityPrepaid !!!');
        
        List<Account> acc_list = createAccount();
        List<Product2> prod_list = createProduct();
        
        List<PricebookEntry> pbe_list = [SELECT Product2Id, Pricebook2Id, UnitPrice, IsActive FROM PricebookEntry ORDER BY CreatedDate ASC];
        
        List<Opportunity> data_oppPrepaidList = new List<Opportunity>();
        
        Opportunity opp_ds_prepaid = new Opportunity();
        opp_ds_prepaid.Name = 'Test DS Opp';
        opp_ds_prepaid.AccountId = acc_list[0].Id;
        opp_ds_prepaid.Account_Type__c = 'Advertiser';
        opp_ds_prepaid.CloseDate = system.today();
        opp_ds_prepaid.StageName = 'Prospecting';
        opp_ds_prepaid.Penagihan_based_on__c = 'Prepaid';
        opp_ds_prepaid.Templated_Proposal__c = true;
        insert opp_ds_prepaid; 
        system.debug('>>> opp_ds_prepaid = ' + opp_ds_prepaid);
        
        opp_ds_prepaid.StageName = 'Visit / Call';
        opp_ds_prepaid.Pricebook2Id = Test.getStandardPricebookId();
        update opp_ds_prepaid;
        
        data_oppPrepaidList.add(opp_ds_prepaid);
        
        List<OpportunityLineItem> oliListToInsert = new List<OpportunityLineItem>();
        
        OpportunityLineItem oli_prod1 = new OpportunityLineItem();
        oli_prod1.OpportunityId = data_oppPrepaidList[0].Id;
        oli_prod1.Product2Id = prod_list[0].Id;
        oli_prod1.UnitPrice = 500;
        oli_prod1.PricebookEntryId = pbe_list[0].Id;
        oli_prod1.Quantity = 100;
        oliListToInsert.add(oli_prod1);
        
        OpportunityLineItem oli_prod2 = new OpportunityLineItem();
        oli_prod2.OpportunityId = data_oppPrepaidList[0].Id;
        oli_prod2.Product2Id = prod_list[1].Id;
        oli_prod2.UnitPrice = 600;
        oli_prod2.PricebookEntryId = pbe_list[1].Id;
        oli_prod2.Quantity = 200;
        oliListToInsert.add(oli_prod2);
              
        insert oliListToInsert;
        system.debug('>>> oliListToInsert.size() = ' + oliListToInsert.size());
        system.debug('>>> oliListToInsert = ' + oliListToInsert);
        
        data_oppPrepaidList[0].Type = 'Existing Business';
        data_oppPrepaidList[0].StageName = 'Proposal';
        data_oppPrepaidList[0].isSubmitCheckPOApproval__c = true;
        data_oppPrepaidList[0].Approval_Status__c = 'Approved';
        data_oppPrepaidList[0].Check_PO__c = 'OK';
        update data_oppPrepaidList[0];
        
        data_oppPrepaidList[0].StageName = 'Closed Won';
        update data_oppPrepaidList[0];
        
        return data_oppPrepaidList;
        
    }
}