/**

**/
public class TH_CampIklans_TriggerHandler{
    // new adjustment 19/05/2023 //api phase 5
    
    // before insert campaign iklan
    public static void beforeInsertHandler(List<Campaigns__c> lstCampIklan) {
    List<Campaigns__c> newCampaignList = new List<Campaigns__c>();
    Map<String, List<Campaigns__c>> mapDuplicateRecord = new Map<String, List<Campaigns__c>>();
    
    for (Campaigns__c newCampaignSeasonal : lstCampIklan) {
        String uniqIdCampaign ='';
        if(newCampaignSeasonal.Id_Paket__c != null){
            uniqIdCampaign = newCampaignSeasonal.User_Id_Formula__c + '_' + newCampaignSeasonal.ID_Iklan__c + '_' + newCampaignSeasonal.Id_Paket__c;
            newCampaignSeasonal.Kategori_Campaign__c = 'Seasonal';
        }else{
            uniqIdCampaign = newCampaignSeasonal.User_Id_Formula__c + '_' + newCampaignSeasonal.ID_Iklan__c;
            newCampaignSeasonal.Kategori_Campaign__c = 'Non Seasonal';
        }
        newCampaignSeasonal.Id_Campaigns__c = uniqIdCampaign;
          
        if (uniqIdCampaign.contains('null')) {
            if (newCampaignSeasonal.ID_Iklan__c == null) {
                newCampaignSeasonal.addError('ID iklan tidak boleh kosong!');
            } else if (newCampaignSeasonal.Id_Paket__c == null && newCampaignSeasonal.Kategori_Campaign__c == 'Seasonal') {
                newCampaignSeasonal.addError('ID paket tidak boleh kosong!');
            }
        }
        
        newCampaignList.add(newCampaignSeasonal);
        
        if (!mapDuplicateRecord.containsKey(uniqIdCampaign)) {
            mapDuplicateRecord.put(uniqIdCampaign, new List<Campaigns__c>{newCampaignSeasonal});
        } else {
            mapDuplicateRecord.get(uniqIdCampaign).add(newCampaignSeasonal);
        }
    }
    
    for (Campaigns__c newCampaignsIklan : newCampaignList) {
        List<Campaigns__c> mapDuplicateRecordList = mapDuplicateRecord.get(newCampaignsIklan.Id_Campaigns__c);
        
        if (mapDuplicateRecordList != null && mapDuplicateRecordList.size() >= 2) {
            newCampaignsIklan.addError('Duplicate data detected ('+newCampaignsIklan.Id_Campaigns__c+')');
        }
    }
    
    System.debug('=====newCampaignList: ' + newCampaignList);
}
    
    public static void afterInsertHandler(list<Campaigns__c> lstCampIklan){
        try
        {
            //
            decimal Month;
            decimal Year;
            Decimal isi_mst;
            String EID;
            String oldEID;
            double Amount_id;
            List<Monthly_Sales_Target__c> MSTlist = new List<Monthly_Sales_Target__c> ();
            Set<String> campSets = new Set <String>();
            Set<Integer> monthSets = new Set <Integer>();
            Set<Integer> yearSets = new Set <Integer>();
            String OwnerID;
            for(Campaigns__c newCamp:lstCampIklan) 
            {
                Date myDate = date.newinstance(newCamp.Tanggal_Iklan__c.year(), newCamp.Tanggal_Iklan__c.month(), newCamp.Tanggal_Iklan__c.day());
                OwnerID=Label.Owner_SME;
                campSets.add(newCamp.ID_Iklan__c);
                monthSets.add(newCamp.Tanggal_Iklan__c.month());
                yearSets.add(newCamp.Tanggal_Iklan__c.year());
            } 
            if(monthSets.size()>0)
            {
                for(Integer montype : monthSets)
                {
                    system.debug('montype'+montype);
                    system.debug('yearSets'+yearSets);
                    AggregateResult[] ListCampIklan = [SELECT count(amount__c)sot,ID_Iklan__c,CALENDAR_MONTH(Tanggal_Iklan__c)
                                                       Month,CALENDAR_YEAR(Tanggal_Iklan__c)Year FROM Campaigns__c WHERE CALENDAR_MONTH(Tanggal_Iklan__c)
                                                       =:montype and CALENDAR_YEAR(Tanggal_Iklan__c) in:yearSets group by ID_Iklan__c,CALENDAR_MONTH(Tanggal_Iklan__c),
                                                       CALENDAR_YEAR(Tanggal_Iklan__c)];
                    
                    for(Integer yeartype : yearSets)
                    {
                        oldEID='Campaigns'+'-'+montype+'-'+yeartype;
                    }
                    system.debug('oldEID'+oldEID);
                    //AggregateResult[] sizecamplis =[SELECT sum(Number_of__c) SOB,CALENDAR_YEAR(date__c)Year FROM Monthly_Sales_Target__c WHERE Type__c='Actual Campaigns' and CALENDAR_MONTH(date__c)=:montype and CALENDAR_YEAR(date__c) in:yearSets group by CALENDAR_MONTH(date__c),CALENDAR_YEAR(date__c),Type__c];             
                    AggregateResult[] sizecamplis =[SELECT sum(Number_of__c) SOB FROM Monthly_Sales_Target__c WHERE Type__c='Actual Campaigns' and Unique_ID__c=:oldEID group by Unique_ID__c,Type__c];             
                    
                    
                    if(ListCampIklan.size()>0)
                    {
                        
                        Monthly_Sales_Target__c new_mst = new Monthly_Sales_Target__c();
                        Month = montype;
                        Year = (Integer) ListCampIklan[0].get('Year');
                        new_mst.Type__c='Actual Campaigns';
                        new_mst.group_type__c='Actual';
                        new_mst.MST_Type__c='SME';
                        new_mst.Date__c= Date.valueOf(Year+'-'+Month+'-'+'1');
                        //Amount_id = (double) art.get('sot');
                        //Amount_id = ListTopInvoicetop[0].get('sot');
                        
                        EId ='Campaigns'+'-'+Month+'-'+Year;
                        new_mst.Unique_ID__c=EID;
                        if(sizecamplis.size()>0){
                            isi_mst =(Decimal)sizecamplis[0].get('SOB');
                        }
                        else
                        {
                            isi_mst=0;
                        }
                        system.debug('ListCampIklan isi'+ListCampIklan);
                        new_mst.Number_of__c=isi_mst+campSets.size(); //buatakumulasi
                        //new_mst.Number_of__c=isi_mst+1; //buatakumulasi
                        
                        
                        system.debug('ListCampIklan.size()'+ListCampIklan.size());
                        system.debug('isi_mst'+isi_mst);
                        //new_mst.Number_of__c=isi_mst;//buatakumulasi
                        new_mst.sales__c=ownerid;
                        new_mst.ownerid=ownerid;
                        MSTlist.add(new_mst);
                        
                        //}
                        upsert MSTlist new_mst.Unique_ID__c;
                    }
                }
                checkValidDateCampaign(lstCampIklan);
            }
        }
        
        catch(exception e) 
        {
            string errMessage = 'Error on Traffic_SID_TriggerHandler beforeInsertHandler function::' + e.getmessage() + '::' + e.getLineNumber() ;
            system.debug('==================== error message : ' + errMessage);
            AppUtils.putError(errMessage );
            
        } 
    }
    
    public static void checkValidDateCampaign(list<Campaigns__c> newCampIklanList){   
        set<id> newCampIklanListId = new set<id>();
        for(campaigns__C newCampaignsRec: newCampIklanList){
            newCampIklanListId.add(newCampaignsRec.Id);
        }
        
        //old campaign
        system.debug('--- in checkValidDateCampaign ---');
        map<string, campaigns__c> oldCampaignMap = new map<string, campaigns__c>();
        list<campaigns__c> oldCampaignsList = [select id, Id_Campaigns__c, is_valid_data__c, Kategori_Campaign__c 
                                               from campaigns__c 
                                               where is_valid_data__c = true 
                                               and tanggal_iklan__c = THIS_MONTH];
        
        for(campaigns__C newCampaignsRec: oldCampaignsList){
            oldCampaignMap.put(newCampaignsRec.Id_Campaigns__c + '_' + newCampaignsRec.Kategori_Campaign__c, newCampaignsRec);
        }
        
        list<campaigns__c> newCampaignsFinalList = [select id, Id_Campaigns__c, is_valid_data__c, Kategori_Campaign__c 
                                                    from campaigns__c 
                                                    where id in:newCampIklanListId ];
        list<campaigns__c> newCampaignsList = new list<campaigns__c>();
        for(campaigns__C newCampaignsRec: newCampaignsList){
            newCampaignsList.add(newCampaignsRec);
        }
        //new campaign
        list<Campaigns__c> oldCampaignIklanListtobeUpdate = new list<Campaigns__c>();
        list<Campaigns__c> newCampaignIklanListtobeUpdate = new list<Campaigns__c>();
        for(Campaigns__c campaignIklanRecordId : newCampaignsFinalList){
            system.debug('campaignIklanRecordId: ' + json.serialize(campaignIklanRecordId));
            campaigns__c campaignOldMap = oldCampaignMap.get(campaignIklanRecordId.Id_Campaigns__c + '_' + campaignIklanRecordId.Kategori_Campaign__c);
            if(campaignOldMap !=null){
                system.debug('campaignOldMap: ' + campaignOldMap);
                campaignOldMap.is_valid_data__c = false;
                oldCampaignIklanListtobeUpdate.add(campaignOldMap);
            }
            
            campaignIklanRecordId.is_valid_data__c = true;
            newCampaignIklanListtobeUpdate.add(campaignIklanRecordId);      
        }
        system.debug('oldCampaignIklanListtobeUpdate: ' + json.serialize(oldCampaignIklanListtobeUpdate));
        system.debug('newCampaignIklanListtobeUpdate: ' + json.serialize(newCampaignIklanListtobeUpdate));
        update oldCampaignIklanListtobeUpdate;
        update newCampaignIklanListtobeUpdate;
        
        deleteCampaignsIklanNotValid();
    }
    
  @future
  public static void deleteCampaignsIklanNotValid(){
        list<campaigns__c> newCampaignsList = [select id, 
                                               Kategori_Campaign__c, 
                                               ID_Iklan__c, 
                                               ID_Paket__c, 
                                               User_Id_Formula__c 
                                               from campaigns__c 
                                               where Kategori_Campaign__c != null and id_campaigns__c != null AND is_valid_data__c = false
                                              ];   
        
        list<campaigns__c> newCampaignsListToDelete = new list<campaigns__c>();
        for(campaigns__c newCampaignIklansRec :newCampaignsList){
            newCampaignsListToDelete.add(newCampaignIklansRec);
        }
        delete newCampaignsListToDelete;
    } 
}