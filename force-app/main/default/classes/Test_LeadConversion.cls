@isTest
public class Test_LeadConversion {
    
    static testMethod void LeadConversion(){
		
        RecordType rt = [SELECT Id, Name, DeveloperName, IsActive, SobjectType FROM RecordType WHERE DeveloperName = 'Publisher' AND SobjectType = 'Lead'];
        System.debug('*** rt = ' + rt );
        
        Lead ld = new Lead();
        ld.Account_Type__c = 'Publisher';
        ld.Company = 'PT. Inti Mesra';
        ld.Site_Domain__c = 'dinamomediant.com';
        ld.Nomor_Verifikasi_Dewan_Pers__c = '456/DP-Terverifikasi/K/XI/2020';
        ld.LeadSource = 'Instagram';
        ld.Status = 'New';
        ld.LastName = 'Andhito';
        ld.Title = 'Marketing Manager';
        ld.Email = 'andhito@gmail.com';
        ld.MobilePhone = '98765467';
        ld.Alamat_PIC_Utama__c = 'grogol';
        ld.PIC_Marketing__c = 'Marduk';
        ld.Title_PIC_Marketing__c = 'Assistant Manager';
        ld.PIC_Marketing_Email__c = 'marduk@gmail.com';
        ld.PIC_Marketing_Mobile__c = '089694813176';
        ld.Alamat_PIC_Marketing__c = 'sawangan';
        ld.Total_Ad_Request_Bulan__c = 1000;
        ld.Tipe_Platform__c = 'Web';
        ld.Tipe_Display_Ads__c = 'Desktop Display 300x250';
        ld.Content__c = 'General';       
        ld.Tipe_Video_Ads__c = 'Video instream - VAST';
        ld.Privacy_Policy__c = 'test';
        ld.RecordTypeId = rt.Id;
        ld.Header_Bidding__c = 'Implementasi Header Bidding';
        insert ld;
        
        ld.Status = 'Qualified';
        update ld;
        
        /*List<Id> leadIdList1 = new List<Id>();
        leadIdList1.add(ld.Id);
        LeadConversion.LeadConversion(leadIdList1);*/
        
        Lead ld2 = new Lead();
        ld2.Account_Type__c = 'Publisher';
        ld2.Company = 'PT. Inti Mesra';
        ld2.Site_Domain__c = 'dinamomediant2.com';
        ld2.Nomor_Verifikasi_Dewan_Pers__c = '457/DP-Terverifikasi/K/XI/2021';
        ld2.LeadSource = 'Instagram';
        ld2.Status = 'New';
        ld2.LastName = 'Andhito2';
        ld2.Title = 'Marketing Manager';
        ld2.Email = 'andhito2@gmail.com';
        ld2.MobilePhone = '987654672';
        ld2.Alamat_PIC_Utama__c = 'beji';
        ld2.PIC_Marketing__c = 'Dikka';
        ld2.Title_PIC_Marketing__c = 'Assistant Manager';
        ld2.PIC_Marketing_Email__c = 'marduk2@gmail.com';
        ld2.PIC_Marketing_Mobile__c = '089694813177';
        ld2.Alamat_PIC_Marketing__c = 'depok';
        ld2.Total_Ad_Request_Bulan__c = 1500;
        ld2.Tipe_Platform__c = 'Web';
        ld2.Tipe_Display_Ads__c = 'Desktop Display 300x250';
        ld2.Content__c = 'General';       
        ld2.Tipe_Video_Ads__c = 'Video instream - VAST';
        ld2.Privacy_Policy__c = 'test2';
        ld2.RecordTypeId = rt.Id;
        ld2.Header_Bidding__c = 'Implementasi Header Bidding';
        insert ld2;
        
        ld2.Status = 'Qualified';
        update ld2;        
        
        /*List<Id> leadIdList2 = new List<Id>();
        leadIdList2.add(ld2.Id);
        LeadConversion.LeadConversion(leadIdList2);*/
        
        Lead ld3 = New Lead();
        ld3.Account_Type__c = 'Publisher';
        ld3.Company = 'PT. Inti Persada';
        ld3.Site_Domain__c ='dinamomediant3.com';
        ld3.Nomor_Verifikasi_Dewan_Pers__c = '457/DP-Terverifikasi/K/XI/2030';
        ld3.LeadSource = 'Instagram';
        ld3.Status = 'New';
        ld3.LastName = 'Oyong';
        ld3.Title = 'Marketing Officer';
        ld3.Email = 'andhito2@gmail.com';
        ld3.MobilePhone = '089694813131';
        ld3.Alamat_PIC_Utama__c = 'Beji';
        ld2.PIC_Marketing__c = 'Jawa';
        ld3.Title_PIC_Marketing__c = 'Assistant Management';
        ld3.PIC_Marketing_Email__c = 'marduk2@gmail.com';
        ld3.PIC_Marketing_Mobile__c = '089694813179';
        ld3.Alamat_PIC_Marketing__c = 'Jonggol';
        ld3.Total_Ad_Request_Bulan__c = 3000;
        ld3.Tipe_Platform__c = 'Web';
        ld3.Tipe_Display_Ads__c = 'Desktop Display 300x250';
        ld3.Content__c = 'General';       
        ld3.Tipe_Video_Ads__c = 'Video instream - VAST';
        ld3.Privacy_Policy__c = 'test2';
        ld3.RecordTypeId = rt.Id;
        ld3.Header_Bidding__c = 'Implementasi Header Bidding';
        insert ld3;
        
        ld3.Status = 'Qualified';
        update ld3;
    }
}