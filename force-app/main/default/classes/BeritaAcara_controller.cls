public class BeritaAcara_controller {
    
    public Berita_Acara__c baRec {get; set;}
    public String pubName {get; set;}
    public String periodBA {get; set;}
    
    public AggregateResult[] arTraffic {get; set;}
    public AggregateResult[] arTrafficGroupByDsSite {get; set;}
    public AggregateResult[] arTrafficDS {get; set;}
    
    public List<String> demandSourceList {get; set;} 
    public Map<String,List<String>> map_demandSource_siteList {get; set;}
    public Map<String,List<Wrap_arTraffic>> map_demandSourceSite_wrapArTrafficList {get; set;}
    public Map<String,List<Wrap_arTrafficGroupByDsSite>> map_demandSource_wrapArTrafficGroupByDsSiteList {get; set;}
    public Map<String,Wrap_calcRev> map_demandSource_wrapCalcRev {get; set;}
    public Decimal gTotalInVat_usd {get; set;}
    public Decimal gTotalExVat_usd {get; set;}
    public Decimal gTotalInVat_idr {get; set;}
    public Decimal gTotalExVat_idr {get; set;}
    
    public Decimal techFee {get; set;}
    public Decimal share {get; set;}
    public Decimal totalShare {get; set;}
    public Decimal vatPercentage {get; set;}
    public Decimal vat {get; set;}
    public String text_grandTotalPublisher {get; set;}
    
    public class Wrap_arTraffic{
        public String wDemandSource {get;set;}
        public String wSiteName {get;set;}
        public String wDemandSourceSite {get;set;}
        public String wDeal {get;set;}
        public Decimal wRevUSD {get;set;}
        public Decimal wRevIDR {get;set;}
    }
    
    public class Wrap_arTrafficGroupByDsSite{
        public String wDemandSource {get;set;}
        public String wSiteName {get;set;}
        public Decimal wRevUSD {get;set;}
        public Decimal wRevIDR {get;set;}
    }
    
    public class Wrap_calcRev{
        public String wDemandSource {get;set;}
        public Decimal wCalcA_usd {get;set;}
        public Decimal wCalcB_usd {get;set;}
        public Decimal wCalcC_usd {get;set;}
        public Decimal wCalcD_usd {get;set;}
        public Decimal wCalcE_usd {get;set;}
        public Decimal wCalcF_usd {get;set;}
        public Decimal wCalcA_idr {get;set;}
        public Decimal wCalcB_idr {get;set;}
        public Decimal wCalcC_idr {get;set;}
        public Decimal wCalcD_idr {get;set;}
        public Decimal wCalcE_idr {get;set;}
        public Decimal wCalcF_idr {get;set;}
        public Decimal wTechFee {get;set;}
        public Decimal wShare {get;set;}
        public Decimal wShareTotal {get;set;}
        public Decimal wSharePublisher {get;set;}
    }
    
    public BeritaAcara_controller(ApexPages.StandardController controller){
        
        system.debug('*** BeritaAcara_controller CONSTRUCTOR !!!');
        
        String ba_id = apexpages.currentpage().getparameters().get('id'); system.debug('*** ba_id = ' + ba_id);
        
        baRec = [SELECT Id, Name, Month__c, Year__c,/*BAST_No__c,*/ Exchange_Rate__c, Account__c, Account__r.Name, Createddate,
                 		Tech_Fee_for_PMP_Tadex__c, Tech_Fee_for_PMP_Client__c, Tech_Fee_for_OMP__c
                 FROM Berita_Acara__c WHERE Id =: ba_id];
        system.debug('*** baRec = ' + baRec);
           
        pubName = baRec.Account__r.Name.remove('.');
        pubName = pubName.replace(' ','_');
        system.debug('*** pubName = ' + pubName);
        
        periodBA = baRec.Month__c + ' ' + baRec.Year__c;
        
        String BA_month = '';
        switch on baRec.Month__c {
            when 'January'   {BA_month = '1';}
            when 'February'  {BA_month = '2';}
            when 'March'     {BA_month = '3';}
            when 'April'     {BA_month = '4';}
            when 'May'       {BA_month = '5';}
            when 'June'      {BA_month = '6';}
            when 'July'      {BA_month = '7';}
            when 'August'    {BA_month = '8';}
            when 'September' {BA_month = '9';}
            when 'October'   {BA_month = '10';}
            when 'November'  {BA_month = '11';}
            when 'December'  {BA_month = '12';}
            when else {BA_month = '01';}
        }
        system.debug('month' + BA_month );
        
        integer month 	= integer.valueOf(BA_month); system.debug('bulan' + month);
       	integer year 	= Integer.ValueOf(baRec.Year__c); system.debug('tahun' + year);
		Date baDate		= Date.newInstance(year, month, 1); system.debug('tanggal' + baDate);
       
        DateTime dT 	= baRec.CreatedDate;
		Date baCrdate 	= dT.date();

        if(baDate >=  Date.newInstance(2022, 03, 01) || baCrDate >= Date.newInstance(2022, 4, 1)){
            vatPercentage = 11;
            vat = 1.11;
        }else{
            vatPercentage = 10;
            vat = 1.1;
		}
        
        map_demandSource_wrapArTrafficGroupByDsSiteList = new Map<String,List<Wrap_arTrafficGroupByDsSite>>();
        
        // Get aggregate traffic by BA (Account & Period) and grouping by Demand Source & Site
        arTrafficGroupByDsSite = [SELECT Demand_Source__c demandSource, Sites__r.siteUrl__c siteName, SUM(Revenue_USD__c) sumRevUsd, SUM(Amount_IDR__c) sumRevIdr 
                                  FROM Traffic__c 
                                  WHERE Berita_Acara__c =: ba_id 
                                  GROUP BY Demand_Source__c, Sites__r.siteUrl__c
                                  ORDER BY Demand_Source__c, Sites__r.siteUrl__c ASC];
        system.debug('*** arTrafficGroupByDsSite = ' + arTrafficGroupByDsSite.size() + ' | ' + arTrafficGroupByDsSite);
        
        for (AggregateResult ar : arTrafficGroupByDsSite)  {
            
            system.debug('**** ar ' + ar);
            
            Wrap_arTrafficGroupByDsSite wat = new Wrap_arTrafficGroupByDsSite();
            wat.wDemandSource = String.valueOf(ar.get('demandSource'));
            wat.wSiteName = String.valueOf(ar.get('siteName'));
            wat.wRevUSD = Decimal.valueOf(String.valueOf(ar.get('sumRevUsd')));
            wat.wRevIDR = Decimal.valueOf(String.valueOf(ar.get('sumRevIdr')));
            system.debug('*** wat = ' + wat);
            
            List<Wrap_arTrafficGroupByDsSite> wrapArTrafficGroupByDsSiteList_temp = new List<Wrap_arTrafficGroupByDsSite>();
            if(map_demandSource_wrapArTrafficGroupByDsSiteList.containsKey(wat.wDemandSource)){
                wrapArTrafficGroupByDsSiteList_temp = map_demandSource_wrapArTrafficGroupByDsSiteList.get(wat.wDemandSource);
                wrapArTrafficGroupByDsSiteList_temp.add(wat);
                map_demandSource_wrapArTrafficGroupByDsSiteList.remove(wat.wDemandSource);
                map_demandSource_wrapArTrafficGroupByDsSiteList.put(wat.wDemandSource,wrapArTrafficGroupByDsSiteList_temp);
            }else{
                wrapArTrafficGroupByDsSiteList_temp.add(wat);
                map_demandSource_wrapArTrafficGroupByDsSiteList.put(wat.wDemandSource,wrapArTrafficGroupByDsSiteList_temp);
            }
            
        }
        system.debug('*** map_demandSource_wrapArTrafficGroupByDsSiteList = ' + map_demandSource_wrapArTrafficGroupByDsSiteList.size() + ' | ' + map_demandSource_wrapArTrafficGroupByDsSiteList);
        
        // Get aggregate traffic by BA (Account & Period) and grouping by Demand Source, Site & Deal
        arTraffic = [SELECT Demand_Source__c demandSource, Sites__r.siteUrl__c siteName, Deal__c, SUM(Revenue_USD__c) sumRevUsd, SUM(Amount_IDR__c) sumRevIdr 
                     FROM Traffic__c 
                     WHERE Berita_Acara__c =: ba_id 
                     GROUP BY Demand_Source__c, Sites__r.siteUrl__c, Deal__c 
                     ORDER BY Demand_Source__c, Sites__r.siteUrl__c, Deal__c ASC];
        system.debug('*** arTraffic = ' + arTraffic.size() + ' | ' + arTraffic);
        
        demandSourceList = new List<String>();
        map_demandSource_siteList = new Map<String,List<String>>();
        map_demandSourceSite_wrapArTrafficList = new Map<String,List<Wrap_arTraffic>>();
        
        for (AggregateResult ar : arTraffic)  {
            
            system.debug('**** ar ' + ar);
            
            // Get Demand Source
            String str_demandSource = String.valueOf(ar.get('demandSource'));          system.debug('*** str_demandSource = ' + str_demandSource);
            
            // Get Site Name
            String str_siteName = String.valueOf(ar.get('siteName'));				   								system.debug('*** str_siteName awal = ' + str_siteName);
            if(str_siteName.contains('|')){
                str_siteName = str_siteName.remove('TADEX|');
                String str_siteName_mid1 = str_siteName.substringBefore('|');
                String str_siteName_end = str_siteName.substringAfter('|');
                String str_siteName_mid2 = str_siteName_end.substringBefore('|');
                str_siteName_end = str_siteName_end.substringAfter('|');
                str_siteName = 'TADEX|' + str_siteName_mid1 + '|' + str_siteName_mid2 + '| ' + str_siteName_end;	system.debug('*** str_siteName akhir | = ' + str_siteName);
            }else{
                if(str_siteName.length() > 40){
                    str_siteName = str_siteName.substringBefore('-') + '- ' + str_siteName.substringAfter('-');		system.debug('*** str_siteName akhir else | = ' + str_siteName);
                }
            }
            
            // Get Deal & Revenue
            String str_deal = String.valueOf(ar.get('Deal__c'));                       system.debug('*** str_deal = ' + str_deal);
            Decimal dcm_revUSD = Decimal.valueOf(String.valueOf(ar.get('sumRevUsd'))); system.debug('*** dcm_revUSD = ' + dcm_revUSD);
            Decimal dcm_revIDR = Decimal.valueOf(String.valueOf(ar.get('sumRevIdr'))); system.debug('*** dcm_revIDR = ' + dcm_revIDR);
            
            // Create List Demand Source & Map for Demand Source with Site List
            List<String> siteList_temp = new List<String>();
            if(demandSourceList.contains(str_demandSource)){
                siteList_temp = map_demandSource_siteList.get(str_demandSource);
                if(!siteList_temp.contains(str_siteName)){
                    siteList_temp.add(str_siteName);
                    map_demandSource_siteList.remove(str_demandSource);
                    map_demandSource_siteList.put(str_demandSource,siteList_temp);
                }
                system.debug('*** map_demandSource_siteList if = ' + map_demandSource_siteList);
            }else{
                demandSourceList.add(str_demandSource);
                siteList_temp.add(str_siteName);
                map_demandSource_siteList.put(str_demandSource,siteList_temp);
                system.debug('*** map_demandSource_siteList else = ' + map_demandSource_siteList);
            }
            
            // Create temporary instance and map for traffic aggregate with new format of Site Name (for display only)
            String demandSourceSite = str_demandSource + '--' + str_siteName;
            
            Wrap_arTraffic wat = new wrap_arTraffic();
            wat.wDemandSource = str_demandSource;
            wat.wSiteName = str_siteName;
            wat.wDemandSourceSite = demandSourceSite;
            wat.wDeal = str_deal;
            wat.wRevUSD = dcm_revUSD;
            wat.wRevIDR =dcm_revIDR;
            system.debug('*** wat = ' + wat);
            
            List<Wrap_arTraffic> wrapArTrafficList_temp = new List<Wrap_arTraffic>();
            if(map_demandSourceSite_wrapArTrafficList.keySet().contains(demandSourceSite)){
                wrapArTrafficList_temp = map_demandSourceSite_wrapArTrafficList.get(demandSourceSite);
                wrapArTrafficList_temp.add(wat);
                map_demandSourceSite_wrapArTrafficList.remove(demandSourceSite);
                map_demandSourceSite_wrapArTrafficList.put(demandSourceSite,wrapArTrafficList_temp);
            } else {
                wrapArTrafficList_temp.add(wat);
                map_demandSourceSite_wrapArTrafficList.put(demandSourceSite,wrapArTrafficList_temp);
            }
        }
        system.debug('*** map_demandSource_siteList = ' + map_demandSource_siteList.size() + ' | ' + map_demandSource_siteList);
        system.debug('*** map_demandSourceSite_wrapArTrafficList = ' + map_demandSourceSite_wrapArTrafficList.size() + ' | ' + map_demandSourceSite_wrapArTrafficList);
        
        // Get aggregate traffic by BA (Account & Period) and grouping by Demand Source
        arTrafficDS = [SELECT Demand_Source__c demandSource, SUM(Revenue_USD__c) sumRevUsd, SUM(Amount_IDR__c) sumRevIdr 
                       FROM Traffic__c 
                       WHERE Berita_Acara__c =: ba_id 
                       GROUP BY Demand_Source__c 
                       ORDER BY Demand_Source__c ASC];
        system.debug('*** arTrafficDS = ' + arTrafficDS.size() + ' | ' + arTrafficDS);
                        
        map_demandSource_wrapCalcRev = new Map<String,Wrap_calcRev>();
        gTotalInVat_usd = 0;
        gTotalExVat_usd = 0;
        gTotalInVat_idr = 0;
        gTotalExVat_idr = 0;
        
        List<Demand_Source_Information__c> dsiList = [SELECT Id, Name, Demand_Source__c, Share__c FROM Demand_Source_Information__c];
        system.debug('*** dsiList = ' + dsiList.size() + ' | ' + dsiList);
        Map<String,Demand_Source_Information__c> mapdsi_demandsource_rec = new Map<String,Demand_Source_Information__c>();
        for(Demand_Source_Information__c dsiRec : dsiList){
            mapdsi_demandsource_rec.put(dsiRec.Demand_Source__c,dsiRec);
        }
        system.debug('*** mapdsi_demandsource_rec = ' + mapdsi_demandsource_rec.size() + ' | ' + mapdsi_demandsource_rec);
        
        text_grandTotalPublisher = '';
        Integer loop_ds = 0;
        
        for (AggregateResult ar : arTrafficDS){
            
            loop_ds = loop_ds + 1;
            if(text_grandTotalPublisher == ''){
                text_grandTotalPublisher = String.valueOf(loop_ds);
            }else{
                text_grandTotalPublisher = text_grandTotalPublisher + '+' + String.valueOf(loop_ds);
            }
            
            
            String str_demandSource_ds = String.valueOf(ar.get('demandSource'));           system.debug('*** str_demandSource_ds = ' + str_demandSource_ds);
            Decimal dcm_sumRevUsd_ds = (Decimal)ar.get('sumRevUsd');                       system.debug('*** dcm_sumRevUsd_ds = ' + dcm_sumRevUsd_ds);
            Decimal dcm_sumRevIdr_ds = (Decimal)ar.get('sumRevIdr');                       system.debug('*** dcm_sumRevIdr_ds = ' + dcm_sumRevIdr_ds);
            
            techFee = 0;
            if(str_demandSource_ds.contains('Programmatic PMP with Tadex\'s DSP')) techFee = baRec.Tech_Fee_for_PMP_Tadex__c;
            else if(str_demandSource_ds.contains('Programmatic PMP with Client\'s DSP')) techFee = baRec.Tech_Fee_for_PMP_Client__c;
            else if(str_demandSource_ds.contains('OMP')) techFee = baRec.Tech_Fee_for_OMP__c;
            
            totalShare = mapdsi_demandsource_rec.get(str_demandSource_ds).Share__c;
            system.debug('*** totalShare = ' + totalShare);
            share = totalShare - techFee; system.debug('*** share = ' + share);
            
            if(str_demandSource_ds.contains('OMP')){
                share = 0;// Poin c Telkomsel Share selalu 0% untuk OMP
                totalShare = share + techFee;
            }
            
            // Create temporary instance and map for revenue calculation 
            Wrap_calcRev wcr = new Wrap_calcRev();
            wcr.wDemandSource = str_demandSource_ds;                            system.debug('*** wcr.wDemandSource = ' + wcr.wDemandSource);
            wcr.wCalcA_usd  = dcm_sumRevUsd_ds;                                 system.debug('*** wcr.wCalcA_usd = ' + wcr.wCalcA_usd);
            wcr.wCalcB_usd  = dcm_sumRevUsd_ds*techFee/100;                     system.debug('*** wcr.wCalcB_usd = ' + wcr.wCalcB_usd);
            wcr.wCalcC_usd  = dcm_sumRevUsd_ds*share/100;                       system.debug('*** wcr.wCalcC_usd = ' + wcr.wCalcC_usd);
            wcr.wCalcD_usd  = wcr.wCalcB_usd + wcr.wCalcC_usd;                  system.debug('*** wcr.wCalcD_usd = ' + wcr.wCalcD_usd);
            wcr.wCalcE_usd  = wcr.wCalcA_usd - wcr.wCalcD_usd;                  system.debug('*** wcr.wCalcE_usd = ' + wcr.wCalcE_usd);
            wcr.wCalcF_usd  = wcr.wCalcE_usd * vat;			                    system.debug('*** wcr.wCalcF_usd = ' + wcr.wCalcF_usd);
            wcr.wCalcA_idr  = dcm_sumRevIdr_ds;                                 system.debug('*** wcr.wCalcA_idr = ' + wcr.wCalcA_idr);
            wcr.wCalcB_idr  = dcm_sumRevIdr_ds*techFee/100;                     system.debug('*** wcr.wCalcB_idr = ' + wcr.wCalcB_idr);
            wcr.wCalcC_idr  = dcm_sumRevIdr_ds*share/100;                       system.debug('*** wcr.wCalcC_idr = ' + wcr.wCalcC_idr);
            wcr.wCalcD_idr  = wcr.wCalcB_idr + wcr.wCalcC_idr;                  system.debug('*** wcr.wCalcD_idr = ' + wcr.wCalcD_idr);
            wcr.wCalcE_idr  = wcr.wCalcA_idr - wcr.wCalcD_idr;                  system.debug('*** wcr.wCalcE_idr = ' + wcr.wCalcE_idr);
            wcr.wCalcF_idr  = wcr.wCalcE_idr * vat;			                    system.debug('*** wcr.wCalcF_idr = ' + wcr.wCalcF_idr);
            wcr.wTechFee = techFee;                                             system.debug('*** wcr.wTechFee = ' + wcr.wTechFee);
            wcr.wShare = share;                                                 system.debug('*** wcr.wShare = ' + wcr.wShare);
            wcr.wShareTotal = totalShare;                                       system.debug('*** wcr.wShareTotal = ' + wcr.wShareTotal);
            wcr.wSharePublisher = 100 - totalShare;                             system.debug('*** wcr.wSharePublisher = ' + wcr.wSharePublisher);
            system.debug('*** wcr = ' + wcr);
            
            map_demandSource_wrapCalcRev.put(wcr.wDemandSource,wcr);
            
            /*gTotalInVat_usd = gTotalInVat_usd + wcr.wCalcE_usd;
            gTotalInVat_idr = gTotalInVat_idr + wcr.wCalcE_idr;*/
            
            if(str_demandSource_ds.contains('Programmatic PMP with Tadex\'s DSP') || str_demandSource_ds.contains('Programmatic PMP with Client\'s DSP')){
                text_grandTotalPublisher = text_grandTotalPublisher + 'e';
                gTotalInVat_usd = gTotalInVat_usd + wcr.wCalcE_usd;
            	gTotalInVat_idr = gTotalInVat_idr + wcr.wCalcE_idr;
            }
            else if(str_demandSource_ds.contains('OMP')){
                text_grandTotalPublisher = text_grandTotalPublisher + 'f';
                gTotalInVat_usd = gTotalInVat_usd + wcr.wCalcF_usd;
            	gTotalInVat_idr = gTotalInVat_idr + wcr.wCalcF_idr;
            }
        }
        system.debug('*** map_demandSource_wrapCalcRev = ' + map_demandSource_wrapCalcRev.size() + ' | ' + map_demandSource_wrapCalcRev);
        
        gTotalExVat_usd = gTotalInVat_usd/vat;
        gTotalExVat_idr = gTotalInVat_idr/vat;
        
    }
}