/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-30-2024
 * @last modified by  : Syaiful Syafani
**/
public with sharing class LeadService {
    public static List<Lead> getLeadDuplicateParams(String LegalName) {
        String Legal = '%'+ LegalName + '%';

        List<Lead> leadList = [
            SELECT Id, Legal_Name__c
            FROM Lead
            WHERE Legal_Name__c LIKE :Legal
        ];

        return leadList;
    }
}