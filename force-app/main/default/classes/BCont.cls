
public class BCont {

    @AuraEnabled(cacheable=true)
  
    public static List<Bill__c> getBillList() {
  
        return 
            [SELECT Invoice_Number__c, Balance__c, Account__r.Name
            FROM Bill__c
        ];
  
    }
  }