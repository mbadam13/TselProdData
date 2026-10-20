@isTest
public with sharing class pubmaticBillingServicesTest {
    
    @TestSetup
    static void makeData(){
    
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

        Sites__c siteRecord = new Sites__c(
            Site_ID__c = '801823',                               // Site ID
            siteUrl__c = 'TADEX|MobileWeb|Abc|Abc.com|Outstream',  // siteUrl
            Platform__c = 'Mobile',                                // Platform
            Status__c = 'New'                                     // Status
        );
        insert siteRecord;

        Demand_Source_Information__c DSIRecord = new Demand_Source_Information__c(
            Demand_Source__c = 'Programmatic PMP with Client\'s DSP',// Demand Source
            Share__c = 17                                          // Share
        );
        insert DSIRecord;

        Business_Model_Category__c BMCRecord = new Business_Model_Category__c(
            BMC_Name__c = 'Tadex Client',                           // BMC Name
            Demand_Source_Information__c = DSIRecord.Id,
            BMC_Text__c = 'TADEX_',                                   // BMC Text
            Percentage__c = 17.00,                                  // Percentage
            Demand_Source__c = 'Programmatic PMP with Client\'s DSP'  // Demand Source
        );
        insert BMCRecord;

        list<traffic__c> newTrafficList = new list <traffic__c>();
        for(Integer i = 0; i < 5; i++){
            traffic__c newTrafficRec = new traffic__c();
            newTrafficRec.Deal_ID__c = 'PM-DAOB-0603-001';                          // Deal ID
            newTrafficRec.Deal__c = 'TADEX_NESTLE_TTD_0000_DISPLAY_08042021';       // Deal
            newTrafficRec.Total_Telkomsel_Share__c = 17;                          // Total Telkomsel Share
            newTrafficRec.Date__c = date.newInstance(2028, 06, 01);
            newTrafficRec.Demand_Source__c = 'Programmatic PMP with Clients DSP';  // Demand Source
            newTrafficRec.Deal_Source__c = 'Publisher';                             // Deal Source
            newTrafficRec.Paid_Impressions__c = 3401;                            // Paid Impressions
            newTrafficRec.Revenue_USD__c = 2.72;                                  // Revenue (USD)
            newTrafficRec.PMP_Fees__c = 0.27;                                     // PMP Fees
            newTrafficRec.Fee__c = 10;                                            // Fee (%)
            newTrafficRec.Net_Revenue__c = 2.45;                                  // Net Revenue
            newTrafficRec.Sites__c = siteRecord.id;
            newTrafficRec.Business_Model_Category__c = BMCRecord.id;
            newTrafficList.add(newTrafficRec);
        }
        insert newTrafficList;
    }

    @isTest
    static void TestGeneratePubmaticBilling() {
        test.startTest();
        pubmaticBillingServices.generatePubmatticBilling(date.newInstance(2028, 06, 01));
        test.stopTest();
    }
}