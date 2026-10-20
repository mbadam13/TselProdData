/**
 * @description       : 
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 07-04-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   07-04-2023   Novando Utoyo Agmawan   Initial Version
**/

@isTest()
public class TH_Traffic_NB_Services_Test {
    public static testMethod void testMethodD(){
        List<Media_Seller_Product_Settings__c> List_MediaSellerProductSettings = new List<Media_Seller_Product_Settings__c>();

        Media_Seller_Product_Settings__c MediaSellerProductSettings1 = new Media_Seller_Product_Settings__c(
            Name = '01',
            CP_Name__c = 'ussd-b',
            Is_Using_CP_Name__c = true,
            Product_Code__c = 'USSD',
            Product_Name__c = 'USSD Bulk',
            Product_SFID__c = '01t2v00000Cd6RZ',
            Product_Services__c = 'Bulk',
            is_Active__c = true
        );
        List_MediaSellerProductSettings.add(MediaSellerProductSettings1);

        Media_Seller_Product_Settings__c MediaSellerProductSettings2 = new Media_Seller_Product_Settings__c(
            Name = '02',
            CP_Name__c = null,
            Is_Using_CP_Name__c = false,
            Product_Code__c = 'IVR',
            Product_Name__c = 'BULK (IVR)',
            Product_SFID__c = '01t2v00000Cdy5s',
            Product_Services__c = 'Bulk',
            is_Active__c = true
        );
        List_MediaSellerProductSettings.add(MediaSellerProductSettings2);

        Test.startTest();

        insert List_MediaSellerProductSettings;

        Map<String,Media_Seller_Product_Settings__c> Map_MediaSellerProductSetting = TH_Traffic_NB_Services.getMediaSellerProductSettingByCpName();
        
        Test.stopTest();
    }
}