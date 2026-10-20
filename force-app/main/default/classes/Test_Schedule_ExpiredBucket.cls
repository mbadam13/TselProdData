@isTest
public class Test_Schedule_ExpiredBucket {
	
    static testMethod void test_schEB(){
        
        DataFactory df = new DataFactory();
        List<Opportunity> oppList = df.createOpportunityPrepaid();
        
        Quote qt = new Quote();
        qt.Name = 'Test Quote';
        qt.Start_Date__c = system.today();
        qt.End_Date__c = system.today().addDays(7);
        qt.OpportunityId = oppList[0].Id;
        insert qt;
        
        Test.startTest();
        
        qt.Status = 'Final';
        update qt;
        
        List<OrderItem> oilist = [SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Camp_ID__c, Campaign_ID__c, OrderItemNumber, Opportunity__c,
                                  		Sales__c, ServiceDate, EndDate, Opp_Product_Id__c, Product_id_number__c, EmployeeID_SF__c, NIK__c, 
                                  		Order.EndDate, Order.Expired_Notif_Date__c, Order.Status, Opportunity__r.Penagihan_based_on__c, Order.StatusCode,
                                  		Opportunity__r.Contract.StartDate, Opportunity__r.Contract.EndDate, Opportunity__r.AccountId
                                  		FROM OrderItem 
                                      	ORDER BY CreatedDate ASC];
        system.debug('*** oilist = ' + oilist.size() + ' | ' + oilist);
        
        //Contract
        Contract newContract = new Contract();
        newContract.StartDate = date.today();
        newContract.ContractTerm = 1;
        newContract.Opportunity__c = oilist[0].Opportunity__c;
        newContract.AccountId = oilist[0].Opportunity__r.AccountId;
        insert newContract;
        
        newContract.Status='Activated';
        update newContract;
        
        system.debug('*** oilist[0].Opportunity__r.Contract.StartDate = ' + oilist[0].Opportunity__r.Contract.StartDate);
        system.debug('*** oilist[0].Opportunity__r.Contract.EndDate = ' + oilist[0].Opportunity__r.Contract.EndDate);
        
        //oilist[0].Order.StatusCode = 'R';
        oilist[0].Order.ContractId = newContract.Id;
        oilist[0].Order.Status = 'Running';
        update oilist[0].Order;
        
        system.debug('*** oilist[0].Opportunity__r.Penagihan_based_on__c = ' + oilist[0].Opportunity__r.Penagihan_based_on__c);
        system.debug('*** oilist[0].Order.Status = ' + oilist[0].Order.Status);
        system.debug('*** oilist[0].Order.Expired_Notif_Date__c = ' + oilist[0].Order.Expired_Notif_Date__c);
        system.debug('*** oilist[0].Order.EndDate = ' + oilist[0].Order.EndDate);
        system.debug('*** oilist[0].EmployeeID_SF__c = ' + oilist[0].EmployeeID_SF__c);
        system.debug('*** oilist[0].Sales__c awal = ' + oilist[0].Sales__c);
        
        oilist[0].Sales__c = oilist[0].EmployeeID_SF__c;
        update oilist[0];
        
        system.debug('*** oilist[0].Sales__c akhir = ' + oilist[0].Sales__c);
        
       	Usage__c usg = new Usage__c();
       	usg.Sales__c = oilist[0].EmployeeID_SF__c;
       	usg.OwnerId = oilist[0].EmployeeID_SF__c;
       	usg.Bucket_Detail__c= oilist[0].Id;
       	usg.NIK__c = oilist[0].NIK__c;
       	usg.Campaign_ID__c = oilist[0].Campaign_ID__c;
       	usg.Amount__c = 50;
       	usg.Date__c= system.today();
       	usg.Unique_ID__c = usg.Campaign_ID__c + '_' + system.now() + '_' + usg.NIK__c;
       	insert usg;
        
        system.debug('*** oilist[0].Opportunity__r.Penagihan_based_on__c kedua = ' + oilist[0].Opportunity__r.Penagihan_based_on__c);
        system.debug('*** oilist[0].Order.Status kedua = ' + oilist[0].Order.Status);
        system.debug('*** oilist[0].Order.Expired_Notif_Date__c kedua = ' + oilist[0].Order.Expired_Notif_Date__c);
        
        String CRON_EXP = '0 0 1 * * ?';
        ID jobID = System.schedule('Test Schedule_ExpiredBucket',CRON_EXP,new Schedule_ExpiredBucket());
		
        List<Expired_Bucket__c> ebList = [SELECT Id, Name, Status__c FROM Expired_Bucket__c ORDER BY CreatedDate ASC];
        system.debug('*** ebList TESTCLASS = ' + ebList.size() + ' | ' + ebList);
        
        Expired_Bucket__c eb_rec = new Expired_Bucket__c();
        eb_rec.Order_Product__c = oilist[0].Id;
        eb_rec.Remaining_Usage__c = 5000;
        eb_rec.Status__c = 'Waiting Confirmation';
        eb_rec.Current_End_Date__c = oilist[0].Order.EndDate;
        insert eb_rec;
                
        eb_rec.Status__c = 'Confirmed Expired';
        update eb_rec;
        
        Test.stopTest();
        
        Order ord = new Order();
        ord.Id = oilist[0].OrderId;
        ord.EndDate = system.today().addDays(7);
        update ord;
        system.debug('*** ord.EndDate = ' + ord.EndDate);
        
        Expired_Bucket__c eb_clone = eb_rec.clone(false, false, false, false);
        eb_clone.Status__c = 'Waiting Confirmation';
        eb_clone.Order_Product__c = oilist[0].Id;
        eb_clone.Remaining_Usage__c = 5500;
        eb_clone.Confirm_Expired_Date__c = null;
        insert eb_clone;
        
        //eb_clone.Approval_Status__c = 'Approved';
        eb_clone.Proposed_End_Date__c = system.today().addDays(7);
        eb_clone.Status__c = 'Extended';
        update eb_clone;
        
        eb_clone.Status__c = 'Waiting Confirmation';
        update eb_clone;
        
        String CRON_EXP_01 = '0 0 1 * * ?';
        ID jobID_01 = System.schedule('Test Schedule_EB_ConfirmedExpired',CRON_EXP,new Schedule_EB_ConfirmedExpired());
        
        List<Expired_Bucket__c> ebceList = new List<Expired_Bucket__c>();
        ebceList.add(eb_clone);
        
        Id testbatchInstanceId = Database.executeBatch(new Batch_EB_ConfirmedExpired(ebceList), 5);
        
        
    }
    
}