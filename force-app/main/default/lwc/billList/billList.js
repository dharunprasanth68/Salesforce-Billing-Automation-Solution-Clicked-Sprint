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

    @wire(getBills, { searchKey: '' })
    wiredBills({ error, data }) {
        console.log('Wired Data:', data);
        console.log('Wired Error:', error);

        if (data) {
            // Initialize allBills with the data from the wire method
            this.allBills = data.map(bill => ({
                ...bill,
                AccountName: bill.Account__r?.Name
            }));
            // Apply initial filtering based on searchKey
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
            this.billList = this.allBills.filter(bill =>
                bill.Invoice_Number__c.includes(this.searchKey) ||
                (bill.AccountName && bill.AccountName.includes(this.searchKey))
            );
        } else {
            this.billList = [...this.allBills]; // Show all bills when searchKey is empty
        }
        this.noRecordFound = this.billList.length === 0;
    }
}
