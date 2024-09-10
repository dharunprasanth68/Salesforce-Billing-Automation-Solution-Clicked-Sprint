public with sharing class BillController {
    @AuraEnabled(cacheable=true)
    public static List<Bill__c> getBills(String searchKey) {
        String query = 'SELECT Id, Invoice_Number__c, Balance__c, Account__r.Name FROM Bill__c WHERE IsDeleted = false';

        // Add wildcard % around searchKey for partial matches
        if (String.isNotEmpty(searchKey)) {
            String wildcardSearchKey = '%' + searchKey + '%';
            query += ' AND (Invoice_Number__c LIKE :wildcardSearchKey OR Account__r.Name LIKE :wildcardSearchKey)';
        }

        // Execute the query
        return Database.query(query);
    }
}
