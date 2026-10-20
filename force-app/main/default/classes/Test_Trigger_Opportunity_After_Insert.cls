/*
 	Can be used for below trigger:
		# Trigger_Opportunity_After_Insert
		# DeleteTrigger
        # Trigger_OppLineItem_After_Insert_Update
        # Trigger_OppLineItem_Before_Insert_Update
        # Trigger_SOA_After_Insert
        # Trigger_OrderProduct_Before_Insert_Update
*/

//@isTest(seealldata=true)
@isTest
public class Test_Trigger_Opportunity_After_Insert {
	
    @testSetup static void setup() {

        Trigger_Setting__c triggerSettingsRec = new Trigger_Setting__c();
        triggerSettingsRec.name = 'Validation:_Deal_ID_Must_be_filled';
        triggerSettingsRec.Error_Message__c = 'Validation:_Deal_ID_Must_be_filled';
        triggerSettingsRec.IsActive__c = false;
        triggerSettingsRec.Object_Name__c = 'Opportunity' ;
        insert triggerSettingsRec;

        Account acc = new Account();
        acc.Name = 'Acc ABC';
        acc.Tipe_Display_Ads__c = 'Desktop Display 300x250;Desktop Display 728x90;Desktop Display 320x50;Mobile Display 300x250;Mobile Display 320x50';  // Tipe Display Ads
        acc.status__c = 'Approved by Settlement';
        acc.NPWP__c = '232413123wewdsaas';

        insert acc; 
        system.debug('>>> acc = ' + acc);
        
        Contact con = new Contact();
        con.lastName = 'Con ABC';
        con.AccountId = acc.Id;
        insert con; 
        system.debug('>>> con = ' + con);

        Brand__c brandRecord = new Brand__c(
            Name = 'Detik Brand UAT',       // Brand Name
            PIC_Advertiser__c = con.id
        );
        insert brandRecord;
        
        Contract newContract = new Contract();
        newContract.StartDate = date.today();
        newContract.ContractTerm = 1;
        newContract.AccountId = acc.id;
        insert newContract;
        
        newContract.Status = 'Activated';
        update newContract;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.AccountId = acc.Id;
        opp.Account_Type__c = 'Advertiser';
        opp.CloseDate = system.today();
        opp.brand__c = brandRecord.id;
        opp.StageName = 'Prospecting';
        opp.regional__c = 'BALINUSRA';
        insert opp; 
        system.debug('>>> opp = ' + opp);
        
        opp.Templated_Proposal__c = true;
        update opp;
        
        opp.StageName = 'Visit / Call';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.Check_PO__c = null ;
        opp.Approval_Status__c = null;
        update opp;
        
        List<Product2> prodListToInsert = new List<Product2>();
        
		Product2 prod1 = new Product2();
        prod1.Name = 'BULK (SMS)';
        prod1.ProductCode = 'Messaging';
        prod1.Product_Type__c = 'SMS';
        prod1.Buying_Method__c = 'I/O';
        prod1.Family = 'SMS';
        prod1.Product_Category__c = 'Advertising';
        prod1.IsActive = true;
        prodListToInsert.add(prod1);
        
        Product2 prod2 = new Product2();
        prod2.Name = 'FRIDA | 3.001 - 10.000 GB';
        prod2.ProductCode = 'Reward';
        prod2.Product_Type__c = 'Data Reward';
        prod2.Buying_Method__c = 'I/O';
        prod2.Product_Category__c = 'Advertising';
        prod2.Family = 'Data Reward';
        prod2.IsActive = true;
        prodListToInsert.add(prod2);
        
        Product2 prod3 = new Product2();
        prod3.Name = 'GITA | 3 GB 30 days';
        prod3.ProductCode = 'Reward';
        prod3.Product_Type__c = 'Data Reward';
        prod3.Buying_Method__c = 'I/O';
        prod3.Product_Category__c = 'Advertising';
        prod3.Family = 'Data Reward';
        prod3.IsActive = true;
        prodListToInsert.add(prod3);
        
        Product2 prod4 = new Product2();
        prod4.Name = 'IVR Bulk Advertising';
        prod4.ProductCode = 'Messaging';
        prod4.Product_Type__c = 'IVR';
        prod4.Product_Category__c = 'Advertising';
        prod4.Buying_Method__c = 'I/O';
        prod4.Family = 'IVR';
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
    }
    
    static testMethod void testMethod_Create_Opportunity() {
        /*Test.startTest();

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
        Test.stopTest();*/
    }
    
    static testMethod void testMethod_oppPostpaid() {
        
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
        
        OpportunityLineItem oli_prod2 = new OpportunityLineItem();
        oli_prod2.OpportunityId = oppList[0].Id;
        oli_prod2.Product2Id = prodList[1].Id;
        oli_prod2.UnitPrice = 600;
        oli_prod2.PricebookEntryId = pbeList[1].Id;
        oli_prod2.Quantity = 200;
        oliListToInsert.add(oli_prod2);
                
        insert oliListToInsert;
        system.debug('>>> oliListToInsert.size() = ' + oliListToInsert.size());
        system.debug('>>> oliListToInsert = ' + oliListToInsert);
        
        oppList[0].Type = 'Existing Business';
        oppList[0].Penagihan_based_on__c = 'Postpaid';
        oppList[0].StageName = 'Negotiation';
        //update oppList[0];
        
        oppList[0].StageName = 'Proposal';
        oppList[0].isSubmitCheckPOApproval__c = true;
        oppList[0].Approval_Status__c = 'Approved';
        oppList[0].Check_PO__c = 'OK';
        update oppList[0];
        
        oppList[0].StageName = 'Closed Won';
        update oppList[0];
        
        SOA__c soa_rec = new SOA__c();
        soa_rec.Opportunity__c = oppList[0].Id;
        soa_rec.SOA_Start_Date__c = system.today();
        soa_rec.SOA_End_Date__c = system.today().addDays(30);
        insert soa_rec;
        
        SOA__c soa_rec_vr = new SOA__c();
        soa_rec_vr.Opportunity__c = oppList[0].Id;
        soa_rec_vr.SOA_Start_Date__c = system.today();
        soa_rec_vr.SOA_End_Date__c = system.today().addDays(30);
        try
        	{insert soa_rec_vr;}
        catch(Exception ex)
        	{Boolean expectedExceptionThrown =  ex.getMessage().contains('Cannot create more') ? true : false;}
		        
        try
        	{delete oli_prod2;}
        catch(Exception ex)
        	{Boolean expectedExceptionThrown =  ex.getMessage().contains('Cannot delete') ? true : false;}
        
        oppList[0].StageName = 'Negotiation';
        update oppList[0];
        
        oli_prod1.Quantity = 110;
        update oli_prod1;
        
        OpportunityLineItem oli_prod3 = new OpportunityLineItem();
        oli_prod3.OpportunityId = oppList[0].Id;
        oli_prod3.Product2Id = prodList[2].Id;
        oli_prod3.UnitPrice = 700;
        oli_prod3.PricebookEntryId = pbeList[2].Id;
        oli_prod3.Quantity = 300;
        insert oli_prod3;
        
        try
        	{delete oli_prod2;}
        catch(Exception ex)
        	{Boolean expectedExceptionThrown =  ex.getMessage().contains('Cannot delete') ? true : false;}
        
        Test.stopTest();
        
        delete oli_prod3;
        
        OpportunityLineItem oli_prod4 = new OpportunityLineItem();
        oli_prod4.OpportunityId = oppList[0].Id;
        oli_prod4.Product2Id = prodList[3].Id;
        oli_prod4.UnitPrice = 800;
        oli_prod4.PricebookEntryId = pbeList[3].Id;
        oli_prod4.Quantity = 400;
        insert oli_prod4;
        
        oppList[0].StageName = 'Proposal';
        oppList[0].isSubmitCheckPOApproval__c = true;
        oppList[0].Approval_Status__c = 'Approved';
        oppList[0].Check_PO__c = 'OK';
        update oppList[0];
        
        oppList[0].StageName = 'Closed Won';
        update oppList[0];       
    }
    
    static testMethod void testMethod_oppPrepaid() {
        
        Test.startTest();
		        
        //List<Contact> ctList = [SELECT Id, Name FROM Contact ORDER BY CreatedDate ASC];
        
        List<Opportunity> oppList = [SELECT Id, Name, AccountId, Account_Type__c, CloseDate, StageName FROM Opportunity ORDER BY CreatedDate ASC];
        
        List<Product2> prodList = [SELECT Id, Name, ProductCode, Product_Type__c, Buying_Method__c, Family, IsActive FROM Product2 ORDER BY CreatedDate ASC];
        
        List<PricebookEntry> pbeList = [SELECT Id, IsActive, Product2Id, Pricebook2Id, UnitPrice FROM PricebookEntry ORDER BY CreatedDate ASC];
        
        List<OpportunityLineItem> oliListToInsert = new List<OpportunityLineItem>();
        
        oppList[0].Type = 'Existing Business';
        oppList[0].Penagihan_based_on__c = 'Prepaid';
        oppList[0].Adjustment_Version__c = 1;
        
        Quote qt = new Quote();
        qt.Name = 'Test Quote';
        //qt.ContactId = ctList[0].Id;
        qt.Start_Date__c = system.today();
        qt.End_Date__c = system.today().addDays(10);
        qt.OpportunityId = oppList[0].Id;
        insert qt;
        
        oppList[0].SyncedQuoteId = qt.Id;
        update oppList[0];
        
        OpportunityLineItem oli_prod1a = new OpportunityLineItem();
        oli_prod1a.OpportunityId = oppList[0].Id;
        oli_prod1a.Product2Id = prodList[0].Id;
        oli_prod1a.UnitPrice = 550;
        oli_prod1a.PricebookEntryId = pbeList[0].Id;
        oli_prod1a.Quantity = 150;
        insert oli_prod1a;
        
        OpportunityLineItem oli_prod2a = new OpportunityLineItem();
        oli_prod2a.OpportunityId = oppList[0].Id;
        oli_prod2a.Product2Id = prodList[1].Id;
        oli_prod2a.UnitPrice = 650;
        oli_prod2a.PricebookEntryId = pbeList[1].Id;
        oli_prod2a.Quantity = 250;
        insert oli_prod2a;
        
        oli_prod1a.Quantity = 110;
        update oli_prod1a;

        OpportunityLineItem oli_prod3 = new OpportunityLineItem();
        oli_prod3.OpportunityId = oppList[0].Id;
        oli_prod3.Product2Id = prodList[1].Id;
        oli_prod3.UnitPrice = 700;
        oli_prod3.PricebookEntryId = pbeList[1].Id;
        oli_prod3.Quantity = 300;
        insert oli_prod3;
        
        try
        	{delete oli_prod2a;}
        catch(Exception ex)
        	{Boolean expectedExceptionThrown =  ex.getMessage().contains('Cannot delete') ? true : false;}
        
        Test.stopTest(); 
        
        delete oli_prod3;
        
        OpportunityLineItem oli_prod4 = new OpportunityLineItem();
        oli_prod4.OpportunityId = oppList[0].Id;
        oli_prod4.Product2Id = prodList[3].Id;
        oli_prod4.UnitPrice = 800;
        oli_prod4.PricebookEntryId = pbeList[3].Id;
        oli_prod4.Quantity = 400;
        insert oli_prod4;
        
        oppList[0].StageName = 'Proposal';
        oppList[0].isSubmitCheckPOApproval__c = true;
        oppList[0].Approval_Status__c = 'Approved';
        oppList[0].Check_PO__c = 'OK';
        //update oppList[0];
        
        oppList[0].StageName = 'Closed Won';
        update oppList[0];       
    }
}