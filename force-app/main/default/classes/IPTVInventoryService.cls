/**
 * @description       : 
 * @author            : Syaiful Syafani
 * @group             : 
 * @last modified on  : 07-31-2024
 * @last modified by  : Syaiful Syafani
**/
public with sharing class IPTVInventoryService {
    public static String[] productInventoryConvert(String productInventory, Integer maxLength){
        List<String> inventoryList = new List<String>{'','','','',''};

        List<String> cutInventoryList = productInventory.split(';');
        
        String tmp='';
        String step = '1';

        for (String kata : cutInventoryList) {
            // == step 1 ==
            if (step == '1') {
                tmp = inventoryList[0] + ' ' + kata;
                tmp = tmp.trim();

                if (tmp.length() < maxLength) {
                    inventoryList[0] = tmp;
                } else {
                  step = '2';  
                }
            }

            // == step 2 ==
            if (step == '2') {
                tmp = inventoryList[1] + ' ' + kata;
                tmp = tmp.trim();

                if (tmp.length() < maxLength) {
                    inventoryList[1] = tmp;
                } else {
                    step = '3';
                }
            }

            // == step 3 ==
            if (step == '3') {
                tmp = inventoryList[2] + ' ' + kata;
                tmp = tmp.trim();

                if (tmp.length() < maxLength) {
                    inventoryList[2] = tmp;
                } else {
                    step = '4';
                }
            }

            // == step 4 ==
            if (step == '4') {
                tmp = inventoryList[3] + ' ' + kata;
                tmp = tmp.trim();

                if (tmp.length() < maxLength) {
                    inventoryList[3] = tmp;
                } else {
                    step = '5';
                }
            }

            // == step 5 ==
            if (step == '5') {
                tmp = inventoryList[4] + ' ' + kata;
                tmp = tmp.trim();

                if (tmp.length() < maxLength) {
                    inventoryList[4] = tmp;
                } else {
                    step = '6';
                }
            }
        }

        return inventoryList;
    }

    public static void updateProductInventory(Set<Id> inventoryIds) {
        System.debug('==inventoryIds: '+ inventoryIds);

        List<IPTV_Inventory__c> inventoryList = [
            SELECT 
                Id, 
                Product_Inventory__c, 
                Inventories__c, 
                Inventories_2__c, 
                Inventories_3__c, 
                Inventories_4__c, 
                Inventories_5__c
            FROM IPTV_Inventory__c
            WHERE Id In :inventoryIds
        ];

        System.debug('==inventoryList: '+ inventoryList);

        List<IPTV_Inventory__c> updateInventoryList = new List<IPTV_Inventory__c>();
        for (IPTV_Inventory__c invRec : inventoryList) {
            List<String> productInventoryList = new List<String>{invRec.Product_Inventory__c};
            System.debug('==productInventoryList: '+ productInventoryList);
            // productInventoryList.remove(null);

            String allProductInv = String.join(productInventoryList, ',');
            System.debug('==allProductInv: '+ allProductInv);

            List<String> productInvenotryList = new List<String>();
            productInvenotryList = productInventoryConvert(allProductInv, 255);

            invRec.Inventories__c = productInvenotryList[0];
            invRec.Inventories_2__c = productInvenotryList[1];
            invRec.Inventories_3__c = productInvenotryList[2];
            invRec.Inventories_4__c = productInvenotryList[3];
            invRec.Inventories_5__c = productInvenotryList[4];

            updateInventoryList.add(invRec);
        }

        System.debug('==updateInventoryList: '+ updateInventoryList);
        if (!updateInventoryList.isEmpty()) {
            update updateInventoryList;
        }
    }
}