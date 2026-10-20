trigger Trigger_Insert_BeritaAcara on Berita_Acara__c (before insert, after insert) {
    
if (label.Trigger_Insert_BeritaAcara_On == 'YES') {
    
    for(Berita_Acara__c newBA : trigger.new){
        
        system.debug('*** Trigger_Insert_BeritaAcara !!!');
        
        String str_month = '';
        
        switch on newBA.Month__c {
            when 'January'   {str_month = '01';}
            when 'February'  {str_month = '02';}
            when 'March'     {str_month = '03';}
            when 'April'     {str_month = '04';}
            when 'May'       {str_month = '05';}
            when 'June'      {str_month = '06';}
            when 'July'      {str_month = '07';}
            when 'August'    {str_month = '08';}
            when 'September' {str_month = '09';}
            when 'October'   {str_month = '10';}
            when 'November'  {str_month = '11';}
            when 'December'  {str_month = '12';}
            when else {str_month = '01';}
        }
        
        system.debug('*** str_month DILUAR = ' + str_month);
        
        Integer baMonth = Integer.valueOf(str_month); system.debug('*** baMonth = ' + baMonth);
        Integer baYear = Integer.valueOf(newBA.Year__c); system.debug('*** baYear = ' + baYear);
        
        Date ba_startDate = date.newInstance(baYear,baMonth,1); system.debug('*** ba_startDate = ' + ba_startDate);
        Date ba_endDate = date.newInstance(baYear,baMonth+1,1).addDays(-1); system.debug('*** ba_endDate = ' + ba_endDate);
        
        system.debug('*** newBA.Account__c = ' + newBA.Account__c);
        List<Traffic__c> trafficBAList = [SELECT Id, Name, Berita_Acara__c, Demand_Source__c, Fee__c FROM Traffic__c 
                                          WHERE Sites__r.Domain__r.Account__c =: newBA.Account__c 
                                          AND Date__c >=: ba_startDate 
                                          AND Date__c <=: ba_endDate];
		system.debug('*** trafficBAList = ' + trafficBAList.size() + ' | ' + trafficBAList);
              
        if(trigger.isBefore){
            system.debug('Masuk Trigger_Insert_BeritaAcara BEFORE');
            if(newBA.BA_Unique_Key__c == '' || newBA.BA_Unique_Key__c == null){
                newBA.BA_Unique_Key__c = newBA.Account__c + '-' + newBA.Year__c + '-' + str_month;
            }
            
            Decimal techFeeForPMPTadex = 0;
            Decimal techFeeForPMPTClient = 0;
            Decimal techFeeForOMP = 0;
            
            // Pengecekan nilai Fee yang berbeda dalam satu Demand Source yang sama
            Map<String,Decimal> map_demandSource_fee = new Map<String,Decimal>();
            for(Traffic__c trf : trafficBAList){
                String demandSource_temp = trf.Demand_Source__c;
                Decimal fee_temp = trf.Fee__c;
                
                if(demandSource_temp.contains('Programmatic PMP with Tadex\'s DSP')) techFeeForPMPTadex = fee_temp;
                else if(demandSource_temp.contains('Programmatic PMP with Client\'s DSP')) techFeeForPMPTClient = fee_temp;
                else if(demandSource_temp.contains('OMP')) techFeeForOMP = fee_temp;
                
                if(map_demandSource_fee.keySet().contains(demandSource_temp)){
                    if(map_demandSource_fee.get(demandSource_temp) != fee_temp){
                        newBA.addError('Terdapat nilai Fee yang berbeda pada "' + demandSource_temp + '" untuk traffic ' + trf.Name + ' yaitu ' 
                                       + map_demandSource_fee.get(demandSource_temp) + '% dan '
                                       + fee_temp + '%. Silahkan perbaiki data Traffic kemudian create record BA kembali.');
                    }
                }else{
                    map_demandSource_fee.put(demandSource_temp,fee_temp);
                }
            }
			
			newBA.Tech_Fee_for_PMP_Tadex__c = techFeeForPMPTadex;   
            newBA.Tech_Fee_for_PMP_Client__c = techFeeForPMPTClient;
			newBA.Tech_Fee_for_OMP__c = techFeeForOMP;
        }
        
        if(trigger.isAfter){ 
            
            system.debug('Masuk Trigger_Insert_BeritaAcara AFTER');
            
            List<Traffic__c> trafficBAListToUpdate = new List<Traffic__c>();
            for(Traffic__c trafficBA : trafficBAList){
                if(trafficBA.Berita_Acara__c == null){
                    system.debug('*** trafficBA = ' + trafficBA.Id + ' | ' + trafficBA.Name);
                    trafficBA.Berita_Acara__c = newBA.Id;
                    trafficBAListToUpdate.add(trafficBA);
                }
            } system.debug('*** trafficBAListToUpdate.size() = ' + trafficBAListToUpdate.size());
            if(trafficBAListToUpdate.size() > 0){
                update trafficBAListToUpdate;
            }
        }
    }
    
}
    
}