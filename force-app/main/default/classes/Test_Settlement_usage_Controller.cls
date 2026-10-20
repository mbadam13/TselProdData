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
public class Test_Settlement_usage_Controller {

    static String strData = 'Date,Campaign_id,Usage\n 04/02/2020,'+System.Label.test_campaign_id+',100\n 998444,'+System.Label.test_campaign_id+',200';  
    
   

    public static String[] csvFileLines;
    public static Blob csvFileBody;

  

    static testmethod void testfileuploadNegative(){
        Test.startTest();       
        csvFileBody = Blob.valueOf(strData);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 

        Settlement_usage_Controller importData = new Settlement_usage_Controller();
        importData.importCSVFile();
        Test.stopTest();
    }
    
    
    static testmethod void testfileupload(){
        Test.startTest();       
        csvFileBody = Blob.valueOf(strData);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 

        Settlement_usage_Controller importData = new Settlement_usage_Controller();
        importData.csvFileBody = csvFileBody;
        importData.importCSVFile();
        //importData.insertCSVFile();
        Test.stopTest();
    } 

    @isTest
    private static void test_Alex() {
        // Test data setup
        List<OrderItem> orderItems = [SELECT Id, Campaign_ID__c, PIC_Product__c 
        FROM OrderItem 
        WHERE PIC_Product__c = 'Alex Soelistyo' ORDER BY CreatedDate LIMIT 1];

        String csvAlexHeader = 'Date,Campaign_id,Usage\n';
        String csvAlex = '04/02/2020,'+orderItems[0].Campaign_ID__c+',100\n 998444,'+orderItems[0].Campaign_ID__c+',200';
    
        // Actual test
        Test.startTest();
        csvFileBody = Blob.valueOf(csvAlexHeader+csvAlex);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 

        Settlement_usage_Controller importData = new Settlement_usage_Controller();
        importData.csvFileBody = csvFileBody;
        importData.importCSVFile();
        Test.stopTest();
    
        // Asserts
    }
}