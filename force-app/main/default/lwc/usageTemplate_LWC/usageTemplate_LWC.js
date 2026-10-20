/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 11/02/2025
 * @last modified by  : Syaiful Syafani
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   09/01/2025   Syaiful Syafani   Initial Version
**/
import { LightningElement, api, wire } from 'lwc';
import getOrderItems from '@salesforce/apex/UsageTemplateController.getOrderItems';
import getOrderNumber from '@salesforce/apex/UsageTemplateController.getOrderNumber'; // new - 10 feb 2025
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class UsageTemplate_LWC extends LightningElement {
    @api recordId;
    orderNumber; // new - 10 feb 2025

    @wire(getOrderNumber, { orderId: '$recordId' }) // new - 10 feb 2025
    wiredOrderNumber({ error, data }) {
        if (data) {
            this.orderNumber = data;
            //console.log('== orderNumber: ',this.orderNumber);
        } else if (error) {
            console.log(error);
        }
    }

    @wire(getOrderItems, { orderId: '$recordId' })
    wiredOrderItems({ error, data }) {
        if (data) {
            //console.log('Fetched media order items CSV content: ', data);
            this.downloadCSV(data);
            this.closePopup();
        } else if (error) {
            let errorMessage = 'An error occurred while exporting data';
            if (error.body && error.body.message) {
                errorMessage = error.body.message;
            } else if (error.message) {
                errorMessage = error.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error exporting data',
                    message: errorMessage,
                    variant: 'error'
                })
            );
            console.error('Error exporting data: ', error);
            this.closePopup();
        }
    }

    getFormattedDate() {
        const now = new Date();
        const day = String(now.getDate()).padStart(2, '0');
        const month = String(now.getMonth() + 1).padStart(2, '0'); // January is 0!
        const year = now.getFullYear();
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        return `${day}-${month}-${year}_${hours}:${minutes}`;
    }

    downloadCSV(csvContent) {
        const formattedDate = this.getFormattedDate();
        const orderNumber = this.orderNumber; // new - 10 feb 2025
        //const filename = `Media_Order_Items_U${formattedDate}.csv`;
        const filename = `Usage_${orderNumber}_${formattedDate}.csv`; // new - 10 feb 2025
        //console.log('Downloading CSV with content: ', csvContent);
        const blob = new Blob([csvContent], { type: 'application/octet-stream' });
        const url = window.URL.createObjectURL(blob);
        const anchor = document.createElement('a');
        anchor.href = url;
        anchor.download = filename;
        anchor.click();
        window.URL.revokeObjectURL(url);
    }

    closePopup() {
        this.dispatchEvent(new CloseActionScreenEvent());
        setTimeout(() => {
            window.close();
        }, 1000); // Wait for a short delay before closing to ensure the download starts
    }
}