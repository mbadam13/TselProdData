import { LightningElement, api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
//import { refreshApex } from '@salesforce/apex';

const DELAY = 300;
const recordsPerPage = [10,25,50,75,100];
const pageNumber = 1;
const SHOWDIV = 'visibility:visible';
const HIDEDIV = 'visibility:hidden';  
const DEFAULTHEIGHT = '300';
const CLEAR_ACTION = 1; 

export default class DatatableUtility extends LightningElement {
   

    // Input Attributes from Parent Componant
    @api pickListOptions;
    @api keyField;
    @api showSearchBox = false; //Show/hide search box; valid values are true/false
    @api showPagination; //Show/hide pagination; valid values are true/false
    @api pageSizeOptions = recordsPerPage; //Page size options; valid values are array of integers
    @api totalRecords; //Total no.of records; valid type is Integer
    @api records; //All records available in the data table; valid type is Array
    @api maxRowSelection; //All records available in the data table; valid type is Array 
    @api columns = []; //Records to be displayed on the page

    saveDraftValues = [];
    @track draftValues = [];
    // attribute column filter
    columnArray =[];
    attribCount = 0;
    isFiltered;
    filterColumns;
    columnNumber;
    baseLabel;
    @track columnFilterValues = [];
    @track columnFilterValue;
    @track columnFilterLabel;
    @track isOpenFilterInput = false;
    @track inputLabel;
    @track inputType = 'text';
    @track inputFormat = null;   


    tableHeightStyle = 'height: '+ DEFAULTHEIGHT +'px;';    // Set Default Height as 300px 
    @api
    get tableHeight() {
        return this.tableHeightStyle;
    }

    set tableHeight(value) {
       this.tableHeightStyle = 'height: '+ value +'px;'; 
    }    

    @track pageSize; //No.of records to be displayed per page
    @track totalPages; //Total no.of pages
    @track pageNumber = pageNumber; //Page number
    @track searchKey; //Search Input
    paginationVisibility = SHOWDIV; 
    @track rowNumberOffset; //Row number
    @track preSelected; //preSelectedOnDisplay
    @track recordsToDisplay = []; //Records to be displayed on the page
    
    filteredRecords = []; //Filtered records available in the data table; valid type is Array
    selectedRecords = []; //OverallSelected records  in the data table; valid type is Array 
    pageSelectedRecords = []; //Page Selected rows  in the data table; valid type is Array
    @track filtredNum; // Total no.of Filtered records; valid type is Integer
    totalSelected = 0;
    refreshCurrentData;
    @track optionsColumn = [];
    @track selectedOptions = [];
    //SORT
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy; 
    @track showSpinner = false;   

    //Called after the component finishes inserting to DOM
    connectedCallback() {
        this.showSpinner = true;
        if(this.pageSizeOptions && this.pageSizeOptions.length > 0) 
            this.pageSize = this.pageSizeOptions[0];
        else{
            this.pageSize = this.totalRecords;
            this.showPagination = false;
        }
        console.log('totalRecords',this.totalRecords);
        console.log('pageSize',this.pageSize);
        this.paginationVisibility = this.showPagination === false ? HIDEDIV : SHOWDIV;
        this.filteredRecords = this.records; 
        this.filtredNum = this.totalRecords;
        this.setRecordsOnPage();
    }

    handleRecordsPerPage(event){
        this.showSpinner = true;
        this.pageSize = event.target.value;
        this.setRecordsOnPage();
    }

    handlePageNumberChange(event){
        if(event.keyCode === 13){
            this.showSpinner = true;
            this.pageNumber = event.target.value;
            this.setRecordsOnPage();
        }
    }
   
    previousPage(){
        this.showSpinner = true;
        this.pageNumber = this.pageNumber-1;
        this.setRecordsOnPage();
    }
    nextPage(){
        this.showSpinner = true;
        this.pageNumber = this.pageNumber+1;
        this.setRecordsOnPage();
    }

    @api
    setRecordsOnPage(){
        try {
            this.recordsToDisplay = [];
            if(!this.pageSize)
                this.pageSize = this.filtredNum;

            this.totalPages = Math.ceil(this.filtredNum/this.pageSize);
            this.setPaginationControls();
            for(let i=(this.pageNumber-1)*this.pageSize; i < this.pageNumber*this.pageSize; i++){
                if(i === this.filtredNum) break;
                this.recordsToDisplay.push(this.filteredRecords[i]);
            }

            this.preSelected = [];
            this.selectedRecords.forEach((item) => {
                if(item.selected)
                    this.preSelected.push(item.Id);
            })       
            let paginatedRecords = new Object();
            paginatedRecords.recordsToDisplay = this.recordsToDisplay;
            paginatedRecords.preSelected = this.preSelected;
            if(this.maxRowSelection === '1' ){
                this.totalSelected = 0;
            }    
            if(this.selectedRecords && this.selectedRecords.length > 0){
                this.refreshCurrentData = true;
            }  
            
            this.showSpinner = false;
        } catch (error) {
            console.log('error ==>',error);
        }
                                          
    }

    setPaginationControls(){
        // Previous/Next buttons visibility by Total pages
        if(this.totalPages === 1){
            this.showPrevious = HIDEDIV;
            this.showNext = HIDEDIV;
        }else if(this.totalPages > 1){
           this.showPrevious = SHOWDIV;
           this.showNext = SHOWDIV;
        }
        // Previous/Next buttons visibility by Page number
        if(this.pageNumber <= 1){
            this.pageNumber = 1;
            this.showPrevious = HIDEDIV;
        }else if(this.pageNumber >= this.totalPages){
            this.pageNumber = this.totalPages;
            this.showNext = HIDEDIV;
        }
        // Previous/Next buttons visibility by Pagination visibility
        if(this.paginationVisibility === HIDEDIV){
            this.showPrevious = HIDEDIV;
            this.showNext = HIDEDIV;
        }
    }

    handleKeyChange(event) {
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        if(searchKey){
            this.delayTimeout = setTimeout(() => {
                //this.paginationVisibility = HIDEDIV;
                this.setPaginationControls();

                this.searchKey = searchKey;
                //Use other field name here in place of 'Name' field if you want to search by other field
                //this.recordsToDisplay = this.records.filter(rec => rec.includes(searchKey));
                //Search with any column value (Updated as per the feedback)
                this.filteredRecords = this.records.filter(rec => JSON.stringify(rec).toLowerCase().includes(searchKey.toLowerCase()));
                this.filtredNum = this.filteredRecords.length; 
                this.setRecordsOnPage();
            }, DELAY);
        }else{
            this.filteredRecords = this.records; 
            this.filtredNum = this.totalRecords;            
            this.paginationVisibility = SHOWDIV;
            this.setRecordsOnPage();
        }        
    }

    handelRowsSelected(selectedRows) {
        console.log(selectedRows.length);
        this.totalSelected = 0;
        this.pageSelectedRecords = [];
        if(this.maxRowSelection != '1' && this.recordsToDisplay && 
            this.recordsToDisplay.length > 0 && 
            ((selectedRows.length === 0 && !this.refreshCurrentData) || selectedRows.length > 0) ){                       
            this.recordsToDisplay.forEach((item)=>{                
                var row = new Object(); 
                row.Id = item.Id;                
                if(selectedRows.includes(item.Id)){
                    row.selected = true;
                }else{
                    row.selected = false;
                }
                this.pageSelectedRecords.push(row) ;
            });                       
        }
        // To store previous row Selection
        if(this.selectedRecords.length == 0 ){
            this.selectedRecords = this.pageSelectedRecords;
        }
        this.selectedRecords = this.mergeObjectArray(this.selectedRecords, this.pageSelectedRecords, "Id");          
        if(this.maxRowSelection === '1' && selectedRows && selectedRows.length > 0){
            this.totalSelected = 1;
        }else{
            let i=0;
            this.selectedRecords.forEach(item => {
                if(item.selected){
                    i++;
                    this.totalSelected = i;
                }
            }) 
            //this.totalSelected = this.totalSelected ===1 && selectedRows.length ===0? 0: this.totalSelected;           
        }
        const filterSelected = this.selectedRecords.filter(({ selected }) => selected === true );
        this.dispatchEvent(new CustomEvent('setselectedrecords', {detail: filterSelected})); //Send records to display on table to the parent component
        this.refreshCurrentData = false;
    }

    mergeObjectArray(firstArray, secondArray, prop){
        var reduced =  firstArray.filter( aitem => ! secondArray.find ( bitem => aitem[prop] === bitem[prop]) )
        //let arr3 = arr1.map((item, i) => Object.assign({}, item, arr2[i]));
        return reduced.concat(secondArray);
    }    

    getSelectedRows(event) {
        const selectedRows = event.detail.selectedRows;
        let selectedRecordIds = [];
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++){
            selectedRecordIds.push(selectedRows[i].Id);
        }     
     //   this.handelRowsSelected(selectedRecordIds);        
    }      

    handelSort(event){        
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.filteredRecords];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.filteredRecords = cloneData;  
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;        
        this.setRecordsOnPage();
    } 

    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }  
    
    /*column Filter*/

    handleMultipleSelectChange(event) {
        try {
            this.selectedOptions = event.detail;
            const selectedValues = event.detail;
            const allSelectedValues = selectedValues.map(item => item.value);
            const allSelectedLabel = selectedValues.map(item => item.label);
            this.columnFilterValue = allSelectedValues.join(';');
            this.columnFilterLabel = allSelectedLabel.join(';');
            this.columnFilterValues[this.columnNumber] = this.columnFilterValue;
            this.isFiltered = false;
          
        } catch (error) {
            console.log('errorr ==> ',error);
        }
       
    }
    
    removeSpaces(string) {
        return string
            .replace(/, | ,/g,',')
            .replace(/: | :/g,':')
            .replace(/{ | {/g,'{')
            .replace(/} | }/g,'}')
            .replace(/; | ;/g,';');
    }

    columnReference(attrib) {
        // The column reference can be either the field API name or the column sequence number (1,2,3 ...)
        // If no column reference is specified, the values are assigned to columns in order (There must be a value provided for each column)
        // Return the actual column # (0,1,2 ...)
        let colRef = 0;
        if (this.attribCount == 0) {
            let colDescriptor = attrib.split(':')[0];
            colRef = Number(colDescriptor)-1;
            if (isNaN(colRef)) {
                colRef = this.columnArray.indexOf(colDescriptor);
                colRef = (colRef != -1) ? colRef : 999; // If no match for the field name, set to non-existent column #
            }
        } else {
            colRef = this.attribCount-1;
            this.attribCount += 1;
        }
        return colRef;
    }

    columnValue(attrib) {
        // Extract the value from the column attribute
        return attrib.slice(attrib.search(':')+1);
    }

    handleHeaderAction(event) {
        try {
            const actionName = event.detail.action.name;
           
        console.log('actionName ==> ',actionName);
        if (actionName.search('filter') == -1 && actionName.search('clear') == -1) return;
        this.isFiltered = false;
        const colDef = event.detail.columnDefinition;
        console.log(' this.colDef ==> ', JSON.stringify(colDef));
        this.filterColumns = JSON.parse(JSON.stringify([...this.columns]));
        console.log(' this.filterColumns ==> ', this.filterColumns);
        this.columnNumber = Number(actionName.split("_")[1]);
        console.log(' this.columnNumber ==> ', this.columnNumber);
        this.baseLabel = this.filterColumns[this.columnNumber].label.split(' [')[0];
        this.inputLabel = 'Column Filter: ' + this.baseLabel;

        const rows = [...this.records];
        
        const recordsData = rows.map(item => {
            
            if (typeof item[colDef.fieldName] !== 'undefined') {
                if (colDef.type === "url" && colDef.typeAttributes && colDef.typeAttributes.label && colDef.typeAttributes.label.fieldName) {
                    const labelValue = item[colDef.fieldName];
                    const cleanedValue = labelValue ? labelValue.replace('/', '') : labelValue;
                    return {
                        label: item[colDef.typeAttributes.label.fieldName],
                        value: cleanedValue
                    };
                } else {
                    return item[colDef.fieldName];
                }
            } else {
                return null; // Gantilah undefined dengan null
            }
        });
        
        console.log('recordsData ==>', recordsData);
        
        // Menghilangkan nilai yang null dari recordsData
        const filteredRecordsData = recordsData.filter(item => item !== null);
        
        const uniqueFilterSet = new Set(filteredRecordsData.map(item => (item !== null) ? JSON.stringify(item) : null));
        const uniqueFilter = Array.from(uniqueFilterSet).filter(item => item !== null).map(item => JSON.parse(item));
        
        console.log('rows ==> ', uniqueFilter);

        this.optionsColumn = uniqueFilter.map(value => {
        if (typeof value === 'object') {
            return value;
        } else {
            return { label: value, value: value };
        }
        });

        switch(actionName.split('_')[0]) {

            case 'filter':
                this.columnFilterValue = this.columnFilterValues[this.columnNumber];
                this.columnFilterValue = (this.columnFilterValue) ? this.columnFilterValue : null;
                console.log(' this.columnFilterValue ==> ', this.columnFilterValue);
                this.columnType = colDef.type;
                this.inputType = this.convertType(this.columnType);
                this.inputFormat = (this.inputType == 'number') ? this.convertFormat(this.columnType) : null;

                this.handleOpenFilterInput();
              
                break;

            case 'clear':
                this.filterColumns[this.columnNumber].label = this.baseLabel;
                this.columnFilterValue = null;
                this.columnFilterValues[this.columnNumber] = this.columnFilterValue;

                this.filterColumnData();

                this.filterColumns[this.columnNumber].actions[CLEAR_ACTION].disabled = true;
                
                break;

            default:
        }

        this.columns = [...this.filterColumns];
        } catch (error) {
            console.log('handleAction ==> ',error);
        }
    }

    convertType(colType) {
        // Set Input Type based on column Data Type
        switch(colType) {
            case 'boolean':
                return 'text';
            case 'date':
                return 'date';
            case 'datetime':
                return 'datetime';
            case 'time':
                return 'time';
            case 'email':
                return 'email';
            case 'phone':
                return 'tel';
            case 'url':
                return 'url';
            case 'number':
                return 'number';
            case 'currency':
                return 'number';
            case 'percent':
                return 'number';
            default:
                return 'text';
        }
    }

    convertFormat(colType) {
        // Set Input Formatter value for different number types
        switch(colType) {
            case 'currency':
                return 'currency';
            case 'percent':
                // return 'percent-fixed';  // This would be to enter 35 to get 35% (0.35)
                return 'percent';
            default:
                return null;
        }
    }

    closeModal(){
        this.isOpenFilterInput = false;
    }

    handleOpenFilterInput() {
        console.log('in handleOpenFilterInput');
        // Display the input dialog for the filter value
        this.isOpenFilterInput = true;
    }

    handleSetFilter() {
        // Handle the filter input when the user clicks out of the input dialog
        if (this.columnFilterValue != null) {
            this.showSpinner = true;
            this.handleCloseFilterInput();
        }
    }

    handleCloseFilterInput() {
        try {
            // Close the input dialog and handle the new column filter value
            this.isOpenFilterInput = false; 
            if (this.columnType == 'boolean') {
                var firstChar = this.columnFilterValue.substring(0, 1).toLowerCase();
                if (firstChar == 't' || firstChar == 'y' || firstChar == '1') { // True, Yes, 1 - allow multiple ways to select a True value
                    this.columnFilterValue = 'true';
                } else {
                    this.columnFilterValue = 'false';
                }
                this.columnFilterValues[this.columnNumber] = this.columnFilterValue;
            }
            

            if (!this.isFiltered) this.filterColumnData();

            this.filterColumns[this.columnNumber].label = this.baseLabel + ' [' + this.columnFilterLabel + ']';
            this.columnFilterValues[this.columnNumber] = this.columnFilterValue;
            // Force a redisplay of the datatable with the filter value shown in the column header
            this.columns = [...this.filterColumns]; 
            this.showSpinner = false;
        } catch (error) {
            console.log('error on handleCloseFilterInput: ', error);
        }
        
    }

    filterColumnData() {
        try {
              // Filter the rows based on the current column filter values
            //const rows = [...this.savePreEditData];
            const rows = [...this.records];
            const cols = this.columnFilterValues;
            console.log('cols :> ' + cols);
            var filteredRows = [];
            rows.forEach(row => {
                var match = true;
                for (var col = 0; col < cols.length; col++) {
                    var fieldName = this.filterColumns[col].fieldName;
                    if (fieldName.endsWith('_lookup')) {
                        fieldName = fieldName.slice(0,fieldName.lastIndexOf('_lookup')) + '_name';   
                    }                
                    if (this.columnFilterValues[col] && this.columnFilterValues[col] != null) {
                        if (!row[fieldName] || row[fieldName] == null) {    // No match because the field is empty
                            match = false;
                            break; 
                        }                   

                        switch(this.filterColumns[col].type) {
                            case 'number':
                            case 'currency':
                            case 'percent':
                                if (row[fieldName] != this.columnFilterValues[col]) {    // Check for exact match on numeric fields
                                    match = false;
                                    break;                                
                                }
                                break;
                            default:
                                var fieldValue = row[fieldName].toString();
                                var filterValue = this.columnFilterValues[col];
                                if (!this.matchCaseOnFilters) {
                                    fieldValue = fieldValue.toLowerCase();
                                    filterValue = filterValue.toLowerCase();
                                }
                                if (filterValue.includes(';')) {
                                    var filterValuesArray = filterValue.split(';');
                                    var allMatch = false;
                                    for (var i = 0; i < filterValuesArray.length; i++) {
                                        console.log('Valuenya apa :> ', fieldValue, ' like ', filterValuesArray[i]);
                                        if (fieldValue.indexOf(filterValuesArray[i]) !== -1) {
                                            allMatch = true;
                                            break;
                                        }
                                    }
                                    if (!allMatch) {
                                        match = false; // Setel match ke false jika tidak ada kecocokan
                                    }
                                } else {
                                    // Jika tidak ada karakter ';', lakukan pembandingan langsung
                                    if (fieldValue.search(filterValue) == -1) {
                                        match = false;
                                        break;
                                    } 
                                }                       
                        }
                    }
                }
                if (match) {    
                    filteredRows.push(row);
                }
            });
            this.filterColumns[this.columnNumber].actions[CLEAR_ACTION].disabled = false;
            this.recordsToDisplay = filteredRows;
            this.isFiltered = true;

            console.log('this.recordsToDisplay: ', this.recordsToDisplay.length);
            console.log('this.recordsToDisplay: ', this.recordsToDisplay);
        } catch (error) {
            console.log('error on filterColumnData: ', error );
        }
      
    }

    updateColumnSorting(event) {
        // Handle column sorting
        console.log('Sort:',event.detail.fieldName,event.detail.sortDirection);
        this.sortedBy = event.detail.fieldName;
        let sortField = this.sortedBy;
        // Change sort field from Id to Name for lookups
        if (sortField.endsWith('_lookup')) {
            sortField = sortField.slice(0,sortField.lastIndexOf('_lookup')) + '_name';   
        }
        this.sortedDirection = event.detail.sortDirection;
        let fieldValue = row => row[sortField] || '';
        let reverse = this.sortedDirection === 'asc'? 1: -1;
        this.mydata = [...this.mydata.sort(
            (a,b)=>(a=fieldValue(a),b=fieldValue(b),reverse*((a>b)-(b>a)))
        )];
    }


    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.data));
 
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
 
        //write changes back to original data
        this.data = [...copyData];
    }
 
    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
 
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }
 
    //handler to handle cell changes & update values in draft values
    handleCellChange(event) {
        //this.updateDraftValues(event.detail.draftValues[0]);
        let draftValues = event.detail.draftValues;
        draftValues.forEach(ele=>{
            this.updateDraftValues(ele);
        })
    }
 
    handleSave(event) {
        this.showSpinner = true;
        this.saveDraftValues = this.draftValues;
 
        const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
 
        // Updateing the records using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.showToast('Success', 'Records Updated Successfully!', 'success', 'dismissable');
            this.saveDraftValues = [];
         //   return this.refresh();
           // eval("$A.get('e.force:refreshView').fire();");
        }).catch(error => {
            console.log(error);
            this.showToast('Error', 'An Error Occured!!', 'error', 'dismissable');
        }).finally(() => {
            this.saveDraftValues = [];
            this.showSpinner = false;
            eval("$A.get('e.force:refreshView').fire();");
        });
    }
 
    handleCancel(event) {
        //remove draftValues & revert data changes
        this.data = JSON.parse(JSON.stringify(this.lastSavedData));
        this.draftValues = [];
    }
/*
    handleSave(event) {
        this.showSpinner = true;
        this.saveDraftValues = event.detail.draftValues;
        const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
 
        // Updateing the records using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.ShowToast('Success', 'Records Updated Successfully!', 'success', 'dismissable');
            this.saveDraftValues = [];
           return this.refresh();
        }).catch(error => {
            this.ShowToast('Error', error.message, 'An Error Occured!!', 'error', 'dismissable');
            this.showSpinner = false;
        }).finally(() => {
            this.saveDraftValues = [];
            this.showSpinner = false;
            this.refresh();
         //   eval("$A.get('e.force:refreshView').fire();");

            //window.location.reload();
        });
    }
 */
    showToast(title, message, variant, mode){
        const evt = new ShowToastEvent({
                title: title,
                message:message,
                variant: variant,
                mode: mode
            });
            this.dispatchEvent(evt);
    }

    // async refresh() {
    //     await refreshApex(this.records);
    // }
}