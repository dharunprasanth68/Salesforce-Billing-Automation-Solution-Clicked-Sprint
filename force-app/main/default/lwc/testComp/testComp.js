import { LightningElement, api, wire } from 'lwc';
import getBills from '@salesforce/apex/BillController.getBills';

export default class TestComponent extends LightningElement {
    @api recordId = '001ak00000UbsDTAAZ'; // Test recordId for validation
    @wire(getBills, { searchKey: '', recId: '$recordId' })
    connectedCallback() {
        console.log('TestComponent initialized');
    }
    wiredBills({ error, data }) {
        console.log('Wired Data:', data);
        console.log('Wired Error:', error);
    }
}
