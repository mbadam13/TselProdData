import { api, LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';
import LightningConfirm from 'lightning/confirm';

//retrive controller method
import getSobjectListFieldsName from '@salesforce/apex/MassRecordUpdateController.getSobjectListFieldsName';
import getSobjectListFieldsLable from '@salesforce/apex/MassRecordUpdateController.getSobjectListFieldsLable';
import getSobjectRecordItemListFieldsLable from '@salesforce/apex/MassRecordUpdateController.getSobjectRecordItemListFieldsLable';
import getSobjectListFieldsType from '@salesforce/apex/MassRecordUpdateController.getSobjectListFieldsType';
import getSobjectRecordList from '@salesforce/apex/MassRecordUpdateController.getSobjectRecordList';
import getSobjectHeaderColumn from '@salesforce/apex/MassRecordUpdateController.getSobjectHeaderColumn';
import getSobjectItemsHeaderColumn from '@salesforce/apex/MassRecordUpdateController.getSobjectItemsHeaderColumn';
import putSelectedRowtoMassRecordUpdateItems from '@salesforce/apex/MassRecordUpdateController.putSelectedRowtoMassRecordUpdateItems';
import getSelectedMassRecordUpdateItems from '@salesforce/apex/MassRecordUpdateController.getSelectedMassRecordUpdateItems';
import removeRecordUpdateItem from '@salesforce/apex/MassRecordUpdateController.removeRecordUpdateItem';
import updateSobjectRecordItems from '@salesforce/apex/MassRecordUpdateController.updateSobjectRecordItems';
import SaveRecordItemListView from '@salesforce/apex/MassRecordUpdateController.SaveRecordItemListView';
import SaveSearchItemListView from '@salesforce/apex/MassRecordUpdateController.SaveSearchItemListView';
import getSobjectPicklistValues from '@salesforce/apex/MassRecordUpdateController.getSobjectPicklistValues';

//get currentvalue in record , getFieldValue
import Get_Sobject_Name from '@salesforce/schema/Mass_Record_Update__c.Object_Name__c';
import Get_Sobject_PageLayoutName from '@salesforce/schema/Mass_Record_Update__c.Page_Layout__c';
import Selected_Search_Items_View from '@salesforce/schema/Mass_Record_Update__c.Selected_Search_Items_View__c';
import Selected_Record_Items_View from '@salesforce/schema/Mass_Record_Update__c.Selected_Record_Items_View__c';
import Batch_Size from '@salesforce/schema/Mass_Record_Update__c.Batch_Size__c';

export default class MassRecordUpdate_LWC extends LightningElement {

    @api recordId;

    filterRowSearchRecordItemsData = '10';
    filterRowSelectedRecordItemsData = '10';
    valueOperatorFilter = 'AND';
    sobjectApiName;
    recordTypeName;

    @track sobjectNameUpdate;
    @track headercolumnDefault;
    @track headercolumnDefaultvalues = [];
    @track headerSelectedItemcolumnDefault;
    @track headerColumnRecordItemDefaultValues = [];
    @track fieldsOptionCombobox;
    @track fieldsRecordItemOptionCombobox;
    @track listFilterGetSobjectRecord;
    @track sobjectRecords;
    @track sobjectAllRecords;
    @track sobjectRecordsSelectedItem;
    @track sobjectRecordsSelectedAllItem;
    @track headerSobjectColumns;
    @track headerSobjectItemColumns;
    @track headerColumnSelected;
    @track headerRecordItemColumnSelected;
    @track selectedItemRecords;
    @track operatorFilterCondition = 'AND';
    @track showModalSearch = false;
    @track showModalRecordItems = false;
    @track valuesSelectRecordItems;
    @track isLoading = false;

    @track selectedFields = [];
    @track selectedRecordItemFields = [];
    @track selectedFieldRecordUpdateItem = [];
    @track selectOptionValue;
    @track getpicklistValue;
    @track batchSize;
    @track batchSizeValue;

    //for searchRecordItems

    sobjectListFieldName;
    sobjectListFieldLable;
    sobjectListRecordItemFieldLable;
    sobjectListFieldType;

    @track searchRecordItemsLoader = false;
    @track searchRecordItemsError = null;
    @track searchRecordItemsPageSize = this.filterRowSearchRecordItemsData;
    @track searchRecordItemsPageNumber = 1;
    @track searchRecordItemsTotalRecords = 0;
    @track searchRecordItemsTotalPages = 0;
    @track searchRecordItemsRecordEnd = 0;
    @track searchRecordItemsRecordStart = 0;
    @track searchRecordItemsIsPrev = true;
    @track searchRecordItemsIsNext = true;

    //for selectedRecordItems
    @track selectedRecordItemsLoader = false;
    @track selectedRecordItemsError = null;
    @track selectedRecordItemsPageSize = this.filterRowSelectedRecordItemsData;
    @track selectedRecordItemsPageNumber = 1;
    @track selectedRecordItemsTotalRecords = 0;
    @track selectedRecordItemsTotalPages = 0;
    @track selectedRecordItemsRecordEnd = 0;
    @track selectedRecordItemsRecordStart = 0;
    @track selectedRecordItemsIsPrev = true;
    @track selectedRecordItemsIsNext = true;

    @track searchItemFields = [];
    @track recordItemFields = [];
    @track searchKeyUpdateRecordItem;
    @track sortBySearchItem;
    @track sortDirectionSearchItem;
    @track sortByRecordItem;
    @track sortDirectionRecordItem;
    @track searchRecordItemData;
    @track selectedRecordItemData;
    @track checkAllSearchitem = false;
    @track checkAllRecorditem = false;

    //sobjectSearchRecorsColumns[] = this.headerSobjectColumns;
    // visible input field search item
    setVisibleFieldOptionName = false;
    setVisibleFieldOptionNumber = false;
    setVisibleFieldOptionStartDate = false;
    setVisibleFieldOptionEndDate = false;
    setVisibleFieldOptionDateTime = false;
    setVisibleFieldOptionCheckbox = false;
    setVisibleFieldOptionPicklist = false;

    // visible input field update item
    setVisibleFieldTextUpdateItem = false;
    setVisibleFieldNumberUpdateItem = false;
    setVisibleFieldStartDateUpdateItem = false;
    setVisibleFieldEndDateUpdateItem = false;
    setVisibleFieldCheckboxUpdateItem = false;
    setVisibleFieldPicklistUpdateItem = false;
    setVisibleFieldTextareaUpdateItem = false;

    // table
    setVisiblePicklistHead = true;
    setVisibleTextFieldHead = true;
    setVisibleNumberFieldHead = true;
    setVisibleStardDateHead = true;
    setVisibleEndDateHead = true;
    setVisiblesobjectSearchRecorsColumns = true;
    setVisiblesobjectSelectedItemRecorsColumns = true;
    setVisibleSobjectFieldNameList = true;
    // end test show input field

    error;
    sobjectRecordItemListFieldName;
    sobjectRecordItemListFieldLable;
    valueFieldUpdateName;
    selectedRowIds;
    selectedrowRecords;
    selectedRecordItemsrow = [];
    saveDraftValues = [];
    valuePicklistField = '';
    selectedSearchRecId = '';
    rowSearchSelectedIds;
    rowSelectedItemIds;
    selectedRecIdAllItems = [];

    // row index
    @track disableRowIndex = true;

    // search criteria
    @track nameShowContentCriteria = 'Hide';
    @track alternativeTextShowContentCriteria = 'Hide';
    @track showContectCriteria = true;
    @track iconNameCriteria = 'utility:hide';

    // result criteria
    @track nameShowContentResultCriteria = 'Hide';
    @track titleShowContentResultCriteria = 'Hide';
    @track showContentResultCriteria = false; // all section of result criteria
    @track showContentResultCriteriaSection = true;
    @track iconNameResultCriteria = 'utility:hide';

    @track showModalMassUpdate = false;
    @track setDefaultField = true;
    @track activeSearchButton = true;
    @track activeAddtoContainer = true;
    @track activeMassUpdate = true;

    @wire(getRecord, { recordId: '$recordId', fields: [Get_Sobject_Name, Selected_Search_Items_View, Get_Sobject_PageLayoutName, Selected_Record_Items_View, Batch_Size] })
    Mass_Record_Update__c(result) {
        console.log('resultWire: ', result);
        if (result.data) {
            //use getFieldValue and show your toast 
            this.headercolumnDefault = result.data.fields.Selected_Search_Items_View__c.value;
            this.headerSelectedItemcolumnDefault = result.data.fields.Selected_Record_Items_View__c.value;
            this.sobjectNameUpdate = result.data.fields.Object_Name__c.value;
            this.sobjectApiName = result.data.fields.Object_Name__c.value;
            this.recordTypeName = result.data.fields.Page_Layout__c.value;
            this.batchSize = result.data.fields.Batch_Size__c.value;


            console.log('headercolumnDefault -> ', this.headercolumnDefault);
            console.log('headerSelectedItemcolumnDefault -> ', this.headerSelectedItemcolumnDefault);
            console.log('sobjectNameUpdate -> ', this.sobjectNameUpdate);
            console.log('sobjectApiName -> ', this.sobjectApiName);
            console.log('recordTypeName -> ', this.recordTypeName);
            console.log('batchSize -> ', this.batchSize);

            this.getSobjectHeaderColumn();
            this.getSobjectItemsHeaderColumn();
            this.getSelectedFieldColumns();
            this.getSelectedRecordItemFieldColumns();
            this.getSelectedMassRecordUpdateItems();
            //this.getSelectedFieldColumns();

            // combobox search item
            getSobjectListFieldsLable({ SobjectApiName: this.sobjectNameUpdate, recordTypeName: this.recordTypeName }).then(result => {
                console.log('comboboxFilterCriteriaField: ', result);
                this.sobjectListFieldLable = result;
                let options = [];
                if (this.sobjectListFieldLable) {
                    for (const key in result) {
                        options.push({ label: result[key], value: result[key] });
                    }
                    this.fieldsOptionCombobox = options;
                }
            })

            // combobox record item
            getSobjectRecordItemListFieldsLable({ SobjectApiName: this.sobjectNameUpdate, recordTypeName: this.recordTypeName }).then(result => {
                console.log('result.getSobjectRecordItemListFieldsLable', result);
                this.sobjectListRecordItemFieldLable = result;
                let options = [];
                if (this.sobjectListRecordItemFieldLable) {
                    if (options != 'Record Id') {
                        for (const key in result) {
                            options.push({ label: result[key], value: result[key] });
                        }
                        this.fieldsRecordItemOptionCombobox = options;
                    }
                }
            })
        }
        else if (result.error) {
            console.log('error: ' + this.error);
        }
    }

    // ================================================== style ================================================== //
    handleShowContentCriteria(event) {
        const name = event.target.name;

        if (name === 'Hide') {
            this.nameShowContentCriteria = 'Show';
            this.showContectCriteria = false;
            this.iconNameCriteria = 'utility:preview';
        } else if (name === 'Show') {
            this.nameShowContentCriteria = 'Hide';
            this.showContectCriteria = true;
            this.iconNameCriteria = 'utility:hide';
        }
    }

    handleShowContentResultCriteria(event) {
        const name = event.target.name;

        if (name === 'Hide') {
            this.nameShowContentResultCriteria = 'Show';
            this.showContentResultCriteriaSection = false;
            this.iconNameResultCriteria = 'utility:preview';
        } else if (name === 'Show') {
            this.nameShowContentResultCriteria = 'Hide';
            this.showContentResultCriteriaSection = true;
            this.iconNameResultCriteria = 'utility:hide';
        }
    }


    // ============== Modal ================

    openModalSearch() {
        this.headercolumnDefault = this.headercolumnDefault;
        console.log('this.headercolumnDefault: ', this.headercolumnDefault);
        this.showModalSearch = true;
    }

    openModalRecordItems() {
        this.headerSelectedItemcolumnDefault = this.headerSelectedItemcolumnDefault;
        console.log('this.headerSelectedItemcolumnDefault: ', this.headerSelectedItemcolumnDefault);
        this.showModalRecordItems = true;
    }

    openModalMassUpdate() {
        this.showModalMassUpdate = true;
    }

    closeModalSearch() {
        this.showModalSearch = false;
    }

    closeModalRecordItems() {
        this.showModalRecordItems = false;
    }

    closeModalMassUpdate() {
        this.showModalMassUpdate = false;

        // field
        this.setVisibleFieldTextUpdateItem = false;
        this.setVisibleFieldNumberUpdateItem = false;
        this.setVisibleFieldStartDateUpdateItem = false;
        this.setVisibleFieldEndDateUpdateItem = false;
        this.setVisibleFieldCheckboxUpdateItem = false;
        this.setVisibleFieldPicklistUpdateItem = false;
        this.setVisibleFieldTextareaUpdateItem = false;
        this.setDefaultField = true;
    }
    // ============== End of Modal ================

    // ================================================== end of style ================================================== //

    refreshTable() {
        this.handleIsLoading(true);
        return refreshApex(this.getSelectedMassRecordUpdateItems());
    }

    doSortingSearchItem(event) {
        this.sortBySearchItem = event.detail.fieldName;
        this.sortDirectionSearchItem = event.detail.sortDirection;
        this.sortDataSearchItem(this.sortBySearchItem, this.sortDirectionSearchItem);

        console.log('this.sortBySearchItem: ', this.sortBySearchItem);
        console.log('this.sortDirectionSearchItem: ', this.sortDirectionSearchItem);
    }

    sortDataSearchItem(fieldName, direction) {
        console.log('In sortDataSearchItem');
        console.log('fieldName.201: ', fieldName);
        console.log('direction.202: ', direction);
        console.log('this.sobjectRecords: ', this.sobjectRecords);

        let parseData = JSON.parse(JSON.stringify(this.sobjectRecords));
        console.log('parseData.247: ', parseData);
        // Return the value stored in the field
        let keyValue = (fieldNameKey) => {
            return fieldNameKey[fieldName];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            console.log(' in isReverse.217: ', isReverse * ((x > y) - (y > x)));
            return isReverse * ((x > y) - (y > x));
        });
        this.sobjectRecords = parseData;
        console.log('this.sobjectRecords.221: ', this.sobjectRecords);
    }

    doSortingRecordItem(event) {
        this.sortByRecordItem = event.detail.fieldName;
        this.sortDirectionRecordItem = event.detail.sortDirection;
        this.sortDataRecordItem(this.sortByRecordItem, this.sortDirectionRecordItem);

        console.log('this.sortByRecordItem: ', this.sortByRecordItem);
        console.log('this.sortDirectionRecordItem: ', this.sortDirectionRecordItem);
    }

    sortDataRecordItem(fieldName, direction) {
        console.log('In sortDataRecordItem');
        console.log('fieldName.242: ', fieldName);
        console.log('direction.243: ', direction);
        console.log('this.sobjectRecordsSelectedItem.244: ', this.sobjectRecordsSelectedItem);

        let parseData = JSON.parse(JSON.stringify(this.sobjectRecordsSelectedItem));
        console.log('parseData.247: ', parseData);
        // Return the value stored in the field
        let keyValue = (fieldNameKey) => {
            return fieldNameKey[fieldName];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            console.log(' in isReverse.260: ', isReverse * ((x > y) - (y > x)));
            return isReverse * ((x > y) - (y > x));
        });
        this.sobjectRecordsSelectedItem = parseData;
        console.log('this.sobjectRecordsSelectedItem.263: ', this.sobjectRecordsSelectedItem);
    }

    handleSearchKeyValue(event) {
        this.searchKeyUpdateRecordItem = event.target.value;
        console.log('searchKeyUpdateRecordItem: ', this.searchKeyUpdateRecordItem);
        console.log('searchKeyUpdateRecordItem.length: ', this.searchKeyUpdateRecordItem.length);

        let keyCodeValue = event.keyCode;
        console.log('==> keyCodeValue: ', keyCodeValue);

        if (keyCodeValue === 13) {
            this.handleIsLoading(true);
            this.getSelectedMassRecordUpdateItems();
        }
    }

    SaveSearchItemListView() {
        console.log('this.headerColumnSelected.192: ', this.headerColumnSelected);
        console.log('this.recordId: ', this.recordId);
        let headerSearchItemColumnSelectedList = [];

        this.handleIsLoading(true);

        for (let i = 0; i < this.headerColumnSelected.length; i++) {
            console.log('isinya apa: ', this.headerColumnSelected[i].fieldName);
            headerSearchItemColumnSelectedList.push(this.headerColumnSelected[i].fieldName);
        }

        console.log('headerSearchItemColumnSelectedList: ', headerSearchItemColumnSelectedList);

        SaveSearchItemListView({ searchItemColumnView: headerSearchItemColumnSelectedList, SobjectrecordIds: this.recordId }).then(listViewDefaultResult => {
            console.log('listViewDefaultResult: ', listViewDefaultResult);
            eval("$A.get('e.force:refreshView').fire();");
            this.closeModalSearch();
            this.showSuccessToast();
            this.handleIsLoading(false);

        }).catch(error => {
            console.log('error: ', error);

            this.showErrorToast();
            this.handleIsLoading(false);
        }).finally(() => {
            this.handleIsLoading(false);
        })
    }

    SaveRecordItemListView() {
        console.log('this.headerRecordItemColumnSelected: ', this.headerRecordItemColumnSelected);
        console.log('this.recordId: ', this.recordId);
        let headerRecordItemColumnSelectedList = [];

        this.handleIsLoading(true);

        for (let i = 0; i < this.headerRecordItemColumnSelected.length; i++) {
            console.log('fieldNameHeaderSelectedItem: ', this.headerRecordItemColumnSelected[i].fieldName);
            headerRecordItemColumnSelectedList.push(this.headerRecordItemColumnSelected[i].fieldName);

            console.log('headerRecordItemColumnSelectedList: ', headerRecordItemColumnSelectedList);
        }

        SaveRecordItemListView({ selectedItemColumnView: headerRecordItemColumnSelectedList, SobjectrecordIds: this.recordId }).then(listViewDefaultResult => {
            console.log('listViewDefaultResult: ', listViewDefaultResult);
            eval("$A.get('e.force:refreshView').fire();");
            this.closeModalRecordItems();
            this.showSuccessToast();
            this.handleIsLoading(false);

        }).catch(error => {
            console.log('error: ', error);

            this.showErrorToast();
            this.handleIsLoading(false);
        }).finally(() => {
            this.handleIsLoading(false);
        })
    }

    // ========== Save Inline ==========
    /*handleSave(event) {
        console.log('In handlesave');

        this.saveDraftValues = event.detail.draftValues;
        console.log('saveDraftValues: ', this.saveDraftValues);

        const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });

        // Updateing the records using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(result => {
            console.log('result: ', result);
            this.saveDraftValues = [];
            this.getSelectedMassRecordUpdateItems();
            this.showSuccessToast();

        }).catch(error => {
            this.showErrorToast();
            console.log('Error: ', error);
        }).finally(() => {
            this.saveDraftValues = [];
        });
    }*/

    //connect Callback
    connectedCallback() {
        this.initData();
    }

    // ============== list view ================
    handleSelectedField(event) {
        this.selectedFields = event.detail.value;
        console.log('this.selectedFields.401: ', this.selectedFields);
        this.getSelectedFieldColumns();
    }

    handleRecordItemSelectedField(event) {
        this.selectedRecordItemFields = event.detail.value;
        console.log('this.selectedRecordItemFields.407: ', this.selectedRecordItemFields);
        this.getSelectedRecordItemFieldColumns();
    }

    // ================ filter search list ===================
    initData() {
        let listFilterGetSobjectRecord = [];
        this.createRow(listFilterGetSobjectRecord);
        this.listFilterGetSobjectRecord = listFilterGetSobjectRecord;
    }

    createRow(listFilterGetSobjectRecord) {
        console.log('listFilterGetSobjectRecord: ', listFilterGetSobjectRecord);
        console.log('listFilterGetSobjectRecord.length: ', listFilterGetSobjectRecord.length);

        let FilterGetSobjectRecordObj = {};
        if (listFilterGetSobjectRecord.length > 0) {
            FilterGetSobjectRecordObj.index = listFilterGetSobjectRecord[listFilterGetSobjectRecord.length - 1].index + 1;
            console.log('FilterGetSobjectRecordObj.index: ', FilterGetSobjectRecordObj.index);
            if (FilterGetSobjectRecordObj.index > 1) {
                this.disableRowIndex = false;
            }

        } else {
            FilterGetSobjectRecordObj.index = 1;
        }
        //FilterGetSobjectRecordObj.filterUpdateField = null;
        //FilterGetSobjectRecordObj.textField = null;
        FilterGetSobjectRecordObj.textFieldVisible = false;
        //FilterGetSobjectRecordObj.numberField = null;
        FilterGetSobjectRecordObj.numberFieldVisible = false;
        //FilterGetSobjectRecordObj.picklistField = null;
        FilterGetSobjectRecordObj.picklistFieldVisible = false;
        //FilterGetSobjectRecordObj.startDateField = null;
        //FilterGetSobjectRecordObj.endDateField = null;
        FilterGetSobjectRecordObj.dateFieldVisible = false;
        //FilterGetSobjectRecordObj.dateTimeField = null;
        FilterGetSobjectRecordObj.dateTimeFieldVisible = false;
        //FilterGetSobjectRecordObj.checkboxField = null;
        FilterGetSobjectRecordObj.checkboxFieldVisible = false;

        // new field
        FilterGetSobjectRecordObj.defaultFieldVisible = true;

        FilterGetSobjectRecordObj.value = {};

        listFilterGetSobjectRecord.push(FilterGetSobjectRecordObj);
        console.log('listFilterGetSobjectRecord: ', listFilterGetSobjectRecord);
    }

    addNewRow() {
        console.log('in addNewRow');
        console.log('in this.listFilterGetSobjectRecord: ', this.listFilterGetSobjectRecord);
        this.createRow(this.listFilterGetSobjectRecord);
    }

    removeRow(event) {
        let toBeDeletedRowIndex = event.target.name;
        console.log('remove row name: ', toBeDeletedRowIndex);

        let listFilterGetSobjectRecord = [];
        for (let i = 0; i < this.listFilterGetSobjectRecord.length; i++) {
            let tempRecord = Object.assign({}, this.listFilterGetSobjectRecord[i]); //cloning object
            console.log('tempRecord: ', tempRecord);
            if (tempRecord.index !== toBeDeletedRowIndex) {
                listFilterGetSobjectRecord.push(tempRecord);
            }
        }

        for (let i = 0; i < listFilterGetSobjectRecord.length; i++) {
            listFilterGetSobjectRecord[i].index = i + 1;
        }

        this.listFilterGetSobjectRecord = listFilterGetSobjectRecord;
        console.log('listFilterGetSobjectRecord: ', listFilterGetSobjectRecord);

        if (this.listFilterGetSobjectRecord.length <= 1) {
            this.disableRowIndex = true;
        }
    }

    removeAllRows() {
        let listFilterGetSobjectRecord = [];
        this.createRow(listFilterGetSobjectRecord);
        this.listFilterGetSobjectRecord = listFilterGetSobjectRecord;
        console.log('listRemoveAllrows: ', listFilterGetSobjectRecord);

        this.setVisibleFieldOptionName = false;
        this.setVisibleFieldOptionNumber = false;
        this.setVisibleFieldOptionStartDate = false;
        this.setVisibleFieldOptionEndDate = false;
        this.setVisibleFieldOptionCheckbox = false;
        this.setVisibleFieldOptionPicklist = false;
        this.disableRowIndex = true;
        this.activeSearchButton = true;
    }


    handleInputChange(event) {
        let index = event.target.dataset.id;
        let fieldNames = event.target.name;
        let value = event.target.value;

        // handle active search button
        if (fieldNames != 'filterUpdateField') {
            this.activeSearchButton = false;
        }

        // looping untuk get record
        for (let i = 0; i < this.listFilterGetSobjectRecord.length; i++) {
            if (this.listFilterGetSobjectRecord[i].index === parseInt(index)) {
                this.listFilterGetSobjectRecord[i][fieldNames] = value;
                console.log('this.listFilterGetSobjectRecord[i][fieldNames]: ', this.listFilterGetSobjectRecord[i][fieldNames]);
                console.log('this.sobjectNameUpdate: ', this.sobjectNameUpdate);

                getSobjectListFieldsName({ fieldLable: value, SobjectApiName: this.sobjectNameUpdate }).then(fieldNameresult => {
                    this.sobjectRecordItemListFieldName = fieldNameresult;

                    console.log('this.sobjectRecordItemListFieldName: ', this.sobjectRecordItemListFieldName);
                    console.log('this.sobjectNameUpdate: ', this.sobjectNameUpdate);

                    getSobjectListFieldsType({ fieldName: this.sobjectRecordItemListFieldName, SobjectApiName: this.sobjectNameUpdate }).then(fieldTyperesult => {
                        console.log('fieldTyperesult: ', fieldTyperesult);

                        this.sobjectListFieldType = fieldTyperesult;
                        console.log('this.sobjectListFieldType: ', this.sobjectListFieldType);

                        // untuk menentukan filter yang ditentukan
                        switch (this.sobjectListFieldType) {
                            case 'STRING':
                                console.log('in STRING');
                                this.listFilterGetSobjectRecord[i].defaultFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].textFieldVisible = true;
                                this.listFilterGetSobjectRecord[i].numberFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].picklistFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].dateFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].dateTimeFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].checkboxFieldVisible = false;
                                break;

                            case 'NUMBER':
                                console.log('in NUMBER');
                                this.listFilterGetSobjectRecord[i].defaultFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].textFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].numberFieldVisible = true;
                                // this.listFilterGetSobjectRecord[i].numberField = value;
                                this.listFilterGetSobjectRecord[i].picklistFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].dateFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].dateTimeFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].checkboxFieldVisible = false;
                                break;

                            case 'DATE':
                                console.log('in DATE');
                                this.listFilterGetSobjectRecord[i].defaultFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].textFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].numberFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].picklistFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].dateFieldVisible = true;
                                this.listFilterGetSobjectRecord[i].dateTimeFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].checkboxFieldVisible = false;
                                break;

                            case 'DATETIME':
                                console.log('in DATETIME');
                                this.listFilterGetSobjectRecord[i].defaultFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].textFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].numberFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].picklistFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].dateFieldVisible = true;
                                this.listFilterGetSobjectRecord[i].dateTimeFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].checkboxFieldVisible = false;
                                break;

                            case 'BOOLEAN':
                                console.log('in BOOLEAN');
                                this.listFilterGetSobjectRecord[i].defaultFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].textFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].numberFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].picklistFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].dateFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].dateTimeFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].checkboxFieldVisible = true;
                                break;

                            case 'PICKLIST':
                                console.log('in PICKLIST');
                                this.listFilterGetSobjectRecord[i].defaultFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].textFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].numberFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].picklistFieldVisible = true;
                                this.listFilterGetSobjectRecord[i].dateFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].dateTimeFieldVisible = false;
                                this.listFilterGetSobjectRecord[i].checkboxFieldVisible = false;

                                //this.getSobjectPicklistValues();
                                getSobjectPicklistValues({ sobjectApiName: this.sobjectNameUpdate, fieldName: this.sobjectRecordItemListFieldName }).then(resultPicklistValue => {
                                    try {
                                        var resultData = JSON.parse(resultPicklistValue);
                                        console.log('resultData: ', resultData);

                                        this.selectOptionValue = resultData;
                                        console.log('this.selectOptionValue: ', this.selectOptionValue);

                                        this.listFilterGetSobjectRecord[i].valueChoosen = this.selectOptionValue;
                                    } catch (error) {
                                        console.log('error: ', error);
                                    }
                                })
                                break;
                        }

                    })
                })
            }
        }
        console.log('this.listFilterGetSobjectRecord: ', this.listFilterGetSobjectRecord);
    }

    handleInputChangeCheckbox(event) {
        let index = event.target.dataset.id;
        let fieldNames = event.target.name;
        let values = event.detail.checked;

        console.log('index: ', index);
        console.log('fieldNames: ', fieldNames);
        console.log('values: ', values);

        getSobjectListFieldsName({ fieldLable: values, SobjectApiName: this.sobjectNameUpdate }).then(fieldNameresult => {
            this.sobjectRecordItemListFieldName = fieldNameresult;
            console.log('sobjectRecordItemListFieldName: ', this.sobjectRecordItemListFieldName);
        })

        for (let i = 0; i < this.listFilterGetSobjectRecord.length; i++) {
            if (this.listFilterGetSobjectRecord[i].index === parseInt(index)) {
                this.listFilterGetSobjectRecord[i][fieldNames] = values;
            }
        }
        console.log('handleInputChangeCheckbox.listFilterGetSobjectRecord: ', this.listFilterGetSobjectRecord);
    }

    handleInputUpdateItem(event) {
        let fieldName = event.target.name;
        let value = event.target.value;
        let valueS = event.detail.value;


        console.log('fieldName: ', fieldName);
        console.log('value: ', value);
        console.log('valueS: ', valueS);

        this.valuesSelectRecordItems = event.target.value;

        console.log('this.valuesSelectRecordItems: ', this.valuesSelectRecordItems);

        if (fieldName == 'filterUpdateItemField') {
            this.sobjectRecordItemListFieldLable = event.detail.value;
            console.log('this.fieldName: ', this.fieldName);
            getSobjectListFieldsName({ fieldLable: value, SobjectApiName: this.sobjectNameUpdate }).then(fieldNameresult => {
                this.sobjectRecordItemListFieldName = fieldNameresult;
                console.log('sobjectRecordItemListFieldName.431: ', this.sobjectRecordItemListFieldName);

                getSobjectListFieldsType({ fieldName: this.sobjectRecordItemListFieldName, SobjectApiName: this.sobjectNameUpdate }).then(fieldTyperesult => {
                    console.log('fieldTyperesult: ', fieldTyperesult);
                    this.sobjectListFieldType = fieldTyperesult;
                    console.log('this.sobjectListFieldType: ', this.sobjectListFieldType);

                    switch (this.sobjectListFieldType) {
                        case 'STRING':
                            console.log('in STRING');
                            this.setVisibleFieldTextUpdateItem = true;
                            this.setVisibleFieldNumberUpdateItem = false;
                            this.setVisibleFieldStartDateUpdateItem = false;
                            this.setVisibleFieldEndDateUpdateItem = false;
                            this.setVisibleFieldCheckboxUpdateItem = false;
                            this.setVisibleFieldPicklistUpdateItem = false;
                            this.setVisibleFieldTextareaUpdateItem = false;
                            this.setDefaultField = false;
                            break;

                        case 'NUMBER':
                            console.log('in NUMBER');
                            this.setVisibleFieldTextUpdateItem = false;
                            this.setVisibleFieldNumberUpdateItem = true;
                            this.setVisibleFieldStartDateUpdateItem = false;
                            this.setVisibleFieldEndDateUpdateItem = false;
                            this.setVisibleFieldCheckboxUpdateItem = false;
                            this.setVisibleFieldPicklistUpdateItem = false;
                            this.setVisibleFieldTextareaUpdateItem = false;
                            this.setDefaultField = false;
                            break;

                        case 'DATE':
                            console.log('in DATE');
                            this.setVisibleFieldTextUpdateItem = false;
                            this.setVisibleFieldNumberUpdateItem = false;
                            this.setVisibleFieldStartDateUpdateItem = true;
                            this.setVisibleFieldEndDateUpdateItem = true;
                            this.setVisibleFieldCheckboxUpdateItem = false;
                            this.setVisibleFieldPicklistUpdateItem = false;
                            this.setVisibleFieldTextareaUpdateItem = false;
                            this.setDefaultField = false;
                            break;

                        case 'DATETIME':
                            console.log('in DATETIME');
                            this.setVisibleFieldTextUpdateItem = false;
                            this.setVisibleFieldNumberUpdateItem = false;
                            this.setVisibleFieldStartDateUpdateItem = true;
                            this.setVisibleFieldEndDateUpdateItem = true;
                            this.setVisibleFieldCheckboxUpdateItem = false;
                            this.setVisibleFieldPicklistUpdateItem = false;
                            this.setVisibleFieldTextareaUpdateItem = false;
                            this.setDefaultField = false;
                            break;

                        case 'BOOLEAN':
                            console.log('in BOOLEAN');
                            this.setVisibleFieldTextUpdateItem = false;
                            this.setVisibleFieldNumberUpdateItem = false;
                            this.setVisibleFieldStartDateUpdateItem = false;
                            this.setVisibleFieldEndDateUpdateItem = false;
                            this.setVisibleFieldCheckboxUpdateItem = true;
                            this.setVisibleFieldPicklistUpdateItem = false;
                            this.setVisibleFieldTextareaUpdateItem = false;
                            this.setDefaultField = false;
                            break;

                        case 'PICKLIST':
                            console.log('in PICKLIST');
                            this.setVisibleFieldTextUpdateItem = false;
                            this.setVisibleFieldNumberUpdateItem = false;
                            this.setVisibleFieldStartDateUpdateItem = false;
                            this.setVisibleFieldEndDateUpdateItem = false;
                            this.setVisibleFieldCheckboxUpdateItem = false;
                            this.setVisibleFieldPicklistUpdateItem = true;
                            this.setVisibleFieldTextareaUpdateItem = false;
                            this.setDefaultField = false;
                            this.getSobjectPicklistValues();
                            break;

                        case 'TEXTAREA':
                            console.log('in TEXTAREA');
                            this.setVisibleFieldTextUpdateItem = false;
                            this.setVisibleFieldNumberUpdateItem = false;
                            this.setVisibleFieldStartDateUpdateItem = false;
                            this.setVisibleFieldEndDateUpdateItem = false;
                            this.setVisibleFieldCheckboxUpdateItem = false;
                            this.setVisibleFieldPicklistUpdateItem = false;
                            this.setVisibleFieldTextareaUpdateItem = true;
                            this.setDefaultField = false;
                            break;
                    }
                })
            })
        } else {
            this.valueFieldUpdateName = value;
            console.log('this.valueFieldUpdateName.644: ', this.valueFieldUpdateName);
        }
    }

    // =============== get sobject record data ==================

    //=========== get picklist value list ===========

    //coment dulu untuk picklist
    getSobjectPicklistValues() {
        getSobjectPicklistValues({ sobjectApiName: this.sobjectNameUpdate, fieldName: this.sobjectRecordItemListFieldName }).then(resultPicklistValue => {
            try {
                var resultData = JSON.parse(resultPicklistValue);
                console.log('resultData: ', resultData);

                this.selectOptionValue = resultData;
                console.log('this.selectOptionValue: ', this.selectOptionValue);

            } catch (error) {
                console.log('error: ', error);
            }
        })
    }


    handleGetPicklistValue(event) {
        console.log('In handleGetPicklistValue');

        getSobjectPicklistValues({ sobjectApiName: this.sobjectNameUpdate, fieldName: this.sobjectRecordItemListFieldName }).then(resultPicklistValue => {

            var resultData = JSON.parse(resultPicklistValue);
            console.log('resultData: ', resultData);

            this.valuesSelectRecordItems = event.detail.value;
            console.log('valuePicklistField: ', this.valuePicklistField);
        })
    }
    //=========== end of get picklist value list ===========


    // operator filter condition
    getOperatorFilterCondition(event) {
        this.operatorFilterCondition = event.detail.value;
        console.log('in getOperatorFilterCondition', this.operatorFilterCondition);
    }

    getSobjectRecordListPagination() {

        var filterRecordValues = JSON.stringify(this.listFilterGetSobjectRecord);
        console.log('filterRecordValues', filterRecordValues);
        getSobjectRecordList({ SobjectApiName: this.sobjectNameUpdate, FilterRecord: filterRecordValues, pageSize: this.searchRecordItemsPageSize, pageNumber: this.searchRecordItemsPageNumber, operatorCondition: this.operatorFilterCondition, recordType: this.recordTypeName }).then(result => {
            console.log('Result: ', result);
            try {
                var resultData = JSON.parse(result);

                //handle lookup references user
                var resultDatasobjectrecordList = resultData.sobjectrecordList;
                console.log('resultData: ' + resultDatasobjectrecordList);
                resultDatasobjectrecordList.forEach(res => {
                    console.log('res.1357: ', res);
                    for (let field in res) {
                        if (typeof res[field] === 'string' && (res[field].substr(0, 2) == '00' || res[field].substr(0, 1) == 'a' || res[field].substr(0, 1) == '0')) {
                            res[field] = '/' + res[field];

                        } else {
                            res[field] = res[field];
                            if (typeof res[field] === 'object') {
                                //console.log('attr.Keys : ', Object.keys(res[field]));
                                //console.log('attr.Values : ', Object.values(res[field])[1]);
                                res[field] = Object.values(res[field])[1];
                            }

                        }
                    }
                })

                console.log('resultData: ', resultData);

                this.sobjectRecords = resultDatasobjectrecordList; //resultData.sobjectrecordList;
                console.log('sobjectRecords: ', this.sobjectRecords);

                this.searchRecordItemsPageNumber = resultData.pageNumber;
                this.searchRecordItemsTotalRecords = resultData.totalRecords;
                this.searchRecordItemsRecordStart = resultData.recordStart;
                this.searchRecordItemsRecordEnd = resultData.recordEnd;
                this.searchRecordItemsTotalPages = Math.ceil(resultData.totalRecords / this.searchRecordItemsPageSize);

                this.searchRecordItemsIsNext = (this.searchRecordItemsPageNumber >= this.searchRecordItemsTotalPages) ? true : false;
                this.searchRecordItemsIsPrev = (this.searchRecordItemsPageNumber <= 1) ? true : false;

            } catch (error) {
                console.log('error: ', error);
            }
        })
    }

    // ========== next & prev pagination ========== 
    // button handle search pagination
    serchRecordItemHandleNext() {
        if (this.searchRecordItemsPageNumber != this.searchRecordItemsTotalPages) {
            this.searchRecordItemsPageNumber = this.searchRecordItemsPageNumber + 1;
        }
        this.getSobjectRecordListPagination();
    }

    serchRecordItemHandlePrev() {
        if (this.searchRecordItemsPageNumber != 1) {
            this.searchRecordItemsPageNumber = this.searchRecordItemsPageNumber - 1;
        }
        this.getSobjectRecordListPagination();
    }

    // button handle selected record update item pagination
    selectedRecordUpdateItemHandleNext() {
        if (this.selectedRecordItemsPageNumber != this.selectedRecordItemsTotalPages) {
            this.selectedRecordItemsPageNumber = this.selectedRecordItemsPageNumber + 1;
        }
        this.getSelectedMassRecordUpdateItems()
    }

    selectedRecordUpdateItemHandlePrev() {
        if (this.selectedRecordItemsPageNumber != 1) {
            this.selectedRecordItemsPageNumber = this.selectedRecordItemsPageNumber - 1;
        }
        this.getSelectedMassRecordUpdateItems();
    }
    // ========== end of next & prev pagination ========== 


    putSelectedRowtoMassRecordUpdateItems() {
        console.log('in putSelectedRowtoMassRecordUpdateItems');
        console.log('==>sobjectAllRecords:', this.sobjectAllRecords);
        console.log('==>checkAllSearchitem: ', this.checkAllSearchitem);
        console.log('==>selectedSearchRecId: ', this.selectedSearchRecId);
        console.log('==>rowSearchSelectedIds: ', this.rowSearchSelectedIds);

        let recordItemIdList = [];
        let SearchRecordItem = [];
        let SearchRecordItemIds = '';

        if (this.checkAllSearchitem == true) {
            SearchRecordItem = this.sobjectAllRecords;
        } else if (this.checkAllSearchitem == false) {
            SearchRecordItemIds = this.rowSearchSelectedIds;
        }
        console.log('==>SearchRecordItem: ', SearchRecordItem);
        console.log('==>SearchRecordItemIds: ', SearchRecordItemIds);

        // for selected all
        for (const sobjectNameUpdateFieldKey in SearchRecordItem) {
            console.log('this.sobjectNameUpdate[sobjectNameUpdateFieldKey][id]: ', SearchRecordItem[sobjectNameUpdateFieldKey]);
            recordItemIdList.push(SearchRecordItem[sobjectNameUpdateFieldKey]['Id']);
        }
        console.log('recordItemIdList: ', recordItemIdList);

        // update -> selectedRecordRowId
        putSelectedRowtoMassRecordUpdateItems({ selectedRecordRowId: SearchRecordItemIds, massUpdateRecordId: this.recordId, SobjectApiName: this.sobjectNameUpdate, pageSize: this.selectedRecordItemsPageSize, pageNumber: this.selectedRecordItemsPageNumber, selectedAllRecordItem: this.checkAllSearchitem, recordItemIdList: recordItemIdList }).then(selectedRecordItems => {

            if (selectedRecordItems) {
                this.selectedItemRecords = selectedRecordItems;
                console.log('this.selectedItemRecords: ', this.selectedItemRecords);

                var resultData = JSON.parse(selectedRecordItems);
                console.log('resultData: ', resultData);

                this.sobjectRecordsSelectedItem = resultData.massRecordUpdateItems;

                this.selectedRecordItemsPageNumber = resultData.pageNumber;
                this.selectedRecordItemsTotalRecords = resultData.totalRecords;
                this.selectedRecordItemsRecordStart = resultData.recordStart;
                this.selectedRecordItemsRecordEnd = resultData.recordEnd;
                this.selectedRecordItemsTotalPages = Math.ceil(resultData.totalRecords / this.selectedRecordItemsPageSize);
                // this.selectedRecordItemsIsNext = (this.selectedRecordItemsPageNumber == this.selectedRecordItemsTotalPages || this.selectedRecordItemsTotalPages == 0);
                this.selectedRecordItemsIsNext = (this.selectedRecordItemsPageNumber >= this.selectedRecordItemsTotalPages) ? true : false;
                // this.selectedRecordItemsIsPrev = (this.selectedRecordItemsPageNumber == 1 || this.selectedRecordItemsTotalRecords < this.selectedRecordItemsPageSize);
                this.selectedRecordItemsIsPrev = (this.selectedRecordItemsPageNumber <= 1) ? true : false;

                this.getSobjectHeaderColumn();
                this.getSobjectItemsHeaderColumn();
                this.getSelectedMassRecordUpdateItems();

                const event = new ShowToastEvent({
                    message: 'Your records has saved in container.',
                    variant: 'success'
                });
                this.dispatchEvent(event);
            } else {
                this.showErrorToast();
                console.log(' Error Message: ', result.error);
            }
        })
    }

    updateSobjectRecordItems() {
        console.log('In updateSobjectRecordItems');

        console.log('SobjectrecordIds: ', this.selectedRecordItemsrow);
        console.log('SobjectApiName: ', this.sobjectApiName);
        console.log('massUpdateRecordId: ', this.recordId);
        console.log('fieldDataType: ', this.sobjectListFieldType);
        console.log('sobjectRecordItemListFieldName: ', this.sobjectRecordItemListFieldName);
        console.log('valuetoUpdate: ', this.valueFieldUpdateName);
        console.log('checkAllRecorditem: ', this.checkAllRecorditem);
        console.log('batchSize: ', this.batchSize);

        this.closeModalMassUpdate();
        this.handleIsLoading(true);

        if (this.sobjectRecordItemListFieldName == 'status__c') {
            this.batchSizeValue = '10';
            console.log('this.batchSizeValue = field status :: ', this.batchSizeValue);
        } else {
            this.batchSizeValue = this.batchSize;
            console.log('this.batchSizeValue :: ', this.batchSizeValue);
        }

        updateSobjectRecordItems({ SobjectrecordIds: this.selectedRecordItemsrow, SobjectApiName: this.sobjectApiName, massUpdateRecordId: this.recordId, fieldDataType: this.sobjectListFieldType, fieldApiName: this.sobjectRecordItemListFieldName, valuetoUpdate: this.valueFieldUpdateName, selectedAllRecordItem: this.checkAllRecorditem, fieldLabel: this.sobjectRecordItemListFieldLable, batchSize: this.batchSizeValue })
            .then(updateItemsResult => {
                try {
                    console.log('updateItemsResult: ', updateItemsResult);
                    this.getSelectedMassRecordUpdateItems();

                    const event = new ShowToastEvent({
                        message: 'Data has been processed, please refresh table periodically after you got email notification.',
                        variant: 'success'
                    });
                    this.dispatchEvent(event);

                } catch (error) {
                    console.log('==> Error Update: ', error);
                    this.showErrorToast();
                    this.handleIsLoading(false);
                }
                return refreshApex(this.getSelectedMassRecordUpdateItems());
            })
    }

    // columns datatable for search item
    getSelectedFieldColumns() {
        console.log('in getSelectedFieldColumns: ');
        if (this.selectedFields.length > 0) {
            console.log('this.selectedFields.886: ', this.selectedFields);
            let headercolumnSelectedList = [];
            let headercolumnSelectedObj = {};
            console.log('this.headerSobjectColumns.628: ', this.headerSobjectColumns);

            for (const selectedFieldsKey in this.selectedFields) {
                for (const headerColumnFieldKey in this.headerSobjectColumns) {
                    if (this.selectedFields[selectedFieldsKey] == this.headerSobjectColumns[headerColumnFieldKey]['fieldName']) {
                        headercolumnSelectedObj = this.headerSobjectColumns[headerColumnFieldKey];
                        console.log('headercolumnSelectedObj: ', headercolumnSelectedObj);
                        console.log('this.selectedFields.891', this.selectedFields[selectedFieldsKey], ' == ', this.headerSobjectColumns[headerColumnFieldKey]['fieldName']);

                    }
                }
                headercolumnSelectedList.push(headercolumnSelectedObj);
            }
            this.headerColumnSelected = headercolumnSelectedList;
            console.log('this.headerColumnSelectedlength: ', this.headerColumnSelected.length);
            console.log('this.headerColumnSelected: ', this.headerColumnSelected);

        }
        else {
            //default header column search items
            console.log('this.sobjectNameUpdate.642: ', this.sobjectNameUpdate);
            getSobjectHeaderColumn({ SobjectApiName: this.sobjectNameUpdate }).then(result => {
                try {
                    let headercolumnSelectedList = [];
                    let headercolumnDefaultvalues = [];
                    let objectfield = [];
                    var headercolumn = JSON.parse(result);
                    this.headerSobjectColumns = headercolumn;
                    console.log('this.headerSobjectColumns.558', this.headerSobjectColumns);

                    // list view search item
                    for (const headercolumnKey in headercolumn) {
                        if (headercolumn[headercolumnKey]['fieldName'] != 'Name' && headercolumn[headercolumnKey]['fieldName'] != 'Name2__c') {
                            objectfield.push({
                                label: headercolumn[headercolumnKey]['label'],
                                value: headercolumn[headercolumnKey]['fieldName']
                            });
                        }
                    }

                    this.searchItemFields = objectfield;
                    console.log('searchItemFields: ', this.searchItemFields);

                    console.log('in else.641');
                    if (this.headercolumnDefault != null) {
                        headercolumnDefaultvalues = this.headercolumnDefault.split(';');
                        this.headercolumnDefaultvalues = headercolumnDefaultvalues;
                    }
                    console.log('headercolumnDefaultvalues: ', headercolumnDefaultvalues);

                    // datatable column search item
                    for (const headerColumnFieldKey in this.headerSobjectColumns) {
                        if (headercolumnDefaultvalues.includes(this.headerSobjectColumns[headerColumnFieldKey]['fieldName'])) {
                            console.log('this.headerSobjectColumns[headerColumnFieldKey]: ', this.headerSobjectColumns[headerColumnFieldKey]);
                            headercolumnSelectedList.push(this.headerSobjectColumns[headerColumnFieldKey]);
                        }
                    }
                    this.headerColumnSelected = headercolumnSelectedList;
                    console.log('this.headerColumnSelectedlength: ', this.headerColumnSelected.length);
                    console.log('this.headerColumnSelected: ', this.headerColumnSelected);

                } catch (error) {
                    console.log('error on search item column');
                    console.log(error);
                }
            })
        }
    }

    // columns datatable for selected record item
    getSelectedRecordItemFieldColumns() {
        console.log('in getSelectedRecordItemFieldColumns: ');
        console.log('In 1031');
        console.log('this.selectedRecordItemFields.length: ', this.selectedRecordItemFields.length);
        if (this.selectedRecordItemFields.length > 0) {
            let headerRecordItemColumnSelectedList = [];
            let headerRecordItemColumnSelectedObj = {};
            for (const selectedRecordItemFieldsKey in this.selectedRecordItemFields) {
                for (const headerColumnFieldKey in this.headerSobjectItemColumns) {
                    if (selectedRecordItemFieldsKey != 'Id' && headerColumnFieldKey != 'Id') {
                        if (this.selectedRecordItemFields[selectedRecordItemFieldsKey] == this.headerSobjectItemColumns[headerColumnFieldKey]['fieldName']) {
                            console.log('Result.968: ', this.selectedRecordItemFields[selectedRecordItemFieldsKey], ' == ', this.headerSobjectItemColumns[headerColumnFieldKey]['fieldName']);
                            headerRecordItemColumnSelectedObj = this.headerSobjectItemColumns[headerColumnFieldKey];
                        }
                    }
                }
                headerRecordItemColumnSelectedList.push(headerRecordItemColumnSelectedObj);
            }

            this.headerRecordItemColumnSelected = headerRecordItemColumnSelectedList;
            console.log('this.headerRecordItemColumnSelectedlength: ', this.headerRecordItemColumnSelected.length);
            console.log('this.headerRecordItemColumnSelected: ', this.headerRecordItemColumnSelected);

        }
        else {
            console.log(' in log 704');
            getSobjectItemsHeaderColumn({ SobjectApiName: this.sobjectNameUpdate }).then(result => {
                try {
                    // console.log('result: ', result);
                    console.log('this.headerSelectedItemcolumnDefault.709: ', this.headerSelectedItemcolumnDefault);

                    let headerRecordItemColumnSelectedList = [];
                    let headercolumnDefaultvalues = [];
                    let objectfield = [];
                    var headercolumn = JSON.parse(result);
                    this.headerSobjectItemColumns = headercolumn;
                    console.log('this.headerSobjectItemColumns.714:  ', this.headerSobjectItemColumns);

                    // list view selected item
                    for (const headercolumnKey in headercolumn) {
                        if (headercolumn[headercolumnKey]['fieldName'] != 'Name' && headercolumn[headercolumnKey]['fieldName'] != 'Name2__c') {
                            objectfield.push({
                                label: headercolumn[headercolumnKey]['label'],
                                value: headercolumn[headercolumnKey]['fieldName']
                            });
                        }
                    }

                    this.recordItemFields = objectfield;
                    console.log('recordItemFields: ', this.recordItemFields);

                    if (this.headerSelectedItemcolumnDefault != null) {
                        headercolumnDefaultvalues = this.headerSelectedItemcolumnDefault.split(';');
                        this.headerColumnRecordItemDefaultValues = headercolumnDefaultvalues;
                        console.log('this.headerColumnRecordItemDefaultValues: ', this.headerColumnRecordItemDefaultValues);
                    }

                    // datatable column selected item
                    for (const headerColumnFieldKey in this.headerSobjectItemColumns) {
                        if (headercolumnDefaultvalues.includes(this.headerSobjectItemColumns[headerColumnFieldKey]['fieldName'])) {
                            headerRecordItemColumnSelectedList.push(
                                this.headerSobjectItemColumns[headerColumnFieldKey]
                            );
                        }
                    }
                    this.headerRecordItemColumnSelected = headerRecordItemColumnSelectedList;
                    console.log('headerRecordItemColumnSelected: ', this.headerRecordItemColumnSelected);
                } catch (error) {
                    console.log('error on selected item column');
                    console.log(error);
                }

            })
        }
    }

    // ==================== get sobject column header ============
    getSobjectHeaderColumn() {

        console.log('in getSobjectHeaderColumn');
        getSobjectHeaderColumn({ SobjectApiName: this.sobjectNameUpdate }).then(result => {
            try {
                // console.log('result-searchItemHeaderColumn: ', result);
                // console.log('result-searchItemParse: ', JSON.parse(result));

                let objectfield = [];
                var headercolumn = JSON.parse(result);

                for (const headercolumnKey in headercolumn) {
                    if (headercolumn[headercolumnKey]['fieldName'] != 'Name' && headercolumn[headercolumnKey]['fieldName'] != 'Name2__c') {
                        objectfield.push({
                            label: headercolumn[headercolumnKey]['label'],
                            value: headercolumn[headercolumnKey]['fieldName']
                        });
                    }
                }

                this.searchItemFields = objectfield;
                console.log('searchItemFields: ', this.searchItemFields);

            } catch (error) {
                console.log('Error on getSobjectHeaderColumn: ' + error);
            }
        })
    }

    getSobjectItemsHeaderColumn() {

        console.log('in getSobjectItemsHeaderColumn');

        getSobjectItemsHeaderColumn({ SobjectApiName: this.sobjectNameUpdate }).then(result => {
            try {
                // console.log('result-selectedItemHeaderColumn: ', result);
                // console.log('result-selectedItemParse:', JSON.parse(result));

                let objectfield = [];
                var headercolumn = JSON.parse(result);

                for (const headercolumnKey in headercolumn) {
                    if (headercolumn[headercolumnKey]['fieldName'] != 'Name' && headercolumn[headercolumnKey]['fieldName'] != 'Name2__c') {
                        objectfield.push({
                            label: headercolumn[headercolumnKey]['label'],
                            value: headercolumn[headercolumnKey]['fieldName']
                        })
                    }
                }

                this.recordItemFields = objectfield;
                console.log('recordItemFields: ', this.recordItemFields);

            } catch (error) {
                console.log('Error on getSobjectItemsHeaderColumn: ' + error);
            }
        })

    }

    getSobjectRecordList() {

        var filterRecordValues = JSON.stringify(this.listFilterGetSobjectRecord);
        this.handleIsLoading(true);
        //let sobjectrecordList = [];

        getSobjectRecordList({ SobjectApiName: this.sobjectNameUpdate, FilterRecord: filterRecordValues, pageSize: this.searchRecordItemsPageSize, pageNumber: this.searchRecordItemsPageNumber, operatorCondition: this.operatorFilterCondition, fieldType: this.sobjectListFieldType, recordType: this.recordTypeName }).then(result => {
            console.log('getSobjectRecordList.result: ', result);
            try {
                var resultData = JSON.parse(result);
                console.log('result-SearchItem: ', resultData);

                //handle lookup references user
                var resultDatasobjectrecordList = resultData.sobjectrecordList;
                console.log('resultDatasobjectrecordList: ', resultDatasobjectrecordList);

                resultDatasobjectrecordList.forEach(res => {
                    for (let field in res) {
                        if (typeof res[field] === 'string' && (res[field].substr(0, 2) == '00' || res[field].substr(0, 1) == 'a' || res[field].substr(0, 1) == '0')) {
                            res[field] = '/' + res[field];
                        } else {
                            res[field] = res[field];
                            if (typeof res[field] === 'object') {
                                console.log('attr.Keys : ', Object.keys(res[field]));
                                console.log('attr.Values : ', Object.values(res[field])[1]);
                                res[field] = Object.values(res[field])[1];
                            }
                        }
                    }
                })

                console.log('resultData: ', resultData);

                this.sobjectRecords = resultDatasobjectrecordList; //resultData.sobjectrecordList;
                this.sobjectAllRecords = resultData.sobjectrecordAllItemList;
                console.log('sobjectRecords: ', this.sobjectRecords);
                console.log('sobjectAllRecords: ', this.sobjectAllRecords);

                this.searchRecordItemsPageNumber = resultData.pageNumber;
                this.searchRecordItemsTotalRecords = resultData.totalRecords;
                this.searchRecordItemsRecordStart = resultData.recordStart;
                this.searchRecordItemsRecordEnd = resultData.recordEnd;
                this.searchRecordItemsTotalPages = Math.ceil(resultData.totalRecords / this.searchRecordItemsPageSize);

                this.searchRecordItemsIsNext = (this.searchRecordItemsPageNumber >= this.searchRecordItemsTotalPages) ? true : false;
                this.searchRecordItemsIsPrev = (this.searchRecordItemsPageNumber <= 1) ? true : false;

            } catch (error) {
                console.log('error: ', error);
                this.handleIsLoading(false);
            }

            // show content result criteria
            this.showContentResultCriteria = true;

            const event = new ShowToastEvent({
                message: 'Data yang berhasil ditampilkan adalah ' + this.searchRecordItemsTotalRecords,
                variant: 'success'
            });
            this.dispatchEvent(event);
            this.getSobjectHeaderColumn();
            this.handleIsLoading(false);
        })
    }

    getSelectedMassRecordUpdateItems() {
        console.log('this.recordId.331: ', this.recordId);
        console.log('this.sobjectNameUpdate: ', this.sobjectNameUpdate);
        console.log('this.selectedRecordItemsPageSize: ', this.selectedRecordItemsPageSize);

        getSelectedMassRecordUpdateItems({ massUpdateRecordId: this.recordId, SobjectApiName: this.sobjectNameUpdate, pageSize: this.selectedRecordItemsPageSize, pageNumber: this.selectedRecordItemsPageNumber, searchKeyUpdateRecordItem: this.searchKeyUpdateRecordItem, selectedRecordUpdateItemViewDefault: this.headerSelectedItemcolumnDefault }).then(getSelectedRecordItems => {

            this.selectedItemRecords = getSelectedRecordItems;
            console.log('this.selectedItemRecords: ', this.selectedItemRecords);

            var resultData = JSON.parse(getSelectedRecordItems);
            console.log('resultData.getSelectedMassRecordUpdateItems: ', resultData);

            //handle lookup references user
            var resultDataMassRecordUpdateItems = resultData.massRecordUpdateItems;
            console.log('resultData: ' + resultDataMassRecordUpdateItems);
            resultDataMassRecordUpdateItems.forEach(res => {
                console.log('res.873: ', res);
                for (let field in res) {
                    if (typeof res[field] === 'string' && (res[field].substr(0, 2) == '00' || res[field].substr(0, 1) == 'a' || res[field].substr(0, 1) == '0')) {
                        res[field] = '/' + res[field];
                    } else {
                        res[field] = res[field];
                        if (typeof res[field] === 'object') {
                            console.log('attr.Keys : ', Object.keys(res[field]));
                            console.log('attr.Values : ', Object.values(res[field])[1]);
                            res[field] = Object.values(res[field])[1];
                        }
                    }
                }
            })

            console.log('==>resultData1525: ', resultData);

            this.sobjectRecordsSelectedItem = resultDataMassRecordUpdateItems;//resultData.massRecordUpdateItems;
            this.sobjectRecordsSelectedAllItem = resultData.massRecordUpdateAllItems;
            console.log('==>sobjectRecordsSelectedItem.getSelectedMassRecordUpdateItems: ', this.sobjectRecordsSelectedItem);
            console.log('==>sobjectRecordsSelectedAllItem.getSelectedMassRecordUpdateItems: ', this.sobjectRecordsSelectedAllItem);

            this.selectedRecordItemsPageNumber = resultData.pageNumber;
            this.selectedRecordItemsTotalRecords = resultData.totalRecords;
            this.selectedRecordItemsRecordStart = resultData.recordStart;
            this.selectedRecordItemsRecordEnd = resultData.recordEnd;
            this.selectedRecordItemsTotalPages = Math.ceil(resultData.totalRecords / this.selectedRecordItemsPageSize);
            console.log('selectedRecordItemsTotalPagesAfter: ', this.selectedRecordItemsTotalPages);

            // this.selectedRecordItemsIsNext = (this.selectedRecordItemsPageNumber == this.selectedRecordItemsTotalPages || this.selectedRecordItemsTotalPages == 0);
            this.selectedRecordItemsIsNext = (this.selectedRecordItemsPageNumber >= this.selectedRecordItemsTotalPages) ? true : false;
            // this.selectedRecordItemsIsPrev = (this.selectedRecordItemsPageNumber == 1 || this.selectedRecordItemsTotalRecords < this.selectedRecordItemsPageSize);
            this.selectedRecordItemsIsPrev = (this.selectedRecordItemsPageNumber <= 1) ? true : false;

            console.log('selectedRecordItemsIsNext: ', this.selectedRecordItemsIsNext);
            console.log('selectedRecordItemsIsPrev: ', this.selectedRecordItemsIsPrev);

            this.getSobjectItemsHeaderColumn()
        })
        this.handleIsLoading(false);
    }

    /*
    getSelectedSobjectRecordsRow() {
        console.log('in getSelectedSobjectRecordsRow');
    
        let selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        console.log('SelectedRecords: ', selectedRecords);
        if (selectedRecords.length > 0) {
            let ids = '';
            selectedRecords.forEach(currentItem => {
                if (currentItem) {
                    ids = ids + ',' + currentItem.Id;
                }
            });
            this.selectedRowIds = ids.replace(/^,/, '');
            this.selectedrowRecords = selectedRecords;
    
            console.log('selectedRowIds: ', this.selectedRowIds);
            console.log('selectedrowRecords: ', this.selectedrowRecords);
        }
    }
    */

    getSelectedSobjectRecordsRow(event) {
        console.log('In getSelectedSobjectRecordsRow');

        this.selectedRowIds = event.target.selectedRows;
        console.log('==>selectedRowIds: ', this.selectedRowIds);

        for (let i = 0; i < this.selectedRowIds.length; i++) {
            if (this.selectedRowIds[i]) {
                this.activeAddtoContainer = false;

                this.selectedSearchRecId = this.selectedRowIds[i].split('/')[1];
                console.log('selectedSearchRecId: ', this.selectedSearchRecId);
                if (!this.selectedRecordItemsrow.includes(this.selectedSearchRecId)) {
                    // If the selected row is not already in the list, add it
                    this.selectedRecordItemsrow.push(this.selectedSearchRecId);
                }
            }
        }

        // Check for any rows that were unchecked by the user
        for (let i = this.selectedRecordItemsrow.length - 1; i >= 0; i--) {
            let recId = this.selectedRecordItemsrow[i];
            let row = this.selectedRowIds.find(row => row.split('/')[1] === recId);

            if (!row) {
                // If the row is not found in the selected rows, remove it from the list
                this.selectedRecordItemsrow.splice(i, 1);
                this.activeAddtoContainer = true;
            }
        }
        console.log('this.selectedRecordItemsrow.suspect: ', this.selectedRecordItemsrow);

        this.rowSearchSelectedIds = this.selectedRecordItemsrow.toString();
        console.log('==>rowSearchSelectedIds: ', this.rowSearchSelectedIds);
    }


    // ================= remove selected item ====================

    /*
    getSelectedSobjectRecordItemsRow(event) {
        console.log('In getSelectedSobjectRecordItemsRow');
        const selectedId = [];
        let selectedRecId;
        const selectedRows = event.target.selectedRows;
        console.log('selectedRows: ', selectedRows);
    
    
    
        if (selectedRows.length > 0) {
            for (let i = 0; i < selectedRows.length; i++) {
                //this.selectedRecordItemsrow = selectedRows;
                console.log('selectedRows.i: ', selectedRows);
                selectedId = selectedRows;
            }
    
            for (let i = 0; i < selectedId.length; i++) {
                console.log('selectedId: ', selectedId[i]);
                selectedRecId = selectedId[i].split('/');
                selectedRecId = selectedRecId[3];
                console.log('selectedRecId.final: ', selectedRecId[3]);
            }
        }
    
        this.selectedRecordItemsrow.push(selectedRecId);
        console.log('this.selectedRecordItemsrow: ', this.selectedRecordItemsrow);
    }
    */

    getSelectedSobjectRecordItemsRow(event) {
        console.log('In getSelectedSobjectRecordItemsRow');
        let selectedRows = event.target.selectedRows;
        console.log('selectedRows: ', selectedRows);
        for (let i = 0; i < selectedRows.length; i++) {
            if (selectedRows[i]) {
                this.activeMassUpdate = false;

                let selectedRecId = selectedRows[i].split('/')[1];
                console.log('selectedRecId: ', selectedRecId);
                if (!this.selectedRecordItemsrow.includes(selectedRecId)) {
                    // If the selected row is not already in the list, add it
                    this.selectedRecordItemsrow.push(selectedRecId);
                }
            }
        }

        // Check for any rows that were unchecked by the user
        for (let i = this.selectedRecordItemsrow.length - 1; i >= 0; i--) {
            let recId = this.selectedRecordItemsrow[i];
            let row = selectedRows.find(row => row.split('/')[1] === recId);

            if (!row) {
                // If the row is not found in the selected rows, remove it from the list
                this.selectedRecordItemsrow.splice(i, 1);
                this.activeMassUpdate = true;
            }
        }
        console.log('this.selectedRecordItemsrow: ', this.selectedRecordItemsrow);

        this.rowSelectedItemIds = this.selectedRecordItemsrow.toString();
        console.log('==>rowSelectedItemIds: ', this.rowSelectedItemIds);
    }

    /*
    getSelectedRecordUpdateItemRow() {
    
        console.log('in getSelectedRecordUpdateItemRow');
    
        var selectedRecordUpdateItem = this.template.querySelector("lightning-datatable").getSelectedRows();
        console.log('selectedRecordUpdateItem: ', selectedRecordUpdateItem);
    
        if (selectedRecordUpdateItem.length > 0) {
            let ids = '';
            selectedRecordUpdateItem.forEach(currentItem => {
                if (currentItem) {
                    ids = ids + ',' + currentItem.Id;
                }
            });
            this.selectedUpdateItemRowIds = ids.replace(/^,/, '');
            this.selectedUpdateItemRowRecords = selectedRecordUpdateItem;
    
            console.log('selectedUpdateItemRowIds: ', this.selectedUpdateItemRowIds);
            console.log('selectedUpdateItemRowRecords: ', this.selectedUpdateItemRowRecords);
        } else {
            console.log('Error: ', this.error);
        }
    
    }
    */

    removeSelectedRecordItem() {
        console.log('In removeSelectedRecordItem');

        console.log('massRecordUpdateId: ', this.recordId);
        console.log('selectedRowRemoveItems: ', this.rowSelectedItemIds);
        console.log('selectedAllRecordRemoveItems: ', this.checkAllRecorditem);
        console.log('SobjectApiName: ', this.sobjectApiName);

        this.handleIsLoading(true);

        let selectedRecordItemIdList = [];
        let SelectedRecordItem = [];
        let SelectedRecordItemIds = '';

        if (this.checkAllRecorditem == true) {
            SelectedRecordItem = this.sobjectRecordsSelectedAllItem;
        } else if (this.checkAllRecorditem == false) {
            SelectedRecordItemIds = this.rowSearchSelectedIds;
        }
        console.log('==>SelectedRecordItem: ', SelectedRecordItem);
        console.log('==>SelectedRecordItemIds: ', SelectedRecordItemIds);

        // for selected all
        for (const sobjectNameUpdateFieldKey in SelectedRecordItem) {
            console.log('this.sobjectNameUpdate[sobjectNameUpdateFieldKey][id]: ', SelectedRecordItem[sobjectNameUpdateFieldKey]);
            selectedRecordItemIdList.push(SelectedRecordItem[sobjectNameUpdateFieldKey]['Id']);
        }
        console.log('selectedRecordItemIdList: ', selectedRecordItemIdList);

        removeRecordUpdateItem({ massRecordUpdateId: this.recordId, selectedRowRemoveItems: this.rowSelectedItemIds, selectedRemoveItems: selectedRecordItemIdList, selectedAllRecordRemoveItems: this.checkAllRecorditem, SobjectApiName: this.sobjectApiName }).then(result => {
            try {
                console.log('==>status: ', result);
                this.getSelectedMassRecordUpdateItems();
                const event = new ShowToastEvent({
                    message: 'Your record has been deleted.',
                    variant: 'success'
                });
                this.dispatchEvent(event);

            } catch (error) {
                console.log('statusFail: ', result);
                console.log(error);
                this.showErrorToast();
            }
        })
        return refreshApex(this.getSelectedMassRecordUpdateItems());
    }

    // ================= get value lightning input  ================
    get operatorOptions() {
        return [
            { label: 'AND', value: 'AND' },
            { label: 'OR', value: 'OR' }
        ];
    }

    // error toast
    showErrorToast() {
        const event = new ShowToastEvent({
            message: 'Some unexpected error',
            variant: 'error'
        });
        this.dispatchEvent(event);
    }
    // end of error toast

    // success toast
    showSuccessToast() {
        const event = new ShowToastEvent({
            message: 'Your data was saved!',
            variant: 'success'
        });
        this.dispatchEvent(event);
    }
    // end of error toast 


    //================ show data ================
    // filter options search record items data
    showSearchRecordItemsDataOptions = [
        {
            label: '10',
            value: '10'
        },
        {
            label: '25',
            value: '25'
        },
        {
            label: '50',
            value: '50'
        },
        {
            label: '100',
            value: '100'
        }
    ];

    // filter options selected record items data
    showSelectedRecordItemsDataOptions = [
        {
            label: '10',
            value: '10'
        },
        {
            label: '25',
            value: '25'
        },
        {
            label: '50',
            value: '50'
        },
        {
            label: '100',
            value: '100'
        }
    ];


    //function for on changes show value 
    searchRecordItemsOnChange(event) {
        this.value = event.target.value;
        this.searchRecordItemsPageSize = event.detail.value;
        console.log('bulky.target.value: ', event.target.value);
        console.log('bulky.this.value: ', this.value);
        this.searchRecordItemsPageNumber = this.searchRecordItemsPageNumber;
        this.getSobjectRecordList();
    }

    selectedRecordItemsOnChange(event) {
        this.value = event.target.value;
        this.selectedRecordItemsPageSize = event.detail.value;
        console.log('bulky.selected.target.value: ', event.target.value);
        console.log('bulky.selected.this.value: ', this.value);
        this.selectedRecordItemsPageNumber = this.selectedRecordItemsPageNumber;
        this.getSelectedMassRecordUpdateItems();
    }

    // click remove item
    async handleConfirmRemoveItem() {
        console.log('In handleConfirmClick');
        const result = await LightningConfirm.open({
            variant: 'headerless',
            message: 'Sure to remove this selected record?'
        });
        if (result == true) {
            if (this.rowSelectedItemIds != null || this.checkAllRecorditem != false) {
                this.removeSelectedRecordItem();
            } else {
                const event = new ShowToastEvent({
                    message: 'No record is selected!',
                    variant: 'error'
                });
                this.dispatchEvent(event);
            }
        }
    }

    // ========== Handle Loading Spinner ========== //
    handleIsLoading(isLoading) {
        this.isLoading = isLoading;
    }

    handleCheckBoxSearchAllItem(event) {
        this.checkAllSearchitem = event.target.checked;

        if (this.checkAllSearchitem == true) {
            this.activeAddtoContainer = false; // button add to container is active

            var filterRecordValues = JSON.stringify(this.listFilterGetSobjectRecord);

            getSobjectRecordList({ SobjectApiName: this.sobjectNameUpdate, FilterRecord: filterRecordValues, pageSize: this.searchRecordItemsPageSize, pageNumber: this.searchRecordItemsPageNumber, operatorCondition: this.operatorFilterCondition, fieldType: this.sobjectListFieldType, recordType: this.recordTypeName }).then(result => {

                var resultData = JSON.parse(result);
                var totalRecords = resultData.totalRecords;

                const event = new ShowToastEvent({
                    message: '"' + totalRecords + '" Records has been selected.',
                    variant: 'success'
                });
                this.dispatchEvent(event);
            })
        } else if (this.checkAllSearchitem == false) {
            this.activeAddtoContainer = true; // button add to container is de-active
        }
    }

    handleCheckBoxcheckAllRecorditem(event) {
        this.checkAllRecorditem = event.target.checked;

        if (this.checkAllRecorditem == true) {
            this.activeMassUpdate = false; // button 'Mass Update' active

            getSelectedMassRecordUpdateItems({ massUpdateRecordId: this.recordId, SobjectApiName: this.sobjectNameUpdate, pageSize: this.selectedRecordItemsPageSize, pageNumber: this.selectedRecordItemsPageNumber, searchKeyUpdateRecordItem: this.searchKeyUpdateRecordItem, selectedRecordUpdateItemViewDefault: this.headerSelectedItemcolumnDefault }).then(result => {
                var resultData = JSON.parse(result);
                var totalRecords = resultData.totalRecords;

                const event = new ShowToastEvent({
                    message: '"' + totalRecords + '" Records has been selected.',
                    variant: 'success'
                });
                this.dispatchEvent(event);
            });
        } else if (this.checkAllRecorditem == false) {
            this.activeMassUpdate = true; // button 'Mass Update' deactive
        }
        console.log('this.checkAllRecorditem: ', this.checkAllRecorditem);
    }

    // click update data
    async handleConfirmUpdate() {
        const result = await LightningConfirm.open({
            variant: 'headerless',
            message: 'Sure want to update data?'
        });
        if (result == true) {
            if ((this.selectedRecordItemsrow.length > 0 || this.checkAllRecorditem != false) && this.sobjectRecordItemListFieldName != null) {
                this.updateSobjectRecordItems();
            } else if (this.selectedRecordItemsrow.length > 0 || this.checkAllRecorditem != false) {
                const event = new ShowToastEvent({
                    message: 'Please select the field to be updated!',
                    variant: 'error'
                });
                this.dispatchEvent(event);
            } else if (this.sobjectRecordItemListFieldName != null) {
                const event = new ShowToastEvent({
                    message: 'Please select the record to be updated!',
                    variant: 'error'
                });
                this.dispatchEvent(event);
            } else {
                const event = new ShowToastEvent({
                    message: 'No record is selected!',
                    variant: 'error'
                });
                this.dispatchEvent(event);
            }
        }
    }
}