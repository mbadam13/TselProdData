/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 16/04/2025
 * @last modified by  : Syaiful Syafani
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   24/03/2025   Syaiful Syafani   Initial Version
**/
@isTest
public with sharing class MassRecordUpdateControllerTest {
    private static User createUser() {
        Profile proRec = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        UserRole roleRec = [SELECT Id, Name, PortalRole FROM UserRole WHERE Name='ADMIN' LIMIT 1];
        User userRec = new User(
            FirstName           = 'System',
            LastName            = 'Admin',
            NIK__c              = '444999',
            Username            = 'admin@digiads.com.invalid',
            Alias               = 'Adm',
            EmailEncodingKey    = 'UTF-8',
            Email               = 'admin@digiads.com.invalid',
            ProfileId           = proRec.Id,
            UserRoleId          = roleRec.Id,
            LocaleSidKey        = 'en_US',
            LanguageLocaleKey   = 'en_US',
            TimeZoneSidKey      = 'America/Los_Angeles'
        );
        insert userRec;
        return userRec;
    }

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

        MRU_Batch_Setting__c batchSetting = new MRU_Batch_Setting__c(
            Name    = 'Default_Size',
            size__c = 15
        );
        insert batchSetting;

        MRU_Email_Setting__c emailSetting = new MRU_Email_Setting__c(
            Name                    = 'MRU_Batch_Email',
            Email_Template_Name__c  = 'MassUpdate_Batch_Notifications',
            CC_Address__c           = '',
            BCC_Address__c          = ''
        );
        insert emailSetting;

        // === product ===
        product2 prodRec = new Product2(
            Name = 'BULK (SMS Premium)',
            Business_Product__c = 'Digital Media',
            Product_Category__c = 'Advertising',
            Family = 'Messaging',
            Product_Type__c = 'SMS',
            Product_Channel__c = 'Mobile',
            Ads_Format__c = 'Text',
            Ads_Size__c = 'Standard',
            Buying_Method__c = 'I/O',
            ProductCode = 'SMS',
            Ads_Detail__c = 'BULK (SMS Premium)_3telco_Icode',
            Channel_Detail__c = 'Mobile',
            Rate_Card_Refference__c = 'Messaging',
            PIC_Product_Type__c = 'Messaging',
            IsActive = true,
            List_Price__c = 600.00
        );
        insert prodRec;

        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prodRec.Id,
            UnitPrice = 600.00,
            IsActive = true
        );
        insert pbEntry;

        // === mass record update ===
        Mass_Record_Update__c mruRec = new Mass_Record_Update__c(
            Name = 'Update Product',
            Object_Name__c = 'Product2',
            Page_Layout__c = 'Product Layout'
        );
        insert mruRec;

        Mass_Record_Update_Item__c mruItemRec = new Mass_Record_Update_Item__c(
            Mass_Record_Update__c = mruRec.id,                                         
            Object_Name__c = 'Product2',                                                
            Selected_Sobject_Record_ID__c = prodRec.id                                 
        );
        insert mruItemRec;
    }

    @isTest
    static void getSobjectHeaderColumn_Test(){
        MassRecordUpdateController.getSobjectHeaderColumn('Product2');
    }

    @isTest
    static void getSobjectItemsHeaderColumn_Test() {
        MassRecordUpdateController.getSobjectItemsHeaderColumn('Product2');
    }

    @isTest
    static void getSobjectListFieldsType_Test(){
        MassRecordUpdateController.getSobjectListFieldsType('Id', 'Product2');
    }

    @isTest
    static void getSobjectListFieldsName_Test(){
        MassRecordUpdateController.getSobjectListFieldsName('Record ID', 'Product2');
    }

    @isTest
    static void getSobjectListFieldsLable_Test(){
        MassRecordUpdateController.getSobjectListFieldsLable('Product2', 'Product Layout');
    }

    @isTest
    static void getSobjectRecordItemListFieldsLable_Test(){
        MassRecordUpdateController.getSobjectRecordItemListFieldsLable('Product2', 'Product Layout');
    }

    @isTest
    static void getSobjectRecordList_Test(){
        // MassRecordUpdateController.getSobjectRecordList(String SobjectApiName, String FilterRecord, Integer pageSize, Integer pageNumber, String operatorCondition, String fieldType, String recordType)
        String filterRecord = '[{"index":1,"filterUpdateField":"Product Name","textField":"Bulk","textFieldVisible":true,"numberField":null,"numberFieldVisible":false,"picklistField":null,"picklistFieldVisible":false,"startDateField":null,"endDateField":null,"dateFieldVisible":false,"dateTimeField":null,"dateTimeFieldVisible":false,"checkboxField":null,"checkboxFieldVisible":false}]';

        MassRecordUpdateController.getSobjectRecordList('Product2', filterRecord, 1, 1, 'AND', 'String', 'Product Layout');
    }

    @isTest
    static void putSelectedRowtoMassRecordUpdateItems_Test(){
        // MassRecordUpdateController.putSelectedRowtoMassRecordUpdateItems(String selectedRecordRowId, id massUpdateRecordId, String SobjectApiName, Integer pageSize, Integer pageNumber, Boolean selectedAllRecordItem, List<String> recordItemIdList)
        list<string> recordItemIdList = new list<string>();
        Product2 prodRec = [SELECT Id FROM Product2 WHERE Name = 'BULK (SMS Premium)'];
        recordItemIdList.add(prodRec.id);
        Mass_Record_Update__c massRecordUpdate = [SELECT id FROM Mass_Record_Update__c WHERE name = 'Update Product'];
        
        MassRecordUpdateController.putSelectedRowtoMassRecordUpdateItems(prodRec.id, massRecordUpdate.id, 'Product2', 10, 10, true, recordItemIdList);
    }

    @isTest
    static void getSelectedMassRecordUpdateItems_Test(){
        // MassRecordUpdateController.getSelectedMassRecordUpdateItems(id massUpdateRecordId, String SobjectApiName, Integer pageSize, Integer pageNumber, String searchKeyUpdateRecordItem, String selectedRecordUpdateItemViewDefault)
        Product2 prodRec = [SELECT id FROM Product2 WHERE Name = 'BULK (SMS Premium)'];

        Mass_Record_Update__c massRecordUpdateRec = [SELECT id FROM Mass_Record_Update__c WHERE name = 'Update Product'];
        Mass_Record_Update_Item__c massRecordupdateItemRec = [SELECT id FROM Mass_Record_Update_Item__c WHERE Mass_Record_Update__c =:massRecordUpdateRec.id ];
        Mass_Record_Update_List_View__c selectedRecordUpdateItemViewSettings = [SELECT id, Selected_List_View__c FROM Mass_Record_Update_List_View__c WHERE name = 'Selected_Search_Items_View' ];

        string massRecordupdateItemRecId = string.valueOf(massRecordupdateItemRec.id);
        string selectedRecordUpdateItemViewDefault = selectedRecordUpdateItemViewSettings.Selected_List_View__c;

        MassRecordUpdateController.getSelectedMassRecordUpdateItems(massRecordUpdateRec.id, 'Product2', 1, 1, massRecordupdateItemRecId.replace(')', '').replace('(', ''), selectedRecordUpdateItemViewDefault);
    }

    @isTest
    static void removeRecordUpdateItem_Test(){
        // MassRecordUpdateController.removeRecordUpdateItem(id massRecordUpdateId, String selectedRowRemoveItems, List<String> selectedRemoveItems, Boolean selectedAllRecordRemoveItems, String SobjectApiName)
        Mass_Record_Update__c massRecordUpdateRec = [SELECT id FROM Mass_Record_Update__c WHERE name = 'Update Product'];

        list<string> massRecordupdateItemList = new list<string>();
        Mass_Record_Update_Item__c massRecordupdateItemRec = [SELECT id FROM Mass_Record_Update_Item__c WHERE Mass_Record_Update__c =:massRecordUpdateRec.id ];
        massRecordupdateItemList.add(massRecordupdateItemRec.id);

        MassRecordUpdateController.removeRecordUpdateItem(massRecordUpdateRec.id, massRecordupdateItemRec.id, massRecordupdateItemList, true, 'Product2');
    }

    @isTest
    static void updateSobjectRecordItems_Test(){
        // MassRecordUpdateController.updateSobjectRecordItems(List<String> SobjectrecordIds, String SobjectApiName, String massUpdateRecordId, String fieldDataType, String fieldApiName, String valuetoUpdate, boolean selectedAllRecordItem, String fieldLabel, Integer batchSize)
        list<string> recordItemIdList = new list<string>();
        Product2 prodRec = [SELECT id FROM Product2 WHERE Name = 'BULK (SMS Premium)'];
        recordItemIdList.add(prodRec.id);

        Mass_Record_Update__c massRecordUpdateRec = [SELECT id FROM Mass_Record_Update__c WHERE name = 'Update Product'];
        
        MassRecordUpdateController.updateSobjectRecordItems(recordItemIdList, 'Product2', massRecordUpdateRec.id, 'string', 'Ads_Detail__c', 'BULK (SMS Premium)_4telco_Icode', true, 'Ads Detail', 1); // before -> BULK (SMS Premium)_3telco_Icode
    }

    @isTest
    static void SaveSearchItemListView_Test(){
        // MassRecordUpdateController.SaveSearchItemListViewSaveSearchItemListView(List<String> searchItemColumnView, String SobjectrecordIds)
        Mass_Record_Update__c massRecordUpdateRec = [SELECT id FROM Mass_Record_Update__c WHERE name = 'Update Product'];
        Mass_Record_Update_List_View__c selectedRecordUpdateItemViewSettings = [SELECT id, Selected_List_View__c FROM Mass_Record_Update_List_View__c WHERE name = 'Selected_Search_Items_View' ];

        list<string> selectedRecordUpdateItemViewDefault = (selectedRecordUpdateItemViewSettings.Selected_List_View__c).split(',');
        
        MassRecordUpdateController.SaveSearchItemListView(selectedRecordUpdateItemViewDefault, massRecordUpdateRec.id);
    }

    @isTest
    static void SaveRecordItemListView_Test(){
        // MassRecordUpdateController.SaveRecordItemListView(List<String> selectedItemColumnView, String SobjectrecordIds)
        Mass_Record_Update__c massRecordUpdateRec = [SELECT id FROM Mass_Record_Update__c WHERE name = 'Update Product'];
        Mass_Record_Update_List_View__c selectedRecordUpdateItemViewSettings = [SELECT id, Selected_List_View__c FROM Mass_Record_Update_List_View__c WHERE name = 'Selected_Search_Items_View' ];

        list<string> selectedRecordUpdateItemViewDefault = (selectedRecordUpdateItemViewSettings.Selected_List_View__c).split(',');

        MassRecordUpdateController.SaveRecordItemListView(selectedRecordUpdateItemViewDefault, massRecordUpdateRec.id);
    }

    @isTest
    static void getSobjectPicklistValues_Test(){
        MassRecordUpdateController.getSobjectPicklistValues('Product2', 'Family');
    }
}