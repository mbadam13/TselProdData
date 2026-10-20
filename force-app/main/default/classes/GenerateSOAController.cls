public with sharing class GenerateSOAController {
    ApexPages.StandardSetController setCon; 
    ApexPages.StandardController con;
 
    
    public String SOAID {get;set;}
    
    public Quote quoteRec {get;set;}
    public List<SOA__c> soaRec {get;set;}
    public List<SOA_Detail__c> soaRecDetail {get;set;}
    public String opportunityContactName {get;set;}
 
    public string pricebook2id;
    public double totCount = 0;
    double soa;
    
    Date myDate = system.today();
    public SOA__c pageSOA;
    public Boolean initialised{get; set;}
    public Decimal grandTotal{get{
        Decimal total = 0;
        for(SOA_Detail__c d : soaRecDetail){
            total += (d.Unit_Price__c != null ? d.Unit_Price__c : 0) * (d.Quantity__c != null ? d.Quantity__c : 0);
        }
        return total;
    }}

    List <QuoteLineItem> Quote_Detail_list = new List <QuoteLineItem>();
    public GenerateSOAController (ApexPages.StandardController controller) {
        con = controller;
        
        //SOAID = ApexPages.currentPage().getParameters().get('id');
        SOAID = con.getRecord().id;
        
        initialised=false;
        //SOA__c soaRec = (SOA__c) con.getrecord();

        
        soaRec= [select id, opportunity__c, opportunity__r.accountid,opportunity__r.Pricebook2Id , opportunity__r.Development_Fee__c,
                                SOA_Start_Date__c, SOA_End_Date__c,SOA_Number__c,Owner_Name__c,Opportunity__r.Account.BillingAddress,Address__c,
                                Agency_Name_Advertiser_Name__c,Attention__c,Attention__r.Name,Attention_Report__c,Brand_Category__c,Campaign_Name__c,Company_Name__c,
                                NPWP__c,Owner_Contact_Number__c,Product_Brand__c,Sales_Manager__c,Date__c,Owner.Email
                              from soa__c where id =:SOAID];
        soaRecDetail= [select id, Product__c, Quantity__c,Product_Name__c,Unit_Price__c,List_Price__c,Discount__c,Start_Date__c,End_Date__c,Total_Impression__c,Remarks__c
                from SOA_Detail__c where SOA__c =:SOAID];

        opportunityContactName = '';
        if (soaRec.size() > 0 && soaRec[0].opportunity__c != null) {
            List<Opportunity> oppList = [SELECT ContactId FROM Opportunity WHERE Id = :soaRec[0].opportunity__c];
            if (oppList.size() > 0 && oppList[0].ContactId != null) {
                List<Contact> contactList = [SELECT Name FROM Contact WHERE Id = :oppList[0].ContactId];
                if (contactList.size() > 0) {
                    opportunityContactName = contactList[0].Name;
                }
            }
        }
                              
        
        String cleanedCompanyName = soaRec[0].Company_Name__c != null ? soaRec[0].Company_Name__c.replaceAll(',', '') : 'SOA';
        String soaNumber = soaRec[0].SOA_Number__c != null ? soaRec[0].SOA_Number__c : 'SOA';
        String myGeneratedFileName = cleanedCompanyName + ' - ' + soaNumber + '.pdf';
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + myGeneratedFilename);
        if(soaRec.size()>0){        
            quoteRec = new Quote();
            quoteRec.soa__c = SOAID;
            quoteRec.opportunityid = soaRec[0].opportunity__c;
            
            pricebook2id=soaRec[0].opportunity__r.Pricebook2Id;
            quoteRec.pricebook2Id=soaRec[0].opportunity__r.Pricebook2Id;
        }
        system.debug ('==== quoteRec : ' + quoteRec);
    }
}