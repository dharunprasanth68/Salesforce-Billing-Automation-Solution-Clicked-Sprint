public with sharing class BillController {
    @AuraEnabled(cacheable=true)
    public static List<Bill__c> getBills(String searchKey) {
        String query = 'SELECT Id, Invoice_Number__c, Balance__c, Account__r.Name FROM Bill__c WHERE IsDeleted = false';

        // Filter by searchKey if provided
        if (String.isNotEmpty(searchKey)) {
            query += ' AND (Invoice_Number__c LIKE :searchKey OR Account__r.Name LIKE :searchKey)';
        }

        // Execute the query
        return Database.query(query);
    }
}
