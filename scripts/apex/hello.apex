// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents
BillAPI.getBills();
BillBatch batch = new BillBatch();
Id batchId = Database.executeBatch(batch);
System.debug(batchId);

// string tempvar = 'Enter_your_name_here';
// System.debug('Hello World!');
// System.debug('My name is ' + tempvar);

// public static void newOpp(List<Bill__c> Bills){
//     //Set of Account Ids whcih are changed in BIll
//     set<Id> AccId = new set<Id>();
//     for(Bill__c b : Bills){
//         AccId.add(b.Account__c);
//     }

//     //Querey Open opportunities in those accountIds
//     map<Id, Opportunity> accOpenOpp = new map<Id, Opportunity>();

//     for(Opportunity opp : [SELECT Id, AccountID FROM Opportunity WHERE AccountID IN :AccId AND StageName NOT IN ('Closed Won','Closed Lost')]){
//         accOpenOpp.put(opp.AccountId, opp);
//     }

//     List<Opportunity>newOpportunity = new List<Opportunity>();

//     for(Bill__c b : Bills){
//         if(!accOpenOpp.containsKey(b.AccountId)){
//             Opportunity newOpp = new Opportunity();
//             newOpp.AccountId = b.Account__c;
//             newOpp.Amount = b.Balance__c;
//             newOpp.Name =  b.Account__c+ ' - Opportunity '+ b.Name;
//             newOpp.StageName = 'Prospecting';
//             newOpp.CloseDate = Date.today().addMonths(1);
//             newOpportunity.add(newOpp);

//         }
//     }

//     if(!newOpportunity.isEmpty()){
//         try {
//             insert newOpportunity;
//         } catch (Exception e) {
//             S
//         }
//     }

// }