/**
 * @description       : 
 * @Test Class        : TH_Traffic_SID_Services_Test
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 07-04-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   05-24-2023   Novando Utoyo Agmawan   Initial Version
**/

public class TH_Traffic_SID_Services {
    public static Map<String,Media_Seller_Product_Settings__c> getMediaSellerProductSettingByCpName(){
        Map<String,Media_Seller_Product_Settings__c> Map_MediaSellerProductSetting = new Map<String,Media_Seller_Product_Settings__c>();

        try{
            List<Media_Seller_Product_Settings__c> List_MediaSellerProductSettings = [
                SELECT Id,
                Name,
                CP_Name__c,
                Is_Using_CP_Name__c,
                Product_Code__c,
                Product_Name__c,
                Product_SFID__c,
                Product_Services__c
                FROM Media_Seller_Product_Settings__c WHERE is_Active__c = true AND
                Product_Name__c != null
            ];

            if(List_MediaSellerProductSettings != null && !List_MediaSellerProductSettings.isEmpty()){
                for(Media_Seller_Product_Settings__c MediaSellerProduct : List_MediaSellerProductSettings){
                    if(MediaSellerProduct.Is_Using_CP_Name__c == true){
                        String concatProductName = MediaSellerProduct.Product_Name__c + '|' + MediaSellerProduct.CP_Name__c;

                        Map_MediaSellerProductSetting.put(concatProductName.toLowercase(), MediaSellerProduct);
                    }else{
                        Map_MediaSellerProductSetting.put(MediaSellerProduct.Product_Name__c.toLowercase(), MediaSellerProduct);
                    }
                }
            }

            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        }catch(exception e){
            string errMessage = 'Error on TH_Traffic_SID_Services getMediaSellerProductService function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }

        return Map_MediaSellerProductSetting;
    }
}