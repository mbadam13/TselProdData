/**
 * @description       : 
 * @author            : M B Adam 
 * @group             : 
 * @last modified on  : 07-23-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest(seealldata=true)
public  class Settlement_usage_Controller_V2_Test {
    static String strDigital = 'Date,Campaign_id,Usage\n 04/02/2020,'+System.Label.test_campaign_id+',100\n 998444,'+System.Label.test_campaign_id+',200';  
    
     static String strTV = 'No MO Item,IPTV Channel,Product Name,House Number,Brand House Number,Versi House Number,Date(YYYY-MM-DD),No,Broadcast time, Note \n'+'TSEL/TMS0000015/Admin TV Ads/7/2024/8,AllPlay.ent,TVC PLATINUM (Regular) 120 AllPlay.ent,CRHTO0101923,Toyota,Toyota Power Ranger,2024-07-12,1,10:21:10 PM,test Data  \n';  

    public static String[] csvFileLines;
    public static Blob csvFileBody;

    static testmethod void testfileuploadDigital(){
        Test.startTest();       
        csvFileBody = Blob.valueOf(strDigital);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 

        Settlement_usage_Controller_V2 importData = new Settlement_usage_Controller_V2();
        importData.csvFileBody = csvFileBody;
        importData.importCSVFileDigital();
        //importData.insertCSVFile();
        Test.stopTest();
    } 

    static testmethod void testfileuploadNegativeDigital(){
        Test.startTest();       
        csvFileBody = Blob.valueOf(strDigital);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 

        Settlement_usage_Controller_V2 importData = new Settlement_usage_Controller_V2();
        importData.importCSVFileDigital();
        Test.stopTest();
    }
    
    
     static testmethod void testfileuploadTV(){
        Test.startTest();       
        csvFileBody = Blob.valueOf(strTV);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 

        Settlement_usage_Controller_V2 importData = new Settlement_usage_Controller_V2();
        importData.csvFileBody = csvFileBody;
        importData.importCSVFileTV();
        //importData.insertCSVFile();
        Test.stopTest();
    } 

    static testmethod void testfileuploadNegativeTV(){
        Test.startTest();       
        csvFileBody = Blob.valueOf(strTV);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 

        Settlement_usage_Controller_V2 importData = new Settlement_usage_Controller_V2();
        importData.importCSVFileTV();
        Test.stopTest();
    }
}