/**
 * @description       : 
 * @author            : Ahmat Zulkifli Murad
 * @group             : 
 * @last modified on  : 04-29-2024
 * @last modified by  : Ahmat Zulkifli Murad
**/
@isTest
public class Test_Trigger_SOA_After_Insert {

    /*
    static testMethod void testMethod_Generate_SOA() {
        // Create Test Data
        User u = [SELECT Id FROM User WHERE Username LIKE '%andi_mario@telkomsel.co.id%' LIMIT 1];
        Account acc = new Account(Name = 'Test Account ABC');
        insert acc;
        
        Contact cont = new Contact(LastName = 'Doddy ABC', AccountId = acc.Id);
        insert cont;
        
        Opportunity opp = new Opportunity(Name = 'Test 888', StageName ='Prospecting', AccountId = acc.Id, CloseDate = System.today().addDays(10));
        insert opp;
        Pricebook2 priceBook = new Pricebook2(Name = 'Standard Price Book');
        insert priceBook;
        Pricebook2 PB = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1];
        
        // Peroleh Product2 yang sudah ada dalam org Anda
        Product2 pro = new Product2(Name = 'Existing Product',Product_Category__c ='Advertising');
        insert pro;
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'Existing Product' LIMIT 1];
        
        // Buat PricebookEntry dengan menggunakan Product2 yang telah ada
        PricebookEntry pbe = new PricebookEntry(
            //Pricebook2Id = PB.Id,01s2v00000BrLSkAAN
            Pricebook2Id = '01s1s000000E1XsAAK',
            Product2Id = prod.Id, // Hubungkan PricebookEntry dengan Product2
            UnitPrice = 100000,
            IsActive = true
        );
        insert pbe;

        // Buat OpportunityLineItem dengan menggunakan PricebookEntry yang telah ada
        OpportunityLineItem oppProduct = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 5,
            TotalPrice = 100000,
            PricebookEntryId = pbe.Id // Hubungkan OpportunityLineItem dengan PricebookEntry
        );
        insert oppProduct;
		opp.Check_PO__c = 'OK';
        opp.StageName ='Closed Won';
        update opp;
          
        Contract newContract = new Contract(StartDate = Date.today()+10, ContractTerm = 1, Opportunity__c = opp.Id, AccountId = acc.Id);
        insert newContract;

        SOA__c newSOA = new SOA__c(Opportunity__c = opp.Id, SOA_Start_Date__c = Date.today(), SOA_End_Date__c = Date.today());
        System.Debug('newSOA ==' + newSOA);
        insert newSOA;

        SOA_Detail__c newSOADetail = new SOA_Detail__c(SOA__c = newSOA.Id, Start_Date__c = Date.today(), End_Date__c = Date.today(), 
                                                        Campaign_ID__c = newSOA.Name + '_' + '001' + '_' + 1, PricebookEntryId__c = pbe.Id, 
                                                        product__c = prod.Id, Quantity__c = 1000, Unit_Price__c = 100000);
        insert newSOADetail;

        // Perform the Test
        Test.startTest();
        ApexPages.StandardController ssc = new ApexPages.StandardController(newSOA);
        GenerateSOAController gsc = new GenerateSOAController(ssc);
        Test.stopTest();

        // Add Assertions if needed
        // Example Assertion:
        // System.assertEquals(expectedValue, actualValue);
    }
    */

    @isTest
    static void handlingSOACreationandUpdate(){
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
        insert oppRecord;
        
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
        
        Test.startTest();
       
        SOA__c soaRecord = new SOA__c(
            Opportunity__c = oppRecord.Id,              // Opportunity
            SOA_Type__c = 'Opportunity',                     // SOA Type
            SOA_Start_Date__c = Date.valueOf('2024-10-01'),  // SOA Start Date
            SOA_End_Date__c = Date.valueOf('2024-10-31'),    // SOA End Date
            SOA_Sources__c = 'Opportunity'                  // SOA
        );
        insert soaRecord;

        soaRecord.SOA_Start_Date__c = Date.valueOf('2024-10-02');
        update soaRecord;
        test.stopTest();
    }
}