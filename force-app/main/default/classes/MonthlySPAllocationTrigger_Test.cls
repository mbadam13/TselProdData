/**
 * @description       : 
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 07-04-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   07-04-2023   Novando Utoyo Agmawan   Initial Version
**/

@isTest()
public class MonthlySPAllocationTrigger_Test {
    public static testMethod void testMethodD(){
        Trigger_Setting__c TriggerSetting1 = new Trigger_Setting__c(
            Name = 'MonthlySpecialPriceAllocationTrigger',
            Error_Message__c = null,
            IsActive__c = true,
            Object_Name__c = 'Monthly_Special_Price_Allocation__c'
        );
        insert TriggerSetting1;

        Kategori_Industri__c KategoriIndustri = new Kategori_Industri__c();
        KategoriIndustri.Name = 'Others'; 
        KategoriIndustri.prefix_ms__c = 'oth' ;
        insert KategoriIndustri;
        
        Account acc = new Account ();
        acc.Name='IMS';
        acc.Account_Type__c='Media_Seller';
        acc.Legal_Name__c='IMS';
        acc.Category__c='others';
        acc.Kategori_Industri__c= KategoriIndustri.Id;
        acc.prefix_ms__c='ims';
        insert acc;

        Monthly_Special_Price_Allocation__c MonthlySPAllocation1 = new Monthly_Special_Price_Allocation__c(
            Media_Seller__c = acc.Id,
            Start_Date__c = System.today(),
            End_Date__c = System.today(),
            Usage__c = 1,
            Invoice__c = 1,
            Minimum_Guarantee__c = 1,
            Target_Commitment__c = 1,
            Special_Price__c = 1,
            Bulk_Alocation_Percentage__c = 1,
            Non_Bulk_Allocation_Percentage__c = 1
        );
        Insert MonthlySPAllocation1;

        Test.startTest();
        
        MonthlySPAllocation1.Usage__c = 2;
        update MonthlySPAllocation1;

        Test.stopTest();
    }
}