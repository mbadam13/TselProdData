public class TrafficController {
    
    public List<Traffic__c> trafficRec {get;set;}
    public Berita_Acara__c BARec {get;set;}
    public List<Wrap_Traffic> wListTraffic {get; set;}
    public List<Wrap_Traffic> wrapTrafficList_temp {get; set;}
    public List<List<Wrap_Traffic>> wrapTrafficList_list {get; set;}
    public String pubName {get; set;}
    public String periodBA {get; set;}
    public String dateGenerateBA {get; set;}
    
    public class Wrap_Traffic{
        public String wDate {get; set;}
        public String wDeal {get; set;}
        public String wDealId {get; set;}
        public String wSiteName {get; set;}
        public Decimal wPaidImpressions {get; set;}
        public Decimal wRevenueUSD {get; set;}
        public String wDealSource {get; set;}
        public Decimal wPMPFees {get; set;}
        public Decimal wOMPFees {get; set;}
        public String wFeesType {get; set;}
        public Decimal wPMPOMPFees {get; set;}
        public Decimal wNetRevenue {get; set;}
    }
    
    public TrafficController(){
                
        String BA_Id = ApexPages.currentPage().getParameters().get('Id');
        
        BARec = [SELECT Id, Name, Month__c, Year__c, Exchange_Rate__c, Account__c, Account__r.Name
                 FROM Berita_Acara__c 
                 WHERE Id =: BA_Id];
        
        pubName = BARec.Account__r.Name.Remove('.');
        pubName = pubName.replace(' ','_');
        
        periodBA = BARec.Month__c + ' ' + BARec.Year__c;
        dateGenerateBA = DateTime.now().format('dd MMMM YYYY');        
        
        trafficRec = [SELECT Id, Name, Amount_IDR__c, Berita_Acara__c, Business_Model_Category__c, Date__c, Deal__c, Deal_ID__c, Deal_Source__c, 
                      		 Fee__c, Net_Revenue__c, Paid_Impressions__c, PMP_Fees__c, Revenue_USD__c, Site_ID__c, Site_Name__c, Sites__r.name , 
                      		 Total_Telkomsel_Share__c, OMP_Fees__c, Fees_Type__c, PMP_OMP_Fees__c  
                      FROM Traffic__c 
                      WHERE Berita_Acara__c =: BA_Id];
        
        wListTraffic = new List<Wrap_Traffic>();
        wrapTrafficList_temp = new List<Wrap_Traffic>();
        wrapTrafficList_list = new List<List<Wrap_Traffic>>();
        
        for (Traffic__c tr : trafficRec){
            
            String str_deal = tr.Deal__c;
            String str_deal_part_1 = str_deal.substringBefore('_');
            String str_deal_temp = str_deal.substringAfter(str_deal_part_1+'_');
            String str_deal_part_2 = str_deal_temp.substringBefore('_');
            str_deal_temp = str_deal_temp.substringAfter('_');
            String str_deal_part_3 = str_deal_temp.substringBefore('_');
            str_deal_temp = str_deal_temp.substringAfter('_');
            str_deal = str_deal_part_1 + '_' + str_deal_part_2 + '_'+ str_deal_part_3 + '_ ' + str_deal_temp;
            
            String str_siteName = tr.Site_Name__c;
            if(str_siteName.contains('|')){
                str_siteName = str_siteName.remove('TADEX|');
                String str_siteName_mid1 = str_siteName.substringBefore('|');
                String str_siteName_end = str_siteName.substringAfter('|');
                String str_siteName_mid2 = str_siteName_end.substringBefore('|');
                str_siteName_end = str_siteName_end.substringAfter('|');
                //str_siteName = 'TADEX|' + str_siteName_mid1 + '| ' + str_siteName_mid2 + '| ' + str_siteName_end;
                str_siteName = 'TADEX|' + str_siteName_mid1 + '|' + str_siteName_mid2;
                if(str_siteName.length() <= 40){
                    str_siteName = str_siteName + '| ' + str_siteName_end;
                }else{
                    String str_siteName_temp = str_siteName_mid2 + '|' + str_siteName_end;
                    if(str_siteName_temp.length() <= 40){
                        str_siteName = 'TADEX|' + str_siteName_mid1 + '| ' + str_siteName_temp;
                    }else{
                    	str_siteName = 'TADEX|' + str_siteName_mid1 + '| ' + str_siteName_mid2 + '| ' + str_siteName_end;
                    }
                }
            }else{
                if(str_siteName.length() > 40){
                    str_siteName = str_siteName.substringBefore('-') + '- ' + str_siteName.substringAfter('-');
                }
            }
            
            DateTime dt = tr.Date__c;
            String str_dt = dt.format('dd-MM-yyyy');
            
            Wrap_Traffic wr = new Wrap_Traffic();
            wr.wDate = str_dt;
            //wr.wDeal = tr.Deal__c;
            wr.wDeal = str_deal;
            wr.wDealId = tr.Deal_ID__c;
            wr.wSiteName = str_siteName;
            wr.wPaidImpressions = tr.Paid_Impressions__c;            
            wr.wRevenueUSD = tr.Revenue_USD__c;
            wr.wDealSource = tr.Deal_Source__c;
            wr.wPMPFees = tr.PMP_Fees__c;
            wr.wOMPFees = tr.OMP_Fees__c;
            wr.wFeesType = tr.Fees_Type__c ;
            wr.wPMPOMPFees = tr.PMP_OMP_Fees__c ;
            wr.wNetRevenue = tr.Net_Revenue__c;
            wListTraffic.add(wr);
            
            // Limit collection size 1000 -start
            wrapTrafficList_temp.add(wr);
            if(wrapTrafficList_temp.size() == 1000){
                wrapTrafficList_list.add(wrapTrafficList_temp);
                wrapTrafficList_temp = new List<Wrap_Traffic>();
            }
            // Limit collection size 1000 -end
        } 
        System.debug('Test wListTraffic = ' + wListTraffic.size());
        
        // Limit collection size 1000 -start
        System.debug('*** wrapTrafficList_temp = ' + wrapTrafficList_temp.size());
        if(wrapTrafficList_temp.size() > 0 && wrapTrafficList_temp.size() < 1000){
            wrapTrafficList_list.add(wrapTrafficList_temp);
        }
        // Limit collection size 1000 -end
    }
}