/**
 * @description       : 
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 06-25-2024
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   06-25-2024   Novando Utoyo Agmawan   Initial Version
**/

import { LightningElement, track, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import exportRecordCsvFile from '@salesforce/apex/mediaOrderItemServices.exportRecordCsvFile';

export default class MediaOrderItemExportLwc extends LightningElement {
    @api recordId;
    @track error;
    @track isLoaded = false;

    connectedCallback() {
        this.isLoaded = true;

        setTimeout(() => {
            this.handleExportRecordCsvFile()
        }, 1);
    }

    handleExportRecordCsvFile() {
        this.isLoaded = true;

        exportRecordCsvFile(
            {
                recordId: this.recordId
            }
        )
            .then(result => {
                if (result != null) {
                    console.log('handleExportRecordCsvFile - result : ' + result);

                    window.open('/sfc/servlet.shepherd/document/download/' + result, '_self');

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success!!',
                            message: 'Export Media Order Item CSV File Success!!!',
                            variant: 'success',
                        }),
                    );

                    this.isLoaded = false;
                    this.dispatchEvent(new CloseActionScreenEvent());
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!!',
                            message: 'Download Example CSV File failed!!!',
                            variant: 'error',
                        }),
                    );
                    this.isLoaded = false;
                    this.dispatchEvent(new CloseActionScreenEvent());
                }
            })
            .catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: JSON.stringify(error),
                        variant: 'error',
                    }),
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            })
    }
}