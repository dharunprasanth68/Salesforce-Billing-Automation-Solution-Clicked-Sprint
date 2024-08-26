public with sharing class BillAPI {
    public static void getBills() {

        // Step 1: Create an HttpRequest object and set the endpoint and method.
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://my-json-server.typicode.com/grizzleevelyn/231017_dev_clicked/db');
        req.setMethod('GET');
        /* 
        Start by creating an HttpRequest object and set the endpoint and method.
        Endpoint: https://my-json-server.typicode.com/walters954/clicked-intro-development-server/bills
        Method: GET
        Learn more about HTTPRequest: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_restful_http_httprequest.htm
        */

        // Step 2: Send the HTTP request and get the response
        HTTP http = new HTTP();
        HttpResponse res = http.send(req);

        // Step 3: Deserialize the JSON response into a Wrapper class object
        BillsResponseWrapper responseWrapper = (BillsResponseWrapper) JSON.deserialize(res.getBody(), BillsResponseWrapper.class);

        // Step 4: Create a list to hold the bills we will insert into Salesforce.
        List<Bill__c> newBills = new List<Bill__c>();

        // Step 5: Query for active accounts (Active__c = 'Yes').
        Map<String, Id> activeAccountMap = new Map<String, Id>();
        List<Account> activeAccounts = [SELECT Id, Name FROM Account WHERE Active__c = 'Yes'];

        // Step 6: Create a map to hold active account names and their IDs.
        for (Account acc : activeAccounts) {
            activeAccountMap.put(acc.Name, acc.Id);
        }

        // Step 7: Iterate over the list of BillWrapper objects and create new Bill__c records.
        for (BillWrapper bw : responseWrapper.bills) {
            if (activeAccountMap.containsKey(bw.accountName)) {
                Bill__c newBill = new Bill__c();
                newBill.Account__c = activeAccountMap.get(bw.accountName);  // Link to Account by Name
                newBill.Balance__c = Decimal.valueOf(bw.balance.replace('$', ''));  // Convert balance to Decimal
                newBill.Invoice_Number__c = bw.billId;  // Assuming Bill_Number__c is a custom field
                
                newBills.add(newBill);
            }
        }

        // Step 8: Finally, insert the new bills list (DML operation).
        if (!newBills.isEmpty()) {
            insert newBills;
        }
    }

    // Wrapper class for the entire JSON response
    public class BillsResponseWrapper {
        public List<BillWrapper> bills;
    }

    // Wrapper class to represent the structure of each bill in the JSON response
    public class BillWrapper {
        public String billId;
        public String accountName;
        public String balance;
    }
}
