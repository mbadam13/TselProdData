/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 04-29-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   17/04/2025   Syaiful Syafani   Initial Version
 * 2.0   10/02/2025   Syaiful Syafani   add method getOrderNumber
 * 3.0   14/03/2025   Syaiful Syafani   change method getOrderItems -> using criteria by pic product
 * 4.0   28/04/2025   M B Adam          Add logic change metode get PIC Product from Single to Multiple
 
 * **/
public with sharing class UsageTemplateController_V2 {
    
   // ganti menjadi V2 
    // @AuraEnabled(cacheable=true)
    // public static string getOrderItems(String orderId){
    //     String currentUser = UserInfo.getName();
    //     String userName;

    //     // get custom setting
    //     PIC_Product_Config__c iptvProductConfig         = PIC_Product_Config__c.getValues('IPTV');
    //     PIC_Product_Config__c messagingProductConfig    = PIC_Product_Config__c.getValues('Messaging');
    //     PIC_Product_Config__c ownMediaProductConfig     = PIC_Product_Config__c.getValues('Own Media');
    //     PIC_Product_Config__c thirdPartyProductConfig   = PIC_Product_Config__c.getValues('Third Party Media');

    //     // set variable
    //     String downloaderIPTV       = iptvProductConfig.Downloader__c;
    //     String downloaderMessaging  = messagingProductConfig.Downloader__c;
    //     String downloaderOwnMedia   = ownMediaProductConfig.Downloader__c;
    //     String downloaderThirdParty = thirdPartyProductConfig.Downloader__c;

    //     // check condition and stamp user
    //     if (currentUser.contains(downloaderIPTV) && downloaderIPTV != null) { // iptv
    //         userName = iptvProductConfig.PIC_Product__c;
    //     } else if (currentUser.contains(downloaderMessaging) && downloaderMessaging != null) { // messaging 
    //         userName = messagingProductConfig.PIC_Product__c;
    //     } else if (currentUser.contains(downloaderOwnMedia) && downloaderOwnMedia != null) { // own media
    //         userName = ownMediaProductConfig.PIC_Product__c;
    //     } else if (currentUser.contains(downloaderThirdParty) && downloaderThirdParty != null) { // third party media
    //         userName = thirdPartyProductConfig.PIC_Product__c;
    //     } else if (Test.isRunningTest()) {
    //         userName = thirdPartyProductConfig.PIC_Product__c;
    //     } else {
    //         userName = currentUser;
    //     }
    //     System.debug('== userName: '+ userName);

    //     // query to order item by param OrderId and PIC Product Name
    //     List<OrderItem> orderItemList = [
    //         SELECT
    //             Id,
    //             Campaign_ID__c,
    //             OrderId,
    //             Order.OrderNumber
    //         FROM
    //             OrderItem
    //         WHERE
    //             OrderId =: orderId AND PIC_Product__c = :userName
    //     ];
    //     System.debug('== orderItemList: '+ orderItemList);
    //     return generateCSVContent(orderItemList);
    // }

    // @AuraEnabled(cacheable=true)
    // public static string getOrderNumber(String orderId){ // new - 10 feb 2025
    //     Order orderRec = [SELECT OrderNumber FROM Order WHERE Id = :orderId LIMIT 1];

    //     String orderNumber = orderRec.OrderNumber;
    //     System.debug('== orderNumber: '+ orderNumber);
    //     return orderNumber;
    // }

    // private static String generateCSVContent(List<OrderItem> orderItemList){
    //     String csvContent = 'Date,Campaign_Id,Usage\n';

    //     for (OrderItem orderItemRec : orderItemList) {
    //         String formattedDate = String.valueOf(Date.today().day()) + '/'
    //                             + String.valueOf(Date.today().month()) + '/'
    //                             + String.valueOf(Date.today().year());

    //         String resultFormattedDate = formattedDate != null ? formattedDate : '';
    //             csvContent += resultFormattedDate + ',' 
    //                 + orderItemRec.Campaign_ID__c + ',' 
    //                 + '\n';
    //     }
    //     return csvContent;
    // }
    // Versi 2 
    @AuraEnabled(cacheable=true)
    public static string getOrderItems(String orderId) {
        Id currentUserProfileID = UserInfo.getProfileId();
        String currentUser = UserInfo.getName();
        String userName;
        List<OrderItem> orderItemList;

        Profile profileRec = [SELECT Id, Name FROM Profile WHERE Id = :currentUserProfileID LIMIT 1];
        String currentUserProfileName = profileRec.Name;

        // get custom settings
        PIC_Product_Config__c iptvProductConfig         = PIC_Product_Config__c.getValues('IPTV');
        PIC_Product_Config__c messagingProductConfig    = PIC_Product_Config__c.getValues('Messaging');
        PIC_Product_Config__c ownMediaProductConfig     = PIC_Product_Config__c.getValues('Own Media');
        PIC_Product_Config__c thirdPartyProductConfig   = PIC_Product_Config__c.getValues('Third Party Media');

        // set variables
        String downloaderIPTV       = iptvProductConfig.PIC_Downloader__c;
        String downloaderMessaging  = messagingProductConfig.PIC_Downloader__c;
        String downloaderOwnMedia   = ownMediaProductConfig.PIC_Downloader__c;
        String downloaderThirdParty = thirdPartyProductConfig.PIC_Downloader__c;

        // check condition and stamp user
        if (isUserInDownloaderList(currentUser, downloaderIPTV)) { // IPTV
            userName = iptvProductConfig.PIC_Product__c;
        } else if (isUserInDownloaderList(currentUser, downloaderMessaging)) { // Messaging
            userName = messagingProductConfig.PIC_Product__c;
        } else if (isUserInDownloaderList(currentUser, downloaderOwnMedia)) { // Own Media
            userName = ownMediaProductConfig.PIC_Product__c;
        } else if (isUserInDownloaderList(currentUser, downloaderThirdParty)) { // Third Party Media
            userName = thirdPartyProductConfig.PIC_Product__c;
        } else if (Test.isRunningTest()) { // handle test class
            userName = thirdPartyProductConfig.PIC_Product__c;
        } else {
            userName = currentUser; // stamp to system admin
        }
        System.debug('== userName: ' + userName);

        // query to order item by param OrderId and PIC Product Name
        if (currentUserProfileName.contains('System Admin')) {
            // query by system admin
            orderItemList = [
                SELECT Id, Campaign_ID__c, OrderId, Order.OrderNumber
                FROM OrderItem
                WHERE OrderId = :orderId
            ];
        } else {
            // query by pic product
            orderItemList = [
                SELECT Id, Campaign_ID__c, OrderId, Order.OrderNumber
                FROM OrderItem
                WHERE OrderId = :orderId AND PIC_Product__c = :userName
            ];
        }
        
        System.debug('== orderItemList: ' + orderItemList);
        return generateCSVContent(orderItemList);
    }

    // Helper untuk cek apakah currentUser ada di list downloader
    private static Boolean isUserInDownloaderList(String currentUser, String downloaderListStr) {
        if (downloaderListStr == null) return false;

        // Support delimiter koma ',' atau titik koma ';'
        List<String> downloaderList = new List<String>();
        if (downloaderListStr.contains(';')) {
            downloaderList = downloaderListStr.split(';');
        } else if (downloaderListStr.contains(',')) {
            downloaderList = downloaderListStr.split(',');
        } else {
            downloaderList.add(downloaderListStr); // single value
        }

        for (String downloader : downloaderList) {
            if (currentUser.contains(downloader.trim())) {
                return true;
            }
        }
        return false;
    }

    @AuraEnabled(cacheable=true)
    public static string getOrderNumber(String orderId) { // new - 10 feb 2025
        Order orderRec = [SELECT OrderNumber FROM Order WHERE Id = :orderId LIMIT 1];
        String orderNumber = orderRec.OrderNumber;
        System.debug('== orderNumber: ' + orderNumber);
        return orderNumber;
    }

    private static String generateCSVContent(List<OrderItem> orderItemList) {
        String csvContent = 'Date,Campaign_Id,Usage\n';

        for (OrderItem orderItemRec : orderItemList) {
            String formattedDate = String.valueOf(Date.today().day()) + '/'
                                 + String.valueOf(Date.today().month()) + '/'
                                 + String.valueOf(Date.today().year());

            String resultFormattedDate = formattedDate != null ? formattedDate : '';
            csvContent += resultFormattedDate + ',' 
                        + orderItemRec.Campaign_ID__c + ',' 
                        + '\n';
        }
        return csvContent;
    }


}