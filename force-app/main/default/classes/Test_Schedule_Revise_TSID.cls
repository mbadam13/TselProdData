@isTest
public class Test_Schedule_Revise_TSID {
    
    static testMethod void test_schRevTsid(){
        
        DataFactory df = new DataFactory();
        List<Account> accList = df.createAccount();
        List<Product2> prodList = df.createProduct();
        
        SID_Tools__c sid_rec = new SID_Tools__c();
        sid_rec.Sender_ID__c = 'jatis';
        sid_rec.Media_Seller__c = accList[1].Id;
        sid_rec.OwnerId = Label.Owner_MS;
        sid_rec.Type_Sender__c = 'Premium';
        sid_rec.Type_SMS__c = 'SMS Bulk';
        sid_rec.SID__c = 'jatis123xyz';
        sid_rec.Sub_Reseller__c = FALSE;
        sid_rec.Company__c = 'PT Coba Testing';
        insert sid_rec;
        
        Date dt = system.today().addMonths(-2);
        
        Usage_Traffic_Media_Seller__c utms_rec = new Usage_Traffic_Media_Seller__c();
        utms_rec.Date__c = Date.newInstance(dt.year(), dt.month(), 1);
        utms_rec.Unique_ID__c = '12300123';
        utms_rec.Media_seller__c = accList[1].Id;
		utms_rec.Sub_Media_Seller__c = accList[1].Id;
		utms_rec.Traffic_Type__c = 'Bulk';
     	utms_rec.Product__c = prodList[0].Id;
		utms_rec.Amount__c = 4500;
        insert utms_rec;
        
        Traffics_SID__c tsid_rec = new Traffics_SID__c();
        tsid_rec.Event_Date__c = dt;
		tsid_rec.CP_Name__c = 'sms-p-dws-dws-oth';
        tsid_rec.SID__c = sid_rec.Id;
        tsid_rec.Traffic__c = 100;
        tsid_rec.Product__c = prodList[0].Id;
        tsid_rec.Traffic_SID_Unique_ID__c = '20220116sms-p-dws-dws-othjatis123xyz';
        tsid_rec.Usage_Traffic_Media_Seller__c = utms_rec.Id;
        insert tsid_rec;
        
        Change_Log_Traffic__c clt_rec = new Change_Log_Traffic__c();
        clt_rec.Change_Type__c = 'Change';
        clt_rec.Traffic_Type__c = 'Traffic SID';
        clt_rec.Old_Value__c = 100;
        clt_rec.New_Value__c = 15;
        clt_rec.Event_Date_Traffic__c = dt;
        clt_rec.Traffics_SID__c = tsid_rec.Id;
        //clt_rec.Record_ID__c = tsid_rec.Id;
        insert clt_rec;
        
        String CRON_EXP = '0 0 1 * * ?';
        ID jobID = System.schedule('Test Schedule_Revise_TSID',CRON_EXP,new Schedule_Revise_TSID());
        
    }
    
}