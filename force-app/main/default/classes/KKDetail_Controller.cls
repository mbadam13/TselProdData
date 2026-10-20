public class KKDetail_Controller {
    
    public Kertas_Kerja__c kkRec {get; set;}
    public List<kkdetail_wrapper> kkdw_list {get; set;}
    public String str_pdfGenerateDate {get; set;}
    
    public class kkdetail_wrapper{
       	public String wkkdId {get;set;}
       	public String wStartDate {get;set;}
       	public String wEndDate {get;set;}
       	public String wRemark {get;set;}
       	public Decimal wPembelian {get;set;}
       	public Decimal wPenggunaan {get;set;}
       	public Decimal wSaldo {get;set;}        
	}
    
    public KKDetail_Controller(ApexPages.StandardController controller){
        
        str_pdfGenerateDate = system.now().format('dd MMMM YYYY');
        
        // -------------------------------------------------- Get Period (Month & Year) -------------------------------------------------- //
        
        String kk_id = apexpages.currentpage().getparameters().get('id'); system.debug('*** kk_id = ' + kk_id);
        
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
            
            kkdetail_wrapper kkdw_rec = new kkdetail_wrapper();
            kkdw_rec.wkkdId = kkdRec.Id;
            kkdw_rec.wStartDate = ((Datetime)kkdRec.Start_Date__c).format('dd-MMM-yyyy');
            kkdw_rec.wEndDate = ((Datetime)kkdRec.End_Date__c).format('dd-MMM-yyyy');
            kkdw_rec.wRemark = kkdRec.Kertas_Kerja_Detail_Name__c;
            kkdw_rec.wPembelian = kkdRec.Pembelian__c;
            kkdw_rec.wPenggunaan = kkdRec.Pengunaan__c; 
            kkdw_rec.wSaldo = prev_saldo + pembelian - penggunaan;
            kkdw_list.add(kkdw_rec);
            
            prev_saldo = kkdw_rec.wSaldo;
        }
        
    }

}