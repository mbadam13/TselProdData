/**
 * @description       : 
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 08-08-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   06-18-2024   Novando Utoyo Agmawan   Initial Version
**/

import { LightningElement, track, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import exportRecordCsvFile from '@salesforce/apex/mediaOrderItemServices.exportRecordCsvFile';
import importRecordCsvFile from '@salesforce/apex/mediaOrderItemServices.importRecordCsvFile';

export default class MediaOrderItemImportLwc extends LightningElement {
    @api recordId;
    @track error;
    @track isLoaded = false;

    get acceptedFormats() {
        return ['.csv'];
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

                    this.isLoaded = false;
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!!',
                            message: 'Download Example CSV File failed!!!',
                            variant: 'error',
                        }),
                    );
                    this.isLoaded = false;
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
            })
    }

    handleUploadFinished(event) {
        this.isLoaded = true;
        const uploadedFiles = event.detail.files;

        importRecordCsvFile(
            {
                idContentDocument: uploadedFiles[0].documentId,
                recordId: this.recordId
            }
        )
            .then(result => {
                console.log('handleUploadFinished - result : ' + result);

                if (result != null) {
                    console.log('handleUploadFinished - result contentDocumentId : ' + result.contentDocumentId);
                    console.log('handleUploadFinished - result countAllData : ' + result.countAllData);
                    console.log('handleUploadFinished - result countAllSuccess : ' + result.countAllSuccess);
                    console.log('handleUploadFinished - result countAllFailed : ' + result.countAllFailed);
                 
                   

                    if (result.countAllFailed > 0) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!!',
                                message: 'Terjadi masalah saat mengupload data. Pastikan format data sesuai dan coba lagi.',
                                variant: 'error',
                            }),
                        );

                        window.open('/sfc/servlet.shepherd/document/download/' + result.contentDocumentId, '_self');
                    } else{

                        alert(
                            'Upload data berhasil. Informasi terbaru Anda sudah tersimpan di Media Order Item'
                            // 'There were ' +
                            // result.countAllSuccess +
                            // ' seccessfull inse rts and ' +
                            // result.countAllFailed +
                            // ' Erros From ' +
                            // result.countAllData +
                            // ' Data.'
                        );
                    }

                    this.isLoaded = false;

                    eval("$A.get('e.force:refreshView').fire();");
                    this.dispatchEvent(new CloseActionScreenEvent());
                }

                if (result === null) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!!',
                            message: 'Import Failed, Please Check Parent Record',
                            variant: 'error',
                        }),
                    );

                    this.isLoaded = false;
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
            })

    }
}