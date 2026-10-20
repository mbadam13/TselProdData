/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 26/03/2025
 * @last modified by  : Syaiful Syafani 
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   26/03/2025   Syaiful Syafani   Initial Version
**/
@isTest
public with sharing class LOBTriggerTest {
    @isTest
    static void testCreateLOB() {
        LOB__c lobRec = new LOB__c(
            Name = 'Agency',
            Active__c = true
        );

        Test.startTest();
            insert lobRec;
        Test.stopTest();
    }
}