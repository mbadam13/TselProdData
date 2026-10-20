public with sharing class SOAQuotationController {
    ApexPages.StandardSetController setCon; 
    ApexPages.StandardController con;
    
    public String SOAID {get;set;}
    
    public Quote quoteRec {get;set;}
 
    public string pricebook2id;
    public double totCount = 0;
    double soa;

    List <QuoteLineItem> Quote_Detail_list = new List <QuoteLineItem>();
    public SOAQuotationController (ApexPages.StandardController controller) {
        con = controller;
        
        //SOAID = ApexPages.currentPage().getParameters().get('id');
        SOAID = con.getRecord().id;

        //SOA__c soaRec = (SOA__c) con.getrecord();

        
        List<SOA__c> soaRec= [select id, opportunity__c, opportunity__r.accountid,opportunity__r.Pricebook2Id from soa__c where id =:SOAID];
        if(soaRec.size()>0){        
            quoteRec = new Quote();
            quoteRec.soa__c = SOAID;
            quoteRec.opportunityid = soaRec[0].opportunity__c;
            
            pricebook2id=soaRec[0].opportunity__r.Pricebook2Id;
            quoteRec.pricebook2Id=soaRec[0].opportunity__r.Pricebook2Id;
        }
    }

      
    public PageReference save ()
        {
        if(quoteRec!=Null)
         {
             insert quoteRec;

        List <SOA_Detail__c> soaDetailRec= [select Id,Unit_Price__C,Opportunity_ID__c,Quantity__c,Product_id_number__c,Product__c,PricebookEntryId__c,campaign_id__c from SOA_Detail__c where SOA__c =:SOAID ];
        
        if(soaDetailRec!=Null)
         {
            for(SOA_Detail__c thisItem : soaDetailRec)
                {   
                AggregateResult[] groupedResults = [SELECT campaign_id__c, sum(amount__c) soa FROM usage__c 
                WHERE Bucket_Detail__r.order.soa__r.id=:SOAID AND date__c >=:quoteRec.Start_Date__c AND date__c <=:quoteRec.End_Date__c AND Bucket_Detail__r.Camp_ID__c=:thisItem.Campaign_id__c
                GROUP BY campaign_id__c];
                            
                system.debug('=== SELECT campaign_id__c, sum(amount__c) soa FROM usage__c WHERE Bucket_Detail__r.order.soa__r.id= : ' + SOAID +'AND date__c >='+quoteRec.Start_Date__c+'AND date__c <='+quoteRec.End_Date__c+'AND Bucket_Detail__r.campaign_id__c='+thisItem.Campaign_id__c+'GROUP BY campaign_id__c');

                    //usage__c usgRec=[select id,amount__c,campaign_id__c,date__c from usage__c where Bucket_Detail__r.order.soa__r.id=:SOAID ];
                    for (AggregateResult ar : groupedResults)  {
                        soa= (double) ar.get('soa') ;
                        totCount=totCount + soa ;
                        if(totCount<thisItem.Quantity__c)
                        {
                            QuoteLineItem newQLI = new QuoteLineItem(UnitPrice=thisItem.Unit_Price__C,PricebookEntryId=thisItem.PricebookEntryId__c,QuoteId=quoteRec.id,quantity=totCount);
                            Quote_Detail_list.add(newQLI);
                        }
                        else
                        {
                            QuoteLineItem newQLI = new QuoteLineItem(UnitPrice=thisItem.Unit_Price__C,PricebookEntryId=thisItem.PricebookEntryId__c,QuoteId=quoteRec.id,quantity=thisItem.Quantity__c);
                            Quote_Detail_list.add(newQLI);
                        }
                        //if totcount>quantity order
                        
                        totCount = 0;
                    }
                }
                if(Quote_Detail_list.size()>0){
                    insert Quote_Detail_list;
                }
            
            }//
           }//endif
            return con.cancel();   
    }
    
    public PageReference back()
    {
        PageReference cancel = con.cancel();
        return cancel;
    }
    
    public PageReference returnToUsage() {
        PageReference returnPage = new PageReference(ApexPages.currentPage().getParameters().get('id'));
        return returnPage;
    }
    
}