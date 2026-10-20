public class KKSummary_Controller {
    
    public Kertas_Kerja__c kkRec {get; set;}
    public List<orderItem_wrapper> oiw_list {get; set;}
    public Map<String,List<orderItem_wrapper>> map_prodName_oiwList {get; set;}
    public String str_pdfGenerateDate {get; set;}
    
    public class orderItem_wrapper{
       	public String wOrderId {get;set;}
       	public String wProductId {get;set;}
       	public String wProductName {get;set;}
       	public String wStartDate {get;set;}
       	public String wEndDate {get;set;}
       	public String wRemark {get;set;}
       	public Decimal wPembelian {get;set;}
       	public Decimal wPenggunaan {get;set;}
       	public Decimal wSaldo {get;set;}        
	}
    
    List<orderItem_wrapper> oiwForBuffer_list;
    
    public KKSummary_Controller(ApexPages.StandardController controller){
        
        str_pdfGenerateDate = system.now().format('dd MMMM yyyy');
        
        // -------------------------------------------------- Get Period (Month & Year) -------------------------------------------------- //
        
        String kk_id = apexpages.currentpage().getparameters().get('id'); system.debug('*** kk_id = ' + kk_id);
        
        kkRec = [SELECT Id, Name, Kertas_Kerja_Name__c, Month__c, Year__c, Type__c, Insert_Buffer_Timestamp__c FROM Kertas_Kerja__c WHERE Id =: kk_id];
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
        
        // -------------------------------------------------- Get Order Info -------------------------------------------------- //
        
        List<Order> orderList = [SELECT Id, Name, FBO__c, EffectiveDate, EndDate, Status 
                                 FROM Order
                                 WHERE EffectiveDate <=: endDate_temp 
                                 AND EndDate >=: startDate_temp 
                                 AND (
                                     Order_Completed_Date__c = null 
                                     OR (Order_Completed_Date__c != null
                                        AND Order_Completed_Date__c >=: startDate_temp))
                                ];
        system.debug('*** orderList = ' + orderList.size() + ' | ' + orderList);
        
        Map<Id,Order> map_orderId_orderRec = new Map<Id,Order>();
        List<Id> orderIdList = new List<Id>();
        
        for(Order orderRec : orderList){
            map_orderId_orderRec.put(orderRec.Id,orderRec);
            orderIdList.add(orderRec.Id);
        }
        
        // -------------------------------------------------- Get Product Info -------------------------------------------------- //
        
        AggregateResult[] orderItemGroupByProduct_agr = [SELECT Product2Id, Product2.Name ProdName FROM OrderItem WHERE OrderId IN: orderIdList GROUP BY Product2Id, Product2.Name];
        system.debug('*** orderItemGroupByProduct_agr = ' + orderItemGroupByProduct_agr.size() + ' | ' + orderItemGroupByProduct_agr);
        
        Map<Id,String> map_productId_productName = new Map<Id,String>();
        
        for (AggregateResult oiForProduct : orderItemGroupByProduct_agr){
            String product_id = (Id) oiForProduct.get('Product2Id');
            String product_name = (String) oiForProduct.get('ProdName');
            map_productId_productName.put(product_id,product_name);
        }
        
        // -------------------------------------------------- Get Usage Info -------------------------------------------------- //
        
        AggregateResult[] usage_agr = [SELECT Bucket_Detail__r.OrderId ordId, Bucket_Detail__r.Product2Id prodId, SUM(Amount__c) QtyUsage 
                                       FROM Usage__c  
                                       WHERE Bucket_Detail__r.OrderId IN: orderIdList  
                                       AND Date__c <=: endDate_temp 
                                       GROUP BY Bucket_Detail__r.OrderId, Bucket_Detail__r.Product2Id];
        system.debug('*** usage_agr = ' + usage_agr.size() + ' | ' + usage_agr);
        
        Map<Id,Map<Id,Decimal>> map_orderId_orderItemId_qtyUsg = new Map<Id,Map<Id,Decimal>>();
        
        for (AggregateResult usg : usage_agr){
            
            Id order_id = (Id) usg.get('ordId');
            Id product_id = (Id) usg.get('prodId');
            Decimal qty_usage = (Decimal) usg.get('QtyUsage');
            //if(qty_usage == null){qty_usage = 0;}
            
            Map<Id,Decimal> mapTemp_orderItemId_qtyUsg = new Map<Id,Decimal>();
            
            if(map_orderId_orderItemId_qtyUsg.keySet().contains(order_id)){
                mapTemp_orderItemId_qtyUsg = map_orderId_orderItemId_qtyUsg.get(order_id);
                map_orderId_orderItemId_qtyUsg.remove(order_id);
                mapTemp_orderItemId_qtyUsg.put(product_id,qty_usage);
                map_orderId_orderItemId_qtyUsg.put(order_id,mapTemp_orderItemId_qtyUsg);
            }else{
                mapTemp_orderItemId_qtyUsg.put(product_id,qty_usage);
                map_orderId_orderItemId_qtyUsg.put(order_id,mapTemp_orderItemId_qtyUsg);
            }
        }
        system.debug('*** map_orderId_orderItemId_qtyUsg = ' + map_orderId_orderItemId_qtyUsg.size() + ' | ' + map_orderId_orderItemId_qtyUsg);
        
        // -------------------------------------------------- Get Last Usage Info per OrderId & ProductId -------------------------------------------------- //
        
        List<Usage__c> usageList = [SELECT Id, Name, Date__c, Bucket_Detail__c, Bucket_Detail__r.OrderId, Bucket_Detail__r.Product2Id, 
                                    	   Bucket_Detail__r.OrderItemNumber, Bucket_Detail__r.Order.OrderNumber, Bucket_Detail__r.Product2.Name 
                                    FROM Usage__c  
                                    WHERE Bucket_Detail__r.OrderId IN: orderIdList  
                                    AND Date__c <=: endDate_temp 
                                    ORDER BY Date__c DESC];
        system.debug('*** usageList = ' + usageList.size() + ' | ' + usageList);
        
        Map<String,Usage__c> map_ordIdprdId_lastUsg = new Map<String,Usage__c>();
        
        for(Usage__c usg : usageList){
            
            String comb_id = usg.Bucket_Detail__r.OrderId + '-' + usg.Bucket_Detail__r.Product2Id;
            
            if(map_ordIdprdId_lastUsg.containsKey(comb_id)){
                Date dateUsg_tmp = map_ordIdprdId_lastUsg.get(comb_id).Date__c;
                if(usg.Date__c > dateUsg_tmp){
                    map_ordIdprdId_lastUsg.remove(comb_id);
                    map_ordIdprdId_lastUsg.put(comb_id,usg);
                }
            }else{
                map_ordIdprdId_lastUsg.put(comb_id,usg);
            }
            
        }
        system.debug('*** map_ordIdprdId_lastUsg = ' + map_ordIdprdId_lastUsg.size() + ' | ' + map_ordIdprdId_lastUsg);
        
        // -------------------------------------------------- Create temp record & list for orderItem_wrapper -------------------------------------------------- //
        
        AggregateResult[] orderItem_agr = [SELECT OrderId, Product2Id, SUM(Quantity) Qty, SUM(Buffer__c) Bfr
                                           FROM OrderItem 
                                           WHERE OrderId IN: orderIdList 
                                           GROUP BY OrderId, Product2Id 
                                           ORDER BY OrderId ASC
                                          ];
        system.debug('*** orderItem_agr = ' + orderItem_agr.size() + ' | ' + orderItem_agr);
        
        oiw_list = new List<orderItem_wrapper>();
        map_prodName_oiwList = new Map<String,List<orderItem_wrapper>>();
		
        oiwForBuffer_list = new List<orderItem_wrapper>();
        
        for (AggregateResult oi : orderItem_agr){
           
            orderItem_wrapper oiw_rec = new orderItem_wrapper();
            
            Id order_id = (Id) oi.get('OrderId');
            Id product_id = (Id) oi.get('Product2Id');
            
            Datetime sd = map_orderId_orderRec.get(order_id).EffectiveDate;
            Datetime ed = map_orderId_orderRec.get(order_id).EndDate;
            
            Decimal temp_pembelian = (Decimal) oi.get('Qty');
            if(temp_pembelian == null){temp_pembelian = 0;}
            
            Decimal temp_buffer = (Decimal) oi.get('Bfr');
            if(temp_buffer == null){temp_buffer = 0;}
            
            Map<Id,Decimal> mapTemp_orderItemId_qtyUsg = map_orderId_orderItemId_qtyUsg.get(order_id);
            
            Decimal temp_penggunaan = 0;
            if(mapTemp_orderItemId_qtyUsg != null){
                temp_penggunaan = mapTemp_orderItemId_qtyUsg.get(product_id);
                if(temp_penggunaan == null){temp_penggunaan = 0;}
            }
            
            oiw_rec.wOrderId = order_id;
       		oiw_rec.wProductId = product_id;
           	oiw_rec.wProductName = map_productId_productName.get(product_id);
           	oiw_rec.wStartDate = sd.format('dd-MMM-yyyy');
            oiw_rec.wEndDate = ed.format('dd-MMM-yyyy');
           	oiw_rec.wRemark = map_orderId_orderRec.get(oiw_rec.wOrderId).FBO__c;
           	oiw_rec.wPembelian = temp_pembelian + temp_buffer;
           	oiw_rec.wPenggunaan = temp_penggunaan;
           	oiw_rec.wSaldo = oiw_rec.wPembelian - oiw_rec.wPenggunaan;
           	//oiw_list.add(oiw_rec);
            
            List<orderItem_wrapper> oiw_templist = new List<orderItem_wrapper>();
            
            /*if(map_prodName_oiwList.keySet().contains(oiw_rec.wProductName)){
                oiw_templist = map_prodName_oiwList.get(oiw_rec.wProductName);
                map_prodName_oiwList.remove(oiw_rec.wProductName);
                oiw_templist.add(oiw_rec);
                map_prodName_oiwList.put(oiw_rec.wProductName,oiw_templist);
            }else{
                oiw_templist.add(oiw_rec);
                map_prodName_oiwList.put(oiw_rec.wProductName,oiw_templist);
            }*/
            String combine_id = order_id + '-' + product_id; system.debug('*** combine_id 1 = ' + combine_id);
            if(map_prodName_oiwList.keySet().contains(oiw_rec.wProductName)){
                oiw_templist = map_prodName_oiwList.get(oiw_rec.wProductName);
                map_prodName_oiwList.remove(oiw_rec.wProductName);
                //oiw_templist.add(oiw_rec);
                if(oiw_rec.wSaldo == 0){
                    Date lastUsgDate = map_ordIdprdId_lastUsg.get(combine_id).Date__c;
                    if(lastUsgDate >= startDate_temp){oiw_templist.add(oiw_rec);}
                }else{
                    oiw_templist.add(oiw_rec);
                }
                map_prodName_oiwList.put(oiw_rec.wProductName,oiw_templist);
            }else{
                //oiw_templist.add(oiw_rec);
                if(oiw_rec.wSaldo == 0){
                    Date lastUsgDate = map_ordIdprdId_lastUsg.get(combine_id).Date__c;
                    if(lastUsgDate >= startDate_temp){oiw_templist.add(oiw_rec);}
                }else{
                    oiw_templist.add(oiw_rec);
                }
                map_prodName_oiwList.put(oiw_rec.wProductName,oiw_templist);
            }
            system.debug('*** map_prodName_oiwList = ' + map_prodName_oiwList);
            
            // -------------------------------------------------- Buffer List -------------------------------------------------- //
            
            String order_status = map_orderId_orderRec.get(order_id).Status;
            
            if(order_status == 'Completed' && oiw_rec.wSaldo < 0){
                system.debug('&&& Masuk if Order Completed dan Saldo minus !!!');
                orderItem_wrapper oiwForBuffer_rec = new orderItem_wrapper();
                oiwForBuffer_rec.wOrderId = order_id;
       			oiwForBuffer_rec.wProductId = product_id;
                oiwForBuffer_rec.wSaldo = oiw_rec.wSaldo * -1;
                oiwForBuffer_list.add(oiwForBuffer_rec);
            }
            
        }
        
        system.debug('*** oiwForBuffer_list = ' + oiwForBuffer_list.size() + ' | ' + oiwForBuffer_list);
        
    }
    
    public void insertBuffer(){
        
        system.debug('*** Masuk "insertBuffer" oiwForBuffer_list = ' + oiwForBuffer_list.size() + ' | ' + oiwForBuffer_list);
        
        List<OrderItem> oiBuffer_list = new List<OrderItem>();		
        
        for(orderItem_wrapper oiw : oiwForBuffer_list){
            
            List<OrderItem> oi_list = [SELECT Id, OrderItemNumber, Buffer__c FROM OrderItem 
                                       WHERE OrderId =: oiw.wOrderId 
                                       AND Product2Id =: oiw.wProductId 
                                       AND (Buffer__c = null OR Buffer__c = 0)
                                       ORDER BY CreatedDate ASC
                                      ];
            
            if(oi_list.size() > 0){
                system.debug('*** oi_list[0] = ' + oi_list[0]);
                system.debug('*** oi_list[0].Id = ' + oi_list[0].Id);
                system.debug('*** oi_list[0].OrderItemNumber = ' + oi_list[0].OrderItemNumber);
                system.debug('*** oi_list[0].Buffer__c = ' + oi_list[0].Buffer__c);
                oi_list[0].Buffer__c = oiw.wSaldo;
                oiBuffer_list.add(oi_list[0]);
            }
        }
        
        system.debug('*** oiBuffer_list = ' + oiBuffer_list.size() + ' | ' + oiBuffer_list);
        update oiBuffer_list;
        
        kkRec.Insert_Buffer_Timestamp__c = system.now();
        update kkRec;
        
    }
    
}