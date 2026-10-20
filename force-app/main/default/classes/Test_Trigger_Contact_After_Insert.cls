/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seealldata=true)
public class Test_Trigger_Contact_After_Insert {

    static testMethod void testMethod_Create_AccountLead() {
        Test.startTest();
        Account acc = new Account ();
        acc.Name ='PT.Company Uji Coba';
        acc.RecordTypeId=Label.Account_RT_Advertiser;
        acc.Account_Type__c='Advertiser';
        acc.Email__c='ujicoba@ujicom.co.id';
        acc.Phone='654321';
        acc.Converted_from_Lead__c=TRUE;
        insert acc;
        
        List<Account> ac=[SELECT id from Account LIMIT 1];
        Contact con = new Contact ();
        con.LastName='Doddy';
        con.AccountId=ac[0].id;
        con.Converted_from_Lead__c=TRUE;
        insert con;
        Test.stopTest();

    }
}