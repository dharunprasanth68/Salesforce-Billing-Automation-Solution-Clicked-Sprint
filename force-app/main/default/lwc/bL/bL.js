import { LightningElement, track, wire } from 'lwc';
import getBills from '@salesforce/apex/BillController.getBills';

const columns = [
    { label: 'Invoice Number', fieldName: 'Invoice_Number__c' },
    { label: 'Balance', fieldName: 'Balance__c', type: 'currency' },
    { label: 'Account Name', fieldName: 'AccountName' }
];

export default class BillList extends LightningElement {
    columns = columns;
    @track searchKey = '';
    @track billList = [];
    @track allBills = [];
    @track error;
    @track noRecordFound = false;
    delayFilter;

    @wire(getBills, { searchKey: '$searchKey' })
wiredBills({ error, data }) {
    if (data) {
        // Ensure that each bill has Account__r and relevant fields
        this.allBills = data.map(bill => ({
            ...bill,
            AccountName: bill.Account__r?.Name || ''  // Fallback to empty string if no Account Name
        }));
        this.filterBills();
    } else if (error) {
        this.error = error;
        this.billList = [];
        this.noRecordFound = true;
    }
}

    handleSearch(event) {
        this.searchKey = event.target.value;
        this.debounceFilter();
    }

    debounceFilter() {
        clearTimeout(this.delayFilter);
        this.delayFilter = setTimeout(() => {
            this.filterBills();
        }, 300);
    }

    filterBills() {
        if (this.searchKey) {
            this.billList = this.allBills.filter(bill => {
                // Ensure both fields are valid strings before searching
                const invoiceNumber = bill.Invoice_Number__c ? bill.Invoice_Number__c.toLowerCase() : '';
                const accountName = bill.AccountName ? bill.AccountName.toLowerCase() : '';
                const searchKeyLower = this.searchKey.toLowerCase();
    
                // Return true if the searchKey is found in either field
                return invoiceNumber.includes(searchKeyLower) || accountName.includes(searchKeyLower);
            });
        } else {
            this.billList = [...this.allBills];  // Show all bills when searchKey is empty
        }
        this.noRecordFound = this.billList.length === 0;
    }
    
}
