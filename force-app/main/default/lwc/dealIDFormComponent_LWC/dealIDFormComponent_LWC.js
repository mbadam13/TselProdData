import { LightningElement, wire, track, api } from 'lwc';
import getOpporutnityLineItemRecord from '@salesforce/apex/DealIDFormComponentController.getOpportunityProduct';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class DealIDFormComponent_LWC extends LightningElement {
    
    @api recordId;
    @track opptyLineItemRecord = [];
    @track opportunityLineItemName;
    @track opportunityLineItemUrl;
    @track OpporuntityLineItemDealID;

    @track columns = [
        {
            label: 'Opportunity Product Name', 
            fieldName: 'Name',  
            type: 'Text',
            editable: false 
        },
        {
            label: 'Deal ID', 
            fieldName: 'Deal_ID__c',  
            type: 'Text',
            editable: true 
        }

    ];
    
    setVisibleDataTableDealIDForm = true;
    saveDraftValues = [];
    
    
   connectedCallback(){
    this.getOpporutnityLineItemRecord();
   }


   getOpporutnityLineItemRecord(){
    getOpporutnityLineItemRecord({opporutnityId: this.recordId}).then(result => {
        this.opptyLineItemRecord = result;
    })
   }
    
   /*
   @wire(recordId)
    wiredGetOpporutnityLineItemRecord(result) {
        const { data, error } = result;
        console.log('result: ', result);
        if(data) {
            let nameUrl;
            this.opptyLineItemRecord = data.map(row => { 
                nameUrl = '/${row.Id}';
                return {...row , nameUrl} 
            })
            this.error = null;
        }
        if(error) {
            this.error = error;
            this.opptyLineItemRecord = [];
        }
    }
    */

    handleSave(event) {
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
            this.showSuccessToast();
            eval("$A.get('e.force:refreshView').fire();");
            refreshApex(this.recordId);

        }).catch(error => {
            this.showErrorToast();
            console.log('Error: ', error);
        }).finally(() => {
            this.saveDraftValues = [];
        });
    }
 
    showSuccessToast() {
        const event = new ShowToastEvent({
            title: 'Success!',
            message: 'Data Was Saved',
            variant: 'success'
            
        });
        eval("$A.get('e.force:refreshView').fire();");
        this.dispatchEvent(event);
        this.getOpporutnityLineItemRecord();
    }
}