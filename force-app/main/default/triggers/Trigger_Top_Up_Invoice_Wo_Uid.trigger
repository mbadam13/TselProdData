trigger Trigger_Top_Up_Invoice_Wo_Uid on Top_Up_Invoice__c(Before insert, After Insert) {

if (label.Trigger_Top_Up_Invoice_WO_ID_ON == 'YES') {
    if(trigger.isBefore)
     {
    
        if(trigger.isInsert)
        {

            for(Top_Up_Invoice__c newTI:trigger.new) {        
                 try {
                       
                       if(newTI.Payment_Method__c=='Credit Card'){
                           newTI.Fee_Finnet__c=Integer.valueof(Label.Credit_Card_Fee);
                       }
                       else if(newTI.Payment_Method__c=='LinkAja'){
                           newTI.Fee_Finnet__c=Integer.valueof(Label.LinkAja_Fee);
                       }
                       else if(newTI.Payment_Method__c=='Pulsa'){
                            newTI.Fee_Finnet__c=0;
                       }
                       else{
                           newTI.Fee_Finnet__c=Integer.valueof(Label.Others_Fee);
                       }
                   }
                   catch (Exception e) {
                       string errMessage = 'Error on AppUtils Trigger_Top_Up_invoice_Before_Insert method.::' + e.getmessage() + '::' + e.getLineNumber() ;
                       system.debug('==================== error message : ' + errMessage);
                       AppUtils.putError(errMessage );
                   }
            }
        }
        
    }
     if(trigger.isAfter)
     {
    
        if(trigger.isInsert)
        {
            decimal Month;
            decimal Year;
            String EID;
			double Amount_id;
           	List<Monthly_Sales_Target__c> MSTlist = new List<Monthly_Sales_Target__c> ();
           	Set<String> tinvSets = new Set <String>();
           	Set<String> ownerset = new Set <String>();
           	Set<Integer> monthSets = new Set <Integer>();
           	Set<Integer> yearSets = new Set <Integer>();
           	String OwnerID;
           	double Amount_id_top;
           	double Amount_id_re;
            
            Integer campAdsCounterCheck = 0;
            
           	for(Top_Up_Invoice__c newTI:trigger.new) 
           	{ 
				Date myDate = date.newinstance(newTI.Paid_Date__c.year(), newTI.Paid_Date__c.month(), newTI.Paid_Date__c.day());
               	system.debug('date.newinstance' + myDate );
               	OwnerID=Label.Owner_SME;
               	//List<Campaign_MyAds__c> ListCampAds = [SELECT Id, Name FROM Campaign_MyAds__c WHERE Start_Date__c >=:myDate AND End_Date__c <=:myDate order by createddate DESC];
                //system.debug('***SOQL ListCampAds = ' + ListCampAds.size() + ' | ' + ListCampAds);
                //System.debug('isi ListCampAds'+ListCampAds);
               	//if(ListCampAds.size()==0){
					tinvSets.add(newTI.Id);
                   	monthSets.add(newTI.Paid_Date__c.month());
                   	yearSets.add(newTI.Paid_Date__c.year());
                   	system.debug('Masuk');
                   	//ownerset.add(newTI.Owner__c);
                /*}else{
                    campAdsCounterCheck = campAdsCounterCheck + 1;
                }*/
           	}
            
            system.debug('*** campAdsCounterCheck = ' + campAdsCounterCheck);
			
            Map<String,List<Top_Up_Invoice__c>> map_mstId_tuiList = new Map<String,List<Top_Up_Invoice__c>>();
            List<Top_Up_Invoice__c> tuiList_updateMst = new List<Top_Up_Invoice__c>();
            
            system.debug('*** monthSets = ' + monthSets.size() + ' | ' + monthSets);
            
           	for(Integer montype : monthSets){
				List<Top_Up_Invoice__c> reTopUpInvList = [SELECT ID, MST_Number_of__c FROM Top_Up_Invoice__c WHERE Id IN: tinvSets AND Status_Topup__c = 'Re-Top up' and CALENDAR_MONTH(Paid_Date_Date__c) =:montype and CALENDAR_YEAR(Paid_Date_Date__c) in:yearSets];
				system.debug('***SOQL ReTopUp new_mst.Id | list = ' + reTopUpInvList.size());
                List<Top_Up_Invoice__c> topUpInvList =[SELECT Id, MST_Number_of__c FROM Top_Up_Invoice__c WHERE Id IN: tinvSets AND Status_Topup__c = 'First Top up' and CALENDAR_MONTH(Paid_Date_Date__c) =:montype and CALENDAR_YEAR(Paid_Date_Date__c) in:yearSets];
				system.debug('***SOQL TopUp new_mst.Id | list ' + topUpInvList.size());
                
               	if(reTopUpInvList.size() > 0)
                {
                    system.debug('*** If ReTopUp in month - ' + montype);
					Monthly_Sales_Target__c new_mst = new Monthly_Sales_Target__c();
                    Month = montype;
                    //Year =  (Integer) ListTopInvoiceretop[0].get('Year');
                    Year = new List<Integer> (yearSets).get(0);
                    new_mst.Type__c='Actual User Re-top';
                    new_mst.group_type__c='Actual';
                    new_mst.Date__c= Date.valueOf(Year+'-'+Month+'-'+'1');
                    new_mst.Status_Top_up__c='Re-Top Up';
                    EId ='Organic-ReTopUp'+'-'+Month+'-'+Year;
                    new_mst.Unique_ID__c=EID;
                    new_mst.MST_Type__c='SME';
                    //new_mst.Number_of__c= (Integer) ListTopInvoiceretop[0].get('som');
                   	system.debug('Number of ' + new_mst.Number_of__c);
                    new_mst.sales__c=ownerid;
                    new_mst.ownerid=ownerid;
                    
                    upsert new_mst Unique_ID__c;
                    
                    map_mstId_tuiList.put(new_mst.Id,reTopUpInvList);
                }
               	
           		if(topUpInvList.size() > 0 )
               	{
                    system.debug('*** If TopUp in month - ' + montype);
                    Monthly_Sales_Target__c new_mst = new Monthly_Sales_Target__c();
                    Month = montype;
                    //Year =  (Integer) ListTopInvoicetop[0].get('Year');
                    Year = new List<Integer> (yearSets).get(0);
                    new_mst.Type__c='Actual User Top Up';
                    new_mst.group_type__c='Actual';
                    new_mst.Date__c= Date.valueOf(Year+'-'+Month+'-'+'1');
                    new_mst.Status_Top_up__c='First Top Up';
                    EId ='Organic-TopUp'+'-'+Month+'-'+Year;
                    new_mst.Unique_ID__c=EID;
                    new_mst.MST_Type__c='SME';
                    //new_mst.Number_of__c= (Integer) ListTopInvoicetop[0].get('sot');
                    system.debug('Number of ' + new_mst.Number_of__c);
                    new_mst.sales__c=ownerid;
                    new_mst.ownerid=ownerid;
                    
                    upsert new_mst Unique_ID__c;
                    
                    map_mstId_tuiList.put(new_mst.Id,topUpInvList);
                }
               	
           	}
            
            system.debug('*** map_mstId_tuiList.size() = ' + map_mstId_tuiList.size());
            
            for(String mstId : map_mstId_tuiList.keySet()){
                system.debug('*** mstId & tuiList.size = ' + mstId + ' & ' + map_mstId_tuiList.get(mstId).size());
            	for(Top_Up_Invoice__c tuiRec : map_mstId_tuiList.get(mstId)){
                	tuiRec.MST_Number_of__c = mstId;
                    tuiList_updateMst.add(tuiRec);
              	}                 
			}
            
            system.debug('*** tuiList_updateMst = ' + tuiList_updateMst.size() + ' | ' + tuiList_updateMst);
            
            if(tuiList_updateMst.size() > 0){update tuiList_updateMst;}
            
            List<Monthly_Sales_Target__c> mstListToUpdate = new List<Monthly_Sales_Target__c>();
            
            AggregateResult[] agr_tui = [SELECT count(ID) numberOf, MST_Number_of__c mstId FROM Top_Up_Invoice__c WHERE MST_Number_of__c IN: map_mstId_tuiList.keySet() GROUP BY MST_Number_of__c];
            system.debug('***SOQL agr_tui = ' + agr_tui.size() + ' | ' + agr_tui);
            for (AggregateResult ar : agr_tui){
                Monthly_Sales_Target__c mst_rec = new Monthly_Sales_Target__c();
                mst_rec.Id = (Id) ar.get('mstId');
                mst_rec.Number_of__c = (Integer) ar.get('numberOf');
                mstListToUpdate.add(mst_rec);
            }
            
            system.debug('*** mstListToUpdate = ' + mstListToUpdate.size() + ' | ' + mstListToUpdate);
            
            if(mstListToUpdate.size() > 0){update mstListToUpdate;}
        }
     }
  }
}