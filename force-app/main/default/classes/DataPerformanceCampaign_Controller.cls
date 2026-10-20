public class DataPerformanceCampaign_Controller {
   	
    public Data_Performance_Campaign__c dpcRec {get; set;}
    
    public List<OpportunityLineItem> oliList;
    public String pc_id;
    
    public Boolean Install_display {get; set;}
    public Boolean Install_Price_display {get; set;}
    public Boolean Register_Leads_display {get; set;}
    public Boolean Register_Leads_Price_display {get; set;}
    public Boolean Acquisition_All_Industries_display {get; set;}
    public Boolean Acquisition_All_Industries_Price_display {get; set;}
    public Boolean Acquisition_F_B_display {get; set;}
    public Boolean Acquisition_F_B_Price_display {get; set;}
    public Boolean Acquisition_FMCG_display {get; set;}
    public Boolean Acquisition_FMCG_Price_display {get; set;}
    public Boolean SMS_Bulk_display {get; set;}
    public Boolean GITA_1_GB_30_days_display {get; set;}
    public Boolean GITA_10_MB_1_day_display {get; set;}
    public Boolean GITA_100_MB_Content_Provider_display {get; set;}
    public Boolean GITA_100_MB_7_days_display {get; set;}
    public Boolean GITA_11_GB_30_days_display {get; set;}
    public Boolean GITA_110_MB_7_days_display {get; set;}
    public Boolean GITA_16_GB_30_days_display {get; set;}
    public Boolean GITA_2_GB_30_days_display {get; set;}
    public Boolean GITA_20_MB_1_day_display {get; set;}
    public Boolean GITA_250_MB_7_days_display {get; set;}
    public Boolean GITA_3_GB_30_days_display {get; set;}
    public Boolean GITA_30_GB_30_days_display {get; set;}
    public Boolean GITA_35_GB_30_days_display {get; set;}
    public Boolean GITA_4_GB_30_days_display {get; set;}
    public Boolean GITA_420_MB_30_days_display {get; set;}
    public Boolean GITA_5_GB_30_days_display {get; set;}
    public Boolean GITA_5_MB_1_day_display {get; set;}
    public Boolean GITA_50_MB_7_day_display {get; set;}
    public Boolean GITA_500_MB_30_days_display {get; set;}
    public Boolean GITA_750_MB_30_days_display {get; set;}
    public Boolean GITA_8_GB_30_days_display {get; set;}
    
    public List<Data_Performance_Campaign__c> dpc_list {get; set;}
    public Id param_dpcId {get;set;}
    public Boolean displayInputSection {get;set;}
    public PERFORMANCE_Campaign__c pcRec {get;set;}
    public Boolean isCreate {get;set;}
    public Boolean isEdit {get;set;}
    public List<hpc_wrapper> hpcw_list {get;set;}
    
    public Map<Id,Data_Performance_Campaign__c> map_test {get; set;}
    
    public Boolean viewAsOps {get; set;}
    
    public Boolean need_StampProductTargetPrice;
    
    public Decimal t_install {get; set;}
    public Decimal t_registerlead {get; set;}
    public Decimal t_acq_all_industries {get; set;}
    public Decimal t_acq_fb {get; set;}
    public Decimal t_acq_fmcg {get; set;}
    public Decimal p_install {get; set;}
    public Decimal p_registerlead {get; set;}
    public Decimal p_acq_all_industries {get; set;}
    public Decimal p_acq_fb {get; set;}
    public Decimal p_acq_fmcg {get; set;}
    
    public class hpc_wrapper{
       	public String wDpcId {get;set;}
       	public String wHpcId {get;set;}
       	public String wDpcName {get;set;}
       	public String wDate {get;set;}
       	public String wCampaignName {get;set;}
        
       	public Decimal wInstall {get;set;}
       	public Decimal wRegisterLeads {get;set;}
       	public Decimal wAcqAllIndusties {get;set;}
       	public Decimal wAcqFB {get;set;}
       	public Decimal wAcqFMCG {get;set;}
        
       	public Decimal wImpression {get;set;}
       	public Decimal wSunkCost {get;set;}
       	public Decimal wRevenue {get;set;}
       	public Decimal wPL {get;set;}
       	public Decimal wPLPercentage {get;set;}      
        
       	public String wRemark {get;set;}
        
        public Data_Performance_Campaign__c wDpc {get;set;}
	}
    
    public DataPerformanceCampaign_Controller(){
		
        hideAllProductDisplay();
        displayInputSection = false;
        isCreate = true;
        isEdit = false;
        
        viewAsOps = false;
        
        need_StampProductTargetPrice = false;
                
        pc_id = apexpages.currentPage().getparameters().get('id'); system.debug('*** pc_id = ' + pc_id);
        
        pcRec = [SELECT Id, Name, Opportunity__c, Start_Periode__c, End_Periode__c, 
                 		Target_Install__c, Target_Register_Leads__c	, Target_Acquisition_All_Industries__c, Target_Acquisition_F_B__c, Target_Acquisition_FMCG__c,
                 		Price_Install__c, Price_Register_Leads__c, Price_Acquisition_All_Industries__c, Price_Acquisition_F_B__c, Price_Acquisition_FMCG__c 
                 FROM PERFORMANCE_Campaign__c WHERE Id =: pc_id];
        system.debug('*** pcRec = ' + pcRec);
        
        t_install = pcRec.Target_Install__c;
        p_install = pcRec.Price_Install__c;
            
        t_registerlead = pcRec.Target_Register_Leads__c;
        p_registerlead = pcRec.Price_Register_Leads__c;
        
        t_acq_all_industries = pcRec.Target_Acquisition_All_Industries__c;
        p_acq_all_industries = pcRec.Price_Acquisition_All_Industries__c;
            
        t_acq_fb = pcRec.Target_Acquisition_F_B__c;
        p_acq_fb = pcRec.Price_Acquisition_F_B__c;
            
        t_acq_fmcg = pcRec.Target_Acquisition_FMCG__c;
        p_acq_fmcg = pcRec.Price_Acquisition_FMCG__c;
        
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name; system.debug('*** profileName = ' + profileName);
        
        if(profileName == 'Campaign Operation Manager' || profileName == 'System Administrator'){viewAsOps = true;}
        
        displayDpcInfo();
        
        queryDPC();
    }
    
    public void hideAllProductDisplay(){
        Install_display = false;
        Install_Price_display = false;
        Register_Leads_display = false;
        Register_Leads_Price_display = false;
        Acquisition_All_Industries_display = false;
        Acquisition_All_Industries_Price_display = false;
        Acquisition_F_B_display = false;
        Acquisition_F_B_Price_display = false;
        Acquisition_FMCG_display = false;
        Acquisition_FMCG_Price_display = false;
        SMS_Bulk_display = false;
        GITA_1_GB_30_days_display = false;
        GITA_10_MB_1_day_display = false;
        GITA_100_MB_Content_Provider_display = false;
        GITA_100_MB_7_days_display = false;
        GITA_11_GB_30_days_display = false;
        GITA_110_MB_7_days_display = false;
        GITA_16_GB_30_days_display = false;
        GITA_2_GB_30_days_display = false;
        GITA_20_MB_1_day_display = false;
        GITA_250_MB_7_days_display = false;
        GITA_3_GB_30_days_display = false;
        GITA_30_GB_30_days_display = false;
        GITA_35_GB_30_days_display = false;
        GITA_4_GB_30_days_display = false;
        GITA_420_MB_30_days_display = false;
        GITA_5_GB_30_days_display = false;
        GITA_5_MB_1_day_display = false;
        GITA_50_MB_7_day_display = false;
        GITA_500_MB_30_days_display = false;
        GITA_750_MB_30_days_display = false;
        GITA_8_GB_30_days_display = false;

    }
    
    public void displayDpcInfo(){
        
        dpcRec = new Data_Performance_Campaign__c();
        
        dpcRec.PERFORMANCE_Campaign__c = pcRec.Id;
        
        oliList = [SELECT Id, Name, Product2Id, Product2.Name, UnitPrice, Quantity FROM OpportunityLineItem 
                   WHERE OpportunityId =: pcRec.Opportunity__c
                   AND Product2.IsActive = true
                   AND (Product2.ProductCode IN ('Performance','Reward') OR Product2.Name = 'BULK (SMS Basic)')
                   ORDER BY CreatedDate ASC
                  ];
        system.debug('*** oliList = ' + oliList.size() + ' | ' + oliList);
        
        for(OpportunityLineItem oli : oliList){
			String productName = oli.Product2.Name;			
            
            if(productName == 'Performance CPI (All Industries)'){
                Install_display = true;
                Install_Price_display = true;
                if(dpcRec.Install_Price__c == null)
                	{dpcRec.Install_Price__c = oli.UnitPrice;}
                if(pcRec.Price_Install__c == null || pcRec.Target_Install__c == null){
                    pcRec.Price_Install__c = oli.UnitPrice;
                    pcRec.Target_Install__c = oli.Quantity;
                    need_StampProductTargetPrice = true;
                }
            }else if(productName == 'Performance CPL (All Industries)'){
                Register_Leads_display = true;
                Register_Leads_Price_display = true;
                if(dpcRec.Register_Leads_Price__c == null)
                	{dpcRec.Register_Leads_Price__c = oli.UnitPrice;}
                if(pcRec.Price_Register_Leads__c == null || pcRec.Target_Register_Leads__c == null){
                    pcRec.Price_Register_Leads__c = oli.UnitPrice;
                    pcRec.Target_Register_Leads__c = oli.Quantity;
                    need_StampProductTargetPrice = true;
                }
            }else if(productName == 'Performance CPA (All Industries)'){
                Acquisition_All_Industries_display = true;
        		Acquisition_All_Industries_Price_display = true;
                if(dpcRec.Acquisition_All_Industries_Price__c == null)
                	{dpcRec.Acquisition_All_Industries_Price__c = oli.UnitPrice;}
                if(pcRec.Price_Acquisition_All_Industries__c == null || pcRec.Target_Acquisition_All_Industries__c == null){
                    pcRec.Price_Acquisition_All_Industries__c = oli.UnitPrice;
                    pcRec.Target_Acquisition_All_Industries__c = oli.Quantity;
                    need_StampProductTargetPrice = true;
                }
            }else if(productName == 'Performance CPA (F&B)'){
                Acquisition_F_B_display = true;
        		Acquisition_F_B_Price_display = true;
                if(dpcRec.Acquisition_F_B_Price__c == null)
                	{dpcRec.Acquisition_F_B_Price__c = oli.UnitPrice;}
                if(pcRec.Price_Acquisition_F_B__c == null || pcRec.Target_Acquisition_F_B__c == null){
                    pcRec.Price_Acquisition_F_B__c = oli.UnitPrice;
                    pcRec.Target_Acquisition_F_B__c = oli.Quantity;
                    need_StampProductTargetPrice = true;
                }
            }else if(productName == 'Performance CPA (FMCG)'){
                Acquisition_FMCG_display = true;
        		Acquisition_FMCG_Price_display = true;
                if(dpcRec.Acquisition_FMCG_Price__c == null)
                	{dpcRec.Acquisition_FMCG_Price__c = oli.UnitPrice;}
                if(pcRec.Price_Acquisition_FMCG__c == null || pcRec.Target_Acquisition_FMCG__c == null){
                    pcRec.Price_Acquisition_FMCG__c = oli.UnitPrice;
                    pcRec.Target_Acquisition_FMCG__c = oli.Quantity;
                    need_StampProductTargetPrice = true;
                }
            }else if(productName == 'BULK (SMS Basic)'){
                SMS_Bulk_display = true;
            }
            
            else if(productName == 'GITA | 1 GB 30 days'){GITA_1_GB_30_days_display = true;}
            else if(productName == 'GITA | 10 MB 1 day'){GITA_10_MB_1_day_display = true;}
            else if(productName == 'GITA | 100 MB (Content Provider)'){GITA_100_MB_Content_Provider_display = true;}
            else if(productName == 'GITA | 100 MB 7 days'){GITA_100_MB_7_days_display = true;}
            
            else if(productName == 'GITA | 11 GB 30 days'){GITA_11_GB_30_days_display = true;}
            else if(productName == 'GITA | 110 MB 7 days'){GITA_110_MB_7_days_display = true;}
            else if(productName == 'GITA | 16 GB 30 days'){GITA_16_GB_30_days_display = true;}
            else if(productName == 'GITA | 2 GB 30 days'){GITA_2_GB_30_days_display = true;}
            else if(productName == 'GITA | 20 MB 1 day'){GITA_20_MB_1_day_display = true;}
            else if(productName == 'GITA | 250 MB 7 days'){GITA_250_MB_7_days_display = true;}
            else if(productName == 'GITA | 3 GB 30 days'){GITA_3_GB_30_days_display = true;}
            else if(productName == 'GITA | 30 GB 30 days'){GITA_30_GB_30_days_display = true;}
            else if(productName == 'GITA | 35 GB 30 days'){GITA_35_GB_30_days_display = true;}
            else if(productName == 'GITA | 4 GB 30 days'){GITA_4_GB_30_days_display = true;}
            
            else if(productName == 'GITA | 420 MB 30 days'){GITA_420_MB_30_days_display = true;}
            else if(productName == 'GITA | 5 GB 30 days'){GITA_5_GB_30_days_display = true;}
            else if(productName == 'GITA | 5 MB 1 day'){GITA_5_MB_1_day_display = true;}
            else if(productName == 'GITA | 50 MB 7 day'){GITA_50_MB_7_day_display = true;}
            else if(productName == 'GITA | 500 MB 30 days'){GITA_500_MB_30_days_display = true;}
            else if(productName == 'GITA | 750 MB 30 days'){GITA_750_MB_30_days_display = true;}
            else if(productName == 'GITA | 8 GB 30 days'){GITA_8_GB_30_days_display = true;}
        }
    }
    
    public void queryDPC(){
        dpc_list = [SELECT Id, Name, Date__c, Performance_Campaign__c, Historical_Campaign_Performance__c, 
                   		Historical_Campaign_Performance__r.Sunk_Cost__c, Historical_Campaign_Performance__r.Revenue__c,
                        Historical_Campaign_Performance__r.P_L__c, Historical_Campaign_Performance__r.P_L_Percentage__c,
                    	Sunk_Cost__c, Revenue__c, Performance_Campaign__r.Campaign_Name__c, Performance_Campaign__r.Campaign_Name__r.Name, Impression__c,
                    	Install__c, Register_Leads__c, Acquisition_All_Industries__c, Acquisition_F_B__c, Acquisition_FMCG__c, Remark__c 
                   	FROM Data_Performance_Campaign__c 
                    WHERE Performance_Campaign__c =: pc_id 
                   	ORDER BY Date__c ASC
                   ];
        system.debug('*** dpc_list = ' + dpc_list.size() + ' | ' + dpc_list);
        
        hpcw_list = new List<hpc_wrapper>();
        
        Decimal temp_impression = 0;
        Decimal temp_sunkcost = 0;
        Decimal temp_revenue = 0;
        
        map_test = new Map<Id,Data_Performance_Campaign__c>();
        
        for(Data_Performance_Campaign__c dpc : dpc_list){
            
            if(dpc.Impression__c == null){dpc.Impression__c = 0;}
            
            hpc_wrapper hpcw_rec = new hpc_wrapper();
            hpcw_rec.wDpcId = dpc.Id;
            hpcw_rec.wHpcId  = dpc.Historical_Campaign_Performance__c;
            hpcw_rec.wDpcName = dpc.Name;
            hpcw_rec.wDate = ((Datetime)dpc.Date__c).format('dd/MM/yyyy');
            hpcw_rec.wCampaignName = dpc.Performance_Campaign__r.Campaign_Name__r.Name;
            
            system.debug('*** dpc.Acquisition_FMCG__c = ' + dpc.Acquisition_FMCG__c);
            
            hpcw_rec.wInstall = dpc.Install__c;
            hpcw_rec.wRegisterLeads = dpc.Register_Leads__c;
            hpcw_rec.wAcqAllIndusties = dpc.Acquisition_All_Industries__c;
            hpcw_rec.wAcqFB = dpc.Acquisition_F_B__c;
            hpcw_rec.wAcqFMCG = dpc.Acquisition_FMCG__c;
            
            hpcw_rec.wImpression = temp_impression + dpc.Impression__c;
            hpcw_rec.wSunkCost = temp_sunkcost + dpc.Sunk_Cost__c;
            hpcw_rec.wRevenue = temp_revenue + dpc.Revenue__c;
            hpcw_rec.wPL = hpcw_rec.wRevenue - hpcw_rec.wSunkCost;
            if(hpcw_rec.wSunkCost == 0){
                hpcw_rec.wPLPercentage = 0;
            }else{
                hpcw_rec.wPLPercentage = (hpcw_rec.wPL/hpcw_rec.wSunkCost)*100;
            }
            
            hpcw_rec.wRemark = dpc.Remark__c;
            
            hpcw_rec.wDpc = dpc;
            
            hpcw_list.add(hpcw_rec);
            
            temp_impression = hpcw_rec.wImpression;
            temp_sunkcost = hpcw_rec.wSunkCost;
            temp_revenue = hpcw_rec.wRevenue;
            
            map_test.put(dpc.Id,dpc);
        }
    }
    
    public PageReference GetProductTargetPrice(){
        
        if(need_StampProductTargetPrice == true){
        	update pcRec;
        }
                
        PageReference pc_page = new PageReference('/'+pc_id);
        //savekkid.setRedirect(true);
        return pc_page;
    }
        
    public PageReference saveButton(){   
        
        if(pcRec.Start_Periode__c == null || pcRec.End_Periode__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please set Performance Campaign Period (Start & End Date).'));
            return null;
        }
        
        if(dpcRec.Date__c == null || dpcRec.Impression__c == null || dpcRec.Harga_COGS_SMS__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please fill Date, Impression & Harga COGS SMS.'));
            return null;
        }
        
        List<Data_Performance_Campaign__c> dpcList_check = [SELECT Id, Name, Date__c
                                                            FROM Data_Performance_Campaign__c 
                                                            WHERE Performance_Campaign__c =: pc_id
                                                            ORDER BY Date__c DESC
                                                           ];
        system.debug('*** dpcList_check = ' + dpcList_check.size() + ' | ' + dpcList_check);
        
        if(dpcRec.Date__c >= pcRec.Start_Periode__c && dpcRec.Date__c <= pcRec.End_Periode__c){
            if(dpcList_check.size() > 0){
                if(dpcRec.Date__c != dpcList_check[0].Date__c.addDays(1) && isCreate == true){
                    Datetime dt = dpcList_check[0].Date__c.addDays(1);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please fill Date sequentially "'+ dt.format('dd/MM/yyyy') +'"'));
                	return null;
                }
            }
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please fill Date within Performance Campaign Period.'));
            return null;
        }
        
        if (isCreate == true){
        	insert dpcRec; 
        }else{
        	update dpcRec;
        }
        
        queryDPC();
        updateHPC();
        
       	PageReference pc_page = new PageReference('/'+pc_id);
        //savekkid.setRedirect(true);
        return pc_page;
                
    }
    
    public void addButton(){
        isCreate = true;
        isEdit = false;
        displayInputSection = true;
    }
    
    public PageReference editLink(){
        
        isCreate = false;
        isEdit = true;
        displayInputSection = true;
        
        Data_Performance_Campaign__c dpcExistingRec = [SELECT Id, Name, Date__c, Harga_COGS_SMS__c, Impression__c, Click__c, Install__c, Install_Price__c,
                                                      	Register_Leads__c, Register_Leads_Price__c, Acquisition_All_Industries__c, Acquisition_All_Industries_Price__c,
                                                      	Acquisition_F_B__c, Acquisition_F_B_Price__c, Acquisition_FMCG__c, Acquisition_FMCG_Price__c, SMS_Bulk__c,
                                                       	GITA_1_GB_30_days__c, GITA_10_MB_1_day__c, GITA_100_MB_Content_Provider__c, GITA_100_MB_7_days__c,
                                                       	GITA_11_GB_30_days__c, GITA_110_MB_7_days__c, GITA_16_GB_30_days__c, GITA_2_GB_30_days__c, GITA_20_MB_1_day__c,
                                                       	GITA_250_MB_7_days__c, GITA_3_GB_30_days__c, GITA_30_GB_30_days__c, GITA_35_GB_30_days__c, GITA_4_GB_30_days__c,
                                                       	GITA_420_MB_30_days__c, GITA_5_GB_30_days__c, GITA_5_MB_1_day__c, GITA_50_MB_7_day__c, GITA_500_MB_30_days__c,
                                                       	GITA_750_MB_30_days__c, GITA_8_GB_30_days__c, Remark__c 
                                                       FROM Data_Performance_Campaign__c 
                                                       WHERE Id =: param_dpcId
                                                      ];
        system.debug('*** dpcExistingRec = ' + dpcExistingRec);
        
        dpcRec.Id = dpcExistingRec.Id;
        dpcRec.Date__c = dpcExistingRec.Date__c;
        dpcRec.Harga_COGS_SMS__c = dpcExistingRec.Harga_COGS_SMS__c;
        dpcRec.Impression__c = dpcExistingRec.Impression__c;
        dpcRec.Click__c = dpcExistingRec.Click__c;
        dpcRec.Install__c = dpcExistingRec.Install__c;
        dpcRec.Install_Price__c = dpcExistingRec.Install_Price__c;
        dpcRec.Register_Leads__c = dpcExistingRec.Register_Leads__c;
        dpcRec.Register_Leads_Price__c = dpcExistingRec.Register_Leads_Price__c;
        dpcRec.Acquisition_All_Industries__c = dpcExistingRec.Acquisition_All_Industries__c;
        dpcRec.Acquisition_All_Industries_Price__c = dpcExistingRec.Acquisition_All_Industries_Price__c;
        dpcRec.Acquisition_F_B__c = dpcExistingRec.Acquisition_F_B__c;
        dpcRec.Acquisition_F_B_Price__c = dpcExistingRec.Acquisition_F_B_Price__c;
        dpcRec.Acquisition_FMCG__c = dpcExistingRec.Acquisition_FMCG__c;
        dpcRec.Acquisition_FMCG_Price__c = dpcExistingRec.Acquisition_FMCG_Price__c;
        dpcRec.SMS_Bulk__c = dpcExistingRec.SMS_Bulk__c;
        dpcRec.Remark__c = dpcExistingRec.Remark__c;
        dpcRec.GITA_1_GB_30_days__c = dpcExistingRec.GITA_1_GB_30_days__c;
        dpcRec.GITA_10_MB_1_day__c = dpcExistingRec.GITA_10_MB_1_day__c;
        dpcRec.GITA_100_MB_Content_Provider__c = dpcExistingRec.GITA_100_MB_Content_Provider__c;
        dpcRec.GITA_100_MB_7_days__c = dpcExistingRec.GITA_100_MB_7_days__c;
        dpcRec.GITA_11_GB_30_days__c = dpcExistingRec.GITA_11_GB_30_days__c;
        dpcRec.GITA_110_MB_7_days__c = dpcExistingRec.GITA_110_MB_7_days__c;
        dpcRec.GITA_16_GB_30_days__c = dpcExistingRec.GITA_16_GB_30_days__c;
        dpcRec.GITA_2_GB_30_days__c = dpcExistingRec.GITA_2_GB_30_days__c;
        dpcRec.GITA_20_MB_1_day__c = dpcExistingRec.GITA_20_MB_1_day__c;
        dpcRec.GITA_250_MB_7_days__c = dpcExistingRec.GITA_250_MB_7_days__c;
        dpcRec.GITA_3_GB_30_days__c = dpcExistingRec.GITA_3_GB_30_days__c;
        dpcRec.GITA_30_GB_30_days__c = dpcExistingRec.GITA_30_GB_30_days__c;
        dpcRec.GITA_35_GB_30_days__c = dpcExistingRec.GITA_35_GB_30_days__c;
        dpcRec.GITA_4_GB_30_days__c = dpcExistingRec.GITA_4_GB_30_days__c;
        dpcRec.GITA_420_MB_30_days__c = dpcExistingRec.GITA_420_MB_30_days__c;
        dpcRec.GITA_5_GB_30_days__c = dpcExistingRec.GITA_5_GB_30_days__c;
        dpcRec.GITA_5_MB_1_day__c = dpcExistingRec.GITA_5_MB_1_day__c;
        dpcRec.GITA_50_MB_7_day__c = dpcExistingRec.GITA_50_MB_7_day__c;
        dpcRec.GITA_500_MB_30_days__c = dpcExistingRec.GITA_500_MB_30_days__c;
        dpcRec.GITA_750_MB_30_days__c = dpcExistingRec.GITA_750_MB_30_days__c;
        dpcRec.GITA_8_GB_30_days__c = dpcExistingRec.GITA_8_GB_30_days__c;
        
        return null;
    }
    
    public void cancelButton(){
        displayDpcInfo();
        displayInputSection = false;
    }
    
    public void updateHPC(){
        
        system.debug('*** Masuk updateHPC !!!');
        
        List<Historical_Campaign_Performance__c> hpc_list = new List<Historical_Campaign_Performance__c>();
        
        for(hpc_wrapper hpcw : hpcw_list){
            
            system.debug('*** hpcw.wHpcId updateHPC = ' + hpcw.wHpcId);
            
            if(hpcw.wHpcId != null){
                Historical_Campaign_Performance__c hpc_rec = new Historical_Campaign_Performance__c();
                hpc_rec.Id = hpcw.wHpcId;
                hpc_rec.Date__c = Date.parse(hpcw.wDate);
                hpc_rec.Campaign_Name__c = hpcw.wCampaignName;
                
                system.debug('*** hpcw.wAcqFMCG updateHPC = ' + hpcw.wAcqFMCG);
                
                hpc_rec.Install__c = hpcw.wInstall;
                hpc_rec.Register_Leads__c = hpcw.wRegisterLeads;
                hpc_rec.Acquisition_All_Industries__c = hpcw.wAcqAllIndusties;
                hpc_rec.Acquisition_F_B__c = hpcw.wAcqFB;
                hpc_rec.Acquisition_FMCG__c= hpcw.wAcqFMCG;
                
                system.debug('*** hpc_rec.Acquisition_FMCG__c updateHPC = ' + hpc_rec.Acquisition_FMCG__c);
                
                hpc_rec.Impression__c = hpcw.wImpression;
                hpc_rec.Sunk_Cost__c = hpcw.wSunkCost;
                hpc_rec.Revenue__c = hpcw.wRevenue;
                hpc_rec.P_L__c = hpcw.wPL;
                hpc_rec.P_L_Percentage__c = hpcw.wPLPercentage;
                hpc_list.add(hpc_rec);
            }
        }
        
        system.debug('*** hpc_list updateHPC = ' + hpc_list.size() + ' | ' + hpc_list);
        update hpc_list;
        
        Performance_Campaign__c pc_rec = new Performance_Campaign__c();
        pc_rec.Id = pc_id;
        pc_rec.Last_Update_History__c = system.now();
        update pc_rec;
    }
}