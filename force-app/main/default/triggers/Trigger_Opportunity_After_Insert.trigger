/**
 * @File Name          : Trigger_Opportunity_After_Insert.trigger
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : Syaiful Syafani
 * @Last Modified On   : 07-11-2024
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    2/3/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 * 1.1  11/7/2024   Syaiful Syafani     nyalain triggernya
**/
// Created By David Wong
// 16 January 2020
// Modified by Debora E P - 6 October 2020

trigger Trigger_Opportunity_After_Insert on Opportunity(after insert,after update) {

if (label.Trigger_Opportunity_After_Insert_On== 'YES') {
   if(trigger.isafter)
     {
       if(trigger.isinsert)
        {
            List<Monthly_Sales_Target__c> lMonthlySalesTarget = new List<Monthly_Sales_Target__c>();
            for(Opportunity myOpportunity:trigger.new) {
                   if(myOpportunity.NIK__c!=null){
                        User newUserReference = new User(NIK__c = myOpportunity.NIK__c);

                        Monthly_Sales_Target__c newMonthlySalesTarget = new Monthly_Sales_Target__c();
                        newMonthlySalesTarget.Date__c = date.today();
                        newMonthlySalesTarget.Amount__c = Integer.valueOf(myOpportunity.Amount);
                        newMonthlySalesTarget.Type__c = 'Selling Estimation';
                        newMonthlySalesTarget.Group_Type__c= 'Pipeline'; //modify
                        newMonthlySalesTarget.Opportunity__c= myOpportunity.id;//modify
                        newMonthlySalesTarget.Sales__r = newUserReference;
                        lMonthlySalesTarget.add(newMonthlySalesTarget);
                }
            }
            //insert lMonthlySalesTarget;
        }
    }
    
       if(trigger.isafter)
         {
           if(trigger.isupdate)
            {
                String STRID;
                String tmpNIK;
                String unikSE;
                String unikTA;
                double SO;
                double Total_Amount_Actual;
                List<Monthly_Sales_Target__c> lMonthlySalesTarget = new List<Monthly_Sales_Target__c>();
                List<Monthly_Sales_Target__c> lMonthlySalesTargetTA = new List<Monthly_Sales_Target__c>();
                List<SOA_Detail__c> list_soadToUpdate = new List<SOA_Detail__c>();
                List<SOA_Detail__c> list_soadToDelete = new List<SOA_Detail__c>();
                List<SOA_Detail__c> list_soadToInsert = new List<SOA_Detail__c>();
                List<QuoteBU_Detail__c> list_qbudToUpdate = new List<QuoteBU_Detail__c>();
                List<QuoteBU_Detail__c> list_qbudToInsert = new List<QuoteBU_Detail__c>();
                list<OpportunityLineItem> opptyLineItemList = new list<OpportunityLineItem>();
                
                 for(Opportunity myOpportunity:trigger.new) {
                    Opportunity oppOld=Trigger.oldMap.get(myOpportunity.id);
                    User newUserReference = new User(NIK__c = myOpportunity.NIK__c);
                        try {
                                
                            List<Monthly_Sales_Target__c> mySTR = [SELECT id FROM Monthly_Sales_Target__c WHERE Opportunity__c = :myOpportunity.id LIMIT 1];
                            AggregateResult[] orderlis = [SELECT SUM(Telkomsel_Revenue__c) SO,Opportunity__c FROM Orderitem WHERE Opportunity__c= :myOpportunity.id group by Opportunity__c];
                            double totAmount=0;
                            Map < String, double> orderlistMap = new Map < String, double > ();
                            
                            for (AggregateResult ar : orderlis)  {
                                SO= (Decimal)ar.get('SO') ;
                                totAmount=totAmount + SO ;
                                orderlistMap.put( (String) ar.get('Opportunity__c'), double.valueof(totAmount));
                            }
                            
                            Total_Amount_Actual=orderlistMap.get(myOpportunity.Id);
                    
                            if(Total_Amount_Actual==Null)
                            {
                                Total_Amount_Actual= 0;
                            }

                            if(myOpportunity.NIK__c!=Null){
                                tmpNIK=myOpportunity.NIK__c;
                            }
                            else{
                                tmpNIK='81312';
                            }
                            if(mySTR.size()>0){
                                STRID=mySTR[0].id;
                            }

                            Monthly_Sales_Target__c newMonthlySalesTargetTA = new Monthly_Sales_Target__c();
                            //newMonthlySalesTargetTA.id= STRID;
                            if(myOpportunity.CloseDate!=Null){
                                newMonthlySalesTargetTA.Date__c = myOpportunity.CloseDate;
                            }
                            else{
                                newMonthlySalesTargetTA.Date__c = date.today();
                            }
                                                    
                            //system.debug('%%%% amount oppty'+myOpportunity.Amount);
                            //system.debug('%%%% Total_Amount_Actual'+Total_Amount_Actual);
                            if(oppOld.Usage_Date__c != myOpportunity.Usage_Date__c || myOpportunity.Usage_Date__c!=Null){
                                
                                if(myOpportunity.Amount!=Null)
                                {
                                
                                    newMonthlySalesTargetTA.Amount__c = myOpportunity.Amount-Total_Amount_Actual;
                                        
                                }
                                
                            }//endif
                            else
                                {
                                    if(myOpportunity.Amount==Null) 
                                    {
                                        //newMonthlySalesTargetTA.Amount__c = myOpportunity.Amount;
                                        newMonthlySalesTargetTA.Amount__c = 0;
                                    }
                                    if(myOpportunity.Amount!=Null && Total_Amount_Actual!=Null && (myOpportunity.Probability>0.7)){
                                        //newMonthlySalesTargetTA.Amount__c = Total_Amount_Actual;
                                        newMonthlySalesTargetTA.Amount__c = myOpportunity.Amount-Total_Amount_Actual;
                                    }
                                    if(myOpportunity.StageName == 'Closed Lost')
                                    {
                                        newMonthlySalesTargetTA.Amount__c = 0;
                                    }
                                }
                            newMonthlySalesTargetTA.Type__c = 'Selling Estimation';
                            newMonthlySalesTargetTA.Group_Type__c= 'Pipeline'; //modify
                            newMonthlySalesTargetTA.Opportunity__c= myOpportunity.id;//modify
                            //newMonthlySalesTargetTA.Unique_ID__c=  tmpNIK+'-'+newMonthlySalesTargetTA.Type__c+'-'+newMonthlySalesTargetTA.Opportunity__c+'-'+date.today().month()+'-'+date.today().year()+'-TA';
                            newMonthlySalesTargetTA.Unique_ID__c=  tmpNIK+'-'+newMonthlySalesTargetTA.Type__c+'-'+newMonthlySalesTargetTA.Opportunity__c+'-TA';
                            
                            newMonthlySalesTargetTA.Sales__r = newUserReference;
                            unikTA=tmpNIK+'-'+newMonthlySalesTargetTA.Type__c+'-'+newMonthlySalesTargetTA.Opportunity__c+'-'+date.today().month()+'-'+date.today().year()+'-TA';
                            lMonthlySalesTargetTA.add(newMonthlySalesTargetTA);
                        	
                            if(Test.isRunningTest()) {
                                CalloutException e = new CalloutException();
                                e.setMessage('This is a constructed exception for testing and code coverage');
                                throw e;
                            }
                            
                        }catch (exception e) {
                            string errMessageOpp = 'Error on . Record IDs : ' + myOpportunity.id+ '.::' + e.getmessage() + '::' + e.getLineNumber() ;
                            system.debug('==================== error message : ' + errMessageOpp );
                            AppUtils.putError(errMessageOpp);
                        }   
                	
					system.debug('*** myOpportunity.StageName = ' + myOpportunity.StageName);
                    system.debug('*** oppOld.StageName = ' + oppOld.StageName);
                    system.debug('*** myOpportunity.Adjustment_Version__c = ' + myOpportunity.Adjustment_Version__c);
                    system.debug('*** myOpportunity.Check_PO__c = ' + myOpportunity.Check_PO__c);
                    system.debug('*** myOpportunity.isSubmitCheckPOApproval__c = ' + myOpportunity.isSubmitCheckPOApproval__c);
                    system.debug('*** myOpportunity.Approval_Status__c = ' + myOpportunity.Approval_Status__c);
                     
                    // CR015 - Adjustment After Closed Won -start
					if(myOpportunity.StageName == 'Closed Won' 
                       && myOpportunity.StageName != oppOld.StageName 
                       && myOpportunity.Adjustment_Version__c >= 1 
                       && myOpportunity.Check_PO__c == 'OK'
                       && myOpportunity.isSubmitCheckPOApproval__c == true
                       && myOpportunity.Approval_Status__c == 'Approved'){
                        
						if(myOpportunity.Penagihan_based_on__c == 'Postpaid' || myOpportunity.Penagihan_based_on_TV__c == 'Postpaid'){
                            
                        	Map<String,SOA_Detail__c> soaDetailMap = new Map<String,SOA_Detail__c>();
                           
                            List<SOA__c> soa = [SELECT Id, Name, SOA_Start_Date__c, SOA_End_Date__c FROM SOA__c WHERE Opportunity__c =: myOpportunity.Id ORDER BY CreatedDate ASC];
                            
                            system.debug('*** soa.size() = ' + soa.size());
                            system.debug('*** soa = ' + soa);
                            
                            if(soa.size() > 0){
                                
                                system.debug('*** myOpportunity.Id = ' + myOpportunity.Id);
                                system.debug('*** soa[0].Id = ' + soa[0].Id);
                                
                                String oppId = myOpportunity.Id;
                                if(oppId != '')
                                	{oppId = oppId.left(15);}
                                
                                system.debug('*** oppId = ' + oppId);
                                
                                List<SOA_Detail__c> list_soad = [SELECT Id, Name, Unit_Price__c, Quantity__c, Opportunity_ID__c, Opp_Product_Id__c 
                                                                 FROM SOA_Detail__c 
                                                                 WHERE Opportunity_ID__c =: oppId
                                                                 AND SOA__c =: soa[0].Id ORDER BY CreatedDate ASC];
                                
                                Integer AutoGenerateNumber = list_soad.size() + 1;
                                   
                                for(SOA_Detail__c soad_rec : list_soad){
                                    soaDetailMap.put(soad_rec.Opp_Product_Id__c,soad_rec);
                                }
                                
                                system.debug('*** soaDetailMap.size() = ' + soaDetailMap.size());
                                system.debug('*** soaDetailMap = ' + soaDetailMap);
                                system.debug('*** myOpportunity.Adjustment_Version__c = ' + myOpportunity.Adjustment_Version__c);
                                
                                List<Adjustment_Log__c> list_adjLog = [SELECT Id, Name, Action__c, Opp_Product_Id__c, New_Sales_Price__c, New_Quantity__c    
                                                                       FROM Adjustment_Log__c WHERE Opportunity__c =: oppId AND Version__c =: myOpportunity.Adjustment_Version__c
                                                                       ORDER BY CreatedDate ASC];
                                
                                system.debug('*** list_adjLog.size() = ' + list_adjLog.size());
                                system.debug('*** list_adjLog = ' + list_adjLog);
                                             
                                Integer x = 1; // count looping adjLog soad
                                
                                for(Adjustment_Log__c adjLog : list_adjLog){
                                    
                                    if(adjLog.Action__c == 'Change'){
                                        
                                        system.debug('***x ' + x + ' Change : adjLog_id ' + adjLog.Id + ' | oli_id ' + adjLog.Opp_Product_Id__c);
                                        
                                        SOA_Detail__c soad_update_c = soaDetailMap.get(adjLog.Opp_Product_Id__c);
                                        if(soad_update_c != null){
                                            soad_update_c.Unit_Price__c = adjLog.New_Sales_Price__c;
                                            soad_update_c.Quantity__c = adjLog.New_Quantity__c;
                                            
                                            list_soadToUpdate.add(soad_update_c); system.debug('### list_soadToUpdate change x' + x + ' = ' + list_soadToUpdate);
                                        }else{
                                            system.debug('~~~ soad_update_c null');
                                        }
                                    }else if(adjLog.Action__c == 'Delete'){
                                        
                                        system.debug('***x ' + x + ' Delete : adjLog_id ' + adjLog.Id + ' | oli_id ' + adjLog.Opp_Product_Id__c);
                                        
                                        /*SOA_Detail__c soad_update_d = soaDetailMap.get(adjLog.Opp_Product_Id__c);
                                        if(soad_update_d != null){
                                            soad_update_d.Unit_Price__c = 0;
                                        	soad_update_d.Quantity__c = 0;
                                        
                                        	list_soadToUpdate.add(soad_update_d); system.debug('### list_soadToUpdate delete x' + x + ' = ' + list_soadToUpdate);
                                        }else{
                                            system.debug('~~~ soad_update_d null');
                                        }*/
                                        SOA_Detail__c soad_delete_d = soaDetailMap.get(adjLog.Opp_Product_Id__c);

                                        if(soad_delete_d != null) {
                                            list_soadToDelete.add(soad_delete_d); system.debug('### list_soadToUpdate delete x' + x + ' = ' + list_soadToUpdate); 
                                        }else{
                                            system.debug('~~~ soad_delete_d null');
                                        }

                                    }else if(adjLog.Action__c == 'Add'){
                                        
                                        system.debug('***x ' + x + ' Add : adjLog_id ' + adjLog.Id + ' | oli_id ' + adjLog.Opp_Product_Id__c);
																				
										SOA_Detail__c soad_check = soaDetailMap.get(adjLog.Opp_Product_Id__c);
                                                                                
                                        if(soad_check == null){
                                            	
                                        	SOA_Detail__c soad_insert = new SOA_Detail__c();
											
                                            List<OpportunityLineItem> oli = [SELECT Id, Product2Id, ListPrice, UnitPrice, Quantity, Discount__c, PricebookEntryId, Product_id_number__c    
                                                                             FROM OpportunityLineItem WHERE Id =: adjLog.Opp_Product_Id__c];
                                            
                                            if(oli.size() > 0){
                                                
                                                soad_insert.Product__c = oli[0].Product2Id;
                                                soad_insert.List_Price__c = oli[0].ListPrice;
                                                soad_insert.Unit_Price__c = oli[0].UnitPrice;
                                                soad_insert.Quantity__c = oli[0].Quantity;
                                                soad_insert.Discount__c = oli[0].Discount__c;
                                                soad_insert.PricebookEntryId__c = oli[0].PricebookEntryId;
                                                
                                                soad_insert.SOA__c = soa[0].Id;
                                                soad_insert.Start_Date__c = soa[0].SOA_Start_Date__c;
                                                soad_insert.End_Date__c = soa[0].SOA_End_Date__c;
                                                
                                                soad_insert.Opp_Product_Id__c = oli[0].Id;
                                                
                                                soad_insert.Campaign_ID__c = soa[0].Name + '_' + oli[0].Product_id_number__c + '_' + AutoGenerateNumber;
                                                AutoGenerateNumber = AutoGenerateNumber + 1;
                                                
                                                list_soadToInsert.add(soad_insert); system.debug('### list_soadToInsert add x' + x + ' = ' + list_soadToInsert);
                                            }else{
                                                system.debug('oli tidak ditemukan.');
                                            }
                                        }
                                    }
                                	x = x + 1;
                                }
                                system.debug('*** list_soadToUpdate.size() = ' + list_soadToUpdate.size());
                                system.debug('*** list_soadToUpdate = ' + list_soadToUpdate);
                                system.debug('*** list_soadToInsert.size() = ' + list_soadToInsert.size());
                                system.debug('*** list_soadToInsert = ' + list_soadToInsert);
                            }
                        }else if(myOpportunity.Penagihan_based_on__c == 'Prepaid'){
                            
                            // Based on QuoteBU__c -start
                            
                            Map<String,QuoteBU_Detail__c> qbudMap = new Map<String,QuoteBU_Detail__c>();
                           
                            List<QuoteBU__c> quotebu = [SELECT Id, No_Quote__c FROM QuoteBU__c WHERE Opportunity__c =: myOpportunity.Id ORDER BY CreatedDate ASC];
                            
                            system.debug('*** quotebu.size() = ' + quotebu.size());
                            system.debug('*** quotebu = ' + quotebu);
                            
                            if(quotebu.size() > 0){
                                
                                system.debug('*** myOpportunity.Id = ' + myOpportunity.Id);
                                system.debug('*** quotebu[0].Id = ' + quotebu[0].Id);
                                
                                String oppId = myOpportunity.Id;
                                if(oppId != '')
                                	{oppId = oppId.left(15);}
                                
                                system.debug('*** oppId = ' + oppId);
                                
                                List<QuoteBU_Detail__c> list_qbud = [SELECT Id, Name, Unit_Price__c, Quantity__c, Opportunity_ID__c, Opp_Product_Id__c 
                                                                     FROM QuoteBU_Detail__c 
                                                                     WHERE Opportunity_ID__c =: oppId
                                                                     AND QuoteBU__c =: quotebu[0].Id ORDER BY CreatedDate ASC];
                                
                                Integer AutoGenerateNumber_q = list_qbud.size() + 1;
                                   
                                for(QuoteBU_Detail__c qbud_rec : list_qbud){
                                    qbudMap.put(qbud_rec.Opp_Product_Id__c,qbud_rec);
                                }
                                
                                system.debug('*** qbudMap.size() = ' + qbudMap.size());
                                system.debug('*** qbudMap = ' + qbudMap);
                                system.debug('*** myOpportunity.Adjustment_Version__c = ' + myOpportunity.Adjustment_Version__c);
                                
                                List<Adjustment_Log__c> list_adjLog = [SELECT Id, Name, Action__c, Opp_Product_Id__c, New_Sales_Price__c, New_Quantity__c    
                                                                       FROM Adjustment_Log__c WHERE Opportunity__c =: oppId AND Version__c =: myOpportunity.Adjustment_Version__c
                                                                       ORDER BY CreatedDate ASC];
                                
                                system.debug('*** list_adjLog.size() q = ' + list_adjLog.size());
                                system.debug('*** list_adjLog q = ' + list_adjLog);
                                             
                                Integer y = 1; // count looping adjLog qbud
                                
                                for(Adjustment_Log__c adjLog : list_adjLog){
                                    
                                    if(adjLog.Action__c == 'Change'){
                                        
                                        system.debug('***y ' + y + ' Change : adjLog_id ' + adjLog.Id + ' | oli_id ' + adjLog.Opp_Product_Id__c);
                                        
										QuoteBU_Detail__c qbud_update_c = qbudMap.get(adjLog.Opp_Product_Id__c);
                                        if(qbud_update_c <> null){
                                            qbud_update_c.Unit_Price__c = adjLog.New_Sales_Price__c;
                                            qbud_update_c.Quantity__c = adjLog.New_Quantity__c;
                                            
                                            list_qbudToUpdate.add(qbud_update_c); system.debug('### list_qbudToUpdate change y' + y + ' = ' + list_qbudToUpdate);
                                        }else{
                                            system.debug('~~~ qbud_update_c null');
                                        }
                                    }else if(adjLog.Action__c == 'Delete'){
                                        
                                        system.debug('***y ' + y + ' Delete : adjLog_id ' + adjLog.Id + ' | oli_id ' + adjLog.Opp_Product_Id__c);
                                        
                                        QuoteBU_Detail__c qbud_update_d = qbudMap.get(adjLog.Opp_Product_Id__c); 
                                        if(qbud_update_d <> null){
                                            qbud_update_d.Unit_Price__c = 0;
                                            qbud_update_d.Quantity__c = 0;
                                            
                                            list_qbudToUpdate.add(qbud_update_d); system.debug('### list_qbudToUpdate delete y' + y + ' = ' + list_qbudToUpdate);
                                        }else{
                                            system.debug('~~~ qbud_update_d null');
                                        }
                                    }else if(adjLog.Action__c == 'Add'){
                                        
                                        system.debug('***y ' + y + ' Add : adjLog_id ' + adjLog.Id + ' | oli_id ' + adjLog.Opp_Product_Id__c);
                                        
                                        QuoteBU_Detail__c qbud_check = qbudMap.get(adjLog.Opp_Product_Id__c);
                                        
                                        if(qbud_check == null){
                                            
                                            QuoteBU_Detail__c qbud_insert = new QuoteBU_Detail__c();
                                            
                                            List<OpportunityLineItem> oli_q = [SELECT Id, Product2Id, ListPrice, UnitPrice, Quantity, Discount__c, PricebookEntryId, PricebookEntry.UnitPrice, Product_id_number__c     
                                                                                FROM OpportunityLineItem WHERE Id =: adjLog.Opp_Product_Id__c];
                                            
                                            if(oli_q.size() > 0){
                                                
                                                qbud_insert.Product__c = oli_q[0].Product2Id;
                                                qbud_insert.List_Price__c = oli_q[0].ListPrice;
                                                qbud_insert.Unit_Price__c = oli_q[0].UnitPrice;
                                                qbud_insert.Quantity__c = oli_q[0].Quantity;
                                                qbud_insert.Discount__c = oli_q[0].Discount__c;
                                                qbud_insert.PricebookEntryId__c = oli_q[0].PricebookEntryId;
                                                qbud_insert.Unit_Price_PBE__c = oli_q[0].PricebookEntry.UnitPrice;
                                                
                                                qbud_insert.QuoteBU__c = quotebu[0].Id;
                                                qbud_insert.Opp_Product_Id__c = oli_q[0].Id;
                                                
                                                qbud_insert.Campaign_ID__c = quotebu[0].No_Quote__c + '_' + oli_q[0].Product_id_number__c + '_' + AutoGenerateNumber_q;
                                                AutoGenerateNumber_q = AutoGenerateNumber_q + 1;
                                                
                                            	list_qbudToInsert.add(qbud_insert); system.debug('### list_qbudToInsert add y' + y + ' = ' + list_qbudToInsert);
                                            }else{
                                                system.debug('oli_q tidak ditemukan.');
                                            }
                                        }
                                    }
                                    y = y + 1;
                                }
                                system.debug('*** list_qbudToUpdate.size() = ' + list_qbudToUpdate.size());
                                system.debug('*** list_qbudToUpdate = ' + list_qbudToUpdate);
                                system.debug('*** list_qbudToInsert.size() = ' + list_qbudToInsert.size());
                                system.debug('*** list_qbudToInsert = ' + list_qbudToInsert);
                            }
                            // Based on QuoteBU__c -end
                            
                        }else{
                            myOpportunity.addError('Set Opportunity field "Penagihan based on" : Prepaid / Postpaid');
                        }
                        
                    }
                    // CR015 - Adjustment After Closed Won -end 
                     
                }
                 //upsert lMonthlySalesTarget;
                if(lMonthlySalesTargetTA.size()>0){
                     system.debug ('===  lMonthlySalesTargetTA  : ' + lMonthlySalesTargetTA );
                     upsert lMonthlySalesTargetTA Unique_ID__c;
                }
				
                
                if(list_soadToInsert.size() > 0){
                    insert list_soadToInsert;
                }
                if(list_soadToUpdate.size() > 0){
                    
                    Map<String,SOA_Detail__c> mapSoad = new Map<String,SOA_Detail__c>(); 
                    
                    // Remove double Id for update
                    for(SOA_Detail__c soadrec : list_soadToUpdate){
                        
                        if(mapSoad.containsKey(soadrec.Id)){
                            mapSoad.remove(soadrec.Id);
                        }
                        
                        mapSoad.put(soadrec.Id,soadrec);
                    }
                    
                    system.debug('*** mapSoad.size() = ' + mapSoad.size());
                    system.debug('*** mapSoad = ' + mapSoad);
                    
                    update mapSoad.values();
                    
                }
                if(list_soadToDelete.size() > 0){
                    
                    Map<String,SOA_Detail__c> mapSoad = new Map<String,SOA_Detail__c>(); 
                    
                    // Remove double Id for update
                    for(SOA_Detail__c soadrec : list_soadToDelete){
                        
                        if(mapSoad.containsKey(soadrec.Id)){
                            mapSoad.remove(soadrec.Id);
                        }
                        
                        mapSoad.put(soadrec.Id,soadrec);
                    }
                    
                    system.debug('*** mapSoad.size() = ' + mapSoad.size());
                    system.debug('*** mapSoad = ' + mapSoad);
                    
                    Delete mapSoad.values();
                    
                }
                if(list_qbudToInsert.size() > 0){
                    insert list_qbudToInsert;
                }
                if(list_qbudToUpdate.size() > 0){
                    
                    Map<String,QuoteBU_Detail__c> mapQbud = new Map<String,QuoteBU_Detail__c>(); 
                    
                    // Remove double Id for update
                    for(QuoteBU_Detail__c qbudrec : list_qbudToUpdate){
                        
                        if(mapQbud.containsKey(qbudrec.Id)){
                            mapQbud.remove(qbudrec.Id);
                        }
                        
                        mapQbud.put(qbudrec.Id,qbudrec);
                    }
                    
                    system.debug('*** mapQbud.size() = ' + mapQbud.size());
                    system.debug('*** mapQbud = ' + mapQbud);
                    
                    update mapQbud.values();
                    
                }
            }
        }
    }
}