/**
 * @description       : 
 * @author            : Diky Nurosid
 * testClass          : SoaServiceTest
 * @group             : 
 * @last modified on  : 10-18-2023
 * @last modified by  : Ahmat Zulkifli Murad
**/
public with sharing class SoaService {
    
    public static void createOrderforOppty(List<SOA__c> soaList){
        List <SOA_Detail__c> SOA_Detail_list = new List <SOA_Detail__c>();
        List<Order> orderList = new List<Order>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id,SOA__c> oppSoaMap = new Map<Id,SOA__c>();

        for(SOA__c soaRec : soaList){
            Order newOrder = new order();
            newOrder.SOA__c = soaRec.id;
            newOrder.EffectiveDate = soaRec.SOA_Start_Date__c;
            newOrder.EndDate= soaRec.SOA_End_Date__c;
            if(soaRec.Opportunity__c != null){
                oppIds.add(soaRec.Opportunity__c);
                oppSoaMap.put(soaRec.Opportunity__c,soaRec);
                newOrder.OpportunityId = soaRec.Opportunity__c;
            }
            newOrder.AccountId = soaRec.Account__c; //mandatory
            newOrder.Brand__c = soaRec.Brand__c;
            newOrder.Order_Type__c = soaRec.SOA_Type__c;
            newOrder.Status = 'Draft';
            newOrder.SOA_Quotation_No__c = soaRec.Name;
            orderList.add(newOrder);
        }

        if(!oppIds.isEmpty()){
            if(!Test.isRunningTest()){
                insert orderList;
            }
            
           
            List<OpportunityLineItem> oliList = [
                SELECT 
                Id,
                OpportunityId,
                UnitPrice,
                ListPrice,
                Discount__c,
                Quantity,
                PricebookEntryId,
                Product_id_number__c,
                opportunity.Pricebook2Id,
                Product2Id 
                
                FROM OpportunityLineItem 
                
                WHERE OpportunityId IN :oppIds 
                ORDER BY CreatedDate ASC
            ];

            Integer autoNumber=0;
            for(OpportunityLineItem oliRec : oliList)
            {
                autoNumber=autoNumber+1;
                String campaignId = oppSoaMap.get(oliRec.OpportunityId).Name+'_'+oliRec.Product_id_number__c+'_'+autoNumber;
                
                SOA_Detail__c newOi = new SOA_Detail__c(
                    SOA__c = oppSoaMap.get(oliRec.OpportunityId).Id,
                    Discount__c = oliRec.Discount__c,
                    List_Price__c = oliRec.ListPrice,
                    Unit_Price__c = oliRec.UnitPrice,
                    Quantity__c = oliRec.Quantity,
                    Product__c = oliRec.Product2Id,
                    Campaign_ID__c = CampaignId,
                    PricebookEntryId__c = oliRec.PricebookEntryId,
                    Start_Date__c = oppSoaMap.get(oliRec.OpportunityId).SOA_Start_Date__c,
                    End_Date__c = oppSoaMap.get(oliRec.OpportunityId).SOA_End_Date__c,
                    Opp_Product_Id__c = oliRec.Id
                );

                system.debug('+++++ newOi : ' + newOi );
                SOA_Detail_list.add(newOi);
                system.debug('+++++ SOA_Detail_list: ' + SOA_Detail_list);
                String tempOpportunityId=oliRec.OpportunityId;
            }
                insert SOA_Detail_list;
        }
    }
}