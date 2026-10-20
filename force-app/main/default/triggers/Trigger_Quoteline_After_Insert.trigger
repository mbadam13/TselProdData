trigger Trigger_Quoteline_After_Insert on QuoteLineItem (after insert) {

if (label.Trigger_Quoteline_After_Insert_ON == 'YES') {
   String QuoteLineItem_ID;
   String QuoteLineItem_IDSF;
   String OrderId;
   String QuoteId;
   String OpportunityId;
   String TempOpportunityId;
   String CampaignId;
   String Account_ID;
   String TempQuoteLineItem_ID;
   Decimal TempUsage_Actual;
   String TempCampaignId;
   Integer AutoNumber;
   String Penagihan;
   List <QuoteLineItem> Quoteline_list = new List <QuoteLineItem>();
   
   if(trigger.isafter)
     {
        if(trigger.isinsert)
        {
        AutoNumber=0;
            for(QuoteLineItem qliNew : system.trigger.new){
                AutoNumber=AutoNumber+1;
                CampaignId = qliNew.No_Quote__c+'_'+qliNew.Product_id_number__c+'_'+AutoNumber;
                QuoteLineItem newOi = new QuoteLineItem(id= qliNew.id,UnitPrice= qliNew.UnitPrice,Quantity= qliNew.Quantity,Product2Id=qliNew.Product2Id,Campaign_ID__c=CampaignId,PricebookEntryId=qliNew.PricebookEntryId);
                system.debug('+++++ newOi : ' + newOi );
                Quoteline_list.add(newOi);
            }
            upsert Quoteline_list;
        } 
     }
     }
     
 }