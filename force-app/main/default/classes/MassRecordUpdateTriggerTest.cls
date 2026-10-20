/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 16/04/2025
 * @last modified by  : Syaiful Syafani 
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   16/04/2025   Syaiful Syafani   Initial Version
**/
@isTest
public with sharing class MassRecordUpdateTriggerTest {
    @TestSetup
    static void makeData(){
        // ========= custom setting =========
        Mass_Record_Update_List_View__c searchItemListView = new Mass_Record_Update_List_View__c(
            Name                    = 'Selected_Search_Items_View',
            Selected_List_View__c   = 'Id;Name;CreatedDate' 
        );
        insert searchItemListView;

        Mass_Record_Update_List_View__c selectedSearchItemListView = new Mass_Record_Update_List_View__c(
            Name                    = 'Selected_Search_Record_Items_View',
            Selected_List_View__c   = 'Id;Name;CreatedDate;Mass_Update_Status__c' 
        );
        insert selectedSearchItemListView;
    }

    @isTest
    static void insertMRU(){
        Mass_Record_Update__c mruRec = new Mass_Record_Update__c(
            name = 'Update Product',
            Object_Name__c = 'Product2',
            Page_Layout__c = 'Product Layout'
        );

        Test.startTest();
            insert mruRec;
        Test.stopTest();
    }
}