trigger Trigger_Account_Before_Insert on Account (Before insert, After Insert) {
if (label.Trigger_Account_After_Insert_On== 'YES') {
	if(trigger.isAfter)
	{
		if(trigger.isInsert)
        {
			decimal Month;
            decimal Year;
            String EID;
            String oldEID;
            double Amount_id;
            Decimal isi_mst;
            List<Monthly_Sales_Target__c> MSTlist = new List<Monthly_Sales_Target__c> ();
            Set<String> accSets = new Set <String>();
            Set<String> ownerset = new Set <String>();
            Set<Integer> monthSets = new Set <Integer>();
            Set<Integer> yearSets = new Set <Integer>();
            String OwnerID;
            
            Integer campAdsCounterCheck = 0;
            
            for(Account newAcc:trigger.new) 
            { 
                if(newAcc.Account_Type__c=='DO'){
					Date myDate = date.newinstance(newAcc.Tanggal_Daftar__c.year(), newAcc.Tanggal_Daftar__c.month(), newAcc.Tanggal_Daftar__c.day());
                    OwnerID=Label.Owner_SME;
                    system.debug('check tanggal'+newAcc.Tanggal_Daftar__c);
                    //List<Campaign_MyAds__c> ListCampAds = [SELECT id FROM Campaign_MyAds__c WHERE Start_Date__c<=:myDate and End_Date__c>=:myDate order by createddate DESC];
                    //System.debug('isi ListCampAds'+ListCampAds);
                    //if(ListCampAds.size()==0){
                        accSets.add(newAcc.Id);
                        monthSets.add(newAcc.Tanggal_Daftar__c.month());
                        yearSets.add(newAcc.Tanggal_Daftar__c.year());
                    /*}else{
                        campAdsCounterCheck = campAdsCounterCheck + 1;
                    }*/
                }
            }
            
            system.debug('*** campAdsCounterCheck = ' + campAdsCounterCheck);
            
            for(Integer montype : monthSets){
            
                for(Integer yeartype : yearSets)
				{
					oldEID='Organic-Register'+'-'+montype+'-'+yeartype;
				}
            
            	AggregateResult[] ListNewAcc = [SELECT count(id)sot,User_Id__c,CALENDAR_MONTH(Tanggal_Daftar__c)Month,CALENDAR_YEAR(Tanggal_Daftar__c)Year FROM Account WHERE id in:accSets and CALENDAR_MONTH(Tanggal_Daftar__c) =:montype and CALENDAR_YEAR(Tanggal_Daftar__c) in:yearSets group by User_Id__c,CALENDAR_MONTH(Tanggal_Daftar__c),CALENDAR_YEAR(Tanggal_Daftar__c)];
            	//AggregateResult[] ListNewAcc = [SELECT count(id)sot,CALENDAR_MONTH(Tanggal_Pendaftaran__c)Month,CALENDAR_YEAR(Tanggal_Pendaftaran__c)Year FROM Account WHERE CALENDAR_MONTH(Tanggal_Pendaftaran__c) =:montype and CALENDAR_YEAR(Tanggal_Pendaftaran__c) in:yearSets group by User_Id__c,CALENDAR_MONTH(Tanggal_Pendaftaran__c),CALENDAR_YEAR(Tanggal_Pendaftaran__c)];
            	AggregateResult[] reglis =[SELECT sum(Number_of__c) SOB FROM Monthly_Sales_Target__c WHERE Type__c='Actual User Register' and Unique_ID__c=:oldEID group by Unique_ID__c,Type__c];             
                    
                if(ListNewAcc.size()>0)
                {
                    // for (AggregateResult art : ListNewAcc)  {
                    Monthly_Sales_Target__c new_mst = new Monthly_Sales_Target__c();
                    //Month = (Integer) art.get('Month');
                    Month = montype;
                    //Year = (Integer) art.get('Year');
                    Year = (Integer) ListNewAcc[0].get('Year');
                    new_mst.Type__c='Actual User Register';
                    new_mst.group_type__c='Actual';
                    new_mst.Status_Top_Up__c='First Top Up';
                    new_mst.Date__c= Date.valueOf(Year+'-'+Month+'-'+'1');
                    //Amount_id = (double) art.get('sot');
                    EId ='Organic-Register'+'-'+Month+'-'+Year;
                    new_mst.Unique_ID__c=EID;
                    new_mst.MST_Type__c='SME';
                    if(reglis.size()>0){
                        isi_mst =(Decimal)reglis[0].get('SOB');
                    }else{
                        isi_mst=0;
                    }
                    new_mst.Number_of__c=isi_mst +ListNewAcc.size();
                    //new_mst.Number_of__c=isi_mst +1;
                    new_mst.sales__c=ownerid;
                    new_mst.ownerid=ownerid;
                    MSTlist.add(new_mst);
                    
                    upsert MSTlist new_mst.Unique_ID__c;
            	}
			}
        }
     }
}
}