@isTest
public class Test_GITA_ProductDiscount_Controller {
	
    static testMethod void myUnitTest() {
        
        Account acc = new Account();
        acc.Name = 'Acc ABC';
        insert acc; system.debug('>>> acc = ' + acc);
        
        Contact con = new Contact();
        con.lastName = 'Con ABC';
        con.AccountId = acc.Id;
        insert con; system.debug('>>> con = ' + con);
        
        LOB__c lob_rec = new LOB__c();
        lob_rec.Name = 'FMCG';
        lob_rec.LOB_Unique_ID__c = 'FMCG';
        lob_rec.Active__c = true;
        insert lob_rec;
        
        Brand__c brand_rec = new Brand__c();
        brand_rec.Name = 'Brand ABC';
        brand_rec.PIC_Advertiser__c = con.Id;
        brand_rec.Brand_Category__c = lob_rec.Id;
        insert brand_rec;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.AccountId = acc.Id;
        opp.Account_Type__c = 'Advertiser';
        opp.CloseDate = system.today();
        opp.StageName = 'Prospecting';
        opp.Brand__c = brand_rec.Id;
        insert opp; system.debug('>>> opp = ' + opp);
        
        opp.StageName = 'Visit / Call';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
        
        Product2 prod = new Product2();
        prod.Name = 'GITA | 3 GB 30 days';
        prod.ProductCode = 'Reward';
        prod.Product_Type__c = 'Data Reward';
        prod.Buying_Method__c = 'I/O';
        prod.Family = 'Data Reward';
        prod.IsActive = true;
        prod.Product_Category__c = 'Advertising';
        prod.Max_Discount__c = 30;
        insert prod;
        system.debug('>>> prod = ' + prod);
        
        PricebookEntry pbe_std = new PricebookEntry();
		pbe_std.IsActive = true;
		pbe_std.Product2Id = prod.Id;
		pbe_std.Pricebook2Id = Test.getStandardPricebookId();
     	pbe_std.UnitPrice = 50000;
        insert pbe_std;
        system.debug('>>> pbe_std = ' + pbe_std);
        
        OpportunityLineItem oli_prod = new OpportunityLineItem();
        oli_prod.OpportunityId = opp.Id;
        oli_prod.Product2Id = prod.Id;
        oli_prod.UnitPrice = 570;
        oli_prod.PricebookEntryId = pbe_std.Id;
        oli_prod.Quantity = 130;
        oli_prod.Discount__c = 26;        
        insert oli_prod;
        
        opp.StageName = 'Negotiation';
        opp.Penagihan_based_on__c = 'Postpaid';
        update opp;
        
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(opp.id);
        Approval.ProcessResult result = Approval.process(app);
        
        //ProcessInstanceWorkitem (after submit approval)
        ProcessInstanceWorkitem piw_rec = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem ORDER BY CreatedDate DESC LIMIT 1 ];
        system.debug('*** piw_rec = ' + piw_rec );
        
        PageReference pRef_01 = Page.GITA_ProductListAndDiscount_VFP;
    	pRef_01.getParameters().put('Id', String.valueOf(piw_rec.Id));
    	Test.setCurrentPage(pRef_01);
        GITA_ProductDiscount_Controller testGitaDisc_01 = new GITA_ProductDiscount_Controller();
        
        //ProcessInstanceStep (after response approve/reject)
        ProcessInstanceStep pis_rec = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId FROM ProcessInstanceStep ORDER BY CreatedDate DESC LIMIT 1 ];
        system.debug('*** pis_rec = ' + pis_rec );
        
        PageReference pRef_02 = Page.GITA_ProductListAndDiscount_VFP;
    	pRef_02.getParameters().put('Id', String.valueOf(pis_rec.Id));
    	Test.setCurrentPage(pRef_02);
        GITA_ProductDiscount_Controller testGitaDisc_02 = new GITA_ProductDiscount_Controller();
    }
}