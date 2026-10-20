@isTest
public class Test_KKBreakdown_Controller {
	
    static testMethod void test_kkBrdController(){
        
        DataFactory df = new DataFactory();
        List<Opportunity> oppList = df.createOpportunity();
        
        List<PricebookEntry> pbeList = [SELECT Id, IsActive, Product2Id, Pricebook2Id, UnitPrice FROM PricebookEntry ORDER BY CreatedDate ASC];
        
        Test.startTest();
        
        Kertas_Kerja__c kk_ds = new Kertas_Kerja__c();
        kk_ds.Month__c = 'January';
        kk_ds.Year__c = '2021';
        kk_ds.Status__c = 'Draft';
        kk_ds.Type__c = 'Direct Sales';
        insert kk_ds;
        
        PageReference pr_kkBrd = Page.KKBreakdown_Page;
        pr_kkBrd.getParameters().put('Id',kk_ds.Id);
        Test.setCurrentPage(pr_kkBrd);
        
        ApexPages.StandardController sc_kk_ds = new  ApexPages.StandardController(kk_ds);
        KKBreakdown_Controller kkBrdCon = new KKBreakdown_Controller(sc_kk_ds);
        kkBrdCon.getKKBreakdownRecs();
        
        SOA__c soa_rec = new SOA__c();
        soa_rec.Opportunity__c = oppList[0].Id;
        soa_rec.SOA_Start_Date__c = date.newInstance(2021,1,1);
        soa_rec.SOA_End_Date__c = date.newInstance(2021,1,31);
        insert soa_rec;
        
        List<Order> data_orderList = [SELECT Id, OrderNumber, Status, EffectiveDate, EndDate, AccountId, SOA__c, Pricebook2id, OpportunityId FROM Order ORDER BY CreatedDate ASC];
        system.debug('*** data_orderList = ' + data_orderList.size() + ' | ' + data_orderList);
        
        List<OrderItem> oilist = [SELECT Id, OrderId, Order.OrderNumber, Product2.Name, Buffer__c, EmployeeID_SF__c, NIK__c, Campaign_ID__c 
                                  FROM OrderItem 
                                  ORDER BY CreatedDate ASC];
        system.debug('*** oilist = ' + oilist.size() + ' | ' + oilist);
        
        
        kkBrdCon.productName = 'Test Product';
        kkBrdCon.getKKBreakdownRecs();
        
        kkBrdCon.orderNo = oilist[0].Order.OrderNumber;
        kkBrdCon.productName = oilist[0].Product2.Name;
        kkBrdCon.getKKBreakdownRecs();
        
        Usage__c usg = new Usage__c();
       	usg.Sales__c = oilist[0].EmployeeID_SF__c;
       	usg.OwnerId = oilist[0].EmployeeID_SF__c;
       	usg.Bucket_Detail__c= oilist[0].Id;
       	usg.NIK__c = oilist[0].NIK__c;
       	usg.Campaign_ID__c = oilist[0].Campaign_ID__c;
       	usg.Amount__c = 50;
       	usg.Date__c= system.today();
        usg.Date__c = Date.newInstance(2021,1,1);
       	usg.Unique_ID__c = usg.Campaign_ID__c + '_' + system.now() + '_' + usg.NIK__c;
       	insert usg;
        
        oilist[0].Buffer__c = 500;
        update oilist[0];
        kkBrdCon.getKKBreakdownRecs();
        
        kkBrdCon.orderNo = '';
        kkBrdCon.productName = '';
        kkBrdCon.getKKBreakdownRecs();
        
        kk_ds.Month__c = 'February';
        update kk_ds;
        kkBrdCon = new KKBreakdown_Controller(sc_kk_ds);
        kkBrdCon.getKKBreakdownRecs();
        
        kk_ds.Month__c = 'March';
        update kk_ds;
        kkBrdCon = new KKBreakdown_Controller(sc_kk_ds);
        kkBrdCon.getKKBreakdownRecs();
        
        kk_ds.Month__c = 'April';
        update kk_ds;
        kkBrdCon = new KKBreakdown_Controller(sc_kk_ds);
        kkBrdCon.getKKBreakdownRecs();
        
        kk_ds.Month__c = 'May';
        update kk_ds;
        kkBrdCon = new KKBreakdown_Controller(sc_kk_ds);
        kkBrdCon.getKKBreakdownRecs();
        
        kk_ds.Month__c = 'June';
        update kk_ds;
        kkBrdCon = new KKBreakdown_Controller(sc_kk_ds);
        kkBrdCon.getKKBreakdownRecs();
        
        kk_ds.Month__c = 'July';
        update kk_ds;
        kkBrdCon = new KKBreakdown_Controller(sc_kk_ds);
        kkBrdCon.getKKBreakdownRecs();
        
        kk_ds.Month__c = 'August';
        update kk_ds;
        kkBrdCon = new KKBreakdown_Controller(sc_kk_ds);
        kkBrdCon.getKKBreakdownRecs();
        
        kk_ds.Month__c = 'September';
        update kk_ds;
        kkBrdCon = new KKBreakdown_Controller(sc_kk_ds);
        kkBrdCon.getKKBreakdownRecs();
        
        kk_ds.Month__c = 'October';
        update kk_ds;
        kkBrdCon = new KKBreakdown_Controller(sc_kk_ds);
        kkBrdCon.getKKBreakdownRecs();
        
        kk_ds.Month__c = 'November';
        update kk_ds;
        kkBrdCon = new KKBreakdown_Controller(sc_kk_ds);
        kkBrdCon.getKKBreakdownRecs();
        
        kk_ds.Month__c = 'December';
        update kk_ds;
        kkBrdCon = new KKBreakdown_Controller(sc_kk_ds);
        kkBrdCon.getKKBreakdownRecs();
        
        Test.stopTest();
        
    }
    
}