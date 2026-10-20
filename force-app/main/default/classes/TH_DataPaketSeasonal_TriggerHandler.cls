/**

**/
public class TH_DataPaketSeasonal_TriggerHandler {
    // before insert data paket
    public static void beforeInsertDataPaket(list<Data_Paket_Seasonal__c> listDataPaketSeasonal)
    {
        List<Data_Paket_Seasonal__c> newDataPaketList = new List<Data_Paket_Seasonal__c>();
        Map<String, List<Data_Paket_Seasonal__c>> mapDuplicateRecord = new Map<String, List<Data_Paket_Seasonal__c>>();
        
        for (Data_Paket_Seasonal__c newDataPaketSeasonal : listDataPaketSeasonal) {
            String uniqIdDataPaket ='';
            system.debug('newDataPaketSeasonal.Id_Paket__c: ' + newDataPaketSeasonal.Id_Paket__c);
          
                uniqIdDataPaket = newDataPaketSeasonal.User_Id_Formula__c + '_' + newDataPaketSeasonal.Id_Paket__c;
                newDataPaketSeasonal.Id_Data_Paket_Seasonal__c = uniqIdDataPaket;
                
                system.debug('newDataPaketSeasonal.Id_Paket__cxxx: ' + newDataPaketSeasonal.Id_Paket__c);
                if (uniqIdDataPaket.contains('null')) {
                    if (newDataPaketSeasonal.Id_Paket__c == null ) {
                        newDataPaketSeasonal.addError('ID paket tidak boleh kosong!');
                    }
                }
                
                newDataPaketList.add(newDataPaketSeasonal);
                
                if (!mapDuplicateRecord.containsKey(uniqIdDataPaket)) {
                    mapDuplicateRecord.put(uniqIdDataPaket, new List<Data_Paket_Seasonal__c>{newDataPaketSeasonal});
                } else {
                    mapDuplicateRecord.get(uniqIdDataPaket).add(newDataPaketSeasonal);
                }
            
            
            for (Data_Paket_Seasonal__c newDataPakets : newDataPaketList) {
                List<Data_Paket_Seasonal__c> mapDuplicateRecordList = mapDuplicateRecord.get(newDataPakets.Id_Data_Paket_Seasonal__c);
                
                if (mapDuplicateRecordList != null && mapDuplicateRecordList.size() >= 2) {
                    newDataPakets.addError('Duplicate data detected ('+newDataPakets.Id_Data_Paket_Seasonal__c+')');
                }
            }
        }
    }
    //after insert
    public static void afterInsertDataPaket(list<Data_Paket_Seasonal__c> newDataPaketSeasonalList){   
        set<id> newDataPaketSeasonalListId = new set<id>();
        for(Data_Paket_Seasonal__c newDataPaketRec: newDataPaketSeasonalList){
            newDataPaketSeasonalListId.add(newDataPaketRec.Id);
        }
        
        //old data paket
        map<string, Data_Paket_Seasonal__c> oldDataPaketMap = new map<string, Data_Paket_Seasonal__c>();
        list<Data_Paket_Seasonal__c> oldDataPaketList = [select id, Id_Data_Paket_Seasonal__c, is_valid_data__c from Data_Paket_Seasonal__c where is_valid_data__c = true];
        for(Data_Paket_Seasonal__c newDataPaketRec: oldDataPaketList){
            oldDataPaketMap.put(newDataPaketRec.Id_Data_Paket_Seasonal__c, newDataPaketRec);
        }
        
        list<Data_Paket_Seasonal__c> newDataPaketFinalList = [select id, Id_Data_Paket_Seasonal__c, is_valid_data__c from Data_Paket_Seasonal__c where id in:newDataPaketSeasonalListId ];
        list<Data_Paket_Seasonal__c> newDataPaketList = new list<Data_Paket_Seasonal__c>();
        for(Data_Paket_Seasonal__c newDataPaketRec: newDataPaketList){
            newDataPaketList.add(newDataPaketRec);
        }
        //new campaign
        list<Data_Paket_Seasonal__c> oldDataPaketListtobeUpdate = new list<Data_Paket_Seasonal__c>();
        list<Data_Paket_Seasonal__c> newDataPaketListtobeUpdate = new list<Data_Paket_Seasonal__c>();
        for(Data_Paket_Seasonal__c dataPaketRecordId : newDataPaketFinalList){
            system.debug('dataPaketRecordId: ' + json.serialize(dataPaketRecordId));
            Data_Paket_Seasonal__c campaignOldMap = oldDataPaketMap.get(dataPaketRecordId.Id_Data_Paket_Seasonal__c);
            if(campaignOldMap !=null){
                system.debug('campaignOldMap: ' + campaignOldMap);
                campaignOldMap.is_valid_data__c = false;
                oldDataPaketListtobeUpdate.add(campaignOldMap);
            }
            
            dataPaketRecordId.is_valid_data__c = true;
            newDataPaketListtobeUpdate.add(dataPaketRecordId);      
        }
        system.debug('oldDataPaketListtobeUpdate: ' + json.serialize(oldDataPaketListtobeUpdate));
        system.debug('newDataPaketListtobeUpdate: ' + json.serialize(newDataPaketListtobeUpdate));
        update oldDataPaketListtobeUpdate;
        update newDataPaketListtobeUpdate;
        deleteDataPaketNotValid();
        
    }    
    
    //for delete
    @future
    public static void deleteDataPaketNotValid(){
        list<Data_paket_seasonal__c> newDataPaketList = [select id, ID_Paket__c, User_Id_Formula__c from Data_paket_seasonal__c where Id_Data_Paket_Seasonal__c !=null AND is_valid_data__c = false];       
        list<Data_paket_seasonal__c> newDataPaketListtoDelete = new list<Data_paket_seasonal__c>();
        for(Data_paket_seasonal__c newDataPaketRec :newDataPaketList){
            newDataPaketListtoDelete.add(newDataPaketRec);
        }
        delete newDataPaketListtoDelete;
    }
    
}