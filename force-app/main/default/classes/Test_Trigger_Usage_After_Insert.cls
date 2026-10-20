/**
 * @description       : 
 * @author            : David Wong
 * @group             : 
 * @last modified on  : 11/02/2025
 * @last modified by  : Syaiful Syafani
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   -            -                 update test class, new methode
 * 2.0   11/02/2025   Syaiful Syafani   update test class to Test_Trigger_Usage_After_Insert_V2
**/

@isTest(seealldata=false)
public class Test_Trigger_Usage_After_Insert {
    
    static testMethod void testMethod_Upload_Usage() {
        
        //LIST<user> u=[SELECT id from user where username='andi_mario@telkomsel.co.id' LIMIT 1];
        //List<Product2> prod=[SELECT id FROM Product2 where Name='BULK SMS Premium' LIMIT 1];
        //List<PricebookEntry> pbe=[SELECT id FROM PricebookEntry where Product2Id=:prod.id LIMIT 1];
        // Account acc = new Account ();
        // Account A=[SELECT id from Account where Ownerid=:u[0].id LIMIT 1];
        // acc = a;
        // acc.npwp__c='123412';
        // acc.Status__c='Approved by Settlement';
        // upsert acc id;

        Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Account acc = new Account(
            Name = 'Wira Pamungkas Pratama',          				// Account Name
            RecordTypeId = recordTypeAccId,                                  // Account Record Type
            Account_Type__c = 'Agency',                                  // Account Type
            Direct_Indirect__c = 'Direct',                               // Direct/Indirect
            Status__c = 'Approved by Settlement',                        // Status
            Reason_by_Settlement__c = 'Approved',
            No_PKS__c = '123456',                                        // No PKS
            NPWP__c = '1',                                               // NPWP
            PKS_Tracker__c = 'Pending'      
        );
        insert acc;
        

        Contact cont = new Contact();
        cont.lastName ='Doddy';
        cont.accountid = acc.id;
        insert cont;

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

        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = new Product2(
            Name = 'BULK (SMS Premium)',                      // Product Name
            Business_Product__c = 'Digital Media',              // Business Product
            Product_Category__c = 'Advertising',                // Product Category
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
            Description = '500'                                // Product Description
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbe;
        
        Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Agency Postpaid').getRecordTypeId();
         Opportunity opp = new Opportunity(
            RecordTypeId = recordTypeOppId,                                                            // Opportunity Record Type
            Name = 'TSEL / OPP-2309-003498 / Wira Pamungkas Pratama / Agency Postpaid / 9/21/2023',  // Opportunity Name
            AccountId = acc.Id,                                                           // Account Name
            CloseDate = Date.valueOf('2023-09-21'),                                                  // Close Date
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
            // Brand__c = 'a011s00000Dk5rF',                                                            // Brand
            Type = 'Existing Business',                                                              // Type
            Penagihan_based_on__c = 'Postpaid',                                                      // Penagihan based on
            Performance_Product__c = false,                                                          // Performance Product
            Programmatic_Product__c = false,                                                         // Programmatic Product
            Performance_Done__c = false,                                                             // Performance Done
            RFP_Status_sales__c = 'Completed',                                                       // RFP Status (sales)
            Check_PO__c = 'OK',
            Pricebook2Id = Test.getStandardPricebookId()
            
        );
        insert opp;

        OpportunityLineItem oli =new OpportunityLineItem();
        oli.Product2id=prod.id;
        oli.Quantity=1000;
        oli.UnitPrice=100000;
        oli.PricebookEntryId=pbe.id;
        oli.opportunityid=opp.id;
        Upsert oli id;

        //Pricebook2 PB=[SELECT id from PriceBook2 WHERE Name='Standard Price Book'];
        opp.Pricebook2id=pricebookId;
        opp.CloseDate=system.today().adddays(10);
        opp.Approval_Status__c='Approved';
        opp.Check_PO__c='OK';
        Upsert opp id;
        
        opp.StageName ='Closed Won';
        Upsert opp id;
           
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
        newSOADetail.PricebookEntryId__c=pbe.id;
        newSOADetail.product__c=prod.id;
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
        odr.Pricebook2id=pricebookId;
        odr.OpportunityId=opp.id;
        odr.ContractId=LContract[0].id;
        odr.EffectiveDate=system.today();
        odr.EndDate=system.today().adddays(10);
        odr.SOA__c=newSOA.id;
        odr.status='Draft';
        
        upsert odr;
        
        List<Order> lneworder=[SELECT id,name,OrderNumber FROM Order where id=:odr.id LIMIT 1];

        OrderItem odit = new OrderItem();
        
        odit.Product2id=prod.id;
        odit.Quantity=1000;
        odit.UnitPrice=100000;
        odit.campaign_id__c=Date.today().year()+'_B'+lneworder[0].OrderNumber+'_'+lnewsoa[0].Name+'_'+'001'+'_'+2;
        //odit.camp_id__c=lnewsoa[0].Name+'_'+'001'+'_'+1;
        odit.PricebookEntryId=pbe.id;
        odit.OrderId =odr.id;
        upsert odit;
        
        List<OrderItem> lodit=[SELECT id,Product2id,campaign_id__c,camp_id__c FROM OrderItem where id=:odit.id LIMIT 1];
        
        Test.startTest();
        Usage__c usg = new Usage__c();
        usg.NIK__c = '81312';
        usg.Campaign_ID__c = lodit[0].campaign_id__c;
        usg.Date__c = date.today();
        usg.amount__c = 1000;
        insert usg;
        Test.stopTest();

    }
}