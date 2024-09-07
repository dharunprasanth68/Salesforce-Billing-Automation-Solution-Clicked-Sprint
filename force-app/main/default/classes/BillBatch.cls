public with sharing class BillBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public List<Id> receivesBillByEmail = new List<Id>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // String query = 'SELECT Id, Bill_By_Email__c FROM Account WHERE Bill_By_Email__c = TRUE AND Active__c = \'YES\'';
        return Database.getQueryLocator([SELECT Id, Bill_By_Email__c FROM Account WHERE Bill_By_Email__c = TRUE AND Active__c = 'YES']);
    }
    

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        // This method processes the queried records. It prepares a list of account IDs (this.receivesBillByEmail)
        // to carry over to the finish method. We do this by iterating over 'scope' and checking whether
        // Bill_By_Email__c is TRUE. This method will also call our BillAPI.getBills() method.
        // Learn more about Batch Apex: https://trailhead.salesforce.com/content/learn/modules/asynchronous_apex/async_apex_batch
        for (Account acc : scope) {
            if (acc.Bill_By_Email__c == TRUE) {
                receivesBillByEmail.add(acc.Id);
            }
        }
        // Example of calling an external API (BillAPI.getBills()) - use callouts if needed.
    }
    

    public void finish(Database.BatchableContext bc) {
        // This is the final method of the class, called after all processing in the start and execute methods is complete.
        // We use this method to send an email to each customer in the receivesBillByEmail list.

        // First, query for the recently created bills for each account using a nested query:
        // [SELECT Id, (SELECT Id FROM Bills__r ORDER BY CreatedDate DESC) FROM Account WHERE Id IN :this.receivesBillByEmail]

        // Next, iterate over the results of this query and associate the ID of the most recent bill with the
        // corresponding account ID in a Map<Id, Id> called billMap, using the .put(Id, Id) method of the Map class.
        // Learn more about Maps: https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_methods_system_map.htm

        // Create a Map<Id, String> called emailMap, where we'll hold the Account ID and account email.

        // Prepare to call our BillEmailer.sendEmails(Map<String, Blob> emailsWithBills) method.
        // The String in the map, called sendMap, will be the Account.Email__c field, and the Blob will be the PDF attachment.

        // Generate a PDF for each bill ID using:
        // PageReference pageRef = new PageReference('/apex/BillVFP?id=' + [BILLID]);
        // Blob pdfBlob = pageRef.getContentAsPDF();
        // You'll need to use the .get() method of the Map class to retrieve values.

        // Finally, call our BillEmailer.sendEmails(sendMap) method. This method is VOID, so there will be no return value.
        // Learn more about generating PDFs: https://developer.salesforce.com/docs/atlas.en-us.pages.meta/pages/pages_controller_sosc_output_pdf.htm

        Map<Id, Id> billMap = new Map<Id, Id>();
        Map<Id, String> emailMap = new Map<Id, String>();
    
        // Query the most recent bills for the accounts including Email__c
        List<Account> accountsWithBills = [SELECT Id, Email__c, (SELECT Id FROM Bills__r ORDER BY CreatedDate DESC LIMIT 1) FROM Account WHERE Id IN :receivesBillByEmail];
    
        // Debug: Check the query results
        System.debug('Accounts with Bills: ' + accountsWithBills);
    
        for (Account acc : accountsWithBills) {
            if (acc.Bills__r != null && acc.Bills__r.size() > 0) {
                billMap.put(acc.Id, acc.Bills__r[0].Id);  // Store the latest bill ID
                emailMap.put(acc.Id, acc.Email__c);       // Store the email for each account
            }
        }
    
        // Debug: Check the contents of billMap and emailMap
        System.debug('Bill Map: ' + billMap);
        System.debug('Email Map: ' + emailMap);
    
        Map<String, Blob> sendMap = new Map<String, Blob>();
        for (Id accId : billMap.keySet()) {
            Id billId = billMap.get(accId);
            String email = emailMap.get(accId);
            
            // Generate PDF for each bill
            PageReference pageRef = new PageReference('/apex/BillVFP?id=' + billId);
            Blob pdfBlob = pageRef.getContentAsPDF();
    
            // Debug: Check the generated PDF blob
            System.debug('Generated PDF for Bill ID ' + billId + ': ' + pdfBlob);
    
            sendMap.put(email, pdfBlob);  // Map email to PDF Blob
        }
    
        // Debug: Check the contents of sendMap before sending emails
        System.debug('Send Map: ' + sendMap);
    
        // Call BillEmailer to send the emails
        BillEmailer.sendEmails(sendMap);
    
        // Debug: Confirm that emails have been sent
        System.debug('Emails sent');
    }
}