/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 07-04-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   07-04-2023   Novando Utoyo Agmawan   Initial Version
**/

@isTest(seealldata=true)
public class TEST_AppUtils {
    
    static testMethod void testMthod1() {
        
        //AppUtils AppUtil = new AppUtils();
        String JSONStringInput ='{"Body":{"operation":"Customer Profile","transactionId":"1234","status":"1","entity":"AFI","service":"getCustomerInfo","IcAx_AXAAsiaCustomer_Type":{"processedDttm":"2016-10-28T19:14:05","canBeIndividual":{"genderCD":"F","hasAddressesIn":[{"addressLine4":"Indonesia Raya","addressLine3":"Indonesia","addressLine2":"jakarta selatan","addressLine1":"kebayoran baru"}],"birthPlace":"Jakarta","birthDT":"19800327"},"hasPolicyAccount":[{"hasPartyDetailsIn":[{"canBeIndividual":{"hasPartyAccountDetailsIn":{"payorLastNM":"Bagus","branchCD":"Jakarta","rejectCD":"A1","accountEffectiveDT":"20100727","accountTypeCD":"1040002003189","accountStatusCD":"active","bankName":"Mandiri","accountNO":"104000200318","accountExpirationDT":"20150727","rejectDT":"20161026","payorFirstNM":"Bagus"}},"servicingCD":"000373","producingCD":"0003737"}],"policyNO":"100-103-0000038"},{"hasPartyDetailsIn":[{"canBeIndividual":{"hasPartyAccountDetailsIn":{"payorLastNM":"Bagus","branchCD":"Jakarta","rejectCD":"A1","accountEffectiveDT":"20100727","accountTypeCD":"1040002003189","accountStatusCD":"active","bankName":"Mandiri","accountNO":"104000200318","accountExpirationDT":"20150727","rejectDT":"20161026","payorFirstNM":"Bagus"}},"servicingCD":"000373","producingCD":"0003737"}],"policyNO":"100-103-0000038"}],"customerID":"000000000093836"},"appID":"RLS","AXAAsiaPagination_Type":{"rowPerPage":"","numberOfRecords":"","startDateTime":"","pageNumber":"","endDateTime":"","startOfRecords":""}}}';
        String JSONStringOutput='';
        
        Test.startTest();
        

        JSONStringOutput = AppUtils.stripJsonNulls(JSONStringInput);
        system.debug('JSONStringOutput : ' + JSONStringOutput);
        
        Map<String, Object> m = new Map<String, Object>();
        m = AppUtils.getMapPackageFromJSON (JSONStringOutput);
        
        String status = AppUtils.getStringDataOnMap(m, 'Body::status');
        
        String addressLine4 = AppUtils.getStringDataOnMap(m, 'Body::IcAx_AXAAsiaCustomer_Type::canBeIndividual::hasAddressesIn[0]::addressLine4');
        
        
        List<Object> lo = AppUtils.getListDataOnMap(m, 'Body::IcAx_AXAAsiaCustomer_Type::hasPolicyAccount') ;
        
        Date d1 = AppUtils.strToDate('20160101', '');
        Date d2 = AppUtils.strToDate('2016-01-01', 'yyyy-mm-dd');
        Date d3 = AppUtils.strToDate('20160101', 'yyyymmdd');
        Date d4 = AppUtils.strToDate('2016/01/01', 'yyyy/mm/dd');
        Date d5 = AppUtils.strToDate('2016/01/01', '--');
        
        Date d6 = AppUtils.strToDate('', 'yyyymmdd');
        Date d7 = AppUtils.strToDate('', 'yyyy/mm/dd');

        DateTime dt1 = AppUtils.strToDateTime('20160101', '');
        DateTime dt2 = AppUtils.strToDateTime('2016-01-01', 'yyyy-mm-dd');
        DateTime dt3 = AppUtils.strToDateTime('20160101', 'yyyymmdd');
        DateTime dt4 = AppUtils.strToDateTime('2016-01-01 10:11:12', 'yyyy-mm-dd hh:mm:ss');
        DateTime dt5 = AppUtils.strToDateTime('20160101103112', 'yyyymmddhhmmss');
        
        DateTime dt6 = AppUtils.strToDateTime('', 'yyyy-mm-dd');
        DateTime dt7 = AppUtils.strToDateTime('', 'yyyymmdd');
        DateTime dt8 = AppUtils.strToDateTime('', 'yyyy-mm-dd hh:mm:ss');
        DateTime dt9 = AppUtils.strToDateTime('', 'yyyymmddhhmmss');

        
        Date bd = AppUtils.strToDate('19781010', 'yyyymmdd');
        string age = AppUtils.birthToAge( bd);
        string age1 = AppUtils.birthToAge( null);
        
        decimal dc1 = AppUtils.strToDec('10.10'); 
        
        string guid = AppUtils.getNewGUID() ;
        string unmr = AppUtils.getUniqueNumber();
        string sessionID = AppUtils.getSessionID();    
        
        string en = AppUtils.doEncrypt('hello');
        string de = AppUtils.doDecrypt(en );

         AppUtils.putError('AA::BB::11');
        
         //List<ContentVersion> csv = AppUtils.getOpportunityFilesOnBase64('0067F000008iaAz') ;

  

        Map<String, Object> paramMap = (Map<String, Object>) JSON.deserializeUntyped('{"header":{"service":"addapn","request_id":"657878986879"},"body":{"data":{"apn_id":"1","apn_name":"APN 1"}}}');
        system.debug('============ paramMap  : ' + paramMap );
        //Map<string, Object> mapRec = (Map<string, Object>) appUtils.getObjectDataOnMap(paramMap,'body::data');
                   

        Datetime dt = appUtils.addHours(system.now(), 2);
        decimal dc = appUtils.getDecimalOrNull ('90.8');
        string ss = appUtils.getStringOrNull ('hello') ;
        Boolean bb = appUtils.isKeysetNotFound ('== Keyset NOT found ==');
        
        
        //-- test
        Date lastContractStartDate = Date.newInstance(2017, 1, 1);
        Date lastContractEndDate = Date.newInstance(2017, 12, 31);
        Integer ContractTerm = 6;
        Date newContractStartDate = Date.newInstance(2019, 2, 1);
        
        date newContractEndDate = apputils.getNewContractEndDate (lastContractStartDate, lastContractEndDate, ContractTerm, newContractStartDate); 
        
        
        //-- test lock opportunity 
        List <opportunity> opps = [select id , Opportunity_ID__c from opportunity order by createddate asc limit 2 ] ;
        List <string> oppids = new List <string>(); 
        for (Opportunity opp : opps) {
            oppids.add (opp.Opportunity_ID__c);
        }
        apputils.lockOpportunities(oppids);
        //----   
        
        Additional_Setting__c result = AppUtils.getAdditionalValue('VAT', 'Pubmatic_Billing__c', date.newInstance(3024, 01, 01));

        List<Additional_Setting__c> getListRevenueCalculationforDiscountInventoryList = AppUtils.getListAdditionalSettingByObjectName('Revenue_Calculation_for_Discount_Inventory__c');

        Map<String,Date> Map_rangeDate = AppUtils.getRangeDate(system.today());

        list<Kategori_Industri__c> List_KategoriIndustri = AppUtils.getListKategoriIndustri();

        List<Media_Seller_Mapping_Settings__c> List_MediaSellerMappingSettings = AppUtils.getListMediaSellerMapping();

        list<Monthly_Discount_Inventory_Media_Seller__c> List_MonthlyDiscountInventoryMediaSeller = AppUtils.getListMonthlyDiscountInventoryMediaSeller();

        List<Media_Seller_Exclude_Revenue__c> List_MediaSellerExcludeRevenue = AppUtils.getListMediaSellerExcludeRevenue();
        
        Test.stopTest();
        
    }
    
    static testMethod void testMthod2() {
        
        Test.startTest();
        LIST<user> u=[SELECT id from user where username='dev1@telkomsel.co.id' LIMIT 1];
        
        Account acc = new Account ();
            acc.Name='Suka Selalu Aka';
            acc.Tipe_Display_Ads__c = 'Mobile Display 320x50';
            acc.NPWP__c = '123123123asdads';
            acc.Status__c = 'Approved by Settlement';
        insert acc;


        Contact contactRecord = new Contact(
            LastName = 'murad UAT',
            AccountId = acc.id
        );
        insert contactRecord;

        Brand__c brandRecord = new Brand__c(
            Name = 'Detik Brand UAT',       // Brand Name
            PIC_Advertiser__c = contactRecord.id
        );
        insert brandRecord;

        Contract newContract = new Contract();
        newContract.StartDate = date.today();
        newContract.ContractTerm = 1;
        newContract.AccountId = acc.id;
        insert newContract;
        
        newContract.Status = 'Activated';
        update newContract;

        Contact cont = new Contact();
        cont.lastName ='Doddy';
        cont.accountid = acc.id;
        insert cont;
        
        Opportunity opp = new Opportunity();
        opp.name = 'TEst';
        opp.regional__c = 'BALINUSRA';
        opp.StageName ='Prospecting';
        opp.accountid = acc.id;
        opp.brand__c = brandRecord.id;

        Pricebook2 PB=[SELECT id from PriceBook2 limit 1];
        opp.Pricebook2id=PB.id;
        opp.CloseDate=system.today().adddays(10);
        opp.Approval_Status__c='Approved';
        opp.Check_PO__c='OK';
        Upsert opp;
        
        
        //SOA
        SOA__c newSOA = new SOA__c();
        newSOA.SOA_Start_Date__c= date.today();
        newSOA.SOA_End_Date__c= date.today();
        newSOA.Opportunity__c=opp.id;
        /*
        Upsert newSOA;
        */
        List<SOA__c> lnewsoa=[SELECT id,name FROM SOA__c where id=:newSOA.id LIMIT 1];
        
     
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'PrivyID';
        cv.PathOnClient = 'PrivyID.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
         
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
         List<ContentVersion> csv = AppUtils.getPrivyFilesOnBase64(newSOA.id) ;
         
         String randomString = AppUtils.fungsirandom();
        Test.stopTest();
        
    }

    @isTest static void testNextDate() {
        // Create a holiday
        Holiday h = new Holiday(
            Name = 'Test Holiday',
            ActivityDate = Date.newInstance(2023, 3, 10),
            IsAllDay = true
        );
        insert h;
        
        // Test adding 3 business days, excluding holidays and weekends
        Date startDate = Date.newInstance(2023, 3, 6); // Sunday
        Date expectedNextDate = Date.newInstance(2023, 3, 9); // Wednesday
        Date actualNextDate = Apputils.nextDate(startDate, 3, false, false, false);
        
        
        // Test adding 5 calendar days, including holidays and weekends
        startDate = Date.newInstance(2023, 3, 6); // Sunday
        expectedNextDate = Date.newInstance(2023, 3, 12); // Saturday
        actualNextDate = Apputils.nextDate(startDate, 5, true, true, true);
        
        
        // Test adding 1 calendar day, excluding holidays and weekends, but including Saturdays
        startDate = Date.newInstance(2023, 3, 9); // Wednesday
        expectedNextDate = Date.newInstance(2023, 3, 10); // Thursday
        actualNextDate = Apputils.nextDate(startDate, 1, false, true, false);
        
        
        // Test adding 1 calendar day, excluding holidays and weekends, but including Sundays
        startDate = Date.newInstance(2023, 3, 9); // Wednesday
        expectedNextDate = Date.newInstance(2023, 3, 10); // Thursday
        actualNextDate = Apputils.nextDate(startDate, 1, false, false, true);
        
        
        // Test adding 1 calendar day, excluding holidays and weekends, but including both Saturdays and Sundays
        startDate = Date.newInstance(2023, 3, 9); // Wednesday
        expectedNextDate = Date.newInstance(2023, 3, 11); // Friday
        actualNextDate = Apputils.nextDate(startDate, 1, false, true, true);
        
        
        // Test adding 1 calendar day, including holidays, but excluding weekends
        startDate = Date.newInstance(2023, 3, 9); // Wednesday
        expectedNextDate = Date.newInstance(2023, 3, 10); // Thursday
        actualNextDate = Apputils.nextDate(startDate, 1, true, false, false);
        
        
        // Test adding 1 calendar day, excluding holidays, but including both Saturdays and Sundays
        startDate = Date.newInstance(2023, 3, 9); // Wednesday
        expectedNextDate = Date.newInstance(2023, 3, 11); // Friday
        actualNextDate = Apputils.nextDate(startDate, 1, false, true, true);
        
        
        // Test adding 1 calendar day, including a holiday and excluding weekends
        startDate = Date.newInstance(2023, 3, 8); // Tuesday
        expectedNextDate = Date.newInstance(2023, 3, 12); // Saturday
        actualNextDate = Apputils.nextDate(startDate, 1, true, false, false);
    }
    
    
}