/**
 * @Last Modified By   : Ibrahim Syafiq
 * @Last Modified On   : 08-Sep-2026
 * @Modification Log   : penambahan field start date & end date
 * Ver   |   Date   |   Author   |   Modification
 * 2.0   |   29-Agu-2026   |   Ibrahim Syafiq   |   Initial version with VF page. standarisasi template SOA dengan Quotation
 * 2.1   |   31-Agu-2026   |   Ibrahim Syafiq   |   bug fixing billing address
 */
public with sharing class GenerateQuotationController {
    ApexPages.StandardController con;

    public String quoteID {get;set;}
    public String mode {get;set;}
    public List<Quote> quoteRec {get;set;}
    public List<QuoteLineItem> quoteRecDetail {get;set;}

    public Decimal grandTotal{get{
        Decimal total = 0;
        for(QuoteLineItem d : quoteRecDetail){
            total += (d.UnitPrice != null ? d.UnitPrice : 0) * (d.Quantity != null ? d.Quantity : 0);
        }
        return total;
    }}

    public GenerateQuotationController(ApexPages.StandardController controller) {
        con = controller;
        quoteID = con.getRecord().id;
        mode = ApexPages.currentPage().getParameters().get('mode');

        if (mode == 'USD') {
            quoteRec = [SELECT Id, QuoteNumber, Name, NPWP__c, SOA_Quotation_No__c,
                               Start_Date__c, End_Date__c, Phone, Email,
                               BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
                               Grand_Total_USD__c, Total_Price_USD__c, Tax_USD__c,
                               Kurs__c, Agency__c, Brand__c, Category__c,
                               Mitra_PIC__c, Account.Name, Contact.Name,
                               Owner.Name, Owner.Email,
                                Opportunity.Campaign_Name__c, Opportunity.Sales_Manager__r.Name
                        FROM Quote WHERE Id = :quoteID];
        } else {
            quoteRec = [SELECT Id, QuoteNumber, Name, NPWP__c, SOA_Quotation_No__c,
                               Start_Date__c, End_Date__c, Phone, Email,
                               BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
                               Grand_Total__c, Total_Prices__c, Temp_Tax__c,
                               Agency__c, Brand__c, Category__c,
                               Mitra_PIC__c, Account.Name, Contact.Name,
                               Owner.Name, Owner.Email,
                               Opportunity.Campaign_Name__c, Opportunity.Sales_Manager__r.Name
                        FROM Quote WHERE Id = :quoteID];
        }

        quoteRecDetail = [SELECT Id, Product2.Name, Remarks__c, UnitPrice, Quantity
                          FROM QuoteLineItem WHERE QuoteId = :quoteID];

        String cleanedCompanyName = quoteRec[0].Account.Name != null ? quoteRec[0].Account.Name.replaceAll(',', '') : 'Quote';
        String quoteNumber = quoteRec[0].QuoteNumber != null ? quoteRec[0].QuoteNumber : 'Quote';
        String myGeneratedFileName = cleanedCompanyName + ' - ' + quoteNumber + '.pdf';
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + myGeneratedFilename);
    }
}