import { LightningElement, track,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class CreationCampaignOrder extends NavigationMixin(LightningElement) {
    @api recordId;
    @api buttonText;
    keyIndex = 0;
    @track itemList = [
        {
            id: 0
        }
    ];
    
    addRow() {
        ++this.keyIndex;
        var newItem = [{ id: this.keyIndex }];
        this.itemList = this.itemList.concat(newItem);
    }

    removeRow(event) {
        if (this.itemList.length >= 2) {
            this.itemList = this.itemList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
        }
    }

    handleSubmit() {
        console.log('Hello world!');
        var isVal = true;
        console.log("Hello world123!#");
        //custom
        let dateCmp = this.template.querySelector(".dateCmp");
        let enddateCmp = this.template.querySelector(".EnddateCmp");
        

        let dtValue = dateCmp.value;
        let dtendValue = enddateCmp.value;

        let tempdate = new Date(dtValue);
        let tempenddate = new Date(dtendValue);
        console.log(tempdate.getTime());
        console.log(tempenddate.getTime());

        if (tempenddate.getTime() < tempdate.getTime()) {
            console.log("Hello world321!");
            //dateCmp.setCustomValidity("Date value is false");
            
            const evt = new ShowToastEvent({
                title: 'Error creating record',
                message: 'End Campaign tidak Boleh Back Date',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }
        else{
                this.template.querySelectorAll('lightning-input-field').forEach(element => {
                isVal = isVal && element.reportValidity();
            });
            if (isVal) {
                this.template.querySelectorAll('lightning-record-edit-form').forEach(element => {
                    element.submit();
                });
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Campaign Order successfully created',
                        variant: 'success',
                    }),
                );
                // Navigate to the Account home page
                this[NavigationMixin.Navigate]({
                    type: 'standard__objectPage',
                    attributes: {
                        objectApiName: 'Order_Non_Bulk__c',
                        //recordId: recordId,
                        actionName: 'home',
                        //actionName: 'view',
                    },
                });
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: 'Please enter all the required fields',
                        variant: 'error',
                    }),
                );
            }

        }
        dateCmp.reportValidity();

        
    }

}