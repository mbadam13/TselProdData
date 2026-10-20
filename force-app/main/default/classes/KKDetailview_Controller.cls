Public class KKDetailview_Controller {   
    Public Kertas_Kerja__c kkRec {get; set;}   
    Public Kertas_Kerja_Detail__c KKDrec {get;set;}
    Public List<kkdetail_wrapper> kkdw_list {get; set;}
	Public String kk_id {get;set;}
    Public Decimal amounttemp {get;set;}
    Public ID KKD_ID {get;set;}
    Public Boolean isCreate;
    Public Boolean displayInputSection {get;set;}
    
    Public class kkdetail_wrapper{
       	Public String wkkdId {get;set;}
       	Public String wStartDate {get;set;}
       	Public String wEndDate {get;set;}
       	Public String wRemark {get;set;}
       	Public Decimal wPembelian {get;set;}
       	Public Decimal wPenggunaan {get;set;}
       	Public Decimal wSaldo {get;set;}        
	}
      
    Public KKDetailview_Controller(ApexPages.StandardController controller){
        isCreate = true;
        displayInputSection = false;
        
        KKDrec = new Kertas_Kerja_Detail__c();
        
        // -------------------------------------------------- Get Period (Month & Year) -------------------------------------------------- //
        
        kk_id = apexpages.currentpage().getparameters().get('id'); system.debug('*** kk_id = ' + kk_id);
        
        kkRec = [SELECT Id, Name, Kertas_Kerja_Name__c, Month__c, Year__c, Type__c, Media_Seller__c, Media_Seller_Name__c FROM Kertas_Kerja__c WHERE Id =: kk_id];
        system.debug('*** kkRec = ' + kkRec);
        
        
        String input_month = kkRec.Month__c;
        String input_year = kkRec.Year__c;       
       	Integer int_month = 0;
        switch on input_month {
            when 'January'   {int_month = 1;}
            when 'February'  {int_month = 2;}
            when 'March'     {int_month = 3;}
            when 'April'     {int_month = 4;}
            when 'May'       {int_month = 5;}
            when 'June'      {int_month = 6;}
            when 'July'      {int_month = 7;}
            when 'August'    {int_month = 8;}
            when 'September' {int_month = 9;}
            when 'October'   {int_month = 10;}
            when 'November'  {int_month = 11;}
            when 'December'  {int_month = 12;}
            when else {int_month = 1;}
        }
        
        Integer int_year = Integer.valueOf(input_year);
        system.debug('*** int_month | int_year = ' + int_month + ' | ' + int_year);

        Date startDate_temp = date.newInstance(int_year,int_month,1);
        Date endDate_temp = null;
        if(int_month == 12){
            endDate_temp = date.newInstance(int_year+1,1,1).addDays(-1);
        }else{
            endDate_temp = date.newInstance(int_year,int_month+1,1).addDays(-1);
        }
        system.debug('*** startDate_temp | endDate_temp = ' + startDate_temp + ' | ' + endDate_temp);
        
        // -------------------------------------------------- Get KKD -------------------------------------------------- //
        
        /*List<Kertas_Kerja_Detail__c> kkdList = [SELECT Id, Name, Kertas_Kerja_Detail_Name__c, Start_Date__c, End_Date__c, Pembelian__c, Pengunaan__c 
                                                FROM Kertas_Kerja_Detail__c 
                                               	WHERE Start_Date__c <=: endDate_temp 
                                                AND End_Date__c >=: startDate_temp 
                                                AND Media_Seller__c =: kkRec.Media_Seller__c 
                                                ORDER BY Start_Date__c ASC, Type_Formula__c ASC, Kertas_Kerja_Detail_Name__c ASC
                                               ];*/
        List<Kertas_Kerja_Detail__c> kkdList = [SELECT Id, Name, Kertas_Kerja_Detail_Name__c, Start_Date__c, End_Date__c, Pembelian__c, Pengunaan__c 
                                                FROM Kertas_Kerja_Detail__c 
                                               	WHERE Start_Date__c <=: endDate_temp 
                                                AND CALENDAR_YEAR(Start_Date__c) =: int_year 
                                                AND Media_Seller__c =: kkRec.Media_Seller__c 
                                                ORDER BY Start_Date__c ASC, Type_Formula__c ASC, Kertas_Kerja_Detail_Name__c ASC
                                               ];
        system.debug('*** kkdList = ' + kkdList.size() + ' | ' + kkdList);      
        kkdw_list = new List<kkdetail_wrapper>();
        Decimal prev_saldo = 0;
        
        for(Kertas_Kerja_Detail__c kkdRec : kkdList){
            
            Decimal pembelian = kkdRec.Pembelian__c;
            if(pembelian == null){pembelian = 0;}
            Decimal penggunaan = kkdRec.Pengunaan__c;
            if(penggunaan == null){penggunaan = 0;}
			
            system.debug('*** kkdRec.End_Date__c = ' + kkdRec.End_Date__c);
            
            /*Datetime ed = (Datetime)kkdRec.End_Date__c;
            system.debug('*** ed = ' + ed);*/
            
            kkdetail_wrapper kkdw_rec = new kkdetail_wrapper();
            kkdw_rec.wkkdId = kkdRec.Id;
            kkdw_rec.wStartDate = ((Datetime)kkdRec.Start_Date__c).format('dd-MMM-yyyy');
            kkdw_rec.wEndDate = ((Datetime)kkdRec.End_Date__c).format('dd-MMM-yyyy');
            //kkdw_rec.wEndDate = ed.format('dd-MMM-YYYY');
            kkdw_rec.wRemark = kkdRec.Kertas_Kerja_Detail_Name__c;
            kkdw_rec.wPembelian = kkdRec.Pembelian__c;
            kkdw_rec.wPenggunaan = kkdRec.Pengunaan__c; 
            kkdw_rec.wSaldo = prev_saldo + pembelian - penggunaan;
            kkdw_list.add(kkdw_rec);
            
            system.debug('*** kkdw_rec.wEndDate = ' + kkdw_rec.wEndDate);
           
            prev_saldo = kkdw_rec.wSaldo;
        }         
    }
      
           
    Public pagereference createkkd(){
        
        system.debug('*** MASUK method utk save kkd ! isCreate = ' + isCreate);
        
        KKDrec.Media_Seller__c = kkRec.Media_Seller__c;
   		if(KKDrec.Type__c=='Pembelian'){
        	KKDrec.Pembelian__c = amounttemp;
        }else if(KKDrec.Type__c=='Penggunaan'){
            KKDrec.Pengunaan__c = amounttemp;
        }
        
        if(KKDrec.Kertas_Kerja_Detail_Name__c == '' || KKDrec.Kertas_Kerja_Detail_Name__c == null 
           || KKDrec.Start_Date__c == null || KKDrec.Type__c == '' || KKDrec.Type__c == null || KKDrec.End_Date__c == null || amounttemp == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please Fill All Fields'));
            return null;
        }else{
            
            if (isCreate == true){
                insert KKDrec; 
            }else{
                update KKDrec;
            }
            
            displayInputSection = false;
            PageReference savekkid = new PageReference('/'+kkRec.Id);
            savekkid.setRedirect(true);
            return savekkid;  
        }
        
        
        /*if (isCreate == true){
            insert KKDrec; 
        }else{
            update KKDrec;
        }
        
        displayInputSection = false;
        PageReference savekkid = new PageReference('/'+kkRec.Id);
        savekkid.setRedirect(true);
        return savekkid;    */           
    }
    
       
    public PageReference EdittheSection(){
        
        isCreate = false;
        displayInputSection = true;
        
        system.debug('*** KKD_ID = ' + KKD_ID);
        
    	Kertas_Kerja_Detail__c KKDisi = [SELECT ID, Start_Date__c, End_Date__c, Kertas_Kerja_Detail_Name__c, Pembelian__c, Pengunaan__c, Media_Seller__c, Type__c
                      					 FROM Kertas_Kerja_Detail__c 
                                         WHERE Id =: KKD_ID
                                        ];
        system.debug('*** KKDisi = ' + KKDisi);
        
        KKDrec.Id = KKDisi.Id;
        KKDrec.Kertas_Kerja_Detail_Name__c = KKDisi.Kertas_Kerja_Detail_Name__c;
        KKDrec.Start_Date__c = KKDisi.Start_Date__c;
        KKDrec.End_Date__c = KKDisi.End_Date__c;
        KKDrec.Media_Seller__c = kkRec.Media_Seller__c;
        KKDrec.Type__c = KKDisi.Type__c;
        
        if(KKDrec.Type__c == 'Pembelian'){
            amounttemp = KKDisi.Pembelian__c;
        }else if(KKDrec.Type__c == 'Penggunaan'){
            amounttemp = KKDisi.Pengunaan__c;
        }
        
        system.debug('*** KKDrec = ' + KKDrec);
        
        return null;
    }
    
    public void addButton(){
        displayInputSection = true;
    }
    
    public void cancelButton(){
        KKDrec = new Kertas_Kerja_Detail__c();
        amounttemp = 0;
        displayInputSection = false;
    }

}