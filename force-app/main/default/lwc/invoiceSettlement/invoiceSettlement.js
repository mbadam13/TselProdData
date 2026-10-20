/**
 *  Author      :   Yusuf Ramadhan (yusuf.ramadhan@saasten.com)
 *  Purposes    :   UI/LWC Component for Invoice Settlement tab
 *      
 *  Date        PIC         Brief of changes
 *  22032024    Yusuf       Initial Create
 *  03042024    Yusuf       Call Combine records
 *  20042024    Yusuf       Either Sales or Sales Manager that able to use Button Actions
 *  08022024    Yusuf       Added 'Business Product' in csv
 * 
 */
import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCombinedRecords from '@salesforce/apex/invoiceSettlementController.getCombinedRecords';
import importDataFromCSV from '@salesforce/apex/invoiceSettlementController.importDataFromCSV';
import canUserAccessButtons from '@salesforce/apex/invoiceSettlementController.canUserAccessButtons';


export default class InvoiceSettlement extends LightningElement {
    @track startDate = new Date(new Date().getFullYear(), new Date().getMonth() - 1, 1).toISOString().slice(0, 10); // First day of current month
    @track endDate = new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0).toISOString().slice(0, 10); // Last day of current month

    @track records;
    @track error;
    @track selectedFileName;
    @track isLoading = false; // Property to control the loading spinner
    filesUploaded = [];
    @track isImportButtonDisabled = true;
    @track canAccessButtons = false;
    errorCatchMsg = '';


    columns = [
        { label: 'SOA/Quotation', fieldName: 'RecordName', initialWidth: 250 },
        { label: 'Mitra', fieldName: 'MitraName', initialWidth: 200 },
        { label: 'Business Product', fieldName: 'businessProduct', initialWidth: 200 },
        { label: 'SOA Start Date', fieldName: 'startDate', type: 'date', initialWidth: 150 },
        { label: 'SOA End Date', fieldName: 'endDate', type: 'date', initialWidth: 150 },
        { label: 'Telkomsel Revenue', fieldName: 'FinalTselRevenue', type: 'currency', initialWidth: 150 },
        { label: 'Hak Telkomsel', fieldName: 'FinalHakTsel', type: 'currency', initialWidth: 150 },
        { label: 'Selisih Revenue', fieldName: 'SelisihFinalRevenue', type: 'currency', initialWidth: 150 },
        { label: 'Tanggal Invoice', fieldName: 'tanggalInvoice', type: 'date', initialWidth: 150 },
        { label: 'No Invoice', fieldName: 'invoiceName', initialWidth: 150 }

        // { label: 'PKS', fieldName: 'Pks', initialWidth: 100 },
        // { label: 'Jangka Waktu PKS', fieldName: 'JangkaWaktuPks', initialWidth: 100 },
        // { label: 'PPN', fieldName: 'Ppn', type: 'currency', initialWidth: 100 },
        // { label: 'Hak Telkomsel setelah PPN', fieldName: 'SetelahPpn', type: 'currency', initialWidth: 100 },
        // { label: 'Type Bisnis', fieldName: 'typeBisnis', initialWidth: 100 },
        // { label: 'No Master', fieldName: 'noMaster', initialWidth: 100 },
        // { label: 'No Individual', fieldName: 'noIndividual', initialWidth: 100 },
        // { label: 'Region', fieldName: 'region', initialWidth: 100 },
        // { label: 'Invoice', fieldName: 'invoiceName', initialWidth: 100 }
    ];
    

    exportColumns = [
        { label: 'ID (DO NOT EDIT)', fieldName: 'recordId' }, // 0
        { label: 'SOA/Quotation', fieldName: 'RecordName' }, // 1
        { label: 'Mitra', fieldName: 'MitraName' }, // 2
        { label: 'Business Product', fieldName: 'businessProduct' }, // 3
        { label: 'SOA Start Date', fieldName: 'startDate'}, // 4
        { label: 'SOA End Date', fieldName: 'endDate'}, // 5
        { label: 'Telkomsel Revenue', fieldName: 'FinalTselRevenue'}, // 6
        { label: 'Hak Telkomsel', fieldName: 'FinalHakTsel'}, // 7
        { label: 'Selisih Revenue (DO NOT EDIT)', fieldName: 'SelisihFinalRevenue'}, // 8
        { label: 'Tanggal Invoice', fieldName: 'tanggalInvoice'}, // 9
        { label: 'No Invoice', fieldName: 'invoiceName' }, // 10
        { label: 'Invoice ID (DO NOT EDIT)', fieldName: 'invoiceId' } // 11
    ];

    @wire(getCombinedRecords, { startDate: '$startDate', endDate: '$endDate' })
    wiredData({ error, data }) {
        this.isLoading = true;
        if (data) {
            this.records = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.records = undefined;
        }
        this.isLoading = false;
    }

    @wire(canUserAccessButtons)
    userProfileCheck({ error, data }) {
        if (data) {
            this.canAccessButtons = data;
        } else if (error) {
            this.showToast('Error', 'Failed to check user permissions.', 'error');
        }
    }

    // Method to fetch data
    fetchData() {
        getCombinedRecords({ startDate: this.startDate, endDate: this.endDate })
            .then(result => {
                this.records = result;
                this.error = undefined;
            })
            .finally(() => {
                this.selectedFileName = null;
                this.isImportButtonDisabled = true;
                this.isLoading = false;
            });
    }

    handleStartDateChange(event) {
        this.isLoading = true; // Show loading spinner
        this.startDate = event.target.value;
    }

    handleEndDateChange(event) {
        this.isLoading = true; // Show loading spinner
        this.endDate = event.target.value;
    }

    handleExport() {
        const now = new Date();
        const year = now.getFullYear();
        const month = (now.getMonth() + 1).toString().padStart(2, '0'); // +1 because getMonth() returns month index (0-11)
        const day = now.getDate().toString().padStart(2, '0');
        const hours = now.getHours().toString().padStart(2, '0');
        const minutes = now.getMinutes().toString().padStart(2, '0');
        const seconds = now.getSeconds().toString().padStart(2, '0');
        const fileName = `Invoice_Settlement_Export_${year}_${month}_${day}_${hours}${minutes}${seconds}`;
    
        this.exportToCSV(this.records, fileName);
    }


    exportToCSV(data, fileName) {
        // Define a function to handle null/undefined
        const formatValue = (value) => {
            if (value === null || value === undefined) {
                return '""'; // or '"-"' to put a dash in empty cells
            }
            return `"${value.toString().replace(/"/g, '""')}"`; // Enclose in quotes and escape existing quotes
        };
    
        // Enclose each header in double quotes and join them with commas
        let csvContent = this.exportColumns.map(col => formatValue(col.label)).join(',') + '\n';
    
        // Process each data row
        data.forEach(record => {
            let row = this.exportColumns.map(col => {
                let value = record[col.fieldName];
                return formatValue(value); // Use the format function here
            }).join(',');
            csvContent += row + '\n';
        });
        
        // Create a blob and download the file
        let element = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvContent);
        let downloadElement = document.createElement('a');
        downloadElement.href = element;
        downloadElement.target = '_self';
        downloadElement.download = fileName + '.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();
    }
    
    
    handleFilesChange(event) {
        this.filesUploaded = event.target.files;
        if (this.filesUploaded.length > 0) {
            this.selectedFileName = this.filesUploaded[0].name;
            this.isImportButtonDisabled = false; // Enable the button
        } else {
            this.selectedFileName = null;
            this.isImportButtonDisabled = true; // Disable the button
        }
    }
    
    importData() {
        this.isLoading = true;
        if (this.filesUploaded.length > 0) {
            this.uploadFileToApex(this.filesUploaded[0]);
        } else {
            // Display an error if no file is selected
            this.showToast('Error', 'Please select a file to import.', 'error');
        }

        this.fetchData();
    }

    uploadFileToApex(file) {
        let reader = new FileReader();
        reader.onload = () => {
            let base64 = btoa(reader.result);
            this.importFile(base64); // Call Apex
        };
        reader.readAsBinaryString(file);
    }
    
    importFile(base64Data) {
        this.isLoading = true;

        importDataFromCSV({ base64Data: base64Data })
            .then(result => {
                this.resultMessage = result; // The returned string is stored here
                if(result === 'Success'){
                    this.isLoading = false;
                    this.showToast('Success', 'File imported successfully.', 'success');
                }else if(result === 'Warning'){
                    this.isLoading = false;
                    this.showToast('Warning', 'File imported doesn\'t have any record updated', 'warning');
                }else if(result.startsWith('Error:')){
                    this.isLoading = false;
                    this.handleErrors(result);
                    this.showToast('Processing is Failing', 'Please see attached detail', 'error');
                }else{
                    this.isLoading = false;
                    this.showToast('Error', result , 'error');
                }
                
                // Handle additional logic post-import if necessary
                this.fetchData();
                this.isLoading = false;                
            })
            // .catch(error => {
            //     this.errorCatchMsg = (error && error.body && error.body.message ? error.body.message : JSON.stringify(error));
            //     this.isLoading = false;
            //     this.showToast('Error Catch', this.errorCatchMsg, 'error');
            // })
            .finally(() => {
                this.isLoading = false;
                this.fetchData();
            });
    }

    handleErrors(errorString) {
        // Assuming error string contains CSV formatted errors
        const fileName = `Error_Log_${new Date().toISOString()}.csv`;
        let csvContent = "data:text/csv;charset=utf-8," + errorString.substring(6); // Removes 'Error:' prefix
        let encodedUri = encodeURI(csvContent);
        let link = document.createElement("a");
        link.setAttribute("href", encodedUri);
        link.setAttribute("download", fileName);
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }
    

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}