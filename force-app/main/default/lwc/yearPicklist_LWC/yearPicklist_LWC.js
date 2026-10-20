import { LightningElement, wire, track, api } from 'lwc';
import getYearPicklistValues from '@salesforce/apex/YearPicklistController.getYearPicklistValues';

export default class YearPicklist_LWC extends LightningElement {

    @track yearOptions = [];
    @track selectedYear = '';
    @api yearData;

    @wire(getYearPicklistValues)
    wiredYears({ error, data }) {
        if (data) {
            this.yearOptions = data.map(year => ({ label: year, value: year }));
        } else if (error) {
            // Handle error
        }
    }

    handleChange(event) {

        this.yearData= event.detail.value;
       
    }
}