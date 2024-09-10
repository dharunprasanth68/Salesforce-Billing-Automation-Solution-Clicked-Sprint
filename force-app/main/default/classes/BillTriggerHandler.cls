public with sharing class BillTriggerHandler {
   
    // Validate that Account__c is not null
   public static void billvalidate(List<Bill__c> newBills) {
       for (Bill__c bill : newBills) {
           if (bill.Account__c == null) {
               bill.Account__c.addError('Account cannot be blank. Please ensure the Account is specified.');
           }
       }

   }

   // Populate Invoice_Number__c with a unique value if it is blank
   public static void invoicePopulate(List<Bill__c> newBills) {
       for (Bill__c bill : newBills) {
           // Check if the Invoice_Number__c field is empty
           if (String.isBlank(bill.Invoice_Number__c)) {
               // Generate a unique Invoice Number using a shortened UUID
               String uniqueInvoiceNumber = 'INV-' + UUID.randomUUID().toString().substring(0, 8);
               bill.Invoice_Number__c = uniqueInvoiceNumber;
           }
       }
   }

       public static void billOpportunities(List<Bill__c> bills) {
           // Debug to ensure trigger is running
           System.debug('BillTriggerHandler.billOpportunities invoked with bills: ' + bills);
           
           // Set to store Account Ids
           Set<Id> accountIds = new Set<Id>();
           
           // Collect Account Ids from the new Bills
           for (Bill__c bill : bills) {
               if (bill.Account__c != null) {
                   accountIds.add(bill.Account__c);
               }
           }
           
           // Debug to check the collected accountIds
           System.debug('Collected Account Ids: ' + accountIds);
           
           // Query for existing open Opportunities related to these Accounts
           Map<Id, Opportunity> accountOpenOppMap = new Map<Id, Opportunity>();
           for (Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE AccountId IN :accountIds AND StageName NOT IN ('Closed Won', 'Closed Lost')]) {
               accountOpenOppMap.put(opp.AccountId, opp);
           }
           // Query the Account records to get their names
           Map<Id, Account> accountMap = new Map<Id, Account>(
               [SELECT Id, Name FROM Account WHERE Id IN :accountIds]
           );
           
           // Debug to check if any open opportunities were found
           System.debug('Existing Open Opportunities: ' + accountOpenOppMap);
           
           // List to store new Opportunities to be created
           List<Opportunity> newOpportunities = new List<Opportunity>();
           
           // Create an Opportunity for Bills where no open Opportunity exists
           for (Bill__c bill : bills) {
               if (!accountOpenOppMap.containsKey(bill.Account__c)) {
                   Account relatedAccount = accountMap.get(bill.Account__c);
                   if (relatedAccount != null) {
                   // Prepare Opportunity record
                   Opportunity newOpp = new Opportunity();
                   newOpp.AccountId = bill.Account__c; // Link Opportunity to the Bill's Account
                   newOpp.Amount = bill.Balance__c; // Set Opportunity amount to the Bill's balance
                   newOpp.Name = relatedAccount.Name + ' - Opportunity ' + bill.Name; // Opportunity name
                   newOpp.CloseDate = Date.today().addMonths(1); // Set a close date 1 month from today
                   newOpp.StageName = 'Prospecting'; // Initial stage
                   
                   // Add to list of new Opportunities
                   newOpportunities.add(newOpp);
                   
                   // Debug to confirm Opportunity creation details
                   System.debug('Created new Opportunity: ' + newOpp);
               } else {
                   System.debug('No related Account found for Bill: ' + bill.Id);
               }
           } else {
               System.debug('Skipping Opportunity creation for AccountId: ' + bill.Account__c + ' because an open Opportunity exists.');
           }
       }

       if (!newOpportunities.isEmpty()) {
           try {
               insert newOpportunities;
               System.debug('Inserted Opportunities: ' + newOpportunities);
           } catch (Exception e) {
               System.debug('Failed to insert Opportunities: ' + e.getMessage());
           }
       } else {
           System.debug('No Opportunities to insert.');
       }
    }
    public static void updateBillWithOpportunity(List<Bill__c> bills) {
        // Set to store Account Ids to fetch newly created Opportunities
        Set<Id> accountIds = new Set<Id>();
        for (Bill__c bill : bills) {
            if (bill.Account__c != null) {
                accountIds.add(bill.Account__c);
            }
        }
    
        // Query the newly created Opportunities related to these Accounts
        Map<Id, Opportunity> accountOpenOppMap = new Map<Id, Opportunity>();
        for (Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE AccountId IN :accountIds AND StageName = 'Prospecting' ORDER BY CreatedDate DESC]) {
            accountOpenOppMap.put(opp.AccountId, opp);
        }
    
        // List to hold the bills that need to be updated
        List<Bill__c> billsToUpdate = new List<Bill__c>();
    
        // Update the Bill's Opportunity__c field with the newly created Opportunity
        for (Bill__c bill : bills) {
            if (bill.Opportunity__c == null && accountOpenOppMap.containsKey(bill.Account__c)) {
                Opportunity newOpportunity = accountOpenOppMap.get(bill.Account__c);
                Bill__c billToUpdate = new Bill__c(
                    Id = bill.Id,  // Use the Id of the current bill
                    Opportunity__c = newOpportunity.Id  // Assign the newly created Opportunity
                );
                billsToUpdate.add(billToUpdate);
            }
        }
    
        // Perform the update if there are Bills to update
        if (!billsToUpdate.isEmpty()) {
            try {
                update billsToUpdate;
                System.debug('Updated Bills with Opportunity: ' + billsToUpdate);
            } catch (Exception e) {
                System.debug('Failed to update Bills: ' + e.getMessage());
            }
        }
    }
    
    
}
