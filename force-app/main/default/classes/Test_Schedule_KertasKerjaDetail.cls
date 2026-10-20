@isTest
public class Test_Schedule_KertasKerjaDetail {
    
    static testMethod void test_schKKD(){
        
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
        
        List<SID_Tools__c> sidList = [SELECT Id, Name, CP_Name__c FROM SID_Tools__c ORDER BY CreatedDate ASC];
        system.debug('*** sidList = ' + sidList.size() + ' | ' + sidList);
        
        Traffics_SID__c tsid  = new Traffics_SID__c();
        tsid.Product_Name__c = 'BULK (SMS)';
        tsid.CP_Name__c = sidList[0].CP_Name__c;
        tsid.Event_Date__c = system.today();
        tsid.SID__c = sid_rec.Id;
        tsid.Traffic__c = 5000;
        tsid.Traffic_SID_Unique_ID__c = '123';
        insert tsid;
        
        String CRON_EXP = '0 0 1 * * ?';
        ID jobID = System.schedule('Test Schedule_KertasKerjaDetail',CRON_EXP,new Schedule_KertasKerjaDetail());
        
    }

}