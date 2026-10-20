/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 20/03/2025
 * @last modified by  : Syaiful Syafani
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   10/03/2025   Syaiful Syafani   Initial Version
**/
public with sharing class TA_AT_MRU_BI_SetSelectedSearchItemsView implements TriggerAction.BeforeInsert {
    public void BeforeInsert(list<Mass_Record_Update__c> massRecordUpateList){
        system.debug('----TA_AT_MRU_BI_SetSelectedSearchItemsView.BeforeInsert----');
         
        string errorMsg;
        try {
            Mass_Record_Update_List_View__c searchItemDataTableListView = Mass_Record_Update_List_View__c.getValues('Selected_Search_Items_View');
            Mass_Record_Update_List_View__c recordItemsDataTableListView = Mass_Record_Update_List_View__c.getValues('Selected_Search_Record_Items_View');
            MRU_Batch_Setting__c defaultBatchSize = MRU_Batch_Setting__c.getValues('Default_Size');
            System.debug('searchItemDataTableListView ::' + searchItemDataTableListView);
            System.debug('recordItemsDataTableListView ::' + recordItemsDataTableListView);
            System.debug('defaultBatchSize ::' + defaultBatchSize);

            list<Mass_Record_Update__c> udpateMassRecordUpdateListView = new list<Mass_Record_Update__c> ();
            for (Mass_Record_Update__c massRecordUpateListRec : massRecordUpateList) {
                massRecordUpateListRec.Selected_Search_Items_View__c = searchItemDataTableListView.Selected_List_View__c;
                massRecordUpateListRec.Selected_Record_Items_View__c = recordItemsDataTableListView.Selected_List_View__c;
                massRecordUpateListRec.Batch_Size__c = defaultBatchSize.Size__c;
                
                udpateMassRecordUpdateListView.add(massRecordUpateListRec);
            }

        } catch (Exception e) {
            errorMsg = errorMsg + '. Error on TA_AT_SetSelectedSearchItemsView Before Insert' + e.getMessage() + ' - ' + e.getStackTraceString() + e.getLineNumber();
            apputils.putError(errorMsg);
            system.debug('==== errorMsg :' + errorMsg);
        }

    }
}