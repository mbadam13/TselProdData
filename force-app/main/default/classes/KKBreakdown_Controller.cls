public class KKBreakdown_Controller {
	
    public Kertas_Kerja__c kkRec {get; set;}
    public String productName {get; set;}
    public String orderNo {get; set;}
    public List<breakdown_wrapper> bwList {get; set;}
    public List<summary_wrapper> swList {get; set;}
    
    public Boolean st_display {get; set;}
    public Boolean bt_display {get; set;}
    
    public string str_bufferTimestamp {get; set;}
    
    public class summary_wrapper{
       	public String wOrderNumber {get;set;}
       	public String wRemark {get;set;}
       	public String wStartDate {get;set;}
       	public String wEndDate {get;set;}
       	public Decimal wPembelian {get;set;}
       	public Decimal wPenggunaan {get;set;}
       	public Decimal wSaldo {get;set;}        
	}
    
    public class breakdown_wrapper{
       	public String wOrderNumber {get;set;}
       	public String wOrderItemId {get;set;}
       	public String wRemark {get;set;}
       	public String wDate {get;set;}
       	public String wType {get;set;}
       	public Decimal wQty {get;set;}        
	}
    
    public KKBreakdown_Controller(ApexPages.StandardController controller){
        String kk_id = apexpages.currentpage().getparameters().get('id'); system.debug('*** kk_id = ' + kk_id);
        
        kkRec = [SELECT Id, Name, Month__c, Year__c, Type__c, Insert_Buffer_Timestamp__c FROM Kertas_Kerja__c WHERE Id =: kk_id];
        system.debug('*** kkRec = ' + kkRec);
        
        st_display = false;
        bt_display = false;
        
        if(kkRec.Insert_Buffer_Timestamp__c != null)
        	{str_bufferTimestamp = kkRec.Insert_Buffer_Timestamp__c.format('yyyy/MM/dd hh:mm:ss');}
        
    }
    
    public void getKKBreakdownRecs(){
        
        st_display = false;
        bt_display = false;
        
        Boolean doSearch = false;
        
        if(orderNo == '' || productName == ''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please fill Product & Order No.'));
        }else{
            doSearch = true;
        }
        
        if(doSearch == true){        
        
        // -------------------------------------------------- Get Period (Month & Year) -------------------------------------------------- //
        
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
        
        List<Order> orderList = [SELECT Id, Name, OrderNumber, FBO__c, EffectiveDate, EndDate 
                                 FROM Order
                                 WHERE EffectiveDate <=: endDate_temp 
                                 AND EndDate >=: startDate_temp 
                                 AND (Name =: orderNo OR OrderNumber =: orderNo OR FBO__c =: orderNo) 
                                 AND (
                                     Order_Completed_Date__c = null 
                                     OR (Order_Completed_Date__c != null
                                        AND Order_Completed_Date__c >=: startDate_temp))
                                ];
        system.debug('*** orderList = ' + orderList.size() + ' | ' + orderList);
        
        if(orderList.size() > 0){
            
            st_display = true;
            bt_display = true;
            
            // -------------------------------------------------- Get Product Info -------------------------------------------------- //
            
            Id productId = null;
            
            List<Product2> productList = [SELECT Id, Name FROM Product2 WHERE Name =: productName];
            if(productList.size() > 0)
                {productId = productList[0].Id;}
            
            system.debug('***- productName = ' + productName);
            system.debug('***- orderNo = ' + orderNo);
            
            bwList = new List<breakdown_wrapper>();
            
            List<OrderItem> oiList = [SELECT Id, OrderItemNumber, Quantity, Buffer__c, CreatedDate, Order.OrderNumber 
                                      FROM OrderItem 
                                      WHERE OrderId =: orderList[0].Id  
                                      AND Product2.Name =: productName
                                     ];
            system.debug('*** oiList = ' + oiList.size() + ' | ' + oiList);
            
            if(oiList.size() > 0 ){
            
                for (OrderItem oi : oiList){
                    breakdown_wrapper bw_oi = new breakdown_wrapper();
                    bw_oi.wOrderNumber = oi.Order.OrderNumber;
                    bw_oi.wOrderItemId = oi.Id;
                    bw_oi.wRemark = oi.OrderItemNumber;
                    bw_oi.wDate = oi.CreatedDate.format('dd MMM yyyy');
                    bw_oi.wType = 'Incoming (+)';
                    bw_oi.wQty = oi.Quantity;
                    bwList.add(bw_oi);
                    system.debug('*** bw_oi = ' + bw_oi);
                    system.debug('*** oi.Buffer__c = ' + oi.Buffer__c);
                    if(oi.Buffer__c != null && oi.Buffer__c != 0){
                        breakdown_wrapper bw_oi_buffer = new breakdown_wrapper();
                        bw_oi_buffer.wOrderItemId = oi.Id;
                        bw_oi_buffer.wRemark = oi.OrderItemNumber + ' - Buffer';
                        bw_oi_buffer.wDate = oi.CreatedDate.format('dd MMM yyyy');
                        bw_oi_buffer.wType = 'Incoming (+)';
                        bw_oi_buffer.wQty = oi.Buffer__c;
                        bwList.add(bw_oi_buffer);
                        system.debug('*** bw_oi_buffer = ' + bw_oi_buffer);
                    }
                }
                system.debug('*** bwList (+) = ' + bwList.size() + ' | ' + bwList);
                
                List<Usage__c> usageList = [SELECT Id, Name, Date__c, Amount__c, Bucket_Detail__c, Bucket_Detail__r.OrderId, Bucket_Detail__r.Order.OrderNumber  
                                            FROM Usage__c 
                                            WHERE Bucket_Detail__r.OrderId =: orderList[0].Id 
                                            AND Bucket_Detail__r.Product2.Name =: productName 
                                            AND Date__c <=: endDate_temp
                                           ];
                system.debug('*** usageList = ' + usageList.size() + ' | ' + usageList);
                
                for (Usage__c usg : usageList){
                    breakdown_wrapper bw_usg = new breakdown_wrapper();
                    bw_usg.wOrderNumber = usg.Bucket_Detail__r.Order.OrderNumber;
                    bw_usg.wOrderItemId = usg.Bucket_Detail__r.OrderId;
                    bw_usg.wRemark = usg.Name;
                    bw_usg.wDate = ((Datetime)usg.Date__c).format('dd MMM yyyy');
                    bw_usg.wType = 'Outgoing (-)';
                    bw_usg.wQty = usg.Amount__c;
                    bwList.add(bw_usg);
                }
                
                Decimal pembelian_total = 0;
                Decimal penggunaan_total = 0;
                
                for(breakdown_wrapper bwRec : bwList){
                    if(bwRec.wType == 'Incoming (+)'){
                        pembelian_total = pembelian_total + bwRec.wQty;
                    }else if(bwRec.wType == 'Outgoing (-)'){
                        penggunaan_total = penggunaan_total + bwRec.wQty;
                    }
                }
                
                swList = new List<summary_wrapper>();
                
                summary_wrapper sw = new summary_wrapper();
                sw.wOrderNumber = orderList[0].OrderNumber;
                sw.wRemark = orderList[0].FBO__c;
                sw.wStartDate = ((Datetime)orderList[0].EffectiveDate).format('dd MMM yyyy');
                sw.wEndDate = ((Datetime)orderList[0].EndDate).format('dd MMM yyyy');
                sw.wPembelian = pembelian_total;
                sw.wPenggunaan = penggunaan_total;
                sw.wSaldo = sw.wPembelian - sw.wPenggunaan;
                swList.add(sw);
                
            }else{
                
                st_display = false;
        		bt_display = false;
            
            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Product "' + productName + '" is not found in Order No. ' + orderNo + '.'));
            }
                
        }else{
            
            st_display = false;
        	bt_display = false;
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Order No. ' + orderNo + ' is not found in this Kertas Kerja.'));
        }
            
        }
    }
    
    public PageReference insertBuffer_KKSum(){
        
        ApexPages.StandardController sc_kksum = new  ApexPages.StandardController(kkRec);
        KKSummary_Controller kkSum = new KKSummary_Controller(sc_kksum);
        kkSum.insertBuffer();
        
        PageReference pr_kkRec = new PageReference('/'+kkRec.Id);
        pr_kkRec.setRedirect(true);
        return pr_kkRec;
    }
}