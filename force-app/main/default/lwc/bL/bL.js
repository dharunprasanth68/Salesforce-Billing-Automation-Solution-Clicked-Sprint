

import {LightningElement, wire} from 'lwc';

import getBillList from '@salesforce/apex/BCont.getBillList';

const columns = [
    { label: 'Invoice Number', fieldName: 'Invoice_Number__c' },
    { label: 'Balance', fieldName: 'Balance__c', type: 'currency' },
    { label: 'Account Name', fieldName: 'AccountName' } // Use the correct API name
];


export default class bL extends LightningElement {

    columns = columns;

    bills = [];

    @wire(getBillList)
    wiredBills({ error, data }) {
        if (data) {
            // Transform data to include AccountName at the top level
            this.bills = data.map(bill => ({
                ...bill,
                AccountName: bill.Account__r?.Name
            }));
        } else if (error) {
            // Handle error
            console.error(error);
        }
    }
}