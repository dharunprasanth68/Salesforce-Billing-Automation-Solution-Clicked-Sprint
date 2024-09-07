import { LightningElement, wire, track } from 'lwc';
import getBills from '@salesforce/apex/BillController.getBills';

export default class BillList extends LightningElement {
  @track bills;
  @track searchKey = '';
  @track error;

  @wire(getBills, { searchKey: '$searchKey' })
  wiredBills({ error, data }) {
    if (data) {
      this.bills = data;
    } else if (error) {
      console.error('Error retrieving bills', error);
    }
  }

  handleSearch(event) {
    const searchKey = event.target.value;
    this.debounce(() => {
      this.searchKey = searchKey;
    }, 300);
  }

  debounce(func, delay) {
    let timeout;
    return (...args) => {
      clearTimeout(timeout);
      timeout = setTimeout(() => func(...args), delay);
    };
  }
}
