/**
 * @description       : 
 * @Test Class        : Test_TH_Traffic_NB_TriggerHandler
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 07-11-2023
 * @last modified by  : Novando Utoyo Agmawan
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   05-23-2023   Novando Utoyo Agmawan   Initial Version
**/

public class TH_Traffic_NB_TriggerHandler{

	public static void beforeInsertHandler(list<Traffic_Non_Bulk__c > lstTrafficTargeted){
        try{
			// ----dep -start
            List<Usage_Traffic_Media_Seller__c> utmslist = [
                SELECT Id, 
                Name, 
                Unique_ID__c 
                FROM Usage_Traffic_Media_Seller__c 
                WHERE Traffic_Type__c = 'Non Bulk' AND (date__c = THIS_YEAR OR date__c = LAST_YEAR)
            ];

            system.debug('*** utmslist = ' + utmslist.size() + ' | ' + utmslist);

            Map<String,Usage_Traffic_Media_Seller__c> map_uniqueId_ustm = new Map<String,Usage_Traffic_Media_Seller__c>();
            for(Usage_Traffic_Media_Seller__c utms : utmslist){
                map_uniqueId_ustm.put(utms.Unique_ID__c, utms);
            }
            system.debug('*** map_uniqueId_ustm = ' + map_uniqueId_ustm.size() + ' | ' + map_uniqueId_ustm);
            // ----dep -end,
            
            
            Map<String,Media_Seller_Product_Settings__c> getMediaSellerProductSettingByCpName = TH_Traffic_NB_Services.getMediaSellerProductSettingByCpName();

            List<Media_Seller_Mapping_Settings__c> List_MediaSellerMappingSettings = AppUtils.getListMediaSellerMapping();

            list<Monthly_Discount_Inventory_Media_Seller__c> List_MonthlyDiscountInventoryMediaSeller = AppUtils.getListMonthlyDiscountInventoryMediaSeller();

             //------- Map Setup brand using special prices --------      
             List<Special_Price_Whitelist__c> spwList = [
                SELECT id, 
                Active__c, 
                CP_Name_SID__c, 
                Product__c,
                Brand__c, 
                Product__r.Product_Name_MS__c, 
                Name 
                FROM Special_Price_Whitelist__c 
                WHERE Active__c = TRUE
            ]; 
            system.debug('*** spwList = ' + spwList.size() + ' | ' + spwList);         
            
            Map<String, Special_Price_Whitelist__c> map_spwUnique_spwRec = new Map <String, Special_Price_Whitelist__c>();
            for(Special_Price_Whitelist__c spw : spwList){
                map_spwUnique_spwRec.put(spw.CP_Name_SID__c, spw);
            }
            system.debug('*** map_spwUnique_spwRec = ' + map_spwUnique_spwRec.size() + ' | ' + map_spwUnique_spwRec);
            // ----- end
            
            set<id> set_traffic_productIds = new set<id>();

            Set<Usage_Traffic_Media_Seller__c> Set_utmsUpdate = new Set<Usage_Traffic_Media_Seller__c>();

            for (Traffic_Non_Bulk__c myTraffic : lstTrafficTargeted){  
                if(getMediaSellerProductSettingByCpName != null && !getMediaSellerProductSettingByCpName.isEmpty()){
                    if(getMediaSellerProductSettingByCpName.get(myTraffic.Campaign_Type__c.toLowercase()) != null){
                        set_traffic_productIds.add(getMediaSellerProductSettingByCpName.get(myTraffic.Campaign_Type__c.toLowercase()).Product_SFID__c);
                    }
                }
            }

            map<string, Product2> Map_traffic_product = new map<string, Product2>();

            if(set_traffic_productIds != null && !set_traffic_productIds.isEmpty()){
                List<Product2> myprods = [
                    SELECT id,
                    name,
                    List_Price__c 
                    FROM Product2 
                    WHERE id IN: set_traffic_productIds
                ];

                if(myprods != null && !myprods.isEmpty()){
                    for(Product2 myprod : myprods){
                        Map_traffic_product.put(myprod.id, myprod);
                    }
                }
            }


            for (Traffic_Non_Bulk__c myTraffic : lstTrafficTargeted){                   
                Decimal advanceProfilingPrice = decimal.valueOf(Label.AP_Price);
                myTraffic.Advance_Profiling_Price__c = advanceProfilingPrice;
                
                //---TNB tanpa ONB--- Start
                system.debug('name' + myTraffic.CP_Name__c );

                if(List_MediaSellerMappingSettings != null && !List_MediaSellerMappingSettings.isEmpty()){
                    System.debug('List_MediaSellerMappingSettings: ' + List_MediaSellerMappingSettings);
                    if(String.isNotBlank(myTraffic.CP_Name__c)){
                        for(Media_Seller_Mapping_Settings__c MediaSellerMappingSettings :List_MediaSellerMappingSettings){
                            string cpname = myTraffic.CP_Name__c.toLowercase();
                            System.debug('MediaSellerMappingSettings: ' + MediaSellerMappingSettings);
                            System.debug('myTraffic.CP_Name__c: ' + myTraffic.CP_Name__c);
                            System.debug('myTraffic.CP_Name__c: ' + myTraffic.CP_Name__c + 'MediaSellerMappingSettings.Key__c: ' + MediaSellerMappingSettings.Key__c);
                            if(cpname.Contains(MediaSellerMappingSettings.Key__c)){
                                System.debug('in condition 1');
                                myTraffic.user_id__c = MediaSellerMappingSettings.Media_Seller_SFID__c;
                            }
                        }
                    }
                }

                string productSFID = '';
                string productServices = '';
                string productCode = '';

                if(getMediaSellerProductSettingByCpName != null && !getMediaSellerProductSettingByCpName.isEmpty()){
                    System.debug('myTraffic.Campaign_Type__c: ' + myTraffic.Campaign_Type__c);
                    if(getMediaSellerProductSettingByCpName.get(myTraffic.Campaign_Type__c.toLowercase()) != null){
                        System.debug('getMediaSellerProductSettingByCpName: ' + json.serialize(getMediaSellerProductSettingByCpName));
                        //myTraffic.Product__c = getMediaSellerProductSettingByCpName.get(myTraffic.Campaign_Type__c.toLowercase()).Product_SFID__c;
                        //myTraffic.Product_Services__c = getMediaSellerProductSettingByCpName.get(myTraffic.Campaign_Type__c.toLowercase()).Product_Services__c;
                        productSFID = getMediaSellerProductSettingByCpName.get(myTraffic.Campaign_Type__c.toLowercase()).Product_SFID__c;

                        productServices = getMediaSellerProductSettingByCpName.get(myTraffic.Campaign_Type__c.toLowercase()).Product_Services__c;

                        productCode = getMediaSellerProductSettingByCpName.get(myTraffic.Campaign_Type__c.toLowercase()).Product_Code__c;

                        System.debug('productSFID: ' + productSFID);
                        System.debug('productServices: ' + productServices);
                    }
                }

                myTraffic.Product__c = productSFID;
                myTraffic.Product_Services__c = productServices;
                myTraffic.Product_Code__c = productCode;

                System.debug('myTraffic.Product__c: ' + myTraffic.Product__c);
                System.debug('myTraffic.Product_Services__c: ' + myTraffic.Product_Services__c);
                System.debug('myTraffic.Product_Code__c: ' + myTraffic.Product_Code__c);
                
                //jika traffic nonbulk menggunakan special price whitelist untuk melakukans set brand
                String concateUniqueCPandNameSID = '';
                if(myTraffic.Product_Services__c == 'Non Bulk'){
                    concateUniqueCPandNameSID = myTraffic.CP_Name__c;
                }
                system.debug('concateUniqueCPandNameSID: ' + concateUniqueCPandNameSID); 

                Special_Price_Whitelist__c get_spw = map_spwUnique_spwRec.get(concateUniqueCPandNameSID);
                system.debug('get_spw: ' + get_spw);
                
                Boolean ProdSpecial = false;
                if(get_spw != null){
                    ProdSpecial = true;
                    //myTraffic.Product_Name__c = get_spw.Product__r.Product_Name_MS__c;
                    myTraffic.brand__c = get_spw.brand__c;
                }else{
                    if(String.isNotBlank(myTraffic.CP_Name__c)){
                        if(myTraffic.CP_Name__c.containsIgnoreCase('tkm')){
                            myTraffic.brand__c = 'Telkom';
                        }else{
                            myTraffic.brand__c = 'all client';
                        }
                    }else{
                        myTraffic.brand__c = 'all client';
                    }
                }
                //-------- End of jika traffic nonbulk menggunakan special price whitelist untuk melakukans set brand ------------------------
                
				/*List<Product2> myprod2 = [
                    SELECT id,
                    name,
                    List_Price__c 
                    FROM Product2 
                    WHERE id=:myTraffic.Product__c
                ];

                if(myprod2 != null && !myprod2.isEmpty()){
                    
                }*/

                if(Map_traffic_product != null && !Map_traffic_product.isEmpty()){
                    if(Map_traffic_product.get(myTraffic.Product__c) != null){
                        myTraffic.List_Price__c = Map_traffic_product.get(myTraffic.Product__c).List_Price__c;
                    }
                }
           		//---TNB tanpa ONB----END

                // -- penentuan discount dan discount type -- 
                string discountType = '';
                double discontValue;

                System.debug('List_MonthlyDiscountInventoryMediaSeller.size(): ' + List_MonthlyDiscountInventoryMediaSeller.size());

                if(List_MonthlyDiscountInventoryMediaSeller != null && !List_MonthlyDiscountInventoryMediaSeller.isEmpty()){
                    for(Monthly_Discount_Inventory_Media_Seller__c MonthlyDiscountInventoryMediaSeller : List_MonthlyDiscountInventoryMediaSeller){
                        System.debug('MonthlyDiscountInventoryMediaSeller.Media_Seller__c: ' + MonthlyDiscountInventoryMediaSeller.Media_Seller__c + ' = ' + myTraffic.user_id__c);
                        System.debug('MonthlyDiscountInventoryMediaSeller.Brand__c.toLowercase(): ' + MonthlyDiscountInventoryMediaSeller.Media_Seller__c + ' contains ' + myTraffic.Brand__c);
                        System.debug('MonthlyDiscountInventoryMediaSeller.Product_Services_and_Code__c.toLowercase(): ' + MonthlyDiscountInventoryMediaSeller.Product_Services_and_Code__c + ' contains ' + myTraffic.Product_Services_and_Code__c);
                        System.debug('myTraffic.Date__c: ' + myTraffic.Date__c + ' >= ' + MonthlyDiscountInventoryMediaSeller.Start_Date__c);
                        System.debug('myTraffic.Date__c: ' + myTraffic.Date__c + ' <= ' + MonthlyDiscountInventoryMediaSeller.Start_Date__c);

                        if(
                            MonthlyDiscountInventoryMediaSeller.Media_Seller__c == myTraffic.user_id__c &&
                            MonthlyDiscountInventoryMediaSeller.Brand__c.toLowercase().contains(myTraffic.Brand__c.toLowercase())  &&
                            myTraffic.Date__c >= MonthlyDiscountInventoryMediaSeller.Start_Date__c &&
                            myTraffic.Date__c <= MonthlyDiscountInventoryMediaSeller.End_Date__c &&
                            MonthlyDiscountInventoryMediaSeller.Product_Name__c != null
                        ){
                            if(MonthlyDiscountInventoryMediaSeller.Product_Name__c != null){
                                System.debug('MonthlyDiscountInventoryMediaSeller Product Name : ' + json.serialize(MonthlyDiscountInventoryMediaSeller));

                                if(MonthlyDiscountInventoryMediaSeller.Product_Name__c == myTraffic.Product__c){
                                    if(MonthlyDiscountInventoryMediaSeller.Discount_Type__c == 'Amount'){
                                        myTraffic.Discount_Amount__c = MonthlyDiscountInventoryMediaSeller.Value__c;
                                        discountType = MonthlyDiscountInventoryMediaSeller.Discount_Type__c;
                                        discontValue = MonthlyDiscountInventoryMediaSeller.Value__c;
                                    }else{
                                        discontValue = MonthlyDiscountInventoryMediaSeller.Value__c;
                                        myTraffic.Discount__c = MonthlyDiscountInventoryMediaSeller.Value__c;
                                        discountType = MonthlyDiscountInventoryMediaSeller.Discount_Type__c;
                                    }

                                    break;
                                }
                            }
                        }

                        if(
                            MonthlyDiscountInventoryMediaSeller.Media_Seller__c == myTraffic.user_id__c &&
                            MonthlyDiscountInventoryMediaSeller.Brand__c.toLowercase().contains(myTraffic.Brand__c.toLowercase())  &&
                            myTraffic.Date__c >= MonthlyDiscountInventoryMediaSeller.Start_Date__c &&
                            myTraffic.Date__c <= MonthlyDiscountInventoryMediaSeller.End_Date__c &&
                            MonthlyDiscountInventoryMediaSeller.Product_Name__c == null &&
                            MonthlyDiscountInventoryMediaSeller.Product_Services_and_Code__c != null
                        ){
                            list<string> MonthlyDiscountInventoryMediaSellerprodServiceCodeList = MonthlyDiscountInventoryMediaSeller.Product_Services_and_Code__c.toLowercase().split(';');

                            System.debug('MonthlyDiscountInventoryMediaSellerprodServiceCodeList: ' + MonthlyDiscountInventoryMediaSellerprodServiceCodeList);

                            for(string MonthlyDiscountInventoryMediaSellerprodServiceCode: MonthlyDiscountInventoryMediaSellerprodServiceCodeList){
                                System.debug('MonthlyDiscountInventoryMediaSellerprodServiceCode: ' + MonthlyDiscountInventoryMediaSellerprodServiceCode + ' = ' + myTraffic.Product_Services__c.toLowercase() + ' ' + myTraffic.Product_Code__c.toLowercase());

                                if(MonthlyDiscountInventoryMediaSellerprodServiceCode == (myTraffic.Product_Services__c.toLowercase() + ' ' + myTraffic.Product_Code__c.toLowercase())){
                                    if(MonthlyDiscountInventoryMediaSeller.Discount_Type__c == 'Amount'){
                                        myTraffic.Discount_Amount__c = MonthlyDiscountInventoryMediaSeller.Value__c;
                                        discountType = MonthlyDiscountInventoryMediaSeller.Discount_Type__c;
                                        discontValue = MonthlyDiscountInventoryMediaSeller.Value__c;
                                    }else{
                                        myTraffic.Discount__c = MonthlyDiscountInventoryMediaSeller.Value__c;
                                        discountType = MonthlyDiscountInventoryMediaSeller.Discount_Type__c;
                                        discontValue = MonthlyDiscountInventoryMediaSeller.Value__c;
                                    }

                                    break;
                                }
                            }
                        }
                    }
                }
                
                system.debug('*** discountType = ' + discountType);
                system.debug('*** discontValue = ' + discontValue);
                // --  end of penentuan discount dan discount type  ---

                // ----dep -start
                system.debug('*** myTraffic.Media_Seller__c = ' + myTraffic.user_id__c);
                system.debug('*** myTraffic.Date__c = ' + myTraffic.date__c);

                String mediaSeller = myTraffic.user_id__c;
                string SubmediaSeller = myTraffic.campaign_name__r.Agency__r.Id; //sudah tidak digunakan dalam pengelompokan
                //String Lob = myTraffic.Kategori_Industri__c;
                String Product = myTraffic.Product__c;
                Integer month = myTraffic.date__c.month();
                Integer year = myTraffic.date__c.year();
                String ProductServcies = myTraffic.Product_Services__c;
                Decimal Amounts = myTraffic.Amount__c;

                String uniqueId_utms = mediaSeller + '-' + myTraffic.Brand__c + '-' + Month + '-' + Year + '-' + ProductServcies + '-' + myTraffic.Product__c; 

                system.debug('*** uniqueId_utms = ' + uniqueId_utms);
                
                String utms_id = '';
                System.debug('map_uniqueId_ustm: ' + map_uniqueId_ustm + ' == ' + uniqueId_utms);
                
                if(!map_uniqueId_ustm.containsKey(uniqueId_utms)){ 
                    system.debug('map_uniqueId_ustm Not Found');

                    Usage_Traffic_Media_Seller__c UTMS = new Usage_Traffic_Media_Seller__c ();
                    UTMS.Date__c = Date.valueOf(Year + '-' + Month + '-' + '1');
                    UTMS.Unique_ID__c = uniqueId_utms;
                    UTMS.Media_seller__c = mediaSeller;
                    UTMS.Traffic_Type__c = ProductServcies;
                    UTMS.Product__c = Product;
                    UTMS.List_Price__c = myTraffic.List_Price__c;
                    UTMS.Brand__c = myTraffic.Brand__c;
                    utms.Discount__c = discontValue;
                    utms.Discount_Type__c = discountType;
                    utms.Product_Code__c = myTraffic.Product_Code__c;

                    upsert UTMS Unique_ID__c;

                    utms_id = UTMS.Id;
                    map_uniqueId_ustm.put(uniqueId_utms,UTMS);
                }else{
                    system.debug('map_uniqueId_ustm Found');
                    if(map_uniqueId_ustm.size() > 0 ){
                        utms_id = map_uniqueId_ustm.get(uniqueId_utms).Id;

                        Usage_Traffic_Media_Seller__c utmsUpdate = map_uniqueId_ustm.get(uniqueId_utms);
                        utmsUpdate.Discount_Type__c = discountType;
                        utmsUpdate.Discount__c = discontValue;

                        Set_utmsUpdate.add(utmsUpdate);
                        //update utmsUpdate;
                    }
                }
                system.debug('*** utms_id = ' + utms_id);

                myTraffic.Usage_Traffic_Media_Seller__c = utms_id;

                if(Set_utmsUpdate != null && !Set_utmsUpdate.isEmpty()){
                    list<Usage_Traffic_Media_Seller__c> utmsListUpdate = new list<Usage_Traffic_Media_Seller__c>();
                    utmsListUpdate.addAll(Set_utmsUpdate);
                    
                    update utmsListUpdate;
                }

                system.debug('*** myTraffic.Usage_Traffic_Media_Seller__c = ' + myTraffic.Usage_Traffic_Media_Seller__c);
                // ----dep -end
            }
        }catch(exception e) {
			string errMessage = 'Error on Traffic_NB_TriggerHandler beforeInsertHandler function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage ); 
        }
    }
    

    /*public static void afterInsertHandler(list<Traffic_Non_Bulk__c > lstTrafficTargeted){
        try{
            Set<String> Set_TrafficTargeted_Id = new Set<String>();
            
            if(lstTrafficTargeted != null && !lstTrafficTargeted.isEmpty()){
                for (Traffic_Non_Bulk__c myTraffic : lstTrafficTargeted){
                    Set_TrafficTargeted_Id.add(myTraffic.Id);
                }

                if(Set_TrafficTargeted_Id != null && !Set_TrafficTargeted_Id.isEmpty()){
                    MonthlySPAllocationServices.createMonthlySpecialPriceAllocation(lstTrafficTargeted[0].Date__c);

                    //TH_Traffic_NB_Services.setCalculationUtms_TrafficsNB(Set_TrafficTargeted_Id);
                }
            }
        }catch(exception e){
            string errMessage = 'Error on Traffic_NB_TriggerHandler afterInsertHandler function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
	}*/
    
}