// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

List<Frame__c> conList = [Select Id from Frame__c where Game__c = 'a0L7F00000sqVbPUAU' AND Frame__c > 9];
database.delete(conList, false);
Game__c gameRec = [Select Id from Game__c where Id ='a0L7F00000sqVbPUAU'];
gameRec.Total_Score__c = 111;
gameRec.Status__c = 'In Progress';
database.update(gameRec, false);

