public with sharing class BillBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    public List<Id> receivesBillByEmail = new List<Id>();
    public Map<Id, String> emailMap = new Map<Id, String>(); // Store Account ID and Email

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Query accounts where Bill_By_Email__c is TRUE and Email is not null
        return Database.getQueryLocator([
            SELECT Id, Email__c, Bill_By_Email__c 
            FROM Account 
            WHERE Bill_By_Email__c = TRUE 
            AND Active__c = 'YES'
            AND Email__c != NULL
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        for (Account acc : scope) {
            if (acc.Bill_By_Email__c == TRUE) {
                receivesBillByEmail.add(acc.Id);
                emailMap.put(acc.Id, acc.Email__c);  // Store email for each account
                System.debug('Account processed: ' + acc.Id + ', Email: ' + acc.Email__c);
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        if (receivesBillByEmail.isEmpty()) {
            System.debug('No accounts found for billing by email.');
            return;
        }

        // Query bills for the accounts that opted for email billing
        List<Account> accountsWithBills = [SELECT Id, (SELECT Id FROM Bills__r ORDER BY CreatedDate DESC LIMIT 1) 
                                           FROM Account WHERE Id IN :receivesBillByEmail];

        Map<Id, Id> billMap = new Map<Id, Id>();  // Map of Account ID to Bill ID
        for (Account acc : accountsWithBills) {
            if (acc.Bills__r.size() > 0) {
                billMap.put(acc.Id, acc.Bills__r[0].Id);
                System.debug('Account ' + acc.Id + ' linked to Bill ' + acc.Bills__r[0].Id);
            }
        }

        // New structure: Map of email to a list of Blob PDFs
        Map<String, List<Blob>> sendMap = new Map<String, List<Blob>>();

        for (Id accId : billMap.keySet()) {
            String email = emailMap.get(accId);
            Id billId = billMap.get(accId);
            PageReference pageRef = new PageReference('/apex/BillVFP?id=' + billId);
            Blob pdfBlob;

            try {
                pdfBlob = pageRef.getContentAsPDF();  // Attempt to generate the PDF
                System.debug('Generated PDF for Account ' + accId + ', Bill ID: ' + billId + ', Blob Size: ' + pdfBlob.size());

                if (pdfBlob != null && pdfBlob.size() > 0) {
                    // Add PDF to the existing email or create a new list if it's the first one
                    if (!sendMap.containsKey(email)) {
                        sendMap.put(email, new List<Blob>{ pdfBlob });
                    } else {
                        sendMap.get(email).add(pdfBlob);
                    }
                } else {
                    System.debug('PDF generation failed or was empty for Bill ID: ' + billId);
                }
            } catch (Exception e) {
                System.debug('Error generating PDF for Bill ID ' + billId + ': ' + e.getMessage());
            }
        }

        // Send emails for each email address, with all associated PDFs
        for (String email : sendMap.keySet()) {
            List<Blob> pdfBlobs = sendMap.get(email);
            BillEmailer.sendEmails(email, pdfBlobs);  // Modified BillEmailer to accept list of PDFs per email
        }
    }
}