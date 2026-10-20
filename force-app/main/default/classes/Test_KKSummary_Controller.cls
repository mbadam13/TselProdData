@isTest
public class Test_KKSummary_Controller {
    
    static testMethod void test_kkSumController(){
        
        DataFactory df = new DataFactory();
        List<Opportunity> oppList = df.createOpportunity();
        
        List<PricebookEntry> pbeList = [SELECT Id, IsActive, Product2Id, Pricebook2Id, UnitPrice FROM PricebookEntry ORDER BY CreatedDate ASC];
        
        Test.startTest();
        
        SOA__c soa_rec = new SOA__c();
        soa_rec.Opportunity__c = oppList[0].Id;
        soa_rec.SOA_Start_Date__c = date.newInstance(2021,1,1);
        soa_rec.SOA_End_Date__c = date.newInstance(2021,1,31);
        insert soa_rec;
        
        List<Order> data_orderList = [SELECT Id, Status, EffectiveDate, EndDate, AccountId, SOA__c, Pricebook2id, OpportunityId FROM Order ORDER BY CreatedDate ASC];
        system.debug('*** data_orderList = ' + data_orderList.size() + ' | ' + data_orderList);
        
        Order ord_clone = data_orderList[0].clone(false, false, false, false);
        insert ord_clone;
        
        List<OrderItem> oilist = [SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Camp_ID__c, Campaign_ID__c, OrderItemNumber,
                                  		Opportunity__c, ServiceDate, EndDate, Opp_Product_Id__c, Product_id_number__c, EmployeeID_SF__c, NIK__c
                                  		FROM OrderItem 
                                      	ORDER BY CreatedDate ASC];
        system.debug('*** oilist = ' + oilist.size() + ' | ' + oilist);
        
        OrderItem oi_clone = oilist[0].clone(false, false, false, false);
        oi_clone.OrderId = ord_clone.Id;
        insert oi_clone;
        
       	Usage__c usg = new Usage__c();
       	usg.Sales__c = oilist[0].EmployeeID_SF__c;
       	usg.OwnerId = oilist[0].EmployeeID_SF__c;
       	usg.Bucket_Detail__c= oilist[0].Id;
       	usg.NIK__c = oilist[0].NIK__c;
       	usg.Campaign_ID__c = oilist[0].Campaign_ID__c;
       	usg.Amount__c = 50;
       	//usg.Date__c= system.today();
       	usg.Date__c = Date.newInstance(2021,1,1);
       	usg.Unique_ID__c = usg.Campaign_ID__c + '_' + system.now() + '_' + usg.NIK__c;
       	insert usg;
        
        Usage__c usg_02 = new Usage__c();
       	usg_02.Sales__c = oilist[1].EmployeeID_SF__c;
       	usg_02.OwnerId = oilist[1].EmployeeID_SF__c;
       	usg_02.Bucket_Detail__c= oilist[1].Id;
       	usg_02.NIK__c = oilist[1].NIK__c;
       	usg_02.Campaign_ID__c = oilist[1].Campaign_ID__c;
       	usg_02.Amount__c = 50;
       	//usg_02.Date__c= system.today();
        usg_02.Date__c = Date.newInstance(2021,1,1);
       	usg_02.Unique_ID__c = usg_02.Campaign_ID__c + '_' + system.now() + '_' + usg_02.NIK__c;
       	insert usg_02;
        
        Kertas_Kerja__c kk_ds = new Kertas_Kerja__c();
        kk_ds.Month__c = 'January';
        kk_ds.Year__c = '2021';
        kk_ds.Status__c = 'Draft';
        kk_ds.Type__c = 'Direct Sales';
        insert kk_ds;
        
        Kertas_Kerja__c kk_ds_clone = kk_ds.clone(false, false, false, false);
        try
        	{insert kk_ds_clone;}
        catch(Exception ex)
        	{Boolean expectedExceptionThrown =  ex.getMessage().contains('Duplicate Kertas Kerja record:') ? true : false;}
        
        PageReference pr_kkSum = Page.KKSummary_Page;
        pr_kkSum.getParameters().put('Id',kk_ds.Id);
        Test.setCurrentPage(pr_kkSum);
        
        ApexPages.StandardController sc_kk_ds = new  ApexPages.StandardController(kk_ds);
        KKSummary_Controller kkSumCon = new KKSummary_Controller(sc_kk_ds);
        
        kk_ds.Month__c = 'February';
        update kk_ds;
        kkSumCon = new KKSummary_Controller(sc_kk_ds);
        
        kk_ds.Month__c = 'March';
        update kk_ds;
        kkSumCon = new KKSummary_Controller(sc_kk_ds);
        
        kk_ds.Month__c = 'April';
        update kk_ds;
        kkSumCon = new KKSummary_Controller(sc_kk_ds);
        
        kk_ds.Month__c = 'May';
        update kk_ds;
        kkSumCon = new KKSummary_Controller(sc_kk_ds);
        
        kk_ds.Month__c = 'June';
        update kk_ds;
        kkSumCon = new KKSummary_Controller(sc_kk_ds);
        
        kk_ds.Month__c = 'July';
        update kk_ds;
        kkSumCon = new KKSummary_Controller(sc_kk_ds);
        Test.stopTest();
        kk_ds.Month__c = 'August';
        update kk_ds;
        kkSumCon = new KKSummary_Controller(sc_kk_ds);
        
        /*kk_ds.Month__c = 'September';
        update kk_ds;
        kkSumCon = new KKSummary_Controller(sc_kk_ds);
        
        //Test.stopTest();
        
        kk_ds.Month__c = 'October';
        update kk_ds;
        kkSumCon = new KKSummary_Controller(sc_kk_ds);*/
        
        /*kk_ds.Month__c = 'November';
        update kk_ds;
        kkSumCon = new KKSummary_Controller(sc_kk_ds);
        
        kk_ds.Month__c = 'December';
        update kk_ds;
        kkSumCon = new KKSummary_Controller(sc_kk_ds);*/
        
    }
}