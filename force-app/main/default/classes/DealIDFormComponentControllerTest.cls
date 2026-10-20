@isTest
public with sharing class DealIDFormComponentControllerTest {
    @TestSetup
    static void makeData(){
        Trigger_Setting__c triggerSettingsRec = new Trigger_Setting__c();
        triggerSettingsRec.name = 'Validation:_Deal_ID_Must_be_filled';
        triggerSettingsRec.Error_Message__c = 'Validation:_Deal_ID_Must_be_filled';
        triggerSettingsRec.IsActive__c = true;
        triggerSettingsRec.Object_Name__c = 'Opportunity' ;
        insert triggerSettingsRec;

        LOB__c LOBRecord = new LOB__c(
            name = 'FMCG'
        );
        insert LOBRecord;

        Account accountRecord = new Account(
            Name = 'PT. Dinamo Media NTq',                                                                                                             // Account Name
            Site_Domain__c = 'dinamomediant.com',                                                                                                        // Site Domain
            Account_Type__c = 'Publisher',                                                                                                               // Account Type
            Nomor_Verifikasi_Dewan_Pers__c = '456/DP-Terverifikasi/K/XI/2020',                                                                           // Nomor Verifikasi Dewan Pers
            AccountSource = 'TADEX Form',                                                                                                                // Account Source
            Nomor_Induk_Berusaha__c = '123450017862',                                                                                                    // Nomor Induk Berusaha
            Publisher_Status__c = 'Ad Tag Shared',                                                                                                       // Publisher Status
            Nama_Penjabat__c = 'Joice',                                                                                                                  // Nama Penjabat
            Jabatan_Penjabat__c = 'Manager',                                                                                                             // Jabatan Penjabat
            Contract_Bypass_Approval__c = 'Approved',                                                                                                    // Contract Bypass Approval
            Status__c = 'Approved by Settlement',                                                                                                        // Status
            Tipe_Platform__c = 'Web;Mobile',                                                                                                             // Tipe Platform
            Total_Ad_Request_Bulan__c = 973,                                                                                                     // Total Ad Request/Bulan
            Tipe_Display_Ads__c = 'Desktop Display 300x250;Desktop Display 728x90;Desktop Display 320x50;Mobile Display 300x250;Mobile Display 320x50',  // Tipe Display Ads
            Content__c = 'General',                                                                                                                     // Content
            Nama_Pemilik__c = 'Tika',                                                                                                                    // Nama Pemilik
            Nomor_Rekening__c = '098907890079',                                                                                                          // Nomor Rekening
            Chatter_Name__c = 'Siska',                                                                                                                   // Chatter Name
            Chatter_Email__c = 'siska@dmnt.com',                                                                                                         // Chatter Email
            Chatter_Group_Id__c = '0F9p0000000NWljCAG'                                                                                                  // Chatter Group Id
                                                                                                               // Account Record Type
        );
        insert accountRecord;

        Contact contactRecord = new Contact(
            LastName = 'murad UAT',
            AccountId = accountRecord.id
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
        newContract.AccountId = accountRecord.id;
        insert newContract;

        newContract.Status = 'Activated';
        update newContract;
     
        // Create a test product
        Product2 prod = new Product2(
            Name = 'Tadex Display', 
            IsActive = true, 
            ProductCode = 'TP001', 
            Description = 'Test Product Description',
            Product_Category__c = 'Tadex'
        );
        insert prod;

        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebookREC = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebookREC;
        
        PricebookEntry pbEntrySTDREC = new PricebookEntry(
            Product2Id = prod.id,  // Product
            IsActive = true,                   // Active
            Pricebook2Id = standardPricebookREC.id,  // Price Book
            UnitPrice = 52.500,                // List Price
            UseStandardPrice = false          // Use Standard Price
        );
        insert pbEntrySTDREC;

        Opportunity opportunityRecord = new Opportunity(
            Name = 'Test Opportunity', 
            accountid = accountRecord.id,
            brand__c = brandRecord.id,
            StageName = 'Prospect', 
            CloseDate = Date.today().addDays(30), 
            Amount = 50000,
            Approval_Status__c = 'Approved',
            Check_PO__c='OK',
            Regional__c = 'BALINUSRA'
        );
        insert opportunityRecord;

        OpportunityLineItem oli_prod1 = new OpportunityLineItem();
        oli_prod1.OpportunityId = opportunityRecord.Id;
        oli_prod1.Product2Id = prod.id;
        oli_prod1.UnitPrice = 500;
        oli_prod1.PricebookEntryId = pbEntrySTDREC.id;
        oli_prod1.Quantity = 100;
        
        insert oli_prod1;
    }

    @isTest
    public static void getOpportunityLineItem(){
        Opportunity opportunityRecord = [select id from Opportunity where StageName = 'prospect'];
        OpportunityLineItem testOpportunityLineItem = [select id, Product2.name, Deal_ID__c from OpportunityLineItem where OpportunityId =:opportunityRecord.id];
        test.startTest();
        //DealIDFormComponentController.getOpportunityProduct(string.valueOf(opportunityRecord.id));
        List<OpportunityLineItem> result = DealIDFormComponentController.getOpportunityProduct(opportunityRecord.Id);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Expected 1 Opportunity Line Item to be returned');
        System.assertEquals(testOpportunityLineItem.Id, result[0].Id, 'Unexpected Opportunity Line Item returned');
        System.assertEquals(testOpportunityLineItem.Product2.Name, result[0].Product2.Name, 'Unexpected Product Name');
        System.assertEquals(testOpportunityLineItem.Deal_ID__c, result[0].Deal_ID__c, 'Unexpected Deal ID value');
    }
}