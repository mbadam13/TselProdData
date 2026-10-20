/*
Can be used for below trigger:
# Trigger_Order_After_Insert
# Trigger_Order_After_Update
*/

//@isTest(seealldata=true)
@isTest
public class Test_Trigger_Order_After_Insert {
    
    @testSetup static void setup() {
        Trigger_Setting__c triggerSettingsRecValidationStartDateIsExist = new Trigger_Setting__c();
        triggerSettingsRecValidationStartDateIsExist.IsActive__c = false;
        triggerSettingsRecValidationStartDateIsExist.name = 'Validation:_Deal_ID_Must_be_filled';
        triggerSettingsRecValidationStartDateIsExist.Error_Message__c = 'Tidak bisa membuat additional setting karena sudah tersedia, silahkan buat ditanggal berbeda';
        triggerSettingsRecValidationStartDateIsExist.Object_Name__c = 'Opportunity';
        
        insert triggerSettingsRecValidationStartDateIsExist;
        
        Trigger_Setting__c triggerSettingsRecValidationOrderMusthaveOppty = new Trigger_Setting__c();
        triggerSettingsRecValidationOrderMusthaveOppty.IsActive__c = false;
        triggerSettingsRecValidationOrderMusthaveOppty.name = 'validation:_orderMustHaveOpportunity';
        triggerSettingsRecValidationOrderMusthaveOppty.Error_Message__c = 'Please set Opportunity to create new Order.';
        triggerSettingsRecValidationOrderMusthaveOppty.Object_Name__c = 'Order';
        
        insert triggerSettingsRecValidationOrderMusthaveOppty;
        
/*
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
    opp.brand__c = brandRecord.id;
    opp.Account_Type__c = 'Advertiser';
    opp.CloseDate = system.today();
    opp.StageName = 'Prospecting';
    opp.Templated_Proposal__c = true;
    opp.regional__c = 'BALINUSRA';
    insert opp; 
    system.debug('>>> opp = ' + opp);

    Opportunity opp1 = new Opportunity();
    opp1.Name = 'Test';
    opp1.AccountId = acc.Id;
    opp1.brand__c = brandRecord.id;
    opp1.Account_Type__c = 'Advertiser';
    opp1.CloseDate = system.today();
    opp1.StageName = 'Prospecting';
    opp1.Templated_Proposal__c = true;
    opp1.regional__c = 'HEAD OFFICE';
    opp1.Adjustment_Version__c = 2;
    insert opp1; 

    opp.Templated_Proposal__c = true;
    update opp;

    opp.StageName = 'Visit / Call';
    opp.Pricebook2Id = Test.getStandardPricebookId();
    update opp;

    List<Product2> prodListToInsert = new List<Product2>();

    Product2 prod1 = new Product2();
    prod1.Name = 'BULK (SMS)';
    prod1.ProductCode = 'Messaging';
    prod1.Product_Type__c = 'SMS';
    prod1.Buying_Method__c = 'I/O';
    prod1.Family = 'SMS';
    prod1.IsActive = true;
    prod1.Product_Category__c = 'Advertising';
    prodListToInsert.add(prod1);

    Product2 prod2 = new Product2();
    prod2.Name = 'FRIDA | 3.001 - 10.000 GB';
    prod2.ProductCode = 'Reward';
    prod2.Product_Type__c = 'Data Reward';
    prod2.Buying_Method__c = 'I/O';
    prod2.Family = 'Data Reward';
    prod2.IsActive = true;
    prod2.Product_Category__c = 'Advertising';
    prodListToInsert.add(prod2);

    Product2 prod3 = new Product2();
    prod3.Name = 'GITA | 3 GB 30 days';
    prod3.ProductCode = 'Reward';
    prod3.Product_Type__c = 'Data Reward';
    prod3.Buying_Method__c = 'I/O';
    prod3.Family = 'Data Reward';
    prod3.IsActive = true;
    prod3.Product_Category__c = 'Advertising';
    prodListToInsert.add(prod3);

    Product2 prod4 = new Product2();
    prod4.Name = 'IVR Bulk Advertising';
    prod4.ProductCode = 'Messaging';
    prod4.Product_Type__c = 'IVR';
    prod4.Buying_Method__c = 'I/O';
    prod4.Family = 'IVR';
    prod4.IsActive = true;
    prod4.Product_Category__c = 'Advertising';
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
    system.debug('>>> pbeListToInsert = ' + pbeListToInsert);*/
        }
        /*
    static testMethod void testMethod_Create_Order() {
    /*Test.startTest();

    LIST<user> u=[SELECT id from user where username='andi_mario@telkomsel.co.id' LIMIT 1];
    List<Product2> prod=[SELECT id FROM Product2 where Name='SMS Bulk OTP' LIMIT 1];
    List<PricebookEntry> pbe=[SELECT id FROM PricebookEntry where Product2Id=:prod[0].id LIMIT 1];
    Account acc = new Account ();

    Account A=[SELECT id from Account where Ownerid=:u[0].id LIMIT 1];
    acc = a;
    acc.npwp__c='123412';
    acc.Status__c='Approved by Settlement';
    upsert acc id;
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
    Upsert opp id;

    opp.StageName ='Closed Won';
    Upsert opp id;

    OpportunityLineItem oli =new OpportunityLineItem();
    oli.Product2id=prod[0].id;
    oli.Quantity=1000;
    oli.UnitPrice=100000;
    oli.PricebookEntryId=pbe[0].id;
    oli.opportunityid=opp.id;
    Upsert oli id;

    //Contract
    Contract newContract = new Contract();
    newContract.StartDate= date.today();
    newContract.ContractTerm= 1;
    newContract.Opportunity__c=opp.id;
    newContract.AccountId=acc.id;
    upsert newContract;

    newContract.Status='Activated';
    upsert newContract id;

    List<Contract> LContract=[SELECT id from Contract where id=:newContract.id LIMIT 1];

    //SOA
    SOA__c newSOA = new SOA__c();
    newSOA.SOA_Start_Date__c= date.today();
    newSOA.SOA_End_Date__c= date.today();
    newSOA.Opportunity__c=opp.id;

    Upsert newSOA id;

    List<SOA__c> lnewsoa=[SELECT id,name FROM SOA__c where id=:newSOA.id LIMIT 1];

    //SOA Detail
    SOA_Detail__c newSOADetail = new SOA_Detail__c();
    newSOADetail.Start_Date__c= date.today();
    newSOADetail.End_Date__c= date.today();
    newSOADetail.SOA__c=newSOA.id;
    newSOADetail.Campaign_ID__c=lnewsoa[0].Name+'_'+'001'+'_'+1;
    newSOADetail.PricebookEntryId__c=pbe[0].id;
    newSOADetail.product__c=prod[0].id;
    newSOADetail.Quantity__c=1000;
    newSOADetail.Unit_Price__c=100000;

    Upsert newSOADetail;
    system.debug('isi debug newSOADetail'+newSOADetail.name);

    List<SOA_Detail__c> lnewsoadetails=[SELECT id,name,campaign_id__c FROM SOA_Detail__c where soa__c=:newSOA.id];
    system.debug('size lnewsoadetails'+lnewsoadetails.size());


    for(SOA_Detail__c thisItem : lnewsoadetails)
    {
    system.debug('isi debug camp id'+thisItem.campaign_id__c);
    }
    //Order
    Order odr = new Order();
    odr.Pricebook2id=PB.id;
    odr.OpportunityId=opp.id;
    odr.ContractId=LContract[0].id;
    odr.EffectiveDate=system.today();
    odr.EndDate=system.today().adddays(10);
    odr.SOA__c=newSOA.id;
    odr.status='Draft';

    upsert odr;

    List<Order> lneworder=[SELECT id,name,OrderNumber FROM Order where id=:odr.id LIMIT 1];

    OrderItem odit = new OrderItem();

    odit.Product2id=prod[0].id;
    odit.Quantity=1000;
    odit.UnitPrice=100000;
    odit.campaign_id__c=Date.today().year()+'_B'+lneworder[0].OrderNumber+'_'+lnewsoa[0].Name+'_'+'001'+'_'+2;
    //odit.camp_id__c=lnewsoa[0].Name+'_'+'001'+'_'+1;
    odit.PricebookEntryId=pbe[0].id;
    odit.OrderId =odr.id;
    upsert odit;

    List<OrderItem> lodit=[SELECT id,Product2id,campaign_id__c,camp_id__c FROM OrderItem where id=:odit.id LIMIT 1];
    Test.stopTest();

    }
    */
        /*
    static testMethod void testMethod_orderPostpaid() { 

    List<Account> accList = [SELECT Id, Name FROM Account ORDER BY CreatedDate ASC];

    List<Contact> ctList = [SELECT Id, Name FROM Contact ORDER BY CreatedDate ASC];

    List<Opportunity> oppList = [SELECT Id, Name, AccountId, Account_Type__c, CloseDate, StageName FROM Opportunity where regional__c = 'BALINUSRA' ORDER BY CreatedDate ASC];

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
    test.startTest();
    insert soa_rec;


    Order ord_rec = new Order();
    ord_rec.status = 'Draft';
    ord_rec.EffectiveDate = system.today();
    ord_rec.EndDate = system.today().adddays(10);
    ord_rec.AccountId = accList[0].id;
    ord_rec.SOA__c = soa_rec.id;
    ord_rec.Pricebook2id = Test.getStandardPricebookId();
    try
    {insert ord_rec;}
    catch(Exception ex)
    {Boolean expectedExceptionThrown =  ex.getMessage().contains('Opportunity ') ? true : false;}

    ord_rec.OpportunityId = oppList[0].Id;
    try
    {insert ord_rec;}
    catch(Exception ex)
    {Boolean expectedExceptionThrown =  ex.getMessage().contains('Opportunity ') ? true : false;}

    oppList[0].StageName = 'Closed Won';
    update oppList[0];

    List<Order> ordList = [SELECT Id FROM Order ORDER BY CreatedDate ASC limit 1];

    List<OrderItem> oilist = new List<OrderItem>();

    if(ordList.size() > 0){
    oilist = [SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Camp_ID__c, Campaign_ID__c, 
    Opportunity__c, ServiceDate, EndDate, Opp_Product_Id__c, Product_id_number__c 
    FROM OrderItem 
    WHERE OrderId =: ordList[0].Id 
    ORDER BY CreatedDate ASC limit 1];
    if(oilist.size() > 0){
    oilist[0].Quantity = 50;
    update oilist[0];
    }

    SOA_Detail__c soad_rec = new SOA_Detail__c();
    soad_rec.SOA__c = soa_rec.Id;
    soad_rec.Product__c = prodList[2].Id;
    soad_rec.Opp_Product_Id__c = '1234567890';
    soad_rec.Quantity__c = 70;
    soad_rec.Unit_Price__c = 100;
    soad_rec.List_Price__c = 100;
    soad_rec.Campaign_ID__c = 'camp001';
    insert soad_rec;

    OrderItem oi_rec = new OrderItem();
    oi_rec.OrderId = ordList[0].Id;
    oi_rec.Quantity = 50;
    oi_rec.UnitPrice = 100;
    oi_rec.PricebookEntryId = pbeList[2].Id;
    oi_rec.Opportunity__c = oppList[0].Id;
    oi_rec.Campaign_ID__c = 'campaignID001';
    oi_rec.Opp_Product_Id__c = '1234567890';
    insert oi_rec;
    }

    // Order ord_rec2 = new Order();
    //     ord_rec2.status = 'Draft';
    //     ord_rec2.EffectiveDate = system.today();
    //     ord_rec2.EndDate = system.today().adddays(15);
    //     ord_rec2.AccountId = accList[0].id;
    //     ord_rec2.SOA__c = soa_rec.id;
    //     ord_rec2.Pricebook2id = Test.getStandardPricebookId(); 
    //     ord_rec2.OpportunityId = oppList[0].Id;
    // insert ord_rec2;
    Test.stopTest();
    }*/
        /*
    static testMethod void testMethod_orderPostpaidAdjVersion() { 

    List<Account> accList = [SELECT Id, Name FROM Account ORDER BY CreatedDate ASC];

    List<Contact> ctList = [SELECT Id, Name FROM Contact ORDER BY CreatedDate ASC];

    List<Opportunity> oppList = [SELECT Id, Name, AccountId, Account_Type__c, CloseDate, StageName FROM Opportunity where regional__c = 'HEAD OFFICE' ORDER BY CreatedDate ASC];

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

    oppList[0].Type = 'New Business';
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
    test.startTest();
    insert soa_rec;


    Order ord_rec = new Order();
    ord_rec.status = 'Draft';
    ord_rec.EffectiveDate = system.today();
    ord_rec.EndDate = system.today().adddays(10);
    ord_rec.AccountId = accList[0].id;
    ord_rec.SOA__c = soa_rec.id;
    ord_rec.Pricebook2id = Test.getStandardPricebookId();
    try
    {insert ord_rec;}
    catch(Exception ex)
    {Boolean expectedExceptionThrown =  ex.getMessage().contains('Opportunity ') ? true : false;}

    ord_rec.OpportunityId = oppList[0].Id;
    try
    {insert ord_rec;}
    catch(Exception ex)
    {Boolean expectedExceptionThrown =  ex.getMessage().contains('Opportunity ') ? true : false;}

    oppList[0].StageName = 'Closed Won';
    update oppList[0];

    List<Order> ordList = [SELECT Id FROM Order ORDER BY CreatedDate ASC limit 1];

    List<OrderItem> oilist = new List<OrderItem>();

    if(ordList.size() > 0){
    oilist = [SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Camp_ID__c, Campaign_ID__c, 
    Opportunity__c, ServiceDate, EndDate, Opp_Product_Id__c, Product_id_number__c 
    FROM OrderItem 
    WHERE OrderId =: ordList[0].Id 
    ORDER BY CreatedDate ASC limit 1];
    if(oilist.size() > 0){
    oilist[0].Quantity = 50;
    update oilist[0];
    }

    SOA_Detail__c soad_rec = new SOA_Detail__c();
    soad_rec.SOA__c = soa_rec.Id;
    soad_rec.Product__c = prodList[2].Id;
    soad_rec.Opp_Product_Id__c = '1234567890';
    soad_rec.Quantity__c = 70;
    soad_rec.Unit_Price__c = 100;
    soad_rec.List_Price__c = 100;
    soad_rec.Campaign_ID__c = 'camp001';
    insert soad_rec;

    OrderItem oi_rec = new OrderItem();
    oi_rec.OrderId = ordList[0].Id;
    oi_rec.Quantity = 50;
    oi_rec.UnitPrice = 100;
    oi_rec.PricebookEntryId = pbeList[2].Id;
    oi_rec.Opportunity__c = oppList[0].Id;
    oi_rec.Campaign_ID__c = 'campaignID001';
    oi_rec.Opp_Product_Id__c = '1234567890';
    insert oi_rec;
    }

    // Order ord_rec2 = new Order();
    //     ord_rec2.status = 'Draft';
    //     ord_rec2.EffectiveDate = system.today();
    //     ord_rec2.EndDate = system.today().adddays(15);
    //     ord_rec2.AccountId = accList[0].id;
    //     ord_rec2.SOA__c = soa_rec.id;
    //     ord_rec2.Pricebook2id = Test.getStandardPricebookId(); 
    //     ord_rec2.OpportunityId = oppList[0].Id;
    // insert ord_rec2;
    Test.stopTest();
    }
    */
        /*
    static testMethod void testMethod_orderPrepaid() {

    Test.startTest();

    List<Contact> ctList = [SELECT Id, Name, AccountId FROM Contact ORDER BY CreatedDate ASC];

    List<Opportunity> oppList = [SELECT Id, Name, AccountId, Account_Type__c, CloseDate, StageName FROM Opportunity WHERE regional__c = 'BALINUSRA' ORDER BY CreatedDate ASC];

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

    insert oliListToInsert;
    system.debug('>>> oliListToInsert.size() = ' + oliListToInsert.size());
    system.debug('>>> oliListToInsert = ' + oliListToInsert);

    oppList[0].Type = 'Existing Business';
    oppList[0].Penagihan_based_on__c = 'Prepaid';
    oppList[0].StageName = 'Negotiation';
    //update oppList[0];

    oppList[0].StageName = 'Proposal';
    oppList[0].isSubmitCheckPOApproval__c = true;
    oppList[0].Approval_Status__c = 'Approved';
    oppList[0].Check_PO__c = 'OK';
    //update oppList[0];

    Quote qt = new Quote();
    qt.Name = 'Test Quote';
    qt.ContactId = ctList[0].Id;
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

    oppList[0].StageName = 'Closed Won';
    update oppList[0];

    qt.Status = 'Final';
    update qt;

    oppList[0].StageName = 'Negotiation';
    update oppList[0];

    Test.stopTest();

    oppList[0].StageName = 'Proposal';
    oppList[0].isSubmitCheckPOApproval__c = true;
    oppList[0].Approval_Status__c = 'Approved';
    oppList[0].Check_PO__c = 'OK';
    //update oppList[0];

    oppList[0].StageName = 'Closed Won';
    update oppList[0];

    List<Order> ordList = [SELECT Id FROM Order ORDER BY CreatedDate ASC];

    List<OrderItem> oilist = new List<OrderItem>();

    if(ordList.size() > 0){
    oilist = [SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Camp_ID__c, Campaign_ID__c, 
    Opportunity__c, ServiceDate, EndDate, Opp_Product_Id__c, Product_id_number__c 
    FROM OrderItem 
    WHERE OrderId =: ordList[0].Id 
    ORDER BY CreatedDate ASC];
    if(oilist.size() > 0){
    oilist[0].Quantity = 50;
    update oilist[0];
    }

    List<QuoteBU__c> qbuList = [SELECT Id FROM QuoteBU__c WHERE Quote__c =: qt.Id];

    if(qbuList.size() > 0){

    QuoteBU_Detail__c qbud_rec = new QuoteBU_Detail__c();
    qbud_rec.QuoteBU__c = qbuList[0].Id;
    qbud_rec.Product__c = prodList[2].Id;
    qbud_rec.Opp_Product_Id__c = '1234567890';
    qbud_rec.Quantity__c = 70;
    qbud_rec.Unit_Price__c = 100;
    qbud_rec.Campaign_ID__c = 'camp001';
    insert qbud_rec;

    OrderItem oi_rec = new OrderItem();
    oi_rec.OrderId = ordList[0].Id;
    oi_rec.Quantity = 70;
    oi_rec.UnitPrice = 100;
    oi_rec.PricebookEntryId = pbeList[2].Id;
    oi_rec.Opportunity__c = oppList[0].Id;
    oi_rec.Campaign_ID__c = 'campaignID001';
    oi_rec.Opp_Product_Id__c = '1234567890';
    insert oi_rec;
    }
    }

    Order ord_rec = new Order();
    ord_rec.status = 'Draft';
    ord_rec.EffectiveDate = system.today();
    ord_rec.EndDate = system.today().adddays(10);
    ord_rec.AccountId = oppList[0].AccountId;
    ord_rec.QuoteId = qt.id;
    ord_rec.Pricebook2id = Test.getStandardPricebookId(); 
    ord_rec.OpportunityId = oppList[0].Id;
    insert ord_rec;              
    }

    static testMethod void testMethod_orderPrepaidAdjVersion() {

    Test.startTest();

    List<Contact> ctList = [SELECT Id, Name, AccountId FROM Contact ORDER BY CreatedDate ASC];

    List<Opportunity> oppList = [SELECT Id, Name, AccountId, Account_Type__c, CloseDate, StageName FROM Opportunity WHERE regional__c = 'HEAD OFFICE' ORDER BY CreatedDate ASC];

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

    insert oliListToInsert;
    system.debug('>>> oliListToInsert.size() = ' + oliListToInsert.size());
    system.debug('>>> oliListToInsert = ' + oliListToInsert);

    oppList[0].Type = 'Existing Business';
    oppList[0].Penagihan_based_on__c = 'Prepaid';
    oppList[0].StageName = 'Negotiation';
    //update oppList[0];

    oppList[0].StageName = 'Proposal';
    oppList[0].isSubmitCheckPOApproval__c = true;
    oppList[0].Approval_Status__c = 'Approved';
    oppList[0].Check_PO__c = 'OK';
    //update oppList[0];

    Quote qt = new Quote();
    qt.Name = 'Test Quote';
    qt.ContactId = ctList[0].Id;
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

    oppList[0].StageName = 'Closed Won';
    update oppList[0];

    qt.Status = 'Final';
    update qt;

    oppList[0].StageName = 'Negotiation';
    update oppList[0];

    Test.stopTest();

    oppList[0].StageName = 'Proposal';
    oppList[0].isSubmitCheckPOApproval__c = true;
    oppList[0].Approval_Status__c = 'Approved';
    oppList[0].Check_PO__c = 'OK';
    oppList[0].Adjustment_Version__c = 1;
    //update oppList[0];

    oppList[0].StageName = 'Closed Won';
    update oppList[0];

    List<Order> ordList = [SELECT Id FROM Order ORDER BY CreatedDate ASC];

    List<OrderItem> oilist = new List<OrderItem>();

    if(ordList.size() > 0){
    oilist = [SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Camp_ID__c, Campaign_ID__c, 
    Opportunity__c, ServiceDate, EndDate, Opp_Product_Id__c, Product_id_number__c 
    FROM OrderItem 
    WHERE OrderId =: ordList[0].Id 
    ORDER BY CreatedDate ASC];
    if(oilist.size() > 0){
    oilist[0].Quantity = 50;
    update oilist[0];
    }

    List<QuoteBU__c> qbuList = [SELECT Id FROM QuoteBU__c WHERE Quote__c =: qt.Id];

    if(qbuList.size() > 0){

    QuoteBU_Detail__c qbud_rec = new QuoteBU_Detail__c();
    qbud_rec.QuoteBU__c = qbuList[0].Id;
    qbud_rec.Product__c = prodList[2].Id;
    qbud_rec.Opp_Product_Id__c = '1234567890';
    qbud_rec.Quantity__c = 70;
    qbud_rec.Unit_Price__c = 100;
    qbud_rec.Campaign_ID__c = 'camp001';
    insert qbud_rec;

    OrderItem oi_rec = new OrderItem();
    oi_rec.OrderId = ordList[0].Id;
    oi_rec.Quantity = 70;
    oi_rec.UnitPrice = 100;
    oi_rec.PricebookEntryId = pbeList[2].Id;
    oi_rec.Opportunity__c = oppList[0].Id;
    oi_rec.Campaign_ID__c = 'campaignID001';
    oi_rec.Opp_Product_Id__c = '1234567890';
    insert oi_rec;
    }
    }

    Order ord_rec = new Order();
    ord_rec.status = 'Draft';
    ord_rec.EffectiveDate = system.today();
    ord_rec.EndDate = system.today().adddays(10);
    ord_rec.AccountId = oppList[0].AccountId;
    ord_rec.QuoteId = qt.id;
    ord_rec.Pricebook2id = Test.getStandardPricebookId(); 
    ord_rec.OpportunityId = oppList[0].Id;
    insert ord_rec;   

}
*/
    @isTest
    static void testAllOrder_withoutOppty(){
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Account acc = new Account(
            Name = 'Wira Pamungkas Pratama',          				// Account Name
            RecordTypeId = recordTypeAccId,                                  // Account Record Type
            Account_Type__c = 'Agency',                                  // Account Type
            Direct_Indirect__c = 'Direct',                               // Direct/Indirect
            Status__c = 'Approved by Settlement',                        // Status
            No_PKS__c = '123456',                                        // No PKS
            NPWP__c = '1',                                               // NPWP
            PKS_Tracker__c = 'Pending'      
        );
        insert acc;
        
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
        
        Contract contract = new Contract(
            StartDate = Date.valueOf('2019-09-01'),// Contract Start Date
            ContractTerm = 9999,                  // Contract Term (months)
            AccountId = acc.Id,
            OwnerExpirationNotice = '120',      // Owner Expiration Notice
            Status = 'Draft',                    // Status
            Terminate__c = false,                    // Terminate
            Archive__c = false,                      // Archive
            No_PKS__c = '123456',                    // No.PKS
            Contract_Signed__c = 'Circulation'     // Contract Signed ?
            // Opportunity__c = oppRecord.Id
        );
        insert contract;
        
        contract.Status = 'Activated';
        update contract;
        
        Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Agency Postpaid').getRecordTypeId();
        
        Opportunity oppRecord = new Opportunity(
            RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
            Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',  // Opportunity Name
            AccountId = acc.Id,                                                           // Account Name
            CloseDate = Date.valueOf('2024-09-21'),                                                  // Close Date
            Account_Type__c = 'Agency',                                                              // Account Type
            StageName = 'Proposal',                                                                // Stage
            Regional__c = 'HEAD OFFICE',                                                             // Regional  (Required)
            Probability = 100,                                                                       // Probability (%)
            Agency_Name__c = acc.Id,                                                      // Agency Name
            Campaign_Customize__c = false,                                                           // Campaign Customize
            Templated_Proposal__c = true,                                                            // Own Proposal?
            Approval_Remark__c = 'Approved',                                                         // Approval Remark
            Document_Version__c = 'Submit',                                                          // Document Version
            Approval_Status__c = 'Approved',                                                         // Approval Status
            Marketing_Package__c = false,                                                            // Marketing Package
            SME__c = false,                                                                          // SME
            Brand__c = brandRecord.Id,                                                            // Brand
            Type = 'Existing Business',                                                              // Type
            Penagihan_based_on__c = 'Prepaid',                                                      // Penagihan based on
            Performance_Product__c = false,                                                          // Performance Product
            Programmatic_Product__c = false,                                                         // Programmatic Product
            Performance_Done__c = false,                                                             // Performance Done
            RFP_Status_sales__c = 'Completed',                                                       // RFP Status (sales)
            Check_PO__c = 'OK',
            Pricebook2Id = Test.getStandardPricebookId(),
            Adjustment_Version__c = 1
        );
        insert oppRecord;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = new Product2(
            Name = 'BULK (SMS Premium)',                      // Product Name
            IsActive = true,                                    // Active
            Family = 'Messaging',                               // Product Family
            Product_Type__c = 'SMS',                            // Product Type
            ProductCode = 'SMS',                                // Product Code
            Ads_Format__c = 'Text',                             // Ads Format
            Ads_Detail__c = 'BULK (SMS Premium)_3telco_Icode',  // Ads Detail
            Ads_Size__c = 'Standard',                           // Ads Size
            Product_Channel__c = 'Mobile',                      // Product Channel
            Channel_Detail__c = 'Mobile',                       // Channel Detail
            Buying_Method__c = 'I/O',                           // Buying Method
            Rate_Card_Refference__c = 'Messaging',              // Rate Card Refference
            List_Price__c = 500.00,                             // List Price
            Product_Category__c = 'Advertising',                // Product Category
            Description = '500'                                // Product Description
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = oppRecord.Id,// Opportunity
            Product2Id = prod.Id,     // Product
            Discount__c = 0.00,               // Discount (%)
            PricebookEntryId = pbEntry.Id,
            UnitPrice = 500.00,                 // Sales Price
            Quantity = 1234.00              // Quantity
        );
        insert oli;
        
        test.startTest();
        Quote qt = new Quote();
        qt.Name = 'Test Quote';
        qt.ContactId = con.Id;
        qt.Start_Date__c = system.today();
        qt.End_Date__c = system.today().addDays(10);
        qt.OpportunityId = oppRecord.Id;
        insert qt;
        
        QuoteLineItem newQuoteLineItem = new QuoteLineItem();
        newQuoteLineItem.QuoteId = qt.id; // Name of the product being quoted
        newQuoteLineItem.Quantity = 100; // Quantity being quoted
        newQuoteLineItem.PricebookEntryId = pbEntry.id;
        newQuoteLineItem.Product2Id = prod.id;
        newQuoteLineItem.UnitPrice = 500; // Price per unit
        newQuoteLineItem.Description = 'This is a description of Product XYZ'; // Description of the product being quoted
        insert newQuoteLineItem;
        
        
        // Call the method with the test data
        
        Order order = new Order(
            AccountId = acc.Id,
            EffectiveDate = System.today(),
            Status = 'Draft',
            PriceBook2Id = Test.getStandardPricebookId(),
            QuoteId = qt.id,
            EndDate = system.today().adddays(10),
            Order_Type__c = 'Opportunity'
        );
        insert order;
        
        OrderItem lineItem = new OrderItem();
        lineItem.OrderId = order.id;
        lineItem.Quantity = 24;
        lineItem.UnitPrice = 240;
        lineItem.Product2id = prod.id;
        lineItem.PricebookEntryId=pbEntry.id;
        insert lineItem;    
        order.Status = 'Completed';
        update order;
        /*  try {

        } catch (Exception e) {
        Assert.areEqual('FAILED_ACTIVATION, An order must have at least one product.', e.getMessage());
        }*/
        
        
        test.stopTest();
        
        // qt.Status = 'Final';
        //update qt;
        
        //        oppList[0].SyncedQuoteId = qt.Id;
        //      update oppList[0];
    }
    
    @isTest 
    static void testCreateOrderforOppty() {
        
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Account acc = new Account(
            Name = 'Wira Pamungkas Pratama',          				// Account Name
            RecordTypeId = recordTypeAccId,                                  // Account Record Type
            Account_Type__c = 'Agency',                                  // Account Type
            Direct_Indirect__c = 'Direct',                               // Direct/Indirect
            Status__c = 'Approved by Settlement',                        // Status
            No_PKS__c = '123456',                                        // No PKS
            NPWP__c = '1',                                               // NPWP
            PKS_Tracker__c = 'Pending'      
        );
        insert acc;
        
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
        
        Contract contract = new Contract(
            StartDate = Date.valueOf('2019-09-01'),// Contract Start Date
            ContractTerm = 9999,                  // Contract Term (months)
            AccountId = acc.Id,
            OwnerExpirationNotice = '120',      // Owner Expiration Notice
            Status = 'Draft',                    // Status
            Terminate__c = false,                    // Terminate
            Archive__c = false,                      // Archive
            No_PKS__c = '123456',                    // No.PKS
            Contract_Signed__c = 'Circulation'     // Contract Signed ?
            // Opportunity__c = oppRecord.Id
        );
        insert contract;
        
        contract.Status = 'Activated';
        update contract;
        Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Agency Postpaid').getRecordTypeId();
        
        Opportunity oppRecord = new Opportunity(
            RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
            Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',  // Opportunity Name
            AccountId = acc.Id,                                                           // Account Name
            CloseDate = Date.valueOf('2024-09-21'),                                                  // Close Date
            Account_Type__c = 'Agency',                                                              // Account Type
            StageName = 'Proposal',                                                                // Stage
            Regional__c = 'HEAD OFFICE',                                                             // Regional  (Required)
            Probability = 100,                                                                       // Probability (%)
            Agency_Name__c = acc.Id,                                                      // Agency Name
            Campaign_Customize__c = false,                                                           // Campaign Customize
            Templated_Proposal__c = true,                                                            // Own Proposal?
            Approval_Remark__c = 'Approved',                                                         // Approval Remark
            Document_Version__c = 'Submit',                                                          // Document Version
            Approval_Status__c = 'Approved',                                                         // Approval Status
            Marketing_Package__c = false,                                                            // Marketing Package
            SME__c = false,                                                                          // SME
            Brand__c = brandRecord.Id,                                                            // Brand
            Type = 'Existing Business',                                                              // Type
            Penagihan_based_on__c = 'Postpaid',                                                      // Penagihan based on
            Performance_Product__c = false,                                                          // Performance Product
            Programmatic_Product__c = false,                                                         // Programmatic Product
            Performance_Done__c = false,                                                             // Performance Done
            RFP_Status_sales__c = 'Completed',                                                       // RFP Status (sales)
            Check_PO__c = 'OK',
            Pricebook2Id = Test.getStandardPricebookId()
            
        );
        insert oppRecord;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = new Product2(
            Name = 'BULK (SMS Premium)',                      // Product Name
            IsActive = true,                                    // Active
            Family = 'Messaging',                               // Product Family
            Product_Type__c = 'SMS',                            // Product Type
            ProductCode = 'SMS',                                // Product Code
            Ads_Format__c = 'Text',                             // Ads Format
            Ads_Detail__c = 'BULK (SMS Premium)_3telco_Icode',  // Ads Detail
            Ads_Size__c = 'Standard',                           // Ads Size
            Product_Channel__c = 'Mobile',                      // Product Channel
            Channel_Detail__c = 'Mobile',                       // Channel Detail
            Buying_Method__c = 'I/O',                           // Buying Method
            Rate_Card_Refference__c = 'Messaging',              // Rate Card Refference
            List_Price__c = 500.00,                             // List Price
            Product_Category__c = 'Advertising',                // Product Category
            Description = '500'                                // Product Description
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = oppRecord.Id,// Opportunity
            Product2Id = prod.Id,     // Product
            Discount__c = 0.00,               // Discount (%)
            PricebookEntryId = pbEntry.Id,
            UnitPrice = 500.00,                 // Sales Price
            Quantity = 1234.00              // Quantity
        );
        insert oli;
        oppRecord.StageName = 'Closed Won';
        update oppRecord;
        acc.ContractId__c = contract.Id;
        update acc;
        Test.startTest();
        
        SOA__c soaRecord = new SOA__c(
            Opportunity__c = oppRecord.Id,              // Opportunity
            SOA_Type__c = 'Opportunity',                     // SOA Type
            SOA_Start_Date__c = Date.valueOf('2024-10-01'),  // SOA Start Date
            SOA_End_Date__c = Date.valueOf('2024-10-31'),    // SOA End Date
            SOA_Sources__c = 'Opportunity'                  // SOA
        );
        insert soaRecord;
        
        // Call the method with the test data
        List<SOA__c> soaList = new List<SOA__c>{soaRecord};
            
            SoaService.createOrderforOppty(soaList);
        
        Test.stopTest();
    }
    
    @isTest 
    static void testCreateOrderforOpptyAdjustmentpost() {
        
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Account acc = new Account(
            Name = 'Wira Pamungkas Pratama',          				// Account Name
            RecordTypeId = recordTypeAccId,                                  // Account Record Type
            Account_Type__c = 'Agency',                                  // Account Type
            Direct_Indirect__c = 'Direct',                               // Direct/Indirect
            Status__c = 'Approved by Settlement',                        // Status
            No_PKS__c = '123456',                                        // No PKS
            NPWP__c = '1',                                               // NPWP
            PKS_Tracker__c = 'Pending'      
        );
        insert acc;
        
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
        
        Contract contract = new Contract(
            StartDate = Date.valueOf('2019-09-01'),// Contract Start Date
            ContractTerm = 9999,                  // Contract Term (months)
            AccountId = acc.Id,
            OwnerExpirationNotice = '120',      // Owner Expiration Notice
            Status = 'Draft',                    // Status
            Terminate__c = false,                    // Terminate
            Archive__c = false,                      // Archive
            No_PKS__c = '123456',                    // No.PKS
            Contract_Signed__c = 'Circulation'     // Contract Signed ?
            // Opportunity__c = oppRecord.Id
        );
        insert contract;
        
        contract.Status = 'Activated';
        update contract;
        Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Agency Postpaid').getRecordTypeId();
        
        Opportunity oppRecord = new Opportunity(
            RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
            Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',  // Opportunity Name
            AccountId = acc.Id,                                                           // Account Name
            CloseDate = Date.valueOf('2024-09-21'),                                                  // Close Date
            Account_Type__c = 'Agency',                                                              // Account Type
            StageName = 'Proposal',                                                                // Stage
            Regional__c = 'HEAD OFFICE',                                                             // Regional  (Required)
            Probability = 100,                                                                       // Probability (%)
            Agency_Name__c = acc.Id,                                                      // Agency Name
            Campaign_Customize__c = false,                                                           // Campaign Customize
            Templated_Proposal__c = true,                                                            // Own Proposal?
            Approval_Remark__c = 'Approved',                                                         // Approval Remark
            Document_Version__c = 'Submit',                                                          // Document Version
            Approval_Status__c = 'Approved',                                                         // Approval Status
            Marketing_Package__c = false,                                                            // Marketing Package
            SME__c = false,                                                                          // SME
            Brand__c = brandRecord.Id,                                                            // Brand
            Type = 'Existing Business',                                                              // Type
            Penagihan_based_on__c = 'Postpaid',                                                      // Penagihan based on
            Performance_Product__c = false,                                                          // Performance Product
            Programmatic_Product__c = false,                                                         // Programmatic Product
            Performance_Done__c = false,                                                             // Performance Done
            RFP_Status_sales__c = 'Completed',                                                       // RFP Status (sales)
            Check_PO__c = 'OK',
            Pricebook2Id = Test.getStandardPricebookId(),
            Adjustment_Version__c = 1
            
            
        );
        insert oppRecord;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = new Product2(
            Name = 'BULK (SMS Premium)',                      // Product Name
            IsActive = true,                                    // Active
            Family = 'Messaging',                               // Product Family
            Product_Type__c = 'SMS',                            // Product Type
            ProductCode = 'SMS',                                // Product Code
            Ads_Format__c = 'Text',                             // Ads Format
            Ads_Detail__c = 'BULK (SMS Premium)_3telco_Icode',  // Ads Detail
            Ads_Size__c = 'Standard',                           // Ads Size
            Product_Channel__c = 'Mobile',                      // Product Channel
            Channel_Detail__c = 'Mobile',                       // Channel Detail
            Buying_Method__c = 'I/O',                           // Buying Method
            Rate_Card_Refference__c = 'Messaging',              // Rate Card Refference
            List_Price__c = 500.00,                             // List Price
            Product_Category__c = 'Advertising',                // Product Category
            Description = '500'                                // Product Description
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = oppRecord.Id,// Opportunity
            Product2Id = prod.Id,     // Product
            Discount__c = 0.00,               // Discount (%)
            PricebookEntryId = pbEntry.Id,
            UnitPrice = 500.00,                 // Sales Price
            Quantity = 1234.00              // Quantity
        );
        insert oli;
        
        oppRecord.isSubmitCheckPOApproval__c = true;
        oppRecord.StageName = 'Closed Won';
        update oppRecord;
        acc.ContractId__c = contract.Id;
        update acc;
        Test.startTest();
        
        SOA__c soaRecord = new SOA__c(
            Opportunity__c = oppRecord.Id,              // Opportunity
            SOA_Type__c = 'Opportunity',                     // SOA Type
            SOA_Start_Date__c = Date.valueOf('2024-10-01'),  // SOA Start Date
            SOA_End_Date__c = Date.valueOf('2024-10-31'),    // SOA End Date
            SOA_Sources__c = 'Opportunity'                  // SOA
        );
        insert soaRecord;
        
        // Call the method with the test data
        List<SOA__c> soaList = new List<SOA__c>{soaRecord};
            
            SoaService.createOrderforOppty(soaList);
        SoaService.createOrderforOppty(soaList);
        
        Test.stopTest();
    }
    
    @isTest 
    static void testCreateOrderforOpptyAdjnegatifpost() {
        
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Account acc = new Account(
            Name = 'Wira Pamungkas Pratama',          				// Account Name
            RecordTypeId = recordTypeAccId,                                  // Account Record Type
            Account_Type__c = 'Agency',                                  // Account Type
            Direct_Indirect__c = 'Direct',                               // Direct/Indirect
            Status__c = 'Approved by Settlement',                        // Status
            No_PKS__c = '123456',                                        // No PKS
            NPWP__c = '1',                                               // NPWP
            PKS_Tracker__c = 'Pending'      
        );
        insert acc;
        
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
        
        Contract contract = new Contract(
            StartDate = Date.valueOf('2019-09-01'),// Contract Start Date
            ContractTerm = 9999,                  // Contract Term (months)
            AccountId = acc.Id,
            OwnerExpirationNotice = '120',      // Owner Expiration Notice
            Status = 'Draft',                    // Status
            Terminate__c = false,                    // Terminate
            Archive__c = false,                      // Archive
            No_PKS__c = '123456',                    // No.PKS
            Contract_Signed__c = 'Circulation'     // Contract Signed ?
            // Opportunity__c = oppRecord.Id
        );
        insert contract;
        
        contract.Status = 'Activated';
        update contract;
        Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Agency Postpaid').getRecordTypeId();
        
        Opportunity oppRecord = new Opportunity(
            RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
            Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',  // Opportunity Name
            AccountId = acc.Id,                                                           // Account Name
            CloseDate = Date.valueOf('2024-09-21'),                                                  // Close Date
            Account_Type__c = 'Agency',                                                              // Account Type
            StageName = 'Proposal',                                                                // Stage
            Regional__c = 'HEAD OFFICE',                                                             // Regional  (Required)
            Probability = 100,                                                                       // Probability (%)
            Agency_Name__c = acc.Id,                                                      // Agency Name
            Campaign_Customize__c = false,                                                           // Campaign Customize
            Templated_Proposal__c = true,                                                            // Own Proposal?
            Approval_Remark__c = 'Approved',                                                         // Approval Remark
            Document_Version__c = 'Submit',                                                          // Document Version
            Approval_Status__c = 'Approved',                                                         // Approval Status
            Marketing_Package__c = false,                                                            // Marketing Package
            SME__c = false,                                                                          // SME
            Brand__c = brandRecord.Id,                                                            // Brand
            Type = 'Existing Business',                                                              // Type
            Penagihan_based_on__c = 'Postpaid',                                                      // Penagihan based on
            Performance_Product__c = false,                                                          // Performance Product
            Programmatic_Product__c = false,                                                         // Programmatic Product
            Performance_Done__c = false,                                                             // Performance Done
            RFP_Status_sales__c = 'Completed',                                                       // RFP Status (sales)
            Check_PO__c = 'OK',
            Pricebook2Id = Test.getStandardPricebookId(),
            Adjustment_Version__c = 1
            
            
        );
        insert oppRecord;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = new Product2(
            Name = 'BULK (SMS Premium)',                      // Product Name
            IsActive = true,                                    // Active
            Family = 'Messaging',                               // Product Family
            Product_Type__c = 'SMS',                            // Product Type
            ProductCode = 'SMS',                                // Product Code
            Ads_Format__c = 'Text',                             // Ads Format
            Ads_Detail__c = 'BULK (SMS Premium)_3telco_Icode',  // Ads Detail
            Ads_Size__c = 'Standard',                           // Ads Size
            Product_Channel__c = 'Mobile',                      // Product Channel
            Channel_Detail__c = 'Mobile',                       // Channel Detail
            Buying_Method__c = 'I/O',                           // Buying Method
            Rate_Card_Refference__c = 'Messaging',              // Rate Card Refference
            List_Price__c = 500.00,                             // List Price
            Product_Category__c = 'Advertising',                // Product Category
            Description = '500'                                // Product Description
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = oppRecord.Id,// Opportunity
            Product2Id = prod.Id,     // Product
            Discount__c = 0.00,               // Discount (%)
            PricebookEntryId = pbEntry.Id,
            UnitPrice = 500.00,                 // Sales Price
            Quantity = 1234.00              // Quantity
        );
        insert oli;
        
        oppRecord.isSubmitCheckPOApproval__c = true;
        oppRecord.StageName = 'Closed Won';
        update oppRecord;
        acc.ContractId__c = contract.Id;
        update acc;
        Test.startTest();
        
        SOA__c soaRecord = new SOA__c(
            Opportunity__c = oppRecord.Id,              // Opportunity
            SOA_Type__c = 'Opportunity',                     // SOA Type
            SOA_Start_Date__c = Date.valueOf('2024-10-01'),  // SOA Start Date
            SOA_End_Date__c = Date.valueOf('2024-10-31'),    // SOA End Date
            SOA_Sources__c = 'Opportunity'                  // SOA
        );
        insert soaRecord;
        
       SOA_Detail__c soaDetail = new SOA_Detail__c(
          Campaign_ID__c = 'S02409_291_1',           // Campaign ID
          SOA__c = soaRecord.Id,                  // SOA
          Product__c = prod.Id,              // Product
          Type__c = 'New',                             // Type
          Start_Date__c = Date.valueOf('2024-10-01'),  // Start Date
          Quantity__c = 1234,                    // Quantity
          End_Date__c = Date.valueOf('2024-10-31'),    // End Date
          Unit_Price__c = 500.00,                      // Unit Price
          List_Price__c = 500.00,                      // List Price
          Discount__c = 0.00,                        // Discount
          Opp_Product_Id__c = null    // Opp Product Id
        );
       insert soaDetail;
        
        // Call the method with the test data
        List<SOA__c> soaList = new List<SOA__c>{soaRecord};
            
            SoaService.createOrderforOppty(soaList);
        SoaService.createOrderforOppty(soaList);
        
        Test.stopTest();
    }
    
    @isTest 
    static void testCreateOrderforOpptyAdjustmentpre() {
        
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Account acc = new Account(
            Name = 'Wira Pamungkas Pratama',          				// Account Name
            RecordTypeId = recordTypeAccId,                                  // Account Record Type
            Account_Type__c = 'Agency',                                  // Account Type
            Direct_Indirect__c = 'Direct',                               // Direct/Indirect
            Status__c = 'Approved by Settlement',                        // Status
            No_PKS__c = '123456',                                        // No PKS
            NPWP__c = '1',                                               // NPWP
            PKS_Tracker__c = 'Pending'      
        );
        insert acc;
        
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
        
        Contract contract = new Contract(
            StartDate = Date.valueOf('2019-09-01'),// Contract Start Date
            ContractTerm = 9999,                  // Contract Term (months)
            AccountId = acc.Id,
            OwnerExpirationNotice = '120',      // Owner Expiration Notice
            Status = 'Draft',                    // Status
            Terminate__c = false,                    // Terminate
            Archive__c = false,                      // Archive
            No_PKS__c = '123456',                    // No.PKS
            Contract_Signed__c = 'Circulation'     // Contract Signed ?
            // Opportunity__c = oppRecord.Id
        );
        insert contract;
        
        contract.Status = 'Activated';
        update contract;
        Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Agency Postpaid').getRecordTypeId();
        
        Opportunity oppRecord = new Opportunity(
            RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
            Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',  // Opportunity Name
            AccountId = acc.Id,                                                           // Account Name
            CloseDate = Date.valueOf('2024-09-21'),                                                  // Close Date
            Account_Type__c = 'Agency',                                                              // Account Type
            StageName = 'Proposal',                                                                // Stage
            Regional__c = 'HEAD OFFICE',                                                             // Regional  (Required)
            Probability = 100,                                                                       // Probability (%)
            Agency_Name__c = acc.Id,                                                      // Agency Name
            Campaign_Customize__c = false,                                                           // Campaign Customize
            Templated_Proposal__c = true,                                                            // Own Proposal?
            Approval_Remark__c = 'Approved',                                                         // Approval Remark
            Document_Version__c = 'Submit',                                                          // Document Version
            Approval_Status__c = 'Approved',                                                         // Approval Status
            Marketing_Package__c = false,                                                            // Marketing Package
            SME__c = false,                                                                          // SME
            Brand__c = brandRecord.Id,                                                            // Brand
            Type = 'Existing Business',                                                              // Type
            Penagihan_based_on__c = 'Prepaid',                                                      // Penagihan based on
            Performance_Product__c = false,                                                          // Performance Product
            Programmatic_Product__c = false,                                                         // Programmatic Product
            Performance_Done__c = false,                                                             // Performance Done
            RFP_Status_sales__c = 'Completed',                                                       // RFP Status (sales)
            Check_PO__c = 'OK',
            Pricebook2Id = Test.getStandardPricebookId(),
            Adjustment_Version__c = 1
            
            
        );
        insert oppRecord;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = new Product2(
            Name = 'BULK (SMS Premium)',                      // Product Name
            IsActive = true,                                    // Active
            Family = 'Messaging',                               // Product Family
            Product_Type__c = 'SMS',                            // Product Type
            ProductCode = 'SMS',                                // Product Code
            Ads_Format__c = 'Text',                             // Ads Format
            Ads_Detail__c = 'BULK (SMS Premium)_3telco_Icode',  // Ads Detail
            Ads_Size__c = 'Standard',                           // Ads Size
            Product_Channel__c = 'Mobile',                      // Product Channel
            Channel_Detail__c = 'Mobile',                       // Channel Detail
            Buying_Method__c = 'I/O',                           // Buying Method
            Rate_Card_Refference__c = 'Messaging',              // Rate Card Refference
            List_Price__c = 500.00,                             // List Price
            Product_Category__c = 'Advertising',                // Product Category
            Description = '500'                                // Product Description
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = oppRecord.Id,// Opportunity
            Product2Id = prod.Id,     // Product
            Discount__c = 0.00,               // Discount (%)
            PricebookEntryId = pbEntry.Id,
            UnitPrice = 500.00,                 // Sales Price
            Quantity = 1234.00              // Quantity
        );
        insert oli;
        
        oppRecord.isSubmitCheckPOApproval__c = true;
        oppRecord.StageName = 'Closed Won';
        update oppRecord;
        acc.ContractId__c = contract.Id;
        update acc;
        Test.startTest();
        
        SOA__c soaRecord = new SOA__c(
            Opportunity__c = oppRecord.Id,              // Opportunity
            SOA_Type__c = 'Opportunity',                     // SOA Type
            SOA_Start_Date__c = Date.valueOf('2024-10-01'),  // SOA Start Date
            SOA_End_Date__c = Date.valueOf('2024-10-31'),    // SOA End Date
            SOA_Sources__c = 'Opportunity'                  // SOA
        );
        insert soaRecord;
        
        Quote qt = new Quote();
        qt.Name = 'Test Quote';
        qt.ContactId = con.Id;
        qt.Start_Date__c = system.today();
        qt.End_Date__c = system.today().addDays(10);
        qt.OpportunityId = oppRecord.Id;
        insert qt;
        
        QuoteLineItem newQuoteLineItem = new QuoteLineItem();
        newQuoteLineItem.QuoteId = qt.id; // Name of the product being quoted
        newQuoteLineItem.Quantity = 100; // Quantity being quoted
        newQuoteLineItem.PricebookEntryId = pbEntry.id;
        newQuoteLineItem.Product2Id = prod.id;
        newQuoteLineItem.UnitPrice = 500; // Price per unit
        newQuoteLineItem.Description = 'This is a description of Product XYZ'; // Description of the product being quoted
        insert newQuoteLineItem;
        
        // Call the method with the test data
        List<SOA__c> soaList = new List<SOA__c>{soaRecord};
            
            SoaService.createOrderforOppty(soaList);
        SoaService.createOrderforOppty(soaList);
        List<Order> ordList = [SELECT Id FROM Order ORDER BY CreatedDate ASC];
        
        List<OrderItem> oilist = new List<OrderItem>();
        
        if(ordList.size() > 0){
            oilist = [SELECT Id, OrderId, Quantity, UnitPrice, PricebookEntryId, Camp_ID__c, Campaign_ID__c, 
                      Opportunity__c, ServiceDate, EndDate, Opp_Product_Id__c, Product_id_number__c 
                      FROM OrderItem 
                      WHERE OrderId =: ordList[0].Id 
                      ORDER BY CreatedDate ASC];
            if(oilist.size() > 0){
                oilist[0].Quantity = 50;
                update oilist[0];
            }
        }
        QuoteBU__c qb = new QuoteBU__c();
        qb.Opportunity__c = oppRecord.id;
        insert qb;
        
        QuoteBU_Detail__c qbud_rec = new QuoteBU_Detail__c();
        qbud_rec.QuoteBU__c = qb.Id;
        qbud_rec.Product__c = prod.Id;
        qbud_rec.Opp_Product_Id__c = '1234567890';
        qbud_rec.Quantity__c = 70;
        qbud_rec.Unit_Price__c = 100;
        qbud_rec.Campaign_ID__c = 'camp001';
        insert qbud_rec;
        Test.stopTest();
    }
    
    @isTest
    static void createOpptyClosedWon(){
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Account acc = new Account(
            Name = 'Wira Pamungkas Pratama',          				// Account Name
            RecordTypeId = recordTypeAccId,                                  // Account Record Type
            Account_Type__c = 'Agency',                                  // Account Type
            Direct_Indirect__c = 'Direct',                               // Direct/Indirect
            Status__c = 'Approved by Settlement',                        // Status
            No_PKS__c = '123456',                                        // No PKS
            NPWP__c = '1',                                               // NPWP
            PKS_Tracker__c = 'Pending'      
        );
        insert acc;

        Contact contactRec = new Contact(
            AccountId = acc.id,                 // Account Name
            Title = 'Planner',                         // Title
            Email = 'test@gmail.com',  // Email
            Phone = '231313123123',                   // Phone
            LastName = 'user1',
            MobilePhone = '231313123123',             // Mobile
            Active__c = true,                         // Active?
            Priority__c = 'Priority 1',                // Priority
            Converted_from_Lead__c = false            // Converted from Lead
        );
        insert contactRec;
        
        Contract contract = new Contract(
            StartDate = Date.valueOf('2019-09-01'),// Contract Start Date
            ContractTerm = 9999,                  // Contract Term (months)
            AccountId = acc.Id,
            OwnerExpirationNotice = '120',      // Owner Expiration Notice
            Status = 'Draft',                    // Status
            Terminate__c = false,                    // Terminate
            Archive__c = false,                      // Archive
            No_PKS__c = '123456',                    // No.PKS
            Contract_Signed__c = 'Circulation'     // Contract Signed ?
           // Opportunity__c = oppRecord.Id
        );
        insert contract;
        
        contract.Status = 'Activated';
        update contract;
        Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Agency Postpaid').getRecordTypeId();

        acc.ContractId__c = contract.Id;
        update acc;

        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = new Product2(
            Name = 'BULK (SMS Premium)',                      // Product Name
            IsActive = true,                                    // Active
            Family = 'Messaging',                               // Product Family
            Product_Type__c = 'SMS',                            // Product Type
            ProductCode = 'SMS',                                // Product Code
            Ads_Format__c = 'Text',                             // Ads Format
            Ads_Detail__c = 'BULK (SMS Premium)_3telco_Icode',  // Ads Detail
            Ads_Size__c = 'Standard',                           // Ads Size
            Product_Channel__c = 'Mobile',                      // Product Channel
            Channel_Detail__c = 'Mobile',                       // Channel Detail
            Buying_Method__c = 'I/O',                           // Buying Method
            Rate_Card_Refference__c = 'Messaging',              // Rate Card Refference
            List_Price__c = 500.00,                             // List Price
            Product_Category__c = 'Advertising',                // Product Category
            Description = '500'                                // Product Description
            );
        insert prod;
            
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
            );
            insert pbEntry;
            
        // Test.startTest();

        Opportunity oppRecord = new Opportunity(
            RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
            Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',  // Opportunity Name
            AccountId = acc.Id,                                                           // Account Name
            CloseDate = Date.valueOf('2024-09-21'),                                                  // Close Date
            Account_Type__c = 'Agency',                                                              // Account Type
            // StageName = 'Proposal',                                                                // Stage
            Regional__c = 'HEAD OFFICE',                                                             // Regional  (Required)
            Probability = 100,                                                                       // Probability (%)
            Agency_Name__c = acc.Id,                                                      // Agency Name
            Campaign_Customize__c = false,                                                           // Campaign Customize
            Templated_Proposal__c = true,                                                            // Own Proposal?
            Approval_Remark__c = 'Approved',                                                         // Approval Remark
            Document_Version__c = 'Submit',                                                          // Document Version
            Approval_Status__c = 'Approved',                                                         // Approval Status
            Marketing_Package__c = false,                                                            // Marketing Package
            SME__c = false,                                                                          // SME
            // Brand__c = 'a011s00000Dk5rF',                                                            // Brand
            Type = 'Existing Business',                                                              // Type
            Penagihan_based_on__c = 'Postpaid',                                                      // Penagihan based on
            Performance_Product__c = false,                                                          // Performance Product
            Programmatic_Product__c = false,                                                         // Programmatic Product
            Performance_Done__c = false,                                                             // Performance Done
            RFP_Status_sales__c = 'Completed',
            isSubmitCheckPOApproval__c = true,                                                       // RFP Status (sales)
            Check_PO__c = 'OK',
            StageName = 'closed won',
            Pricebook2Id = Test.getStandardPricebookId()            
        );
        insert oppRecord;
        
        test.startTest();
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = oppRecord.Id,// Opportunity
            Product2Id = prod.Id,     // Product
            Discount__c = 0.00,               // Discount (%)
            PricebookEntryId = pbEntry.Id,
            UnitPrice = 500.00,                 // Sales Price
            Quantity = 1234.00              // Quantity
        );
        insert oli;

        oppRecord.StageName = 'Closed Won';
        update oppRecord;
        
       
        SOA__c soaRecord = new SOA__c(
            Opportunity__c = oppRecord.Id,              // Opportunity
            SOA_Type__c = 'Opportunity',                     // SOA Type
            SOA_Start_Date__c = Date.valueOf('2024-10-01'),  // SOA Start Date
            SOA_End_Date__c = Date.valueOf('2024-10-31'),    // SOA End Date
            SOA_Sources__c = 'Opportunity'                  // SOA
        );
        insert soaRecord;

        SOA_Detail__c soaDetail = new SOA_Detail__c(
          Campaign_ID__c = 'S02409_291_1',           // Campaign ID
          SOA__c = soaRecord.Id,                  // SOA
          Product__c = prod.Id,              // Product
          Type__c = 'New',                             // Type
          Start_Date__c = Date.valueOf('2024-10-01'),  // Start Date
          Quantity__c = 1234,                    // Quantity
          End_Date__c = Date.valueOf('2024-10-31'),    // End Date
          Unit_Price__c = 500.00,                      // Unit Price
          List_Price__c = 500.00,                      // List Price
          Discount__c = 0.00,                        // Discount
          Opp_Product_Id__c = null    // Opp Product Id
        );
       insert soaDetail;
       
        Order order = new Order(
          Status = 'Draft',                                                    // Status
          SOA__c = soaRecord.Id,
          OpportunityId = oppRecord.id,
          order_type__c = 'Opportunity',                                          // SOA
          EffectiveDate = Date.newInstance(2024, 12,01),                              // Order Start Date
          EndDate = Date.newInstance(2024, 12,31),                                                      // Order Type
          AccountId = acc.Id,
          Pricebook2Id = Test.getStandardPricebookId()
        );
        insert order;

        OrderItem orderItem = new OrderItem();
            orderItem.OrderId = order.id; 
            orderItem.Product2Id = prod.Id;
            orderItem.PricebookEntryId = pbEntry.id;
            orderItem.Quantity = 10; 
            orderItem.UnitPrice = 100.00; 
        insert orderItem;

        Invoice__c invRec = new Invoice__c(
            Mitra__c = acc.id,                                   // Mitra
            No_Invoice__c = 'TS.123123.4123125',                        // No Invoice
            No_Master__c = '123123',                                    // No Master
            Tanggal_Invoice__c = Date.newInstance(2024, 12,01),            // Tanggal Invoice
            No_Individual__c = '3123123',                               // No Individual
            Jangka_Waktu_PKS__c = '1 Januari 2024 - 31 Desember 2025',  // Jangka Waktu PKS
            Hak_Telkomsel__c = 150000                                 // Hak Telkomsel
            // VAT_Related__c = 'undefined'                               // VAT Related
        );
        insert invRec;

        soaRecord.invoice__c = invRec.id;
        update soaRecord;

        // for quoteation
        Opportunity oppRecord1 = new Opportunity(
            RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
            Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',  // Opportunity Name
            AccountId = acc.Id,                                                           // Account Name
            CloseDate = Date.valueOf('2024-09-21'),                                                  // Close Date
            Account_Type__c = 'Agency',                                                              // Account Type
            StageName = 'Closed Won',                                                                // Stage
            Regional__c = 'HEAD OFFICE',                                                             // Regional  (Required)
            Probability = 100,                                                                       // Probability (%)
            Agency_Name__c = acc.Id,                                                      // Agency Name
            Campaign_Customize__c = false,                                                           // Campaign Customize
            Templated_Proposal__c = true,                                                            // Own Proposal?
            Approval_Remark__c = 'Approved',                                                         // Approval Remark
            Document_Version__c = 'Submit',
            Adjustment_Version__c = 3,                                                        // Document Version
            Approval_Status__c = 'Approved', 
            isSubmitCheckPOApproval__c = true,                                                   // Approval Status
            Marketing_Package__c = false,                                                            // Marketing Package
            SME__c = false,                                                                          // SME
            // Brand__c = 'a011s00000Dk5rF',                                                            // Brand
            Type = 'Existing Business',                                                              // Type
            Penagihan_based_on__c = 'Prepaid',                                                      // Penagihan based on
            Performance_Product__c = false,                                                          // Performance Product
            Programmatic_Product__c = false,                                                         // Programmatic Product
            Performance_Done__c = false,                                                             // Performance Done
            RFP_Status_sales__c = 'Completed',                                                       // RFP Status (sales)
            Check_PO__c = 'OK',
            Pricebook2Id = Test.getStandardPricebookId()            
        );
        insert oppRecord1;

        oppRecord1.StageName = 'proposal';
        update oppRecord1;
        
        OpportunityLineItem oli1 = new OpportunityLineItem(
            OpportunityId = oppRecord1.Id,// Opportunity
            Product2Id = prod.Id,     // Product
            Discount__c = 0.00,               // Discount (%)
            PricebookEntryId = pbEntry.Id,
            UnitPrice = 500.00,                 // Sales Price
            Quantity = 1234.00              // Quantity
            );
        insert oli1;
            
        oppRecord1.StageName = 'Closed Won';
        update oppRecord1;
        // Test.startTest();
       
        Invoice__c invRec1 = new Invoice__c(
            Mitra__c = acc.id,                                   // Mitra
            No_Invoice__c = 'TS.123123.4121233125',                        // No Invoice
            No_Master__c = '123123',                                    // No Master
            Tanggal_Invoice__c = Date.newInstance(2024, 12,01),            // Tanggal Invoice
            No_Individual__c = '3123123',                               // No Individual
            Jangka_Waktu_PKS__c = '1 Januari 2024 - 31 Desember 2025',  // Jangka Waktu PKS
            Hak_Telkomsel__c = 150000                                 // Hak Telkomsel
            // VAT_Related__c = 'undefined'                               // VAT Related
        );
        insert invRec1;

        // insert soaRecord;
        Quote quoteRec = new Quote(
            Name = 'TSEL / Q02250 / dev1/9/25/2024',        // Quotation Name
            OpportunityId = oppRecord1.id,                      // Opportunity Name
            ContactId = contactRec.id,                          // Contact Name
            Status = 'Final',                                 // Status
            Start_Date__c = Date.newInstance(2024, 1,01),       // Start Date
            End_Date__c = Date.newInstance(2029, 12,01),         // End Date
            Invoice__c = invRec1.id                         // Invoice
        );

        insert quoteRec; 

        QuoteBU__c qb = new QuoteBU__c();
        qb.Quote__c = quoteRec.id;
        qb.Opportunity__c = oppRecord.id;
        insert qb;

        QuoteBU_Detail__c qbud_rec = new QuoteBU_Detail__c();
            qbud_rec.QuoteBU__c = qb.Id;
            qbud_rec.Product__c = prod.Id;
            qbud_rec.Opp_Product_Id__c = oli1.Id;
            qbud_rec.Quantity__c = 70;
            qbud_rec.Unit_Price__c = 100;
            // qbud_rec.Campaign_ID__c = 'camp001';
        insert qbud_rec;

        Order order1 = new Order(
          Status = 'Draft',                                                    // Status
          quoteid = quoteRec.Id,                                              // SOA
          EffectiveDate = Date.newInstance(2024, 12,01),                              // Order Start Date
          EndDate = Date.newInstance(2024, 12,31),                                                      // Order Type
          AccountId = acc.Id,
          order_type__c = 'Opportunity',
          opportunityId = oppRecord1.Id,
          Pricebook2Id = Test.getStandardPricebookId()
          
        );
        insert order1;

        OrderItem orderItem1 = new OrderItem();
            orderItem1.OrderId = order1.id; 
            orderItem1.Product2Id = prod.Id;
            orderItem1.PricebookEntryId = pbEntry.id;
            orderItem1.Quantity = 10; 
            orderItem1.UnitPrice = 100.00; 
            
        // test.startTest();
        insert orderItem1;

        Order order2 = new Order(
            Status = 'Draft',                                                    // Status
            quoteid = quoteRec.Id,                                              // SOA
            EffectiveDate = Date.newInstance(2024, 12,01),                              // Order Start Date
            EndDate = Date.newInstance(2024, 12,31),                                                      // Order Type
            AccountId = acc.Id,
            order_type__c = 'Opportunity',
            opportunityId = oppRecord1.Id,
            Pricebook2Id = Test.getStandardPricebookId()           
            );
        
        insert order2;
    
            OrderItem orderItem2 = new OrderItem();
                orderItem2.OrderId = order1.id; 
                orderItem2.Product2Id = prod.Id;
                orderItem2.PricebookEntryId = pbEntry.id;
                orderItem2.Quantity = 10; 
                orderItem2.UnitPrice = 100.00;               
            // test.startTest();
                insert orderItem2;
        test.stopTest();
    }

    @isTest
    static void createOpptyClosedWonoli_temp_qNull(){
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Account acc = new Account(
            Name = 'Wira Pamungkas Pratama',          				// Account Name
            RecordTypeId = recordTypeAccId,                                  // Account Record Type
            Account_Type__c = 'Agency',                                  // Account Type
            Direct_Indirect__c = 'Direct',                               // Direct/Indirect
            Status__c = 'Approved by Settlement',                        // Status
            No_PKS__c = '123456',                                        // No PKS
            NPWP__c = '1',                                               // NPWP
            PKS_Tracker__c = 'Pending'      
        );
        insert acc;

        Contact contactRec = new Contact(
            AccountId = acc.id,                 // Account Name
            Title = 'Planner',                         // Title
            Email = 'test@gmail.com',  // Email
            Phone = '231313123123',                   // Phone
            LastName = 'user1',
            MobilePhone = '231313123123',             // Mobile
            Active__c = true,                         // Active?
            Priority__c = 'Priority 1',                // Priority
            Converted_from_Lead__c = false            // Converted from Lead
        );
        insert contactRec;
        
        Contract contract = new Contract(
            StartDate = Date.valueOf('2019-09-01'),// Contract Start Date
            ContractTerm = 9999,                  // Contract Term (months)
            AccountId = acc.Id,
            OwnerExpirationNotice = '120',      // Owner Expiration Notice
            Status = 'Draft',                    // Status
            Terminate__c = false,                    // Terminate
            Archive__c = false,                      // Archive
            No_PKS__c = '123456',                    // No.PKS
            Contract_Signed__c = 'Circulation'     // Contract Signed ?
           // Opportunity__c = oppRecord.Id
        );
        insert contract;
        
        contract.Status = 'Activated';
        update contract;
        Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Agency Postpaid').getRecordTypeId();

        acc.ContractId__c = contract.Id;
        update acc;

        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = new Product2(
            Name = 'BULK (SMS Premium)',                      // Product Name
            IsActive = true,                                    // Active
            Family = 'Messaging',                               // Product Family
            Product_Type__c = 'SMS',                            // Product Type
            ProductCode = 'SMS',                                // Product Code
            Ads_Format__c = 'Text',                             // Ads Format
            Ads_Detail__c = 'BULK (SMS Premium)_3telco_Icode',  // Ads Detail
            Ads_Size__c = 'Standard',                           // Ads Size
            Product_Channel__c = 'Mobile',                      // Product Channel
            Channel_Detail__c = 'Mobile',                       // Channel Detail
            Buying_Method__c = 'I/O',                           // Buying Method
            Rate_Card_Refference__c = 'Messaging',              // Rate Card Refference
            List_Price__c = 500.00,                             // List Price
            Product_Category__c = 'Advertising',                // Product Category
            Description = '500'                                // Product Description
            );
        insert prod;
            
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
            );
            insert pbEntry;
            
        // Test.startTest();

        Opportunity oppRecord = new Opportunity(
            RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
            Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',  // Opportunity Name
            AccountId = acc.Id,                                                           // Account Name
            CloseDate = Date.valueOf('2024-09-21'),                                                  // Close Date
            Account_Type__c = 'Agency',                                                              // Account Type
            // StageName = 'Proposal',                                                                // Stage
            Regional__c = 'HEAD OFFICE',                                                             // Regional  (Required)
            Probability = 100,                                                                       // Probability (%)
            Agency_Name__c = acc.Id,                                                      // Agency Name
            Campaign_Customize__c = false,                                                           // Campaign Customize
            Templated_Proposal__c = true,                                                            // Own Proposal?
            Approval_Remark__c = 'Approved',                                                         // Approval Remark
            Document_Version__c = 'Submit',                                                          // Document Version
            Approval_Status__c = 'Approved',                                                         // Approval Status
            Marketing_Package__c = false,                                                            // Marketing Package
            SME__c = false,                                                                          // SME
            // Brand__c = 'a011s00000Dk5rF',                                                            // Brand
            Type = 'Existing Business',                                                              // Type
            Penagihan_based_on__c = 'Postpaid',                                                      // Penagihan based on
            Performance_Product__c = false,                                                          // Performance Product
            Programmatic_Product__c = false,                                                         // Programmatic Product
            Performance_Done__c = false,                                                             // Performance Done
            RFP_Status_sales__c = 'Completed',
            isSubmitCheckPOApproval__c = true,                                                       // RFP Status (sales)
            Check_PO__c = 'OK',
            StageName = 'closed won',
            Pricebook2Id = Test.getStandardPricebookId()            
        );
        insert oppRecord;
        
        test.startTest();
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = oppRecord.Id,// Opportunity
            Product2Id = prod.Id,     // Product
            Discount__c = 0.00,               // Discount (%)
            PricebookEntryId = pbEntry.Id,
            UnitPrice = 500.00,                 // Sales Price
            Quantity = 1234.00              // Quantity
        );
        insert oli;

        oppRecord.StageName = 'Closed Won';
        update oppRecord;
        
       
        SOA__c soaRecord = new SOA__c(
            Opportunity__c = oppRecord.Id,              // Opportunity
            SOA_Type__c = 'Opportunity',                     // SOA Type
            SOA_Start_Date__c = Date.valueOf('2024-10-01'),  // SOA Start Date
            SOA_End_Date__c = Date.valueOf('2024-10-31'),    // SOA End Date
            SOA_Sources__c = 'Opportunity'                  // SOA
        );
        insert soaRecord;

        SOA_Detail__c soaDetail = new SOA_Detail__c(
          Campaign_ID__c = 'S02409_291_1',           // Campaign ID
          SOA__c = soaRecord.Id,                  // SOA
          Product__c = prod.Id,              // Product
          Type__c = 'New',                             // Type
          Start_Date__c = Date.valueOf('2024-10-01'),  // Start Date
          Quantity__c = 1234,                    // Quantity
          End_Date__c = Date.valueOf('2024-10-31'),    // End Date
          Unit_Price__c = 500.00,                      // Unit Price
          List_Price__c = 500.00,                      // List Price
          Discount__c = 0.00,                        // Discount
          Opp_Product_Id__c = null    // Opp Product Id
        );
       insert soaDetail;
       
        Order order = new Order(
          Status = 'Draft',                                                    // Status
          SOA__c = soaRecord.Id,
          OpportunityId = oppRecord.id,
          order_type__c = 'Opportunity',                                          // SOA
          EffectiveDate = Date.newInstance(2024, 12,01),                              // Order Start Date
          EndDate = Date.newInstance(2024, 12,31),                                                      // Order Type
          AccountId = acc.Id,
          Pricebook2Id = Test.getStandardPricebookId()
        );
        insert order;

        OrderItem orderItem = new OrderItem();
            orderItem.OrderId = order.id; 
            orderItem.Product2Id = prod.Id;
            orderItem.PricebookEntryId = pbEntry.id;
            orderItem.Quantity = 10; 
            orderItem.UnitPrice = 100.00; 
        insert orderItem;

        Invoice__c invRec = new Invoice__c(
            Mitra__c = acc.id,                                   // Mitra
            No_Invoice__c = 'TS.123123.4123125',                        // No Invoice
            No_Master__c = '123123',                                    // No Master
            Tanggal_Invoice__c = Date.newInstance(2024, 12,01),            // Tanggal Invoice
            No_Individual__c = '3123123',                               // No Individual
            Jangka_Waktu_PKS__c = '1 Januari 2024 - 31 Desember 2025',  // Jangka Waktu PKS
            Hak_Telkomsel__c = 150000                                 // Hak Telkomsel
            // VAT_Related__c = 'undefined'                               // VAT Related
        );
        insert invRec;

        soaRecord.invoice__c = invRec.id;
        update soaRecord;

        // for quoteation
        Opportunity oppRecord1 = new Opportunity(
            RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
            Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',  // Opportunity Name
            AccountId = acc.Id,                                                           // Account Name
            CloseDate = Date.valueOf('2024-09-21'),                                                  // Close Date
            Account_Type__c = 'Agency',                                                              // Account Type
            StageName = 'Closed Won',                                                                // Stage
            Regional__c = 'HEAD OFFICE',                                                             // Regional  (Required)
            Probability = 100,                                                                       // Probability (%)
            Agency_Name__c = acc.Id,                                                      // Agency Name
            Campaign_Customize__c = false,                                                           // Campaign Customize
            Templated_Proposal__c = true,                                                            // Own Proposal?
            Approval_Remark__c = 'Approved',                                                         // Approval Remark
            Document_Version__c = 'Submit',
            Adjustment_Version__c = 3,                                                        // Document Version
            Approval_Status__c = 'Approved', 
            isSubmitCheckPOApproval__c = true,                                                   // Approval Status
            Marketing_Package__c = false,                                                            // Marketing Package
            SME__c = false,                                                                          // SME
            // Brand__c = 'a011s00000Dk5rF',                                                            // Brand
            Type = 'Existing Business',                                                              // Type
            Penagihan_based_on__c = 'Prepaid',                                                      // Penagihan based on
            Performance_Product__c = false,                                                          // Performance Product
            Programmatic_Product__c = false,                                                         // Programmatic Product
            Performance_Done__c = false,                                                             // Performance Done
            RFP_Status_sales__c = 'Completed',                                                       // RFP Status (sales)
            Check_PO__c = 'OK',
            Pricebook2Id = Test.getStandardPricebookId()            
        );
        insert oppRecord1;

        oppRecord1.StageName = 'proposal';
        update oppRecord1;
        
        OpportunityLineItem oli1 = new OpportunityLineItem(
            OpportunityId = oppRecord1.Id,// Opportunity
            Product2Id = prod.Id,     // Product
            Discount__c = 0.00,               // Discount (%)
            PricebookEntryId = pbEntry.Id,
            UnitPrice = 500.00,                 // Sales Price
            Quantity = 1234.00              // Quantity
            );
        insert oli1;
            
        oppRecord1.StageName = 'Closed Won';
        update oppRecord1;
        // Test.startTest();
       
        Invoice__c invRec1 = new Invoice__c(
            Mitra__c = acc.id,                                   // Mitra
            No_Invoice__c = 'TS.123123.4121233125',                        // No Invoice
            No_Master__c = '123123',                                    // No Master
            Tanggal_Invoice__c = Date.newInstance(2024, 12,01),            // Tanggal Invoice
            No_Individual__c = '3123123',                               // No Individual
            Jangka_Waktu_PKS__c = '1 Januari 2024 - 31 Desember 2025',  // Jangka Waktu PKS
            Hak_Telkomsel__c = 150000                                 // Hak Telkomsel
            // VAT_Related__c = 'undefined'                               // VAT Related
        );
        insert invRec1;

        // insert soaRecord;
        Quote quoteRec = new Quote(
            Name = 'TSEL / Q02250 / dev1/9/25/2024',        // Quotation Name
            OpportunityId = oppRecord1.id,                      // Opportunity Name
            ContactId = contactRec.id,                          // Contact Name
            Status = 'Final',                                 // Status
            Start_Date__c = Date.newInstance(2024, 1,01),       // Start Date
            End_Date__c = Date.newInstance(2029, 12,01),         // End Date
            Invoice__c = invRec1.id                         // Invoice
        );

        insert quoteRec; 

        QuoteBU__c qb = new QuoteBU__c();
        qb.Quote__c = quoteRec.id;
        qb.Opportunity__c = oppRecord.id;
        insert qb;

        QuoteBU_Detail__c qbud_rec = new QuoteBU_Detail__c();
            qbud_rec.QuoteBU__c = qb.Id;
            qbud_rec.Product__c = prod.Id;
            // qbud_rec.Opp_Product_Id__c = oli1.Id;
            qbud_rec.Quantity__c = 70;
            qbud_rec.Unit_Price__c = 100;
            // qbud_rec.Campaign_ID__c = 'camp001';
        insert qbud_rec;

        Order order1 = new Order(
          Status = 'Draft',                                                    // Status
          quoteid = quoteRec.Id,                                              // SOA
          EffectiveDate = Date.newInstance(2024, 12,01),                              // Order Start Date
          EndDate = Date.newInstance(2024, 12,31),                                                      // Order Type
          AccountId = acc.Id,
          order_type__c = 'Opportunity',
          opportunityId = oppRecord1.Id,
          Pricebook2Id = Test.getStandardPricebookId()
          
        );
        insert order1;

        OrderItem orderItem1 = new OrderItem();
            orderItem1.OrderId = order1.id; 
            orderItem1.Product2Id = prod.Id;
            orderItem1.PricebookEntryId = pbEntry.id;
            orderItem1.Quantity = 10; 
            orderItem1.UnitPrice = 100.00; 
            
        // test.startTest();
        insert orderItem1;

        Order order2 = new Order(
            Status = 'Draft',                                                    // Status
            quoteid = quoteRec.Id,                                              // SOA
            EffectiveDate = Date.newInstance(2024, 12,01),                              // Order Start Date
            EndDate = Date.newInstance(2024, 12,31),                                                      // Order Type
            AccountId = acc.Id,
            order_type__c = 'Opportunity',
            opportunityId = oppRecord1.Id,
            Pricebook2Id = Test.getStandardPricebookId()           
            );
        
        insert order2;
    
            OrderItem orderItem2 = new OrderItem();
                orderItem2.OrderId = order1.id; 
                orderItem2.Product2Id = prod.Id;
                orderItem2.PricebookEntryId = pbEntry.id;
                orderItem2.Quantity = 10; 
                orderItem2.UnitPrice = 100.00;               
            // test.startTest();
                insert orderItem2;
        test.stopTest();
    }

    @isTest
    static void createOpptyClosedWonoliAdjNull(){
        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Account acc = new Account(
            Name = 'Wira Pamungkas Pratama',          				// Account Name
            RecordTypeId = recordTypeAccId,                                  // Account Record Type
            Account_Type__c = 'Agency',                                  // Account Type
            Direct_Indirect__c = 'Direct',                               // Direct/Indirect
            Status__c = 'Approved by Settlement',                        // Status
            No_PKS__c = '123456',                                        // No PKS
            NPWP__c = '1',                                               // NPWP
            PKS_Tracker__c = 'Pending'      
        );
        insert acc;

        Contact contactRec = new Contact(
            AccountId = acc.id,                 // Account Name
            Title = 'Planner',                         // Title
            Email = 'test@gmail.com',  // Email
            Phone = '231313123123',                   // Phone
            LastName = 'user1',
            MobilePhone = '231313123123',             // Mobile
            Active__c = true,                         // Active?
            Priority__c = 'Priority 1',                // Priority
            Converted_from_Lead__c = false            // Converted from Lead
        );
        insert contactRec;
        
        Contract contract = new Contract(
            StartDate = Date.valueOf('2019-09-01'),// Contract Start Date
            ContractTerm = 9999,                  // Contract Term (months)
            AccountId = acc.Id,
            OwnerExpirationNotice = '120',      // Owner Expiration Notice
            Status = 'Draft',                    // Status
            Terminate__c = false,                    // Terminate
            Archive__c = false,                      // Archive
            No_PKS__c = '123456',                    // No.PKS
            Contract_Signed__c = 'Circulation'     // Contract Signed ?
           // Opportunity__c = oppRecord.Id
        );
        insert contract;
        
        contract.Status = 'Activated';
        update contract;
        Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Agency Postpaid').getRecordTypeId();

        acc.ContractId__c = contract.Id;
        update acc;

        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = new Product2(
            Name = 'BULK (SMS Premium)',                      // Product Name
            IsActive = true,                                    // Active
            Family = 'Messaging',                               // Product Family
            Product_Type__c = 'SMS',                            // Product Type
            ProductCode = 'SMS',                                // Product Code
            Ads_Format__c = 'Text',                             // Ads Format
            Ads_Detail__c = 'BULK (SMS Premium)_3telco_Icode',  // Ads Detail
            Ads_Size__c = 'Standard',                           // Ads Size
            Product_Channel__c = 'Mobile',                      // Product Channel
            Channel_Detail__c = 'Mobile',                       // Channel Detail
            Buying_Method__c = 'I/O',                           // Buying Method
            Rate_Card_Refference__c = 'Messaging',              // Rate Card Refference
            List_Price__c = 500.00,                             // List Price
            Product_Category__c = 'Advertising',                // Product Category
            Description = '500'                                // Product Description
            );
        insert prod;
            
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
            );
            insert pbEntry;
            
        // Test.startTest();

        Opportunity oppRecord = new Opportunity(
            RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
            Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',  // Opportunity Name
            AccountId = acc.Id,                                                           // Account Name
            CloseDate = Date.valueOf('2024-09-21'),                                                  // Close Date
            Account_Type__c = 'Agency',                                                              // Account Type
            // StageName = 'Proposal',                                                                // Stage
            Regional__c = 'HEAD OFFICE',                                                             // Regional  (Required)
            Probability = 100,                                                                       // Probability (%)
            Agency_Name__c = acc.Id,                                                      // Agency Name
            Campaign_Customize__c = false,                                                           // Campaign Customize
            Templated_Proposal__c = true,                                                            // Own Proposal?
            Approval_Remark__c = 'Approved',                                                         // Approval Remark
            Document_Version__c = 'Submit',                                                          // Document Version
            Approval_Status__c = 'Approved',                                                         // Approval Status
            Marketing_Package__c = false,                                                            // Marketing Package
            SME__c = false,                                                                          // SME
            // Brand__c = 'a011s00000Dk5rF',                                                            // Brand
            Type = 'Existing Business',                                                              // Type
            Penagihan_based_on__c = 'Postpaid',                                                      // Penagihan based on
            Performance_Product__c = false,                                                          // Performance Product
            Programmatic_Product__c = false,                                                         // Programmatic Product
            Performance_Done__c = false,                                                             // Performance Done
            RFP_Status_sales__c = 'Completed',
            isSubmitCheckPOApproval__c = true,                                                       // RFP Status (sales)
            Check_PO__c = 'OK',
            StageName = 'closed won',
            Pricebook2Id = Test.getStandardPricebookId()            
        );
        insert oppRecord;
        
        test.startTest();
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = oppRecord.Id,// Opportunity
            Product2Id = prod.Id,     // Product
            Discount__c = 0.00,               // Discount (%)
            PricebookEntryId = pbEntry.Id,
            UnitPrice = 500.00,                 // Sales Price
            Quantity = 1234.00              // Quantity
        );
        insert oli;

        oppRecord.StageName = 'Closed Won';
        update oppRecord;
        
       
        SOA__c soaRecord = new SOA__c(
            Opportunity__c = oppRecord.Id,              // Opportunity
            SOA_Type__c = 'Opportunity',                     // SOA Type
            SOA_Start_Date__c = Date.valueOf('2024-10-01'),  // SOA Start Date
            SOA_End_Date__c = Date.valueOf('2024-10-31'),    // SOA End Date
            SOA_Sources__c = 'Opportunity'                  // SOA
        );
        insert soaRecord;

        SOA_Detail__c soaDetail = new SOA_Detail__c(
          Campaign_ID__c = 'S02409_291_1',           // Campaign ID
          SOA__c = soaRecord.Id,                  // SOA
          Product__c = prod.Id,              // Product
          Type__c = 'New',                             // Type
          Start_Date__c = Date.valueOf('2024-10-01'),  // Start Date
          Quantity__c = 1234,                    // Quantity
          End_Date__c = Date.valueOf('2024-10-31'),    // End Date
          Unit_Price__c = 500.00,                      // Unit Price
          List_Price__c = 500.00,                      // List Price
          Discount__c = 0.00,                        // Discount
          Opp_Product_Id__c = null    // Opp Product Id
        );
       insert soaDetail;
       
        Order order = new Order(
          Status = 'Draft',                                                    // Status
          SOA__c = soaRecord.Id,
          OpportunityId = oppRecord.id,
          order_type__c = 'Opportunity',                                          // SOA
          EffectiveDate = Date.newInstance(2024, 12,01),                              // Order Start Date
          EndDate = Date.newInstance(2024, 12,31),                                                      // Order Type
          AccountId = acc.Id,
          Pricebook2Id = Test.getStandardPricebookId()
        );
        insert order;

        OrderItem orderItem = new OrderItem();
            orderItem.OrderId = order.id; 
            orderItem.Product2Id = prod.Id;
            orderItem.PricebookEntryId = pbEntry.id;
            orderItem.Quantity = 10; 
            orderItem.UnitPrice = 100.00; 
        insert orderItem;

        Invoice__c invRec = new Invoice__c(
            Mitra__c = acc.id,                                   // Mitra
            No_Invoice__c = 'TS.123123.4123125',                        // No Invoice
            No_Master__c = '123123',                                    // No Master
            Tanggal_Invoice__c = Date.newInstance(2024, 12,01),            // Tanggal Invoice
            No_Individual__c = '3123123',                               // No Individual
            Jangka_Waktu_PKS__c = '1 Januari 2024 - 31 Desember 2025',  // Jangka Waktu PKS
            Hak_Telkomsel__c = 150000                                 // Hak Telkomsel
            // VAT_Related__c = 'undefined'                               // VAT Related
        );
        insert invRec;

        soaRecord.invoice__c = invRec.id;
        update soaRecord;

        // for quoteation
        Opportunity oppRecord1 = new Opportunity(
            RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
            Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2024',  // Opportunity Name
            AccountId = acc.Id,                                                           // Account Name
            CloseDate = Date.valueOf('2024-09-21'),                                                  // Close Date
            Account_Type__c = 'Agency',                                                              // Account Type
            StageName = 'Closed Won',                                                                // Stage
            Regional__c = 'HEAD OFFICE',                                                             // Regional  (Required)
            Probability = 100,                                                                       // Probability (%)
            Agency_Name__c = acc.Id,                                                      // Agency Name
            Campaign_Customize__c = false,                                                           // Campaign Customize
            Templated_Proposal__c = true,                                                            // Own Proposal?
            Approval_Remark__c = 'Approved',                                                         // Approval Remark
            Document_Version__c = 'Submit',
            Adjustment_Version__c = null,                                                        // Document Version
            Approval_Status__c = 'Approved', 
            isSubmitCheckPOApproval__c = true,                                                   // Approval Status
            Marketing_Package__c = false,                                                            // Marketing Package
            SME__c = false,                                                                          // SME
            // Brand__c = 'a011s00000Dk5rF',                                                            // Brand
            Type = 'Existing Business',                                                              // Type
            Penagihan_based_on__c = 'Prepaid',                                                      // Penagihan based on
            Performance_Product__c = false,                                                          // Performance Product
            Programmatic_Product__c = false,                                                         // Programmatic Product
            Performance_Done__c = false,                                                             // Performance Done
            RFP_Status_sales__c = 'Completed',                                                       // RFP Status (sales)
            Check_PO__c = 'OK',
            Pricebook2Id = Test.getStandardPricebookId()            
        );
        insert oppRecord1;

        oppRecord1.StageName = 'proposal';
        update oppRecord1;
        
        OpportunityLineItem oli1 = new OpportunityLineItem(
            OpportunityId = oppRecord1.Id,// Opportunity
            Product2Id = prod.Id,     // Product
            Discount__c = 0.00,               // Discount (%)
            PricebookEntryId = pbEntry.Id,
            UnitPrice = 500.00,                 // Sales Price
            Quantity = 1234.00              // Quantity
            );
        insert oli1;
            
        oppRecord1.StageName = 'Closed Won';
        update oppRecord1;
        // Test.startTest();
       
        Invoice__c invRec1 = new Invoice__c(
            Mitra__c = acc.id,                                   // Mitra
            No_Invoice__c = 'TS.123123.4121233125',                        // No Invoice
            No_Master__c = '123123',                                    // No Master
            Tanggal_Invoice__c = Date.newInstance(2024, 12,01),            // Tanggal Invoice
            No_Individual__c = '3123123',                               // No Individual
            Jangka_Waktu_PKS__c = '1 Januari 2024 - 31 Desember 2025',  // Jangka Waktu PKS
            Hak_Telkomsel__c = 150000                                 // Hak Telkomsel
            // VAT_Related__c = 'undefined'                               // VAT Related
        );
        insert invRec1;

        // insert soaRecord;
        Quote quoteRec = new Quote(
            Name = 'TSEL / Q02250 / dev1/9/25/2024',        // Quotation Name
            OpportunityId = oppRecord1.id,                      // Opportunity Name
            ContactId = contactRec.id,                          // Contact Name
            Status = 'Final',                                 // Status
            Start_Date__c = Date.newInstance(2024, 1,01),       // Start Date
            End_Date__c = Date.newInstance(2029, 12,01),         // End Date
            Invoice__c = invRec1.id                         // Invoice
        );

        insert quoteRec; 

        QuoteBU__c qb = new QuoteBU__c();
        qb.Quote__c = quoteRec.id;
        qb.Opportunity__c = oppRecord.id;
        insert qb;

        QuoteBU_Detail__c qbud_rec = new QuoteBU_Detail__c();
            qbud_rec.QuoteBU__c = qb.Id;
            qbud_rec.Product__c = prod.Id;
            // qbud_rec.Opp_Product_Id__c = oli1.Id;
            qbud_rec.Quantity__c = 70;
            qbud_rec.Unit_Price__c = 100;
            // qbud_rec.Campaign_ID__c = 'camp001';
        insert qbud_rec;

        Order order1 = new Order(
          Status = 'Draft',                                                    // Status
          quoteid = quoteRec.Id,                                              // SOA
          EffectiveDate = Date.newInstance(2024, 12,01),                              // Order Start Date
          EndDate = Date.newInstance(2024, 12,31),                                                      // Order Type
          AccountId = acc.Id,
          order_type__c = 'Opportunity',
          opportunityId = oppRecord1.Id,
          Pricebook2Id = Test.getStandardPricebookId()
          
        );
        insert order1;

        OrderItem orderItem1 = new OrderItem();
            orderItem1.OrderId = order1.id; 
            orderItem1.Product2Id = prod.Id;
            orderItem1.PricebookEntryId = pbEntry.id;
            orderItem1.Quantity = 10; 
            orderItem1.UnitPrice = 100.00; 
            
        // test.startTest();
        insert orderItem1;

        Order order2 = new Order(
            Status = 'Draft',                                                    // Status
            quoteid = quoteRec.Id,                                              // SOA
            EffectiveDate = Date.newInstance(2024, 12,01),                              // Order Start Date
            EndDate = Date.newInstance(2024, 12,31),                                                      // Order Type
            AccountId = acc.Id,
            order_type__c = 'Opportunity',
            opportunityId = oppRecord1.Id,
            Pricebook2Id = Test.getStandardPricebookId()           
            );
        
        insert order2;
    
            OrderItem orderItem2 = new OrderItem();
                orderItem2.OrderId = order1.id; 
                orderItem2.Product2Id = prod.Id;
                orderItem2.PricebookEntryId = pbEntry.id;
                orderItem2.Quantity = 10; 
                orderItem2.UnitPrice = 100.00;               
            // test.startTest();
                insert orderItem2;
        test.stopTest();
    }
}