global with sharing class Schedule_KertasKerjaDetail  implements Schedulable {
	
    // MOnthly Scheduler
    global void execute(SchedulableContext sc){
        
        Date executeDate = null;
        if(!Test.isRunningTest()){
            executeDate = system.today();
            if(label.ManualRunSchedulerClass == 'YES'){executeDate = date.parse(Label.SchDateForTesting);} // For Run Manual
        }else{
            executeDate = system.today().addDays(7);
        } 
        system.debug('*** executeDate = ' + executeDate);
        
        Date tmp_date = date.newInstance(executeDate.year(),executeDate.month(),1);
        Date rangeDate_end = tmp_date.addDays(-1);
        Date rangeDate_start = date.newInstance(rangeDate_end.year(),rangeDate_end.month(),1);
        system.debug('*** rangeDate star & end = ' + rangeDate_start + ' | ' + rangeDate_end);
        
        String mdAccIds = Label.MediaSeller_AccIds_KertasKerja;
        mdAccIds = mdAccIds.trim();
        List<String> mdAccId_list = mdAccIds.split(',');
        system.debug('*** mdAccId_list = ' + mdAccId_list.size() + ' | ' + mdAccId_list);
        
        // Query UTMS
        AggregateResult[] utmsGroupByAccId_agr = null;
        
        if(!Test.isRunningTest()){
			utmsGroupByAccId_agr = [SELECT Media_Seller__c, SUM(Traffic_Bulk_Amount__c) sum_bulkAmount, SUM(Traffic_Non_Bulk_Amount__c) sum_nonBulkAmount 
                                                  FROM Usage_Traffic_Media_Seller__c 
                                                  WHERE Date__c >=: rangeDate_start
                                                  AND Date__c <=: rangeDate_end
                                                  AND Traffic_Type__c IN ('Bulk','Non Bulk') 
                                                  AND Media_Seller__c IN: mdAccId_list 
                                                  GROUP BY Media_Seller__c
                                                 ];
        }else{
        	utmsGroupByAccId_agr = [SELECT Media_Seller__c, SUM(Traffic_Bulk_Amount__c) sum_bulkAmount, SUM(Traffic_Non_Bulk_Amount__c) sum_nonBulkAmount 
                                                  FROM Usage_Traffic_Media_Seller__c 
                                                  WHERE Traffic_Type__c IN ('Bulk','Non Bulk') 
                                                  GROUP BY Media_Seller__c
                                                 ];
        }
        system.debug('*** utmsGroupByAccId_agr = ' + utmsGroupByAccId_agr.size() + ' | ' + utmsGroupByAccId_agr);
        
        List<Kertas_Kerja_Detail__c> kkdList = new List<Kertas_Kerja_Detail__c>();
        
        for (AggregateResult utms : utmsGroupByAccId_agr){
            
            Id mediaSellerId = (Id) utms.get('Media_Seller__c');
            Decimal amount_bulk = (Decimal) utms.get('sum_bulkAmount');
            if(amount_bulk == null){amount_bulk = 0;}
            Decimal amount_nonbulk = (Decimal) utms.get('sum_nonBulkAmount');
            if(amount_nonbulk == null){amount_nonbulk = 0;}
            
            String str_month = ((Datetime)rangeDate_start).format('MMM');
            String str_year = rangeDate_start.year().format().right(2);
            
            Kertas_Kerja_Detail__c kkd = new Kertas_Kerja_Detail__c();
			kkd.Kertas_Kerja_Detail_Name__c = 'Sum-' + str_month + str_year;
            kkd.Media_Seller__c = (Id) utms.get('Media_Seller__c');
            kkd.Start_Date__c = rangeDate_start;
            kkd.End_Date__c = rangeDate_end;
            kkd.Pembelian__c = null;
            kkd.Pengunaan__c = amount_bulk + amount_nonbulk;
            kkd.Type__c = 'Penggunaan';
            kkd.Month__c = ((Datetime)rangeDate_start).format('MMMM');
            kkd.Year__c = String.valueOf(rangeDate_start.year());
            kkdList.add(kkd);
        
        }
        system.debug('*** kkdList = ' + kkdList.size() + ' | ' + kkdList);
        
        insert kkdList;
    }
}