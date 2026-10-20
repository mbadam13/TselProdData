import { LightningElement, api, track, wire } from 'lwc';
import getOrderItem from '@salesforce/apex/dataTableSettlementWeekly_Controller.getOrderItem';
import getPicklistValue from '@salesforce/apex/dataTableSettlementWeekly_Controller.getSobjectpicklistValues';

const columnsWeekly = [
    {
        label: 'Pencatatan Keuangan',
        fieldName: 'Pencatatan_Keuangan__c',
        type: 'date-local',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Start Date',
        fieldName: 'ServiceDate',
        type: 'date',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'End Date',
        fieldName: 'EndDate',
        type: 'date',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Penagihan',
        fieldName: 'Penagihan__c',
        type: 'text',
        editable: false,
        initialWidth: 150,
    },
    // {
    //     label: 'Kirim Nodin',
    //     fieldName: 'Kirim_Nodin_Submit_To_Finance__c', // perlu di ubah menggunakan field Tanggal Invoice
    //     type: 'date-local',
    //     editable: true,
    //     initialWidth: 150,
    // },
    {
        label: 'Tanggal Invoice',
        fieldName: 'Tanggal_Invoice__c', // perlu di ubah menggunakan field Tanggal Invoice
        type: 'date-local',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'No Invoice',
        fieldName: 'No_Invoice_Tsel__c',
        type: 'text',
        editable: false,
        initialWidth: 150,
    },

    {
        label: 'Order Item Number',
        fieldName: 'OrderItemId',
        type: 'url',
        typeAttributes: { label: { fieldName: 'OrderItemNumber' }, target: '_blank' },
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Payment Date ke Telkomsel',
        fieldName: 'Payment_Date_ke_Telkomsel__c',
        type: 'date-local',
        editable: true,
        initialWidth: 150,
    },
    {
        label: 'Grouping DS', 
        fieldName: 'Grouping_DS__c', 
        type: 'picklist', 
        editable: true, 
        typeAttributes: {
            placeholder: 'Choose Option', 
            options: { fieldName: 'pickListOptions' }, 
            value: { fieldName: 'Grouping_DS__c' },
            context: { fieldName: 'Id' } 
        },
        initialWidth: 150,
    },
    {
        label: 'Product Category',
        fieldName: 'Product_Category__c',
        type: 'text',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Invoice Finance',
        fieldName: 'Invoice_Finance__c', // diubah menggunakan formula jika no invoice terisi
        type: 'text',
        editable: true,
        initialWidth: 150,
    },
    {
        label: 'Order Status',
        fieldName: 'orderStatus',
        type: 'text',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Order Item Status',
        fieldName: 'Order_Item_Status__c',
        type: 'text',
        editable: true,
        initialWidth: 150,
    },
    
    {
        label: 'Account Name',
        fieldName: 'AccountId',
        type: 'url',
        typeAttributes: { label: { fieldName: 'AccountName' }, target: '_blank' },
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Agency Name',
        fieldName: 'AgencyId',
        type: 'url',
        typeAttributes: { label: { fieldName: 'AgencyName' }, target: '_blank' },
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Brand Product',
        fieldName: 'BrandId',
        type: 'url',
        typeAttributes: { label: { fieldName: 'BrandName' }, target: '_blank' },
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Campaign Name',
        fieldName: 'Campaign_Name__c',
        type: 'text',
        editable: true,
        initialWidth: 150,
    },
    {
        label: 'Business Product',
        fieldName: 'Business_Product__c',
        type: 'text',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Sales',
        fieldName: 'SalesName',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Sales__c' }, target: '_blank' },
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Sales Team',
        fieldName: 'SalesTeam',
        type: 'text',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Source',
        fieldName: 'Source__c',
        type: 'text',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'SOA Invoice',
        fieldName: 'SOAInvoice',
        type: 'text',
        editable: false,
        initialWidth: 150,
    },
    /*{
        label: 'No. FBO',
        fieldName: 'No_FBO__c',
        type: 'text',
        editable: true,
        initialWidth: 150,
    }, */
    {
        label: 'Source SME',
        fieldName: 'Source_SME__c',
        type: 'text',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Grouping Layanan',
        fieldName: 'Grouping_Layanan__c',
        type: 'text',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Product Name',
        fieldName: 'ProductId',
        type: 'url',
        typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank' },
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Quantity',
        fieldName: 'Quantity',
        type: 'number',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Unit Price',
        fieldName: 'UnitPrice',
        type: 'currency',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Total Gross / Inventory',
        fieldName: 'Total_Gross_Inventory__c',
        type: 'currency',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Sub Total FBO',
        fieldName: 'Sub_Total_FBO__c',
        type: 'currency',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Disc Adv FBO',
        fieldName: 'Disc_Adv_FBO__c',
        type: 'currency',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Total Dicount FBO',
        fieldName: 'Total_Diskon_FBO__c',
        type: 'currency',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Discount',
        fieldName: 'Discount__c',
        type: 'text',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Revenue After Discount',
        fieldName: 'Telkomsel_Revenue__c',
        type: 'currency',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'VAT',
        fieldName: 'VAT__c',
        type: 'text',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Setelah PPN / FBO',
        fieldName: 'Setelah_PPn_FBO__c',
        type: 'currency',
        editable: false,
        initialWidth: 150,
    },
    /*
    {
        label: 'Final Usage',
        fieldName: 'Final_Usage__c',
        type: 'Number',
        editable: true,
        initialWidth: 150,
    },
    */
    {
        label: 'Usage Actual',
        fieldName: 'Usage_Actual__c',
        type: 'number',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Sisa Usage',
        fieldName: 'Sisa_Usage__c',
        type: 'number',
        editable: false,
        initialWidth: 150,
    },
    {
        label: 'Sisa Usage After Discount ',
        fieldName: 'Sisa_Usage_After_Disc__c',
        type: 'currency',
        editable: false,
        initialWidth: 150,
    }
];

export default class DataTableSettlementWeekly extends LightningElement {
    sfdcBaseURL;
    error;
    columns = columnsWeekly;
    allRecords; //All Cases available for data table    
    showTable = false; //Used to render table after we get the data from apex controller    
    recordsToDisplay = []; //Records to be displayed on the page
    rowNumberOffset; //Row number
    preSelected = [];
    selectedRows;
    @track recordSize;
    @track pickListOptions = [
        // Daftar opsi picklist Anda di sini, misalnya:
        { label: 'Opsi 1', value: 'Option 1' },
        { label: 'Opsi 2', value: 'Option 2' },
        { label: 'Opsi 3', value: 'Option 3' },
    ];
    @track showSpinner = false;  
    renderedCallback() {
        this.sfdcBaseURL = window.location.origin;
    }
    connectedCallback() {

        this.columns = this.columns.map((column, index) => {
            const actions = [
                { label: 'Set Filter', disabled: false, name: `filter_${index}`, iconName: 'utility:filter' },
                { label: 'Clear Filter', disabled: true, name: `clear_${index}`, iconName: 'utility:clear' }
            ];
            column = { ...column, sortable: "true" };
            return { ...column, actions };
        });
        this.getpickListValues();
        this.fetchData();
        this.showSpinner = false;
    }

    async fetchData() {
        
        try {
            this.showSpinner = true;  
            let fixRecords = [];
            const result = await getOrderItem();
          
            this.recordSize = result.length;
            this.showTable = true;
         
            result.forEach(res => {
                let tempRecord = Object.assign({}, res); //cloning object
                
                console.log(tempRecord);
                tempRecord.pickListOptions = this.pickListOptions;

                if( tempRecord.Sales__c != null){
                    tempRecord.SalesName = '/' + tempRecord.Sales__r.Id;
                    tempRecord.Sales__c = tempRecord.Sales__r.Name;
                }

                if(tempRecord.Order.Account != null){
                    tempRecord.AccountId = '/' +tempRecord.Order.Account.Id;
                    tempRecord.AccountName = tempRecord.Order.Account.Name;
                }

                if(tempRecord.Opportunity__r != null){
                    if(tempRecord.Opportunity__r.Agency_Name__r != null){
                        tempRecord.AgencyId = '/' +tempRecord.Opportunity__r.Agency_Name__c;
                        tempRecord.AgencyName = tempRecord.Opportunity__r.Agency_Name__r.Name;
                    }
                }else{
                    if(tempRecord.Order.Account != null){
                        tempRecord.AgencyId = '/' +tempRecord.Order.Account.Id;
                        tempRecord.AgencyName = tempRecord.Order.Account.Name;
                    }
                   
                }

                if(tempRecord.MyAds__c != null){

                   if(tempRecord.Order.Brand__c != null){
                        tempRecord.BrandId = '/' +tempRecord.Order.Brand__r.Id;
                        tempRecord.BrandName = tempRecord.Order.Brand__r.Name;
                    }
                 
                }else{
                    if(tempRecord.Opportunity__c == null){

                        if(tempRecord.Order.Brand__c != null){
                            tempRecord.BrandId = '/' +tempRecord.Order.Brand__r.Id;
                            tempRecord.BrandName = tempRecord.Order.Brand__r.Name;
                        }
                    }else{
                        if(tempRecord.Opportunity__r != null){
                            if(tempRecord.Opportunity__r.Brand__r != null){
                                tempRecord.BrandId = '/' +tempRecord.Opportunity__r.Brand__r.Id;
                                tempRecord.BrandName = tempRecord.Opportunity__r.Brand__r.Name;
                            }  
                           
                        }
                    }
                }

                if(tempRecord.Order.SOA_Invoice__c != null){
                    tempRecord.SOAInvoice = tempRecord.Order.SOA_Invoice__c;
                }

                if(tempRecord.Order.Status != null){
                    tempRecord.orderStatus = tempRecord.Order.Status;
                }

                if(tempRecord.Order.Sales_Team__c != null){
                    tempRecord.SalesTeam = tempRecord.Order.Sales_Team__c;
                }

                if(tempRecord.OrderItemNumber != null){
                    tempRecord.OrderItemId = '/' +  tempRecord.Id;
                }

                if(tempRecord.Product2 != null){
                    tempRecord.ProductId = '/' +  tempRecord.Product2Id;
                    tempRecord.ProductName = tempRecord.Product2.Name;
                }
                fixRecords.push( tempRecord );
               
            });
            console.log(fixRecords);
            this.allRecords = fixRecords;
            this.showSpinner = false;  
        } catch (error) {
            console.log('error FetchData : ' + error);
        }
    }

    getpickListValues(){
        getPicklistValue({ sobjectApiName: 'OrderItem', fieldName: 'Grouping_DS__c' }).then(resultPicklistValue => {
            try {
                var resultData = JSON.parse(resultPicklistValue);
                this.pickListOptions = resultData;
            console.log('picklist ',this.pickListOptions)
            } catch (error) {
                console.log('error: ', error);
            }
        })
    }

    handlePaginatorChange(event){
        this.recordsToDisplay = event.detail.recordsToDisplay;
        this.preSelected = event.detail.preSelected;
        if(this.recordsToDisplay && this.recordsToDisplay > 0){
            this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
        }else{
            this.rowNumberOffset = 0;
        } 
    }    

    getSelectedRows(event) {
        const selectedRows = event.detail.selectedRows;
        let selectedRecordIds = [];
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++){
            console.log(selectedRows[i].Id);
            selectedRecordIds.push(selectedRows[i].Id);
        }     
        this.template.querySelector('c-datatable-utility').handelRowsSelected(selectedRecordIds);        
    }  
 
    handleAllSelectedRows(event) {
        this.selectedRows = [];
        const selectedItems = event.detail;          
        let items = [];
        selectedItems.forEach((item) => {
            this.showActionButton = true;
            console.log(item);
            items.push(item);
        });
        this.selectedRows = items;  
        console.log(this.selectedRows);        
    } 

    changeStyle() {
        //Generate Dynamic Values
        let mdata = [];
        this.allRecords.forEach(ele => {
            if(ele['Priority']){
                ele.priorityModified = ele.Priority === 'High' ? 'slds-text-color_error':'slds-text-color_success';            
            }  
            
            if(ele['Status']){
                ele.statusModified = ele.Status === 'Closed' ? `slds-is-edited`:``;            
            }              
            mdata.push(ele);
        });       
        this.allRecords = mdata;
        this.template.querySelector('c-datatable-utility').setRecordsOnPage(); 
    }

    

}