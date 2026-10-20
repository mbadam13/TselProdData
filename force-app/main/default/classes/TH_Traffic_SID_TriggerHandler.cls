/**
 * @description       : 
 * @Test Class        : Test_TH_Traffic_SID_TriggerHandler
 * @author            : Novando Utoyo Agmawan
 * @group             : 
 * @last modified on  : 09-14-2023
 * @last modified by  : Ahmat Zulkifli Murad
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.0   05-23-2023   Novando Utoyo Agmawan   Initial Version
**/

public class TH_Traffic_SID_TriggerHandler{
    
    public static void beforeInsertHandler(list<Traffics_SID__c> lstTrafficSID){
        System.debug('in TH_Traffic_SID_TriggerHandler.beforeInsertHandler');
        try{
            List<Usage_Traffic_Media_Seller__c> utmslist = [
                SELECT Id, 
                Name, 
                Unique_ID__c,
                Sub_Media_Seller__c 
                FROM Usage_Traffic_Media_Seller__c 
                WHERE (date__c = THIS_YEAR OR date__c = LAST_YEAR)
            ];
            
            system.debug('*** utmslist = ' + utmslist.size() + ' | ' + utmslist);

            Map<String,Usage_Traffic_Media_Seller__c> map_uniqueId_ustm = new Map<String,Usage_Traffic_Media_Seller__c>();  

            for(Usage_Traffic_Media_Seller__c utms : utmslist){
                map_uniqueId_ustm.put(utms.Unique_ID__c, utms);
            }

            system.debug('*** map_uniqueId_ustm = ' + map_uniqueId_ustm.size() + ' | ' + map_uniqueId_ustm);
            
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
           
            Map<String, Special_Price_Whitelist__c> map_spwUnique_spwRec = new Map <String, Special_Price_Whitelist__c>();
            if(spwList.size() > 0){    
                for(Special_Price_Whitelist__c spw : spwList){
                    map_spwUnique_spwRec.put(spw.CP_Name_SID__c, spw);
                }
                system.debug('*** map_spwUnique_spwRec = ' + map_spwUnique_spwRec.size() + ' | ' + map_spwUnique_spwRec);
            }
          
            // ----- end

            Map<String,Media_Seller_Product_Settings__c> Map_MediaSellerProductSetting = TH_Traffic_SID_Services.getMediaSellerProductSettingByCpName();

            list<Monthly_Discount_Inventory_Media_Seller__c> List_MonthlyDiscountInventoryMediaSeller = AppUtils.getListMonthlyDiscountInventoryMediaSeller();

            List<Media_Seller_Mapping_Settings__c> List_MediaSellerMappingSettings = AppUtils.getListMediaSellerMapping();
            

            set<id> trafficSIDs = new set<id>();
            set<id> set_traffic_productIds = new set<id>(); 

            for(Traffics_SID__c myTraffic :lstTrafficSID){
                if(myTraffic.sid__c != null){
                    trafficSIDs.add(myTraffic.sid__c);
                }

                if(Map_MediaSellerProductSetting != null && !Map_MediaSellerProductSetting.isEmpty()){
                    if(myTraffic.Product_Name__c != null){
                        if(Map_MediaSellerProductSetting.get(myTraffic.Product_Name__c.toLowercase()) != null){
                            set_traffic_productIds.add(Map_MediaSellerProductSetting.get(myTraffic.Product_Name__c.toLowercase()).Product_SFID__c);
                        }
                    }else{
                        set_traffic_productIds.add(Map_MediaSellerProductSetting.get('null').Product_SFID__c);
                    }
                    
    
                    if(String.isNotBlank(myTraffic.CP_Name__c)){
                        if(myTraffic.CP_Name__c.containsIgnoreCase('ussd')){
                            List<String> List_CPName = myTraffic.CP_Name__c.split('-');
    
                            String concatCPName = myTraffic.Product_Name__c + '|' + List_CPName[0] + '-' + List_CPName[1];
    
                            if(Map_MediaSellerProductSetting.get(concatCPName.toLowercase()) != null){
                                set_traffic_productIds.add(myTraffic.Product__c = Map_MediaSellerProductSetting.get(concatCPName.toLowercase()).Product_SFID__c);
                            }
                        }
                    }
                }
            }

            //set unique sid
            map<string, SID_Tools__c> sidToolsMap = new map<string, SID_Tools__c>();

            if(trafficSIDs != null && !trafficSIDs.isEmpty()){
                List<SID_Tools__c> mysid = [
                    SELECT id,
                    Media_Seller__c,
                    Media_Seller__r.ParentId,
                    Sub_Reseller__c,
                    SID__c 
                    FROM SID_Tools__c 
                    WHERE media_seller__c != null 
                    AND sid__c != null 
                    AND cp_name__c != null 
                    AND id in: trafficSIDs
                    //AND (createdDate = LAST_YEAR OR createdDate = THIS_YEAR)
                ];

                if(mysid != null && !mysid.isEmpty()){
                    for(SID_Tools__c SIDToolsRec : mysid){
                        sidToolsMap.put(SIDToolsRec.id, SIDToolsRec);
                    }
                }
            }

            map<string, Product2> Map_traffic_product = new map<string, Product2>();

            if(set_traffic_productIds != null && !set_traffic_productIds.isEmpty()){
                List<Product2> myprods = [
                    SELECT id,
                    Name, 
                    List_Price__c, 
                    Amount_CP_Share__c, 
                    Discount__c, 
                    Discount_Amount__c FROM Product2 
                    WHERE Id IN : set_traffic_productIds
                ]; 

                if(myprods != null && !myprods.isEmpty()){
                    for(Product2 myprod : myprods){
                        Map_traffic_product.put(myprod.id, myprod);
                    }
                }
            }

            List<Media_Seller_Exclude_Revenue__c> List_MediaSellerExcludeRevenue = AppUtils.getListMediaSellerExcludeRevenue();
            
            Set<Usage_Traffic_Media_Seller__c> Set_utmsUpdate = new Set<Usage_Traffic_Media_Seller__c>();

            for (Traffics_SID__c myTraffic :lstTrafficSID){
                system.debug('ini lstTrafficSID'+myTraffic.SID__c);

                String mysid_SID = '';  

                //set product first
                if(Map_MediaSellerProductSetting != null && !Map_MediaSellerProductSetting.isEmpty()){
                    if(myTraffic.Product_Name__c != null){
                        if(Map_MediaSellerProductSetting.get(myTraffic.Product_Name__c.toLowercase()) != null){
                            myTraffic.Product_Services__c = Map_MediaSellerProductSetting.get(myTraffic.Product_Name__c.toLowercase()).Product_Services__c;
    
                            myTraffic.Product__c = Map_MediaSellerProductSetting.get(myTraffic.Product_Name__c.toLowercase()).Product_SFID__c;
    
                            myTraffic.Product_Code__c = Map_MediaSellerProductSetting.get(myTraffic.Product_Name__c.toLowercase()).Product_Code__c;
                        }
                    }else{
                        if(Map_MediaSellerProductSetting.get('null') != null){
                            myTraffic.Product_Services__c = Map_MediaSellerProductSetting.get('null').Product_Services__c;
    
                            myTraffic.Product__c = Map_MediaSellerProductSetting.get('null').Product_SFID__c;
    
                            myTraffic.Product_Code__c = Map_MediaSellerProductSetting.get('null').Product_Code__c;
                        }
                    }
                    
    
                    if(String.isNotBlank(myTraffic.CP_Name__c)){
                        if(myTraffic.CP_Name__c.containsIgnoreCase('ussd')){
                            List<String> List_CPName = myTraffic.CP_Name__c.split('-');
    
                            String concatCPName = myTraffic.Product_Name__c + '|' + List_CPName[0] + '-' + List_CPName[1];
    
                            if(Map_MediaSellerProductSetting.get(concatCPName.toLowercase()) != null){
                                myTraffic.Product_Services__c = Map_MediaSellerProductSetting.get(concatCPName.toLowercase()).Product_Services__c;

                                myTraffic.Product__c = Map_MediaSellerProductSetting.get(concatCPName.toLowercase()).Product_SFID__c;

                                myTraffic.Product_Code__c = Map_MediaSellerProductSetting.get(concatCPName.toLowercase()).Product_Code__c;
                            }
                        }
                    }
                }

                // set the media seller
                if(myTraffic.sid__c != null){
                    if(sidToolsMap != null && !sidToolsMap.isEmpty()){
                        if(sidToolsMap.get(myTraffic.SID__c) != null){
                            SID_Tools__c SIDToolsRec = sidToolsMap.get(myTraffic.SID__c);

                            mysid_SID = SIDToolsRec.SID__c;
                            
                            if(myTraffic.Product_Name__c != null){
                                if(List_MediaSellerMappingSettings != null && !List_MediaSellerMappingSettings.isEmpty() && myTraffic.Product_Name__c.contains('USSD')){
                                    System.debug('List_MediaSellerMappingSettings: ' + List_MediaSellerMappingSettings);
                                    if(String.isNotBlank(myTraffic.CP_Name__c)){
                                        for(Media_Seller_Mapping_Settings__c MediaSellerMappingSettings :List_MediaSellerMappingSettings){
                                            string cpname = myTraffic.CP_Name__c.toLowercase();
                                            System.debug('MediaSellerMappingSettings: ' + MediaSellerMappingSettings);
                                            System.debug('myTraffic.CP_Name__c: ' + myTraffic.CP_Name__c);
                                            System.debug('myTraffic.CP_Name__c: ' + myTraffic.CP_Name__c + 'MediaSellerMappingSettings.Key__c: ' + MediaSellerMappingSettings.Key__c);
                                            if(cpname.Contains(MediaSellerMappingSettings.Key__c)){
                                                System.debug('in condition 1');
                                                myTraffic.media_seller__c = MediaSellerMappingSettings.Media_Seller_SFID__c;
                                            }
                                        }
                                    }
                                }else{
                                    if(SIDToolsRec.Sub_Reseller__c == false){
                                        myTraffic.Media_Seller__c = SIDToolsRec.Media_Seller__c;
                                    }else{
                                        if(SIDToolsRec.Media_Seller__r.ParentId != null){
                                            myTraffic.Media_Seller__c = SIDToolsRec.Media_Seller__r.ParentId;
                                        }
                                        else{
                                            myTraffic.Media_Seller__c = SIDToolsRec.Media_Seller__c;
                                        }
                                    }    
                                }
                            }
                        }
                    }
                }

                system.debug('*** Product_Services__c = ' + myTraffic.Product_Services__c);

                //------- Discount Special untuk beberapa product --------
                Boolean ProdSpecial = false;
                system.debug('*** CPName__c = ' + myTraffic.CP_Name__c);
                system.debug('*** SID__c = ' + mysid_SID);
                
                String concateUniqueCPandNameSID = '';
                if(myTraffic.Product_Services__c == 'Bulk'){
                    concateUniqueCPandNameSID = myTraffic.CP_Name__c +'_'+mysid_SID;
                }
                if(myTraffic.Product_Services__c == 'Non Bulk'){
                    concateUniqueCPandNameSID = myTraffic.CP_Name__c;
                }
                if(myTraffic.Product_Services__c == 'PNV'){
                    concateUniqueCPandNameSID = myTraffic.CP_Name__c;
                }
                //concateUniqueCPandNameSID= myTraffic.CP_Name__c +'_'+ mysid_SID;
                system.debug('concateUniqueCPandNameSID: ' + concateUniqueCPandNameSID); 

                Special_Price_Whitelist__c get_spw = map_spwUnique_spwRec.get(concateUniqueCPandNameSID);
                system.debug('get_spw: ' + get_spw);

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
                //-------- End------------------------

                /*if(myTraffic.Product__c != null){
                    List<Product2> myprod = [
                        SELECT id,
                        Name, 
                        List_Price__c, 
                        Amount_CP_Share__c, 
                        Discount__c, 
                        Discount_Amount__c FROM Product2 
                        WHERE Id =: myTraffic.Product__c
                    ]; 

                    if(myprod != null && !myprod.isEmpty()){
                        myTraffic.Sales_Price__c = myprod[0].List_Price__c;
                        myTraffic.Amount_CP_Share__c = myprod[0].Amount_CP_Share__c;               
                        //myTraffic.Discount_Amount__c = myprod[0].Discount_Amount__c;
                    }
                }*/

                if(Map_traffic_product != null && !Map_traffic_product.isEmpty()){
                    if(Map_traffic_product.get(myTraffic.Product__c) != null){
                        if(myTraffic.Sales_Price__c == null || myTraffic.Sales_Price__c == 0){
                            myTraffic.Sales_Price__c = Map_traffic_product.get(myTraffic.Product__c).List_Price__c;
                            myTraffic.Amount_CP_Share__c = Map_traffic_product.get(myTraffic.Product__c).Amount_CP_Share__c; 
                        }
                    }
                }

                System.debug('myTraffic.Product_Services_and_Code__c : ' + myTraffic.Product_Services_and_Code__c);

                //pengisian discount dan discount type
                string discountType = '';
                double discontValue;

                if(List_MonthlyDiscountInventoryMediaSeller != null && !List_MonthlyDiscountInventoryMediaSeller.isEmpty()){
                    for(Monthly_Discount_Inventory_Media_Seller__c MonthlyDiscountInventoryMediaSeller : List_MonthlyDiscountInventoryMediaSeller){
                        
                        System.debug('MonthlyDiscountInventoryMediaSeller.Media_Seller__c: ' + MonthlyDiscountInventoryMediaSeller.Media_Seller__c + ' like ' + myTraffic.Media_Seller__c);
                        System.debug('MonthlyDiscountInventoryMediaSeller.Brand__c: ' + MonthlyDiscountInventoryMediaSeller.Brand__c + ' like ' + myTraffic.Brand__c);
                        System.debug('MonthlyDiscountInventoryMediaSeller.Product_Services_and_Code__c: ' + MonthlyDiscountInventoryMediaSeller.Product_Services_and_Code__c + ' like ' + myTraffic.Product_Services_and_Code__c);
                        System.debug('MonthlyDiscountInventoryMediaSeller.Product_Name__c: ' + MonthlyDiscountInventoryMediaSeller.Product_Name__c);

                        if(
                            MonthlyDiscountInventoryMediaSeller.Media_Seller__c == myTraffic.Media_Seller__c &&
                            MonthlyDiscountInventoryMediaSeller.Brand__c.toLowercase().contains(myTraffic.Brand__c.toLowercase()) &&
                            myTraffic.Event_Date__c >= MonthlyDiscountInventoryMediaSeller.Start_Date__c &&
                            myTraffic.Event_Date__c <= MonthlyDiscountInventoryMediaSeller.End_Date__c &&
                            MonthlyDiscountInventoryMediaSeller.Product_Name__c != null
                        ){
                            if(MonthlyDiscountInventoryMediaSeller.Product_Name__c == myTraffic.Product__c){
                                System.debug('MonthlyDiscountInventoryMediaSeller Product Name : ' + json.serialize(MonthlyDiscountInventoryMediaSeller));
                                if(
                                    (myTraffic.Discount_Amount__c == null || myTraffic.Discount_Amount__c == 0) ||
                                    (myTraffic.Discount__c == null || myTraffic.Discount__c == 0)

                                ){
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
                            MonthlyDiscountInventoryMediaSeller.Media_Seller__c == myTraffic.Media_Seller__c &&
                            MonthlyDiscountInventoryMediaSeller.Brand__c.toLowercase().contains(myTraffic.Brand__c.toLowercase()) &&
                            myTraffic.Event_Date__c >= MonthlyDiscountInventoryMediaSeller.Start_Date__c &&
                            myTraffic.Event_Date__c <= MonthlyDiscountInventoryMediaSeller.End_Date__c  &&
                            MonthlyDiscountInventoryMediaSeller.Product_Name__c == null
                        ){
                            list<string> MonthlyDiscountInventoryMediaSellerprodServiceCodeList = MonthlyDiscountInventoryMediaSeller.Product_Services_and_Code__c.toLowercase().split(';');
                            System.debug('MonthlyDiscountInventoryMediaSellerprodServiceCodeList: ' + MonthlyDiscountInventoryMediaSellerprodServiceCodeList);
                            system.debug('myTraffic.Product_Services__c.301: ' +  myTraffic.Product_Services__c);
                            system.debug('myTraffic.Product_Code__c.302: ' +  myTraffic.Product_Code__c);
                            if(MonthlyDiscountInventoryMediaSellerprodServiceCodeList != null){
                                for(string MonthlyDiscountInventoryMediaSellerprodServiceCode :MonthlyDiscountInventoryMediaSellerprodServiceCodeList){
                                    if(myTraffic.Product_Services__c != null && myTraffic.Product_Code__c != null){
                                        //System.debug('MonthlyDiscountInventoryMediaSellerprodServiceCode: ' + MonthlyDiscountInventoryMediaSellerprodServiceCode);
                                        //System.debug('MonthlyDiscountInventoryMediaSellerprodServiceCode.302: ' + MonthlyDiscountInventoryMediaSellerprodServiceCode + ' = ' + myTraffic.Product_Services__c.toLowercase() + ' ' + myTraffic.Product_Code__c.toLowercase());
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

                        /*
                        if(
                            MonthlyDiscountInventoryMediaSeller.Media_Seller__c == myTraffic.Media_Seller__c &&
                            MonthlyDiscountInventoryMediaSeller.Brand__c.toLowercase().contains(myTraffic.Brand__c.toLowercase()) &&
                            myTraffic.Event_Date__c >= MonthlyDiscountInventoryMediaSeller.Start_Date__c &&
                            myTraffic.Event_Date__c <= MonthlyDiscountInventoryMediaSeller.End_Date__c  &&
                            MonthlyDiscountInventoryMediaSeller.Product_Name__c == null
                        ){
                            if(MonthlyDiscountInventoryMediaSeller.Product_Services_and_Code__c.toLowercase().contains(myTraffic.Product_Services_and_Code__c.toLowercase())){
                                System.debug('MonthlyDiscountInventoryMediaSeller Product Code : ' + json.serialize(MonthlyDiscountInventoryMediaSeller));

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
                        */
                    }
                }
                

                system.debug('*** discountType = ' + discountType);
                system.debug('*** discontValue = ' + discontValue);
                // ----- end of discount dan discount type ------------

                String mediaSeller = myTraffic.Media_Seller__c;
                String SubmediaSeller = myTraffic.Media_Seller_ID__c;
                String kategoriIndustri = myTraffic.Kategori_Industri__c;
                String Lob = myTraffic.kategori_industri__c;
                String Product = myTraffic.Product__c;
                Decimal traffics = myTraffic.Traffic__c;
                Decimal Amounts = myTraffic.Amount__c;
                Integer month = myTraffic.Event_Date__c.month();
                Integer year = myTraffic.Event_Date__c.year();
                String ProductServcies = myTraffic.Product_Services__c;

                String uniqueId_utms = mediaSeller + '-' + myTraffic.Brand__c + '-' + Month + '-' + Year + '-' + ProductServcies + '-' + myTraffic.Product__c; 

                system.debug('*** uniqueId_utms = ' + uniqueId_utms);
                

                Boolean createUtms = true;

                if(List_MediaSellerExcludeRevenue != null && !List_MediaSellerExcludeRevenue.isEmpty()){
                    if(String.isNotBlank(myTraffic.CP_Name__c)){
                        for(Media_Seller_Exclude_Revenue__c MediaSellerExcludeRevenue : List_MediaSellerExcludeRevenue){
                            if(myTraffic.CP_Name__c.toLowercase().contains(MediaSellerExcludeRevenue.Name.toLowercase())){
                                createUtms = false;
                            }
                        }
                    }
                }

                system.debug('*** createUtms = ' + createUtms);

                if(createUtms){
                    String utms_id = '';
                    
                    if(!map_uniqueId_ustm.containsKey(uniqueId_utms)){ 
                        system.debug('MAP UTMS Not Found');
                        
                        Usage_Traffic_Media_Seller__c UTMS = new Usage_Traffic_Media_Seller__c ();
                        UTMS.Date__c = Date.valueOf(Year+'-'+Month+'-'+'1');
                        UTMS.Unique_ID__c = uniqueId_utms;
                        UTMS.Media_seller__c = mediaSeller;
                        UTMS.Traffic_Type__c = ProductServcies;
                        utms.List_Price__c = myTraffic.Sales_Price__c;
                        UTMS.Product__c = Product;
                        utms.Discount__c = discontValue;
                        utms.Discount_Type__c = discountType;
                        utms.Brand__c = myTraffic.Brand__c;
                        utms.Product_Code__c = myTraffic.Product_Code__c;

                        upsert UTMS Unique_ID__c; // dipindah add to list dulu baru insert

                        utms_id = UTMS.Id;
                        map_uniqueId_ustm.put(uniqueId_utms,UTMS);
                    }else{
                        system.debug('MAP UTMS Found');

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
                }
            }
        }catch(exception e) {
            string errMessage = 'Error on Traffic_SID_TriggerHandler beforeInsertHandler function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    } 
    
    /*
    public static void afterInsertHandler(list<Traffics_SID__c> lstTrafficSIDOld){
        system.debug('afterInsertHandler: ');
        set<id> trafficSIDs = new set<id>();
        for(Traffics_SID__c lstTrafficSIDOldRec :lstTrafficSIDOld){
            trafficSIDs.add(lstTrafficSIDOldRec.id);
        }

        list<Traffics_SID__c> TrafficsSIDExistingLIst = [select id, 
                                                        Temp_Amount__c, 
                                                        Amount_Net__c,
                                                        list_price__c,
                                                        sales_price__c,
                                                        Traffic__c,
                                                        Discounts__c

                                                        FROM Traffics_SID__c 
                                                        where id in:trafficSIDs 
                                                        ];
        system.debug('TrafficsSIDExistingLIst.size: ' + TrafficsSIDExistingLIst.size());
        system.debug('TrafficsSIDExistingLIst: ' + TrafficsSIDExistingLIst);

        list<Traffics_SID__c> trafficSIDListUpdate = new list<Traffics_SID__c>();

        for(Traffics_SID__c TrafficsSIDExistingLIstRec: TrafficsSIDExistingLIst){
            system.debug('TrafficsSIDExistingLIstRec: ' + TrafficsSIDExistingLIstRec);
            system.debug('TrafficsSIDExistingLIstRec.list_price__c: ' + TrafficsSIDExistingLIstRec.list_price__c);
            system.debug('TrafficsSIDExistingLIstRec.sales_price__c: ' + TrafficsSIDExistingLIstRec.sales_price__c);
            system.debug('TrafficsSIDExistingLIstRec.Discounts__c: ' + TrafficsSIDExistingLIstRec.Discounts__c);
            system.debug('TrafficsSIDExistingLIstRec.Amount_Net__c: ' + TrafficsSIDExistingLIstRec.Amount_Net__c);
            system.debug('TrafficsSIDExistingLIstRec.Temp_Amount__c: ' + TrafficsSIDExistingLIstRec.Temp_Amount__c);
            
            //TrafficsSIDExistingLIstRec.Temp_Amount__c = TrafficsSIDExistingLIstRec.Amount_Net__c;
            TrafficsSIDExistingLIstRec.Temp_Amount__c = TrafficsSIDExistingLIstRec.Traffic__c * TrafficsSIDExistingLIstRec.list_price__c;
            trafficSIDListUpdate.add(TrafficsSIDExistingLIstRec);
            
        }   

        if(trafficSIDListUpdate != null){
            update trafficSIDListUpdate;
        }
        
    }
    */

    /*public static void afterInsertHandler(list<Traffics_SID__c> lstTrafficSID){
        try{
            Set<Date> Set_TrafficsSID_Date = new Set<Date>();
            
            if(lstTrafficSID != null && !lstTrafficSID.isEmpty()){
                for (Traffics_SID__c myTraffic : lstTrafficSID){
                    Set_TrafficsSID_Date.add(date.newinstance(myTraffic.Event_Date__c.year(), myTraffic.Event_Date__c.month(), 01));
                }

                if(Set_TrafficsSID_Date != null && !Set_TrafficsSID_Date.isEmpty()){
                    for(Date TrafficsSID_Date : Set_TrafficsSID_Date){
                        MonthlySPAllocationServices.createMonthlySpecialPriceAllocation(TrafficsSID_Date);
                    }

                    //handleAsyncRefreshData(Set_TrafficsSID_Date);
                }

                MonthlySPAllocationServices.createMonthlySpecialPriceAllocation(lstTrafficSID[0].Event_Date__c); 
            }
        }catch(exception e){
            string errMessage = 'Error on Traffic_SID_TriggerHandler afterInsertHandler function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
        }
    }*/

    /*@future
    public static void handleAsyncRefreshData(Set<Date> Set_TrafficsSID_Date){
        System.debug(' == in handleAsyncRefreshData == ');

        for(Date TrafficsSID_Date : Set_TrafficsSID_Date){
            MonthlySPAllocationServices.createMonthlySpecialPriceAllocation(TrafficsSID_Date); 
        }

        TH_Traffic_SID_Services.setCalculationUtms_TrafficsSID();
    }*/
}