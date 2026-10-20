public with sharing class GenerateOrderCO_NB_Controller {
    ApexPages.StandardSetController setCon; 
    ApexPages.StandardController con;
 
    public String OrderID {get;set;}

    public List<Campaign_Order__c> coRec {get;set;}
    //public List<Order_Product_Non_Bulk__c> orderitemRec {get;set;}
    public List<Order_Non_Bulk__c> orderRec {get;set;}

    public GenerateOrderCO_NB_Controller (ApexPages.StandardController controller) {
 
        con = controller;


        OrderID= con.getRecord().id;
        
        coRec= [select id, Name,Channel__c,Impression_Click__c,Masking_Sender_Brand__c,Order_Product__c,OwnerId,Placement__c,Profiling_Lokasi__c,SMS_Per_Day_Location__c,WORDING_PICTURE_VIDEO__c,Start_Campaign__c,End_Campaign__c,of_Broadcast__c,Gender__c,Umur__c,ARPU__c,Religion__c
                              from Campaign_Order__c where Order_Non_Bulk__c =:OrderID];
                              
        //orderitemRec= [select id, Telephone__c,Advertiser_Name__c,Brand_Product__c from OrderItem where OrderId=:OrderID];
        orderRec= [select id,Account__r.Name,Agency__r.Name,Agency__r.Legal_Name__c,brand__r.Name,Email__c,Whitelist_and_UAT__c,Whitelist_and_UAT_Media_Seller__c,Status_Approval__c,Address__c,Telephone__c,Fax__c,Media_Seller_Manager__c,Media_Seller_Manager_Title__c,Agency__r.Parent.Name from Order_Non_Bulk__c where id=:OrderID];
        
        String myGeneratedFileName = orderRec[0].Agency__r.Name+'_'+'CO.pdf';
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename='+myGeneratedFilename); 
                              
    }
    
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}
    
}